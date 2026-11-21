import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/push_notification_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _cachedProfile;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get cachedProfile => _cachedProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authService.isAuthenticated || _cachedProfile != null;

  String get customerName => _cachedProfile?['name'] ?? 'Customer';
  String get customerPhone => _cachedProfile?['phone'] ?? '';
  String get customerEmail => _cachedProfile?['email'] ?? '';
  String get defaultCorporateId => _cachedProfile?['corporateId'] ?? '';
  String get defaultCorporateName => _cachedProfile?['corporateName'] ?? '';
  String get defaultCollectionPointId => _cachedProfile?['collectionPointId'] ?? '';
  String get defaultCollectionPointName => _cachedProfile?['collectionPointName'] ?? '';

  AuthProvider() {
    loadCachedProfile();
  }

  Future<void> loadCachedProfile() async {
    _cachedProfile = await _authService.getCachedUserProfile();
    notifyListeners();
  }

  Future<void> sendOtp({
    required String phone,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await _authService.sendOtp(
      phone: phone,
      onCodeSent: (vId) {
        _isLoading = false;
        notifyListeners();
        onCodeSent(vId);
      },
      onError: (err) {
        _isLoading = false;
        _errorMessage = err;
        notifyListeners();
        onError(err);
      },
    );
  }

  Future<bool> verifyAndSaveProfile({
    required String verificationId,
    required String smsCode,
    required String name,
    required String phone,
    String email = '',
    String corporateId = '',
    String corporateName = '',
    String collectionPointId = '',
    String collectionPointName = '',
  }) async {
    if (!AuthService.isValidCustomerName(name)) {
      _errorMessage = 'Please enter a valid full name (test names are not permitted).';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.verifyOtpAndSignIn(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      await _authService.saveUserProfile(
        phone: phone,
        name: name,
        email: email,
        defaultCorporateId: corporateId,
        defaultCorporateName: corporateName,
        defaultCollectionPointId: collectionPointId,
        defaultCollectionPointName: collectionPointName,
      );

      await PushNotificationService().registerSubscription(
        phone: AuthService.cleanIndianMobile(phone),
        customerName: name,
      );

      await loadCachedProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> updateDeliveryLocation({
    required String corporateId,
    required String corporateName,
    required String collectionPointId,
    required String collectionPointName,
  }) async {
    if (_cachedProfile == null) return;
    await _authService.saveUserProfile(
      phone: customerPhone,
      name: customerName,
      email: customerEmail,
      defaultCorporateId: corporateId,
      defaultCorporateName: corporateName,
      defaultCollectionPointId: collectionPointId,
      defaultCollectionPointName: collectionPointName,
    );
    await loadCachedProfile();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _cachedProfile = null;
    notifyListeners();
  }
}

