import 'package:flutter/foundation.dart';
import 'firebase_service.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  /// Registers push subscription in RTDB under pushSubscriptions/{subId}
  Future<void> registerSubscription({
    required String phone,
    required String customerName,
    String? token,
  }) async {
    final subId = token ?? 'sub_${phone}_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now().toIso8601String();

    try {
      await FirebaseService().pushSubscriptionsRef.child(subId).set({
        'subscriptionId': subId,
        'customerMobile': phone,
        'customerName': customerName,
        'platform': defaultTargetPlatform.name,
        'active': true,
        'updatedAt': now,
      });
      debugPrint('Push subscription registered for $phone');
    } catch (e) {
      debugPrint('Push subscription registration error: $e');
    }
  }
}

