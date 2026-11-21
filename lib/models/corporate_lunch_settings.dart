class CorporateLunchSettings {
  final bool corporateLunchEnabled;
  final double corporateLunchPrice;
  final double? vegLunchPrice;
  final double? nonVegLunchPrice;
  final String lunchOrderCutoffTime; // "20:00" (IST)
  final String businessTimezone; // "Asia/Kolkata"
  final bool promotionEnabled;
  final int promotionBuyQuantity; // e.g. 20
  final int promotionFreeQuantity; // e.g. 1
  final String cashfreeEnvironment; // "SANDBOX" | "PRODUCTION"
  final bool enableCashfreePayment;
  final bool enableCodPayment;
  final bool introductoryOfferEnabled;
  final double? introductoryOfferPrice; // e.g. 80.0
  final double? introductoryMaxDiscount;
  final String? todaySpecialNonVegItem;

  CorporateLunchSettings({
    this.corporateLunchEnabled = true,
    this.corporateLunchPrice = 80.0,
    this.vegLunchPrice = 80.0,
    this.nonVegLunchPrice = 80.0,
    this.lunchOrderCutoffTime = "20:00",
    this.businessTimezone = "Asia/Kolkata",
    this.promotionEnabled = true,
    this.promotionBuyQuantity = 20,
    this.promotionFreeQuantity = 1,
    this.cashfreeEnvironment = "PRODUCTION",
    this.enableCashfreePayment = true,
    this.enableCodPayment = true,
    this.introductoryOfferEnabled = true,
    this.introductoryOfferPrice = 80.0,
    this.introductoryMaxDiscount = 0.0,
    this.todaySpecialNonVegItem,
  });

  factory CorporateLunchSettings.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return CorporateLunchSettings();
    return CorporateLunchSettings(
      corporateLunchEnabled: map['corporateLunchEnabled'] ?? true,
      corporateLunchPrice: (map['corporateLunchPrice'] as num?)?.toDouble() ?? 80.0,
      vegLunchPrice: (map['vegLunchPrice'] as num?)?.toDouble() ?? 80.0,
      nonVegLunchPrice: (map['nonVegLunchPrice'] as num?)?.toDouble() ?? 80.0,
      lunchOrderCutoffTime: map['lunchOrderCutoffTime'] ?? "20:00",
      businessTimezone: map['businessTimezone'] ?? "Asia/Kolkata",
      promotionEnabled: map['promotionEnabled'] ?? true,
      promotionBuyQuantity: (map['promotionBuyQuantity'] as num?)?.toInt() ?? 20,
      promotionFreeQuantity: (map['promotionFreeQuantity'] as num?)?.toInt() ?? 1,
      cashfreeEnvironment: map['cashfreeEnvironment'] ?? "PRODUCTION",
      enableCashfreePayment: map['enableCashfreePayment'] ?? true,
      enableCodPayment: map['enableCodPayment'] ?? true,
      introductoryOfferEnabled: map['introductoryOfferEnabled'] ?? true,
      introductoryOfferPrice: (map['introductoryOfferPrice'] as num?)?.toDouble() ?? 80.0,
      introductoryMaxDiscount: (map['introductoryMaxDiscount'] as num?)?.toDouble() ?? 0.0,
      todaySpecialNonVegItem: map['todaySpecialNonVegItem'],
    );
  }

  Map<String, dynamic> toMap() => {
    'corporateLunchEnabled': corporateLunchEnabled,
    'corporateLunchPrice': corporateLunchPrice,
    'vegLunchPrice': vegLunchPrice,
    'nonVegLunchPrice': nonVegLunchPrice,
    'lunchOrderCutoffTime': lunchOrderCutoffTime,
    'businessTimezone': businessTimezone,
    'promotionEnabled': promotionEnabled,
    'promotionBuyQuantity': promotionBuyQuantity,
    'promotionFreeQuantity': promotionFreeQuantity,
    'cashfreeEnvironment': cashfreeEnvironment,
    'enableCashfreePayment': enableCashfreePayment,
    'enableCodPayment': enableCodPayment,
    'introductoryOfferEnabled': introductoryOfferEnabled,
    'introductoryOfferPrice': introductoryOfferPrice,
    'introductoryMaxDiscount': introductoryMaxDiscount,
    'todaySpecialNonVegItem': todaySpecialNonVegItem,
  };
}

