import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/corporate_lunch_settings.dart';
import '../models/corporate_models.dart';
import '../models/meal_option.dart';
import '../models/corporate_lunch_order.dart';
import 'firebase_service.dart';

class TimezoneHelper {
  /// Always calculate based on Asia/Kolkata (UTC + 05:30)
  static DateTime getKolkataNow() {
    return DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
  }

  /// Checks if ordering for tomorrow is closed (past cutoff, e.g. "20:00")
  static bool isTomorrowOrderingClosed(String cutoffTimeStr) {
    final now = getKolkataNow();
    final parts = cutoffTimeStr.split(':');
    final cutoffHour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 20 : 20;
    final cutoffMin = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    final cutoffToday = DateTime(now.year, now.month, now.day, cutoffHour, cutoffMin);
    return now.isAfter(cutoffToday);
  }

  /// Returns the earliest eligible lunch date (YYYY-MM-DD)
  static String getDefaultLunchDate(String cutoffTimeStr) {
    final now = getKolkataNow();
    DateTime targetDate = now.add(const Duration(days: 1));
    if (isTomorrowOrderingClosed(cutoffTimeStr)) {
      targetDate = now.add(const Duration(days: 2));
    }
    return DateFormat('yyyy-MM-dd').format(targetDate);
  }
}

class PricingCalculationResult {
  final double unitPrice;
  final double addOnPrice;
  final double discountPerMeal;
  final int paidQuantity;
  final int freeQuantity;
  final int totalQuantity;
  final double totalAmount;

  PricingCalculationResult({
    required this.unitPrice,
    required this.addOnPrice,
    required this.discountPerMeal,
    required this.paidQuantity,
    required this.freeQuantity,
    required this.totalQuantity,
    required this.totalAmount,
  });
}

class LunchOrderingService {
  static final LunchOrderingService _instance = LunchOrderingService._internal();
  factory LunchOrderingService() => _instance;
  LunchOrderingService._internal();

  final FirebaseService _fb = FirebaseService();
  static const String _prefKeyLocalOrders = 'onelunch_offline_orders';

  // -------------------------------------------------------------
  // 1. REALTIME STREAMS
  // -------------------------------------------------------------

