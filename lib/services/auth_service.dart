import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseService().auth;
  static const String _prefKeyUser = 'onelunch_cached_user';

  // Validation: block dummy names
  static const List<String> _blockedNames = [
    'test',
    'dummy',
    'customer',
    'admin',
    'user',
    'none',
    'na',
    'unknown',
  ];

  static bool isValidCustomerName(String name) {
    final trimmed = name.trim().toLowerCase();
    if (trimmed.length < 2) return false;
    for (final blocked in _blockedNames) {
      if (trimmed == blocked || trimmed.startsWith('$blocked ') || trimmed.endsWith(' $blocked')) {
        return false;
      }
    }
    return true;
  }

  static String cleanIndianMobile(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.startsWith('91') && cleaned.length > 10) {
      cleaned = cleaned.substring(2);
    }
    return cleaned;
  }

  // Current session data
  String? currentVerificationId;
  int? resendToken;

  /// Map Firebase Auth error codes to user-friendly messages
  static String _mapAuthError(FirebaseAuthException e) {
    debugPrint('🔥 FirebaseAuth error: code=${e.code} msg=${e.message} details=${e.credential}');
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Invalid phone number. Please enter a valid 10-digit Indian mobile number.';
      case 'too-many-requests':
        return 'Too many OTP requests. Please wait a few minutes before trying again.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please contact support.';
      case 'captcha-check-failed':
        return 'reCAPTCHA verification failed. Please try again.';
      case 'missing-client-identifier':
        return 'App verification failed. SHA-1 fingerprint may not be registered in Firebase.';
      case 'app-not-authorized':
        return 'App not authorized for Firebase Phone Auth. Please contact support.';
      case 'web-context-already-presented':
        return 'Please dismiss any open dialogs and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'invalid-verification-code':
        return 'Invalid OTP code. Please check the SMS and try again.';
      case 'session-expired':
        return 'OTP session expired. Please request a new OTP.';
      default:
        return e.message ?? 'Phone verification failed (${e.code})';
    }
  }

  /// Trigger SMS OTP via Firebase Auth
  Future<void> sendOtp({
    required String phone,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    Function(PhoneAuthCredential credential)? onAutoVerify,
    int? forceResendToken,
  }) async {
    final clean = cleanIndianMobile(phone);
    final fullNumber = '+91$clean';
    debugPrint('📱 Sending OTP to $fullNumber');

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: fullNumber,
        timeout: const Duration(seconds: 60),
        forceResendingToken: forceResendToken ?? resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('✅ Auto-verification completed');
          if (onAutoVerify != null) {
            onAutoVerify(credential);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          final msg = _mapAuthError(e);
          debugPrint('❌ Verification failed: ${e.code} → $msg');
          onError(msg);
        },
        codeSent: (String verificationId, int? resend) {
          debugPrint('📨 OTP code sent. verificationId=$verificationId resendToken=$resend');
          currentVerificationId = verificationId;
          resendToken = resend;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('⏰ Auto-retrieval timeout. verificationId=$verificationId');
          currentVerificationId = verificationId;
        },
      );
    } catch (e) {
      debugPrint('💥 sendOtp exception: $e');
      onError(e.toString());
    }
  }

  /// Verify 6-digit OTP code and sign in
  Future<UserCredential> verifyOtpAndSignIn({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  /// Cache user profile locally
  Future<void> saveUserProfile({
    required String phone,
    required String name,
    String email = '',
    String defaultCorporateId = '',
    String defaultCorporateName = '',
    String defaultCollectionPointId = '',
    String defaultCollectionPointName = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanPhone = cleanIndianMobile(phone);
    final data = {
      'phone': cleanPhone,
      'name': name,
      'email': email,
      'corporateId': defaultCorporateId,
      'corporateName': defaultCorporateName,
      'collectionPointId': defaultCollectionPointId,
      'collectionPointName': defaultCollectionPointName,
      'savedAt': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_prefKeyUser, jsonEncode(data));

    // Also persist customer preferences to RTDB customerPreferences/{cleanPhone}/lunchOrdering
    try {
      if (defaultCorporateId.isNotEmpty && defaultCollectionPointId.isNotEmpty) {
        await FirebaseService().customerPrefRef(cleanPhone).update({
          'corporateId': defaultCorporateId,
          'corporateName': defaultCorporateName,
          'collectionPointId': defaultCollectionPointId,
          'collectionPointName': defaultCollectionPointName,
          'customerName': name,
          'customerMobile': cleanPhone,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Error updating RTDB customer preferences: $e');
    }
  }

  /// Load cached user profile
  Future<Map<String, dynamic>?> getCachedUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_prefKeyUser);
    if (str == null || str.isEmpty) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKeyUser);
  }

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => _auth.currentUser != null;
}

