class WeeklyBooking {
  final String weeklyBookingId; // "WB-YYYYMMDD-XXXX"
  final String customerId;
  final String customerName;
  final String customerMobile;
  final String customerEmail;
  final String corporateId;
  final String corporateName;
  final String collectionPointId;
  final String collectionPointName;
  final List<String> bookingDates; // ["2026-11-16", "2026-11-17", ...]
  final List<String> childOrderIds; // ["RL-...", "RL-..."]
  final int totalDays;
  final int mealsPerDay;
  final int totalMeals;
  final double totalAmount;
  final String paymentId;
  final String paymentMethod;
  final String paymentStatus;
  final String status; // "CONFIRMED" | "CANCELLED"
  final String createdAt;
  final String updatedAt;

  WeeklyBooking({
    required this.weeklyBookingId,
    required this.customerId,
    required this.customerName,
    required this.customerMobile,
    required this.customerEmail,
    required this.corporateId,
    required this.corporateName,
    required this.collectionPointId,
    required this.collectionPointName,
    required this.bookingDates,
    required this.childOrderIds,
    required this.totalDays,
    required this.mealsPerDay,
    required this.totalMeals,
    required this.totalAmount,
    required this.paymentId,
    required this.paymentMethod,
    required this.paymentStatus,
    this.status = 'CONFIRMED',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'weeklyBookingId': weeklyBookingId,
    'customerId': customerId,
    'customerName': customerName,
    'customerMobile': customerMobile,
    'customerEmail': customerEmail,
    'corporateId': corporateId,
    'corporateName': corporateName,
    'collectionPointId': collectionPointId,
    'collectionPointName': collectionPointName,
    'bookingDates': bookingDates,
    'childOrderIds': childOrderIds,
    'totalDays': totalDays,
    'mealsPerDay': mealsPerDay,
    'totalMeals': totalMeals,
    'totalAmount': totalAmount,
    'paymentId': paymentId,
    'paymentMethod': paymentMethod,
    'paymentStatus': paymentStatus,
    'status': status,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory WeeklyBooking.fromMap(String id, Map<dynamic, dynamic> map) {
    return WeeklyBooking(
      weeklyBookingId: id,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerMobile: map['customerMobile'] ?? '',
      customerEmail: map['customerEmail'] ?? '',
      corporateId: map['corporateId'] ?? '',
      corporateName: map['corporateName'] ?? '',
      collectionPointId: map['collectionPointId'] ?? '',
      collectionPointName: map['collectionPointName'] ?? '',
      bookingDates: (map['bookingDates'] as List?)?.map((e) => e.toString()).toList() ?? [],
      childOrderIds: (map['childOrderIds'] as List?)?.map((e) => e.toString()).toList() ?? [],
      totalDays: (map['totalDays'] as num?)?.toInt() ?? 0,
      mealsPerDay: (map['mealsPerDay'] as num?)?.toInt() ?? 1,
      totalMeals: (map['totalMeals'] as num?)?.toInt() ?? 0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentId: map['paymentId'] ?? '',
      paymentMethod: map['paymentMethod'] ?? 'CASHFREE',
      paymentStatus: map['paymentStatus'] ?? 'PENDING',
      status: map['status'] ?? 'CONFIRMED',
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
    );
  }
}
