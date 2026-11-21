import 'package:flutter/material.dart';

class AppConstants {
  // Brand Name & Identifiers
  static const String appName = 'OneLunch';
  static const String companyName = 'Rinus Food Products';
  static const String tagline = 'Corporate Lunch Ordering';

  // Firebase Realtime Database Target URL (Asia Southeast 1)
  static const String rtdbUrl =
      'https://rfproducts-e76ce-default-rtdb.asia-southeast1.firebasedatabase.app';

  // Cloud Functions Endpoints
  static const String functionsBaseUrl =
      'https://us-central1-rfproducts-e76ce.cloudfunctions.net';
  static const String createCashfreeOrderUrl =
      '$functionsBaseUrl/createCashfreeOrder';
  static const String verifyCashfreeOrderUrl =
      '$functionsBaseUrl/verifyCashfreeOrder';

  // Realtime Database Paths (Exact contract with rinusfoodproduct)
  static const String pathCorporateLunchSettings = 'corporateLunchSettings';
  static const String pathLunchMealOptions = 'lunchMealOptions';
  static const String pathCorporates = 'corporates';
  static const String pathCollectionPoints = 'collectionPoints';
  static const String pathLunchAvailability = 'lunchAvailability';
  static const String pathCorporateLunchOrders = 'corporateLunchOrders';
  static const String pathWeeklyBookings = 'weeklyBookings';
  static const String pathCorporateLunchDeliveries = 'corporateLunchDeliveries';
  static const String pathCorporateLunchPayments = 'corporateLunchPayments';
  static const String pathCustomerPreferences = 'customerPreferences';
  static const String pathPushSubscriptions = 'pushSubscriptions';
  static const String pathCorporateEnquiries = 'corporateEnquiries';
  static const String pathAuditLogs = 'auditLogs';

  // Business Operational Defaults
  static const String defaultTimezone = 'Asia/Kolkata';
  static const String defaultCutoffTime = '20:00'; // 8:00 PM IST
  static const double defaultPrice = 80.0;
  static const int promoBuyQty = 20;
  static const int promoFreeQty = 1;
}

class AppColors {
  // Brand Palette derived from official Rinus Food Products Logo
  static const Color primaryGreen = Color(0xFF075B25); // Emerald Forest Green #075B25
  static const Color darkGreen = Color(0xFF022B10);    // Deep Forest Green #022B10
  static const Color forestGreen = Color(0xFF05441C);  // Pine Green #05441C
  static const Color accentGreen = Color(0xFF75B94A);  // Accent Fresh Green #75B94A
  
  // Authentic Logo Gold & Warm Spice Ribbon
  static const Color logoGold = Color(0xFFECC875);        // Rinus Authentic Gold #ECC875
  static const Color logoGoldDeep = Color(0xFFD49B30);    // Warm Brass Gold #D49B30
  static const Color logoOrange = Color(0xFFE65100);      // Warm Food Orange #E65100 / #D9701E
  static const Color logoOrangeBright = Color(0xFFFF6D00);// Bright Spice Orange #FF6D00
  static const Color logoCream = Color(0xFFFFFDF2);       // Cream Background #FFFDF2

  // Surfaces & Backgrounds
  static const Color background = Color(0xFFF7F8F5);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F4F0);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF0E2E16);
  static const Color textDark = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF5E6D60);
  static const Color textMuted = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);

  // Indicators & Status
  static const Color vegGreen = Color(0xFF0F8A43);
  static const Color nonVegRed = Color(0xFFD32F2F);
  static const Color warningOrange = Color(0xFFF57C00);
  static const Color borderLight = Color(0xFFE0E0E0);
}

