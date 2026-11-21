import 'meal_option.dart';

class CorporateLunchOrder {
  final String orderId; // e.g. "RL-20261114-1234"
  final String customerId; // "user_{phone}"
  final String customerName;
  final String customerMobile;
  final String customerEmail;
  final String corporateId;
  final String corporateName;
  final String collectionPointId;
  final String collectionPointName;
  final String lunchDate; // "YYYY-MM-DD"
  final String deliveryDate; // "YYYY-MM-DD"
  final String bookingType; // "daily" | "weekly"
  final int paidQuantity;
  final int freeQuantity;
  final int totalQuantity;
  final double unitPrice;
  final double discount;
  final double totalAmount;
  final String paymentId; // "PAY-{orderId}"
  final String paymentMethod; // "CASHFREE" | "COD"
  final String paymentMode;
  final String paymentStatus; // "PENDING" | "PAID" | "FAILED" | "REFUNDED"
  final String orderStatus; // "PENDING_PAYMENT" | "CONFIRMED" | "CANCELLED"
  final String deliveryStatus; // "UNASSIGNED" | "ASSIGNED" | "OUT_FOR_DELIVERY" | "ARRIVED" | "DELIVERED"
  final MealSelectionSnapshot meal;
  final String createdAt;
  final String updatedAt;

  CorporateLunchOrder({
    required this.orderId,
    required this.customerId,
    required this.customerName,
    required this.customerMobile,
    required this.customerEmail,
    required this.corporateId,
    required this.corporateName,
    required this.collectionPointId,
    required this.collectionPointName,
    required this.lunchDate,
    required this.deliveryDate,
    this.bookingType = 'daily',
    required this.paidQuantity,
    required this.freeQuantity,
    required this.totalQuantity,
    required this.unitPrice,
    required this.discount,
    required this.totalAmount,
    required this.paymentId,
    required this.paymentMethod,
    required this.paymentMode,
    required this.paymentStatus,
    required this.orderStatus,
    this.deliveryStatus = 'UNASSIGNED',
    required this.meal,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'orderId': orderId,
    'customerId': customerId,
    'customerName': customerName,
    'customerMobile': customerMobile,
    'customerEmail': customerEmail,
    'corporateId': corporateId,
    'corporateName': corporateName,
    'collectionPointId': collectionPointId,
    'collectionPointName': collectionPointName,
    'lunchDate': lunchDate,
    'deliveryDate': deliveryDate,
    'bookingType': bookingType,
    'paidQuantity': paidQuantity,
    'freeQuantity': freeQuantity,
    'totalQuantity': totalQuantity,
    'unitPrice': unitPrice,
    'discount': discount,
    'totalAmount': totalAmount,
    'paymentId': paymentId,
    'paymentMethod': paymentMethod,
    'paymentMode': paymentMode,
    'paymentStatus': paymentStatus,
    'orderStatus': orderStatus,
    'deliveryStatus': deliveryStatus,
    'meal': meal.toMap(),
    'createdBy': {
      'type': 'CUSTOMER',
      'userId': customerId,
    },
    'auditHistory': [
      {
        'action': 'ORDER_CREATED',
        'newValue': 'Customer placed $paymentMethod order for $totalQuantity meals via onelunch App',
        'changedBy': customerName,
        'changedAt': createdAt,
      }
    ],
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory CorporateLunchOrder.fromMap(String id, Map<dynamic, dynamic> map) {
    return CorporateLunchOrder(
      orderId: id,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerMobile: map['customerMobile'] ?? '',
      customerEmail: map['customerEmail'] ?? '',
      corporateId: map['corporateId'] ?? '',
      corporateName: map['corporateName'] ?? '',
      collectionPointId: map['collectionPointId'] ?? '',
      collectionPointName: map['collectionPointName'] ?? '',
      lunchDate: map['lunchDate'] ?? '',
      deliveryDate: map['deliveryDate'] ?? map['lunchDate'] ?? '',
      bookingType: map['bookingType'] ?? 'daily',
      paidQuantity: (map['paidQuantity'] as num?)?.toInt() ?? 1,
      freeQuantity: (map['freeQuantity'] as num?)?.toInt() ?? 0,
      totalQuantity: (map['totalQuantity'] as num?)?.toInt() ?? 1,
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 80.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 80.0,
      paymentId: map['paymentId'] ?? 'PAY-$id',
      paymentMethod: map['paymentMethod'] ?? 'CASHFREE',
      paymentMode: map['paymentMode'] ?? map['paymentMethod'] ?? 'CASHFREE',
      paymentStatus: map['paymentStatus'] ?? 'PENDING',
      orderStatus: map['orderStatus'] ?? 'PENDING_PAYMENT',
      deliveryStatus: map['deliveryStatus'] ?? 'UNASSIGNED',
      meal: MealSelectionSnapshot.fromMap(map['meal'] as Map?),
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
    );
  }
}

