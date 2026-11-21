import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../firebase/firebase_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseService _fb = FirebaseService();

  FirebaseAuth get _auth => _fb.auth;
  FirebaseAuth get auth => _fb.auth;
  DatabaseReference get _usersRef => _fb.usersRef;

  static const String keySavedUser = 'onelunch_saved_user';
  static const String keyIsLoggedIn = 'onelunch_is_logged_in';

  User? get currentFirebaseUser => _auth.currentUser;
  bool get hasActiveSession => _auth.currentUser != null;

  /// Listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Send OTP to Indian mobile number (+91)
  Future<void> sendOtp({
    required String mobileNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(FirebaseAuthException e) onVerificationFailed,
    required Function(PhoneAuthCredential credential) onAutoVerify,
    required Function(String verificationId) onCodeTimeout,
  }) async {
    final cleanDigits = mobileNumber.replaceAll(RegExp(r'\D'), '');
    final phoneKey = cleanDigits.length >= 10 ? cleanDigits.substring(cleanDigits.length - 10) : cleanDigits;
    final formattedPhone = '+91$phoneKey';

    await _auth.verifyPhoneNumber(
      phoneNumber: formattedPhone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: onAutoVerify,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onCodeTimeout,
    );
  }

  /// Verify OTP code
  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  /// Get user profile from onelunch/users/{uid}
  Future<UserModel?> getUserProfile(String uid) async {
    final snapshot = await _usersRef.child(uid).get();
    if (snapshot.exists && snapshot.value is Map) {
      return UserModel.fromMap(snapshot.value as Map, uid);
    }
    return null;
  }

  /// Save or update user profile
  Future<void> saveUserProfile(UserModel user) async {
    try {
      await _usersRef.child(user.uid).update(user.toMap());
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keySavedUser, user.name);
    await prefs.setString('onelunch_saved_phone', user.mobile);
    await prefs.setString('onelunch_saved_uid', user.uid);
    await prefs.setString('onelunch_comp_id', user.defaultCompanyId);
    await prefs.setString('onelunch_comp_name', user.defaultCompanyName);
    await prefs.setString('onelunch_cp_id', user.defaultCollectionPointId);
    await prefs.setString('onelunch_cp_name', user.defaultCollectionPointName);
    await prefs.setString('onelunch_cp_time', user.defaultDeliveryTime);
    await prefs.setString('onelunch_cp_addr', user.defaultDeliveryAddress);
    await prefs.setBool(keyIsLoggedIn, true);
  }

  Future<bool> checkPersistedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsLoggedIn) ?? false;
  }

  Future<UserModel?> getPersistedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLogged = prefs.getBool(keyIsLoggedIn) ?? false;
    if (!isLogged) return null;
    final name = prefs.getString(keySavedUser) ?? 'OneLunch Customer';
    final phone = prefs.getString('onelunch_saved_phone') ?? '+91 99952 26139';
    final uid = prefs.getString('onelunch_saved_uid') ?? 'user_9995226139';
    final compId = prefs.getString('onelunch_comp_id') ?? '';
    final compName = prefs.getString('onelunch_comp_name') ?? '';
    final cpId = prefs.getString('onelunch_cp_id') ?? '';
    final cpName = prefs.getString('onelunch_cp_name') ?? '';
    final cpTime = prefs.getString('onelunch_cp_time') ?? '12:30 PM';
    final cpAddr = prefs.getString('onelunch_cp_addr') ?? '';

    return UserModel(
      uid: uid,
      name: name,
      mobile: phone,
      defaultCompanyId: compId,
      defaultCompanyName: compName,
      defaultCollectionPointId: cpId,
      defaultCollectionPointName: cpName,
      defaultDeliveryTime: cpTime,
      defaultDeliveryAddress: cpAddr,
    );
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keySavedUser);
    await prefs.setBool(keyIsLoggedIn, false);
  }
}
