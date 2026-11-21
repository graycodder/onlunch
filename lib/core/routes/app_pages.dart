import 'package:get/get.dart';
import 'app_routes.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/welcome_login_screen.dart';
import '../../features/auth/screens/otp_verification_screen.dart';
import '../../features/home/screens/main_nav_screen.dart';
import '../../features/products/screens/meal_customization_screen.dart';
import '../../features/products/screens/menu_catalog_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/orders/screens/my_orders_screen.dart';
import '../../features/orders/screens/order_details_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

class AppPages {
  static const String initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.welcomeLogin,
      page: () => const WelcomeLoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.otpVerification,
      page: () => const OtpVerificationScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const MainNavScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.productDetails,
      page: () => const MealCustomizationScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.mealCustomization,
      page: () => const MealCustomizationScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.menuCatalog,
      page: () => const MenuCatalogScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.cart,
      page: () => const CartScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.myOrders,
      page: () => const MyOrdersScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.orderDetails,
      page: () => const OrderDetailsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}

