class SettingsModel {
  final bool lunchAvailability;
  final String orderCutoffTime;
  final String supportPhone;
  final double minimumOrderAmount;

  SettingsModel({
    this.lunchAvailability = true,
    this.orderCutoffTime = '11:30 AM',
    this.supportPhone = '+919995226139',
    this.minimumOrderAmount = 0.0,
  });

  factory SettingsModel.fromMap(Map<dynamic, dynamic> map) {
    return SettingsModel(
      lunchAvailability: map['lunchAvailability'] == null ? true : (map['lunchAvailability'] as bool),
      orderCutoffTime: map['orderCutoffTime']?.toString() ?? '11:30 AM',
      supportPhone: map['supportPhone']?.toString() ?? '+919995226139',
      minimumOrderAmount: (map['minimumOrderAmount'] is num)
          ? (map['minimumOrderAmount'] as num).toDouble()
          : double.tryParse(map['minimumOrderAmount']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lunchAvailability': lunchAvailability,
      'orderCutoffTime': orderCutoffTime,
      'supportPhone': supportPhone,
      'minimumOrderAmount': minimumOrderAmount,
    };
  }
}

