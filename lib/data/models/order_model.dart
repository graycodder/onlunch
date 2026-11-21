import 'cart_item_model.dart';
import 'meal_customization_model.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final String customerName;
  final String mobile;
  final String companyId;
  final String companyName;
  final String collectionPointId;
  final String collectionPointName;
  final String deliveryAddress;
  final String deliveryTime;
  final String deliveryDate; // e.g. "Tomorrow, 08 Nov 2026"
  final List<MealCustomizationModel> customizedMeals;
  final List<CartItemModel> items;
  final double baseMealsTotal;
  final double addonsTotal;
  final double discount;
  final double totalAmount;
  final String orderStatus; // Pending, Accepted, Preparing, Ready, Completed, Cancelled
  final String paymentStatus; // PAID, PENDING_COD
  final String paymentMethod; // Prepaid Online, Cash on Delivery
  final String paymentRef;
  final String deliveryStatus; // Pending, Assigned, Out for Delivery, Delivered
  final String assignedDriverId;
  final String assignedDriverName;
  final String createdAt;
  final dynamic timestamp;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.customerName,
    required this.mobile,
    this.companyId = '',
    this.companyName = '',
    this.collectionPointId = '',
    this.collectionPointName = '',
    this.deliveryAddress = '',
    this.deliveryTime = '12:30 PM',
    this.deliveryDate = '',
    this.customizedMeals = const [],
    this.items = const [],
    this.baseMealsTotal = 0.0,
    this.addonsTotal = 0.0,
    this.discount = 0.0,
    required this.totalAmount,
    this.orderStatus = 'Pending',
    this.paymentStatus = 'PAID',
    this.paymentMethod = 'Prepaid Online',
    this.paymentRef = '',
    this.deliveryStatus = 'Pending',
    this.assignedDriverId = '',
    this.assignedDriverName = '',
    required this.createdAt,
    this.timestamp,
  });

  bool get isPending =>
      orderStatus.toLowerCase() == 'pending' ||
      orderStatus.toLowerCase() == 'accepted' ||
      orderStatus.toLowerCase() == 'preparing';
  bool get isCompleted =>
      orderStatus.toLowerCase() == 'completed' ||
      orderStatus.toLowerCase() == 'delivered';

  int get totalBoxesCount {
    if (customizedMeals.isNotEmpty) {
      return customizedMeals.fold(0, (sum, m) => sum + m.mealQuantity);
    }
    return items.fold(0, (sum, i) => sum + i.quantity);
  }

  factory OrderModel.fromMap(Map<dynamic, dynamic> map, String orderId) {
    // 1. Parse customized meals
    final List<MealCustomizationModel> parsedMeals = [];
    final rawMeals = map['customizedMeals'];
    if (rawMeals is List) {
      for (var i = 0; i < rawMeals.length; i++) {
        if (rawMeals[i] is Map) {
          parsedMeals.add(MealCustomizationModel.fromMap(rawMeals[i] as Map, 'cfg_$i'));
        }
      }
    } else if (rawMeals is Map) {
      rawMeals.forEach((key, val) {
        if (val is Map) parsedMeals.add(MealCustomizationModel.fromMap(val, key.toString()));
      });
    }

    // 2. Parse legacy items for backwards compatibility
    final List<CartItemModel> itemsList = [];
    final rawItems = map['items'];
    if (rawItems is List) {
      for (var i = 0; i < rawItems.length; i++) {
        if (rawItems[i] != null && rawItems[i] is Map) {
          itemsList.add(CartItemModel.fromMap(rawItems[i] as Map, 'item_$i'));
        }
      }
    } else if (rawItems is Map) {
      rawItems.forEach((key, val) {
        if (val is Map) itemsList.add(CartItemModel.fromMap(val, key.toString()));
      });
    }

    return OrderModel(
      orderId: orderId,
      userId: map['userId']?.toString() ?? '',
      customerName: map['customerName']?.toString() ?? 'Customer',
      mobile: map['mobile']?.toString() ?? '',
      companyId: map['companyId']?.toString() ?? '',
      companyName: map['companyName']?.toString() ?? '',
      collectionPointId: map['collectionPointId']?.toString() ?? '',
      collectionPointName: map['collectionPointName']?.toString() ?? '',
      deliveryAddress: map['deliveryAddress']?.toString() ?? map['address']?.toString() ?? '',
      deliveryTime: map['deliveryTime']?.toString() ?? '12:30 PM',
      deliveryDate: map['deliveryDate']?.toString() ?? '',
      customizedMeals: parsedMeals,
      items: itemsList,
      baseMealsTotal: (map['baseMealsTotal'] is num)
          ? (map['baseMealsTotal'] as num).toDouble()
          : double.tryParse(map['baseMealsTotal']?.toString() ?? '0') ?? 0.0,
      addonsTotal: (map['addonsTotal'] is num)
          ? (map['addonsTotal'] as num).toDouble()
          : double.tryParse(map['addonsTotal']?.toString() ?? '0') ?? 0.0,
      discount: (map['discount'] is num)
          ? (map['discount'] as num).toDouble()
          : double.tryParse(map['discount']?.toString() ?? '0') ?? 0.0,
      totalAmount: (map['totalAmount'] is num)
          ? (map['totalAmount'] as num).toDouble()
          : double.tryParse(map['totalAmount']?.toString() ?? '0') ?? 0.0,
      orderStatus: map['orderStatus']?.toString() ?? 'Pending',
      paymentStatus: map['paymentStatus']?.toString() ?? 'PAID',
      paymentMethod: map['paymentMethod']?.toString() ?? 'Prepaid Online',
      paymentRef: map['paymentRef']?.toString() ?? '',
      deliveryStatus: map['deliveryStatus']?.toString() ?? 'Pending',
      assignedDriverId: map['assignedDriverId']?.toString() ?? '',
      assignedDriverName: map['assignedDriverName']?.toString() ?? '',
      createdAt: map['createdAt']?.toString() ?? '',
      timestamp: map['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'customerName': customerName,
      'mobile': mobile,
      'companyId': companyId,
      'companyName': companyName,
      'collectionPointId': collectionPointId,
      'collectionPointName': collectionPointName,
      'deliveryAddress': deliveryAddress,
      'deliveryTime': deliveryTime,
      'deliveryDate': deliveryDate,
      'customizedMeals': customizedMeals.map((m) => m.toMap()).toList(),
      'items': items.map((i) => i.toMap()).toList(),
      'baseMealsTotal': baseMealsTotal,
      'addonsTotal': addonsTotal,
      'discount': discount,
      'totalAmount': totalAmount,
      'orderStatus': orderStatus,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'paymentRef': paymentRef,
      'deliveryStatus': deliveryStatus,
      'assignedDriverId': assignedDriverId,
      'assignedDriverName': assignedDriverName,
      'createdAt': createdAt,
      'timestamp': timestamp,
    };
  }
}
