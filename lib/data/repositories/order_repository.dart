import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../../firebase/firebase_service.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../models/meal_customization_model.dart';

class OrderRepository {
  final FirebaseService _fb = FirebaseService();

  /// Stream of orders for a specific user
  Stream<List<OrderModel>> getUserOrdersStream(String uid) {
    return _fb.ordersRef.orderByChild('userId').equalTo(uid).onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];
      final List<OrderModel> orders = [];
      if (data is Map) {
        data.forEach((key, val) {
          if (val is Map) {
            orders.add(OrderModel.fromMap(val, key.toString()));
          }
        });
      }
      // Sort newest first
      orders.sort((a, b) {
        final tA = a.timestamp is num ? (a.timestamp as num).toInt() : 0;
        final tB = b.timestamp is num ? (b.timestamp as num).toInt() : 0;
        return tB.compareTo(tA);
      });
      return orders;
    });
  }

  /// Stream of ALL orders for Admin dashboard and Kitchen reports
  Stream<List<OrderModel>> getAllOrdersStream() {
    return _fb.ordersRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];
      final List<OrderModel> orders = [];
      if (data is Map) {
        data.forEach((key, val) {
          if (val is Map) {
            orders.add(OrderModel.fromMap(val, key.toString()));
          }
        });
      }
      orders.sort((a, b) {
        final tA = a.timestamp is num ? (a.timestamp as num).toInt() : 0;
        final tB = b.timestamp is num ? (b.timestamp as num).toInt() : 0;
        return tB.compareTo(tA);
      });
      return orders;
    });
  }

  /// Stream single order by ID for live tracking
  Stream<OrderModel?> getOrderByIdStream(String orderId) {
    return _fb.orderRef(orderId).onValue.map((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        return OrderModel.fromMap(data, orderId);
      }
      return null;
    });
  }

  /// Generate human readable order ID (e.g. OL1001)
  String generateOrderId() {
    final randomPart = 1000 + Random().nextInt(9000);
    return 'OL$randomPart';
  }

  /// Create and place new Corporate Order with customized meals & collection point
  Future<OrderModel> placeCorporateOrder({
    required String userId,
    required String customerName,
    required String mobile,
    required String companyId,
    required String companyName,
    required String collectionPointId,
    required String collectionPointName,
    required String deliveryAddress,
    required String deliveryTime,
    required String deliveryDate,
    required List<MealCustomizationModel> customizedMeals,
    required double baseMealsTotal,
    required double addonsTotal,
    double discount = 0.0,
    required double totalAmount,
    String paymentMethod = 'Prepaid Online',
    String paymentRef = '',
    String paymentStatus = 'PAID',
  }) async {
    final orderId = generateOrderId();
    final now = DateTime.now();
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(now);

    final order = OrderModel(
      orderId: orderId,
      userId: userId,
      customerName: customerName.isNotEmpty ? customerName : 'OneLunch Customer',
      mobile: mobile,
      companyId: companyId,
      companyName: companyName,
      collectionPointId: collectionPointId,
      collectionPointName: collectionPointName,
      deliveryAddress: deliveryAddress,
      deliveryTime: deliveryTime,
      deliveryDate: deliveryDate,
      customizedMeals: customizedMeals,
      items: const [],
      baseMealsTotal: baseMealsTotal,
      addonsTotal: addonsTotal,
      discount: discount,
      totalAmount: totalAmount,
      orderStatus: 'Pending',
      paymentStatus: paymentStatus,
      paymentMethod: paymentMethod,
      paymentRef: paymentRef.isNotEmpty ? paymentRef : 'TXN_${DateTime.now().millisecondsSinceEpoch}',
      deliveryStatus: 'Pending',
      createdAt: formattedDate,
      timestamp: ServerValue.timestamp,
    );

    await _fb.orderRef(orderId).set(order.toMap());
    return order;
  }

  /// Legacy placeOrder for backwards compatibility
  Future<OrderModel> placeOrder({
    required String userId,
    required String customerName,
    required String mobile,
    required List<CartItemModel> items,
    required double totalAmount,
    String address = '',
    String paymentMethod = 'Cash on Delivery',
  }) async {
    final orderId = generateOrderId();
    final now = DateTime.now();
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(now);

    final order = OrderModel(
      orderId: orderId,
      userId: userId,
      customerName: customerName.isNotEmpty ? customerName : 'OneLunch Customer',
      mobile: mobile,
      items: items,
      totalAmount: totalAmount,
      orderStatus: 'Pending',
      paymentStatus: paymentMethod == 'Cash on Delivery' ? 'PENDING_COD' : 'PAID',
      paymentMethod: paymentMethod,
      deliveryAddress: address,
      createdAt: formattedDate,
      timestamp: ServerValue.timestamp,
    );

    await _fb.orderRef(orderId).set(order.toMap());
    return order;
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _fb.orderRef(orderId).update({'orderStatus': status});
  }

  Future<void> updateDeliveryStatus(
    String orderId,
    String deliveryStatus, {
    String driverId = '',
    String driverName = '',
  }) async {
    final Map<String, dynamic> updates = {'deliveryStatus': deliveryStatus};
    if (driverId.isNotEmpty) updates['assignedDriverId'] = driverId;
    if (driverName.isNotEmpty) updates['assignedDriverName'] = driverName;
    if (deliveryStatus.toLowerCase() == 'delivered') {
      updates['orderStatus'] = 'Delivered';
    }
    await _fb.orderRef(orderId).update(updates);
  }
}