  /// Stream of CorporateLunchSettings from corporateLunchSettings
  Stream<CorporateLunchSettings> streamSettings() {
    return _fb.settingsRef.onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return CorporateLunchSettings();
      }
      final map = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      return CorporateLunchSettings.fromMap(map);
    });
  }

  /// Stream of Meal Options from lunchMealOptions
  Stream<List<LunchMealOption>> streamMealOptions() {
    return _fb.mealOptionsRef.onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return [];
      }
      final map = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      final List<LunchMealOption> list = [];
      map.forEach((key, val) {
        if (val is Map) {
          list.add(LunchMealOption.fromMap(key.toString(), val));
        }
      });
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return list;
    });
  }

  /// Stream of Corporates from corporates
  Stream<List<Corporate>> streamCorporates() {
    return _fb.corporatesRef.onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return [];
      }
      final map = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      final List<Corporate> list = [];
      map.forEach((key, val) {
        if (val is Map) {
          final c = Corporate.fromMap(key.toString(), val);
          if (c.status == 'ACTIVE') {
            list.add(c);
          }
        }
      });
      return list;
    });
  }

  /// Stream of Collection Points from collectionPoints
  Stream<List<CollectionPoint>> streamCollectionPoints({String? corporateId}) {
    return _fb.collectionPointsRef.onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return [];
      }
      final map = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      final List<CollectionPoint> list = [];
      map.forEach((key, val) {
        if (val is Map) {
          final cp = CollectionPoint.fromMap(key.toString(), val);
          if (cp.active && (corporateId == null || cp.corporateId == corporateId)) {
            list.add(cp);
          }
        }
      });
      return list;
    });
  }

  /// Stream of customer orders from corporateLunchOrders filtered by mobile
  Stream<List<CorporateLunchOrder>> streamCustomerOrders(String mobile) {
    final clean = mobile.replaceAll(RegExp(r'\D'), '');
    final phone = clean.startsWith('91') && clean.length > 10 ? clean.substring(2) : clean;

    return _fb.ordersRef
        .orderByChild('customerMobile')
        .equalTo(phone)
        .onValue
        .map((event) {
      final List<CorporateLunchOrder> orders = [];
      if (event.snapshot.exists && event.snapshot.value != null) {
        final map = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        map.forEach((key, val) {
          if (val is Map) {
            orders.add(CorporateLunchOrder.fromMap(key.toString(), val));
          }
        });
        orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
      return orders;
    });
  }

  // -------------------------------------------------------------
  // 2. PRICING & PROMOTION CALCULATION
  // -------------------------------------------------------------

  PricingCalculationResult calculatePricing({
    required CorporateLunchSettings settings,
    required String mealType, // "VEG" | "NON_VEG"
    required List<LunchMealOption> selectedAddons,
    required int paidQuantity,
    double? mealTypePriceOverride,
  }) {
    // 1. Base Unit Price
    double unitPrice = mealType == 'VEG'
        ? (settings.vegLunchPrice ?? settings.corporateLunchPrice)
        : (settings.nonVegLunchPrice ?? settings.corporateLunchPrice);

    if (mealTypePriceOverride != null && mealTypePriceOverride > 0) {
      unitPrice = mealTypePriceOverride;
    }

    // 2. Add-on Price
    double addOnPrice = 0.0;
    for (final addon in selectedAddons) {
      addOnPrice += addon.price;
    }

    // 3. Introductory Discount Engine
    double discountPerMeal = 0.0;
    if (settings.introductoryOfferEnabled && mealType == 'NON_VEG' && addOnPrice > 0) {
      final targetIntroPrice = settings.introductoryOfferPrice ?? 80.0;
      final fullMenuPrice = unitPrice + addOnPrice;
      final calcDiscount = max(0.0, fullMenuPrice - targetIntroPrice);
      final maxDisc = settings.introductoryMaxDiscount ?? 0.0;
      discountPerMeal = (maxDisc > 0) ? min(calcDiscount, maxDisc) : calcDiscount;
    }

    // 4. 20+1 Free Promotion
    int freeQuantity = 0;
    if (settings.promotionEnabled && settings.promotionBuyQuantity > 0) {
      freeQuantity = (paidQuantity ~/ settings.promotionBuyQuantity) * settings.promotionFreeQuantity;
    }
    final totalQuantity = paidQuantity + freeQuantity;

    // Total Amount = (paidQuantity * (unitPrice + addOnPrice)) - (paidQuantity * discountPerMeal)
    final grossTotal = paidQuantity * (unitPrice + addOnPrice);
    final totalDiscount = paidQuantity * discountPerMeal;
    final totalAmount = max(0.0, grossTotal - totalDiscount);

    return PricingCalculationResult(
      unitPrice: unitPrice,
      addOnPrice: addOnPrice,
      discountPerMeal: discountPerMeal,
      paidQuantity: paidQuantity,
      freeQuantity: freeQuantity,
      totalQuantity: totalQuantity,
      totalAmount: totalAmount,
    );
  }

  // -------------------------------------------------------------
  // 3. ORDER ID GENERATOR
  // -------------------------------------------------------------

  String generateOrderId(String lunchDate) {
    final datePart = lunchDate.replaceAll('-', '');
    final randomPart = (1000 + Random().nextInt(9000)).toString();
    return "RL-$datePart-$randomPart";
  }

  String generateWeeklyBookingId(String firstDate) {
    final datePart = firstDate.replaceAll('-', '');
    final randomPart = (1000 + Random().nextInt(9000)).toString();
    return "WB-$datePart-$randomPart";
  }

  // -------------------------------------------------------------
  // 4. PLACE DAILY ORDER
  // -------------------------------------------------------------

  Future<CorporateLunchOrder> createDailyOrder({
    required String customerId,
    required String customerName,
    required String customerMobile,
    required String customerEmail,
    required Corporate corporate,
    required CollectionPoint collectionPoint,
    required String lunchDate,
    required MealSelectionSnapshot meal,
    required PricingCalculationResult pricing,
    required String paymentMethod, // "CASHFREE" | "COD"
    required String paymentStatus, // "PENDING" | "PAID"
    required String orderStatus,   // "PENDING_PAYMENT" | "CONFIRMED"
  }) async {
    final now = DateTime.now().toIso8601String();
    final orderId = generateOrderId(lunchDate);
    final paymentId = "PAY-$orderId";

    final order = CorporateLunchOrder(
      orderId: orderId,
      customerId: customerId,
      customerName: customerName,
      customerMobile: customerMobile,
      customerEmail: customerEmail,
      corporateId: corporate.corporateId,
      corporateName: corporate.companyName,
      collectionPointId: collectionPoint.collectionPointId,
      collectionPointName: collectionPoint.name,
      lunchDate: lunchDate,
      deliveryDate: lunchDate,
      bookingType: 'daily',
      paidQuantity: pricing.paidQuantity,
      freeQuantity: pricing.freeQuantity,
      totalQuantity: pricing.totalQuantity,
      unitPrice: pricing.unitPrice + pricing.addOnPrice,
      discount: pricing.discountPerMeal * pricing.paidQuantity,
      totalAmount: pricing.totalAmount,
      paymentId: paymentId,
      paymentMethod: paymentMethod,
      paymentMode: paymentMethod,
      paymentStatus: paymentStatus,
      orderStatus: orderStatus,
      deliveryStatus: 'UNASSIGNED',
      meal: meal,
      createdAt: now,
      updatedAt: now,
    );

    // Write order to corporateLunchOrders/{orderId}
    await _fb.orderRef(orderId).set(order.toMap());

    // Audit log
    try {
      await _fb.auditLogsRef.push().set({
        'action': 'ORDER_CREATED',
        'orderId': orderId,
        'customerMobile': customerMobile,
        'totalAmount': pricing.totalAmount,
        'paymentMethod': paymentMethod,
        'timestamp': now,
      });
    } catch (_) {}

    // If order is confirmed or COD, synchronize with corporateLunchDeliveries
    if (orderStatus == 'CONFIRMED' || paymentMethod == 'COD') {
      await updateAggregatedDelivery(order, collectionPoint);
    }

    // Cache locally as offline fallback
    await _cacheOrderLocally(order);

    return order;
  }

  // -------------------------------------------------------------
  // 5. AGGREGATED DELIVERY SYNCHRONIZATION
  // -------------------------------------------------------------

  Future<void> updateAggregatedDelivery(CorporateLunchOrder order, CollectionPoint cp) async {
    final deliveryId = "DEL-${order.lunchDate.replaceAll('-', '')}-${order.collectionPointId}";
    final delRef = _fb.deliveryRef(deliveryId);

    try {
      final snap = await delRef.get();
      final now = DateTime.now().toIso8601String();

      if (snap.exists && snap.value != null) {
        final data = Map<String, dynamic>.from(snap.value as Map);
        List<dynamic> trackedIds = List<dynamic>.from(data['trackedOrderIds'] ?? []);
        if (trackedIds.contains(order.orderId)) return; // Prevent double-counting!

        trackedIds.add(order.orderId);
        await delRef.update({
          'totalOrders': (data['totalOrders'] ?? 0) + 1,
          'totalPaidMeals': (data['totalPaidMeals'] ?? 0) + order.paidQuantity,
          'totalFreeMeals': (data['totalFreeMeals'] ?? 0) + order.freeQuantity,
          'totalMeals': (data['totalMeals'] ?? 0) + order.totalQuantity,
          'updatedAt': now,
          'trackedOrderIds': trackedIds,
        });
      } else {
        await delRef.set({
          'deliveryId': deliveryId,
          'lunchDate': order.lunchDate,
          'corporateId': order.corporateId,
          'corporateName': order.corporateName,
          'collectionPointId': order.collectionPointId,
          'collectionPointName': order.collectionPointName,
          'contactPerson': cp.name,
          'contactMobile': order.customerMobile,
          'address': cp.address,
          'deliveryTime': cp.deliveryTime,
          'totalOrders': 1,
          'totalPaidMeals': order.paidQuantity,
          'totalFreeMeals': order.freeQuantity,
          'totalMeals': order.totalQuantity,
          'status': 'UNASSIGNED',
          'verificationPin': cp.verificationPin,
          'createdAt': now,
          'updatedAt': now,
          'trackedOrderIds': [order.orderId],
        });
      }
    } catch (e) {
      debugPrint('Error updating aggregated delivery: $e');
    }
  }

  // -------------------------------------------------------------
  // 6. SWITCH PENDING ORDER TO COD
  // -------------------------------------------------------------

  Future<void> switchOrderToCod(String orderId, CollectionPoint cp) async {
    final now = DateTime.now().toIso8601String();
    final snap = await _fb.orderRef(orderId).get();
    if (!snap.exists || snap.value == null) return;

    final data = Map<String, dynamic>.from(snap.value as Map);
    final order = CorporateLunchOrder.fromMap(orderId, data);

    await _fb.orderRef(orderId).update({
      'paymentMethod': 'COD',
      'paymentMode': 'COD',
      'paymentStatus': 'PENDING',
      'orderStatus': 'CONFIRMED',
      'updatedAt': now,
    });

    await updateAggregatedDelivery(order, cp);
  }

  // -------------------------------------------------------------
  // 7. CORPORATE ENQUIRY SUBMISSION
  // -------------------------------------------------------------

  Future<void> submitCorporateEnquiry({
    required String companyName,
    required String contactPerson,
    required String mobile,
    required String email,
    required String officeLocation,
    required int employeeCount,
    required int expectedDailyMeals,
    String message = '',
  }) async {
    final now = DateTime.now().toIso8601String();
    await _fb.enquiriesRef.push().set({
      'companyName': companyName,
      'contactPerson': contactPerson,
      'mobile': mobile,
      'email': email,
      'officeLocation': officeLocation,
      'employeeCount': employeeCount,
      'expectedDailyMeals': expectedDailyMeals,
      'message': message,
      'status': 'NEW',
      'createdAt': now,
    });
  }

  // -------------------------------------------------------------
  // 8. LOCAL OFFLINE CACHE
  // -------------------------------------------------------------

  Future<void> _cacheOrderLocally(CorporateLunchOrder order) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> list = prefs.getStringList(_prefKeyLocalOrders) ?? [];
      list.insert(0, jsonEncode(order.toMap()));
      if (list.length > 50) list = list.sublist(0, 50);
      await prefs.setStringList(_prefKeyLocalOrders, list);
    } catch (_) {}
  }

  Future<List<CorporateLunchOrder>> getOfflineOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_prefKeyLocalOrders) ?? [];
      return list.map((str) {
        final map = jsonDecode(str) as Map;
        return CorporateLunchOrder.fromMap(map['orderId'] ?? '', map);
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
