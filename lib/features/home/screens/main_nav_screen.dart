import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/constants/assets.dart';
import '../../../core/routes/app_routes.dart';
import '../../common/widgets/custom_header.dart';
import '../controllers/home_controller.dart';
import 'home_screen.dart';
import 'my_location_screen.dart';
import '../../orders/screens/my_orders_screen.dart';
import '../../profile/screens/profile_screen.dart';

class MainNavScreen extends StatelessWidget {
  const MainNavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    final List<Widget> pages = [
      const HomeScreen(),
      const MyOrdersScreen(isTab: true),
      const MyLocationScreen(isTab: true),
      const ProfileScreen(isTab: true),
    ];

    PreferredSizeWidget? buildTabAppBar(int index) {
      switch (index) {
        case 0:
          return null; // HomeScreen builds its own top immersive header
        case 1:
          return const CustomHeader(
            title: AppStrings.myOrders,
            showBackButton: false,
            showCart: true,
          );
        case 2:
          return AppBar(
            backgroundColor: AppColors.primaryGreen,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: Text(
              'My Delivery Location',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          );
        case 3:
          return const CustomHeader(
            title: AppStrings.profile,
            showBackButton: false,
            showCart: false,
          );
        default:
          return null;
      }
    }

    return Obx(() {
      final currentIndex = controller.selectedNavIndex.value;

      return Scaffold(
        key: scaffoldKey,
        backgroundColor: AppColors.lightBg,
        appBar: buildTabAppBar(currentIndex),
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60, bottom: 24, left: 24, right: 24),
                color: AppColors.primaryGreen,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      AppAssets.rinusBadgeLogo,
                      width: 64,
                      height: 64,
                      errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, color: Colors.white, size: 48),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppStrings.appName,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'By ${AppStrings.companyName}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_rounded, color: AppColors.primaryGreen),
                title: const Text('Home'),
                onTap: () {
                  Get.back();
                  controller.switchTab(0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.restaurant_menu_rounded, color: AppColors.primaryGreen),
                title: const Text('Our Lunch Menu'),
                onTap: () {
                  Get.back();
                  Get.toNamed(AppRoutes.menuCatalog);
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_cart_rounded, color: AppColors.primaryGreen),
                title: const Text('Cart'),
                onTap: () {
                  Get.back();
                  Get.toNamed(AppRoutes.cart);
                },
              ),
              ListTile(
                leading: const Icon(Icons.assignment_rounded, color: AppColors.primaryGreen),
                title: const Text('My Orders'),
                onTap: () {
                  Get.back();
                  controller.switchTab(1);
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_on_rounded, color: AppColors.primaryGreen),
                title: const Text('My Delivery Location'),
                onTap: () {
                  Get.back();
                  controller.switchTab(2);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_rounded, color: AppColors.primaryGreen),
                title: const Text('Profile'),
                onTap: () {
                  Get.back();
                  controller.switchTab(3);
                },
              ),
              const Divider(),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'OneLunch v1.0.0\nRinus Food Products',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: IndexedStack(
          index: currentIndex,
          children: pages,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: controller.switchTab,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.boltOrange,
            unselectedItemColor: const Color(0xFF6B7280),
            selectedLabelStyle: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.lunch_dining_outlined),
                activeIcon: Icon(Icons.lunch_dining_rounded),
                label: 'Food',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bolt_outlined),
                activeIcon: Icon(Icons.bolt_rounded),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.location_on_outlined),
                activeIcon: Icon(Icons.location_on_rounded),
                label: 'Location',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      );
    });
  }
}
