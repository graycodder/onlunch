import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/corporate_lunch_order.dart';
import 'firebase_service.dart';

class CashfreeOrderResponse {
  final bool success;
  final String? orderId;
  final String? paymentSessionId;
  final String? errorMessage;

  CashfreeOrderResponse({
    required this.success,
    this.orderId,
    this.paymentSessionId,
    this.errorMessage,
  });
}

class CashfreePaymentService {
  static final CashfreePaymentService _instance = CashfreePaymentService._internal();
  factory CashfreePaymentService() => _instance;
  CashfreePaymentService._internal();

  /// Creates Cashfree order session via Cloud Functions proxy
  /// NOTE: Cloud Function expects Cashfree Standard API snake_case keys!
  Future<CashfreeOrderResponse> createPaymentSession({
    required String orderId,
    required double orderAmount,
    required String customerId,
    required String customerPhone,
    required String customerName,
    required String customerEmail,
  }) async {
    try {
      final cleanPhone = customerPhone.replaceAll(RegExp(r'\D'), '');
      final formattedPhone = cleanPhone.length > 10
          ? cleanPhone.substring(cleanPhone.length - 10)
          : cleanPhone;

      final body = {
        'order_id': orderId,
        'order_amount': orderAmount,
        'order_currency': 'INR',
        'customer_details': {
          'customer_id': customerId.isNotEmpty ? customerId : 'cust_$formattedPhone',
          'customer_phone': formattedPhone,
          'customer_name': customerName.isNotEmpty ? customerName : 'Customer',
          'customer_email': customerEmail.isNotEmpty ? customerEmail : '$formattedPhone@onelunch.in',
        },
      };

      debugPrint('Cashfree createPaymentSession request: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(AppConstants.createCashfreeOrderUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint('Cashfree createPaymentSession response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final sessionId = data['payment_session_id'] ?? data['paymentSessionId'];
        return CashfreeOrderResponse(
          success: true,
          orderId: orderId,
          paymentSessionId: sessionId,
        );
      } else {
        return CashfreeOrderResponse(
          success: false,
          errorMessage: 'Gateway Error (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Cashfree session creation error: $e');
      return CashfreeOrderResponse(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Initiates Cashfree Payment Gateway checkout via Flutter SDK
  Future<void> startCheckout({
    required String orderId,
    required String paymentSessionId,
    String environment = 'PRODUCTION',
    required Function(String orderId) onVerify,
    required Function(String error) onError,
  }) async {
    try {
      final cfService = CFPaymentGatewayService();

      cfService.setCallback(
        (String verifiedOrderId) {
          debugPrint('Cashfree callback verifyPayment for $verifiedOrderId');
          onVerify(verifiedOrderId);
        },
        (CFErrorResponse errorResponse, String failedOrderId) {
          debugPrint('Cashfree callback onError: ${errorResponse.getMessage()} code: ${errorResponse.getCode()} for $failedOrderId');
          onError(errorResponse.getMessage() ?? 'Payment was cancelled or failed');
        },
      );

      final env = environment.toUpperCase() == 'SANDBOX'
          ? CFEnvironment.SANDBOX
          : CFEnvironment.PRODUCTION;

      final session = CFSessionBuilder()
          .setEnvironment(env)
          .setOrderId(orderId)
          .setPaymentSessionId(paymentSessionId)
          .build();

      final theme = CFThemeBuilder()
          .setButtonBackgroundColor("#075B25")
          .setButtonTextColor("#FFFFFF")
          .setPrimaryTextColor("#075B25")
          .build();

      final payment = CFWebCheckoutPaymentBuilder()
          .setSession(session)
          .setTheme(theme)
          .build();

      cfService.doPayment(payment);
    } catch (e) {
      debugPrint('Cashfree startCheckout exception: $e');
      onError(e.toString());
    }
  }

  /// Verifies order payment status via Cloud Function
  Future<bool> verifyPayment(String orderId) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.verifyCashfreeOrderUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'order_id': orderId}),
      );

      debugPrint('Cashfree verifyPayment response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final status = data['order_status'] ?? data['status'];
        return status == 'PAID' || status == 'SUCCESS';
      }
      return false;
    } catch (e) {
      debugPrint('Payment verification error: $e');
      return false;
    }
  }

  /// Records payment success audit entry in corporateLunchPayments
  Future<void> recordPaymentSuccess({
    required CorporateLunchOrder order,
    required String referenceId,
  }) async {
    final now = DateTime.now().toIso8601String();
    final paymentRecord = {
      'paymentId': order.paymentId,
      'orderId': order.orderId,
      'customerId': order.customerId,
      'customerMobile': order.customerMobile,
      'amount': order.totalAmount,
      'paymentMethod': 'CASHFREE',
      'paymentStatus': 'PAID',
      'referenceId': referenceId,
      'createdAt': now,
      'updatedAt': now,
    };

    await FirebaseService().paymentsRef.child(order.paymentId).set(paymentRecord);

    // Update order status in corporateLunchOrders
    await FirebaseService().orderRef(order.orderId).update({
      'paymentStatus': 'PAID',
      'orderStatus': 'CONFIRMED',
      'updatedAt': now,
    });
  }
}
