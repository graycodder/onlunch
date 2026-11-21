import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../config/constants.dart';
import '../config/firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseApp? _app;
  FirebaseAuth? _auth;
  FirebaseDatabase? _database;

  FirebaseApp get app => _app ?? Firebase.app();
  FirebaseAuth get auth => _auth ?? FirebaseAuth.instance;
  FirebaseDatabase get database =>
      _database ??
      FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: AppConstants.rtdbUrl,
      );

  Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        _app = await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } else {
        _app = Firebase.app();
      }
    } catch (e) {
      debugPrint('FirebaseApp init: $e');
      _app = Firebase.app();
    }

    try {
      _auth = FirebaseAuth.instanceFor(app: app);
      _database = FirebaseDatabase.instanceFor(
        app: app,
        databaseURL: AppConstants.rtdbUrl,
      );

      if (!kIsWeb) {
        try {
          database.setPersistenceEnabled(true);
        } catch (_) {}
      }
      debugPrint('Connected to RTDB at ${AppConstants.rtdbUrl}');
    } catch (e) {
      debugPrint('Firebase RTDB setup: $e');
    }
  }

  // Exact Root RTDB References conforming to rinusfoodproduct contract
  DatabaseReference get settingsRef =>
      database.ref(AppConstants.pathCorporateLunchSettings);

  DatabaseReference get mealOptionsRef =>
      database.ref(AppConstants.pathLunchMealOptions);

  DatabaseReference get corporatesRef =>
      database.ref(AppConstants.pathCorporates);

  DatabaseReference get collectionPointsRef =>
      database.ref(AppConstants.pathCollectionPoints);

  DatabaseReference get availabilityRef =>
      database.ref(AppConstants.pathLunchAvailability);

  DatabaseReference get ordersRef =>
      database.ref(AppConstants.pathCorporateLunchOrders);

  DatabaseReference get weeklyBookingsRef =>
      database.ref(AppConstants.pathWeeklyBookings);

  DatabaseReference get deliveriesRef =>
      database.ref(AppConstants.pathCorporateLunchDeliveries);

  DatabaseReference get paymentsRef =>
      database.ref(AppConstants.pathCorporateLunchPayments);

  DatabaseReference get preferencesRef =>
      database.ref(AppConstants.pathCustomerPreferences);

  DatabaseReference get pushSubscriptionsRef =>
      database.ref(AppConstants.pathPushSubscriptions);

  DatabaseReference get enquiriesRef =>
      database.ref(AppConstants.pathCorporateEnquiries);

  DatabaseReference get auditLogsRef =>
      database.ref(AppConstants.pathAuditLogs);

  // Helper child references
  DatabaseReference orderRef(String orderId) => ordersRef.child(orderId);
  DatabaseReference deliveryRef(String deliveryId) => deliveriesRef.child(deliveryId);
  DatabaseReference weeklyBookingRef(String wbId) => weeklyBookingsRef.child(wbId);
  DatabaseReference customerPrefRef(String cleanPhone) =>
      preferencesRef.child(cleanPhone).child('lunchOrdering');
}

