import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/assets.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/home_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import 'change_location_dialog.dart';
import '../../../data/models/meal_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final authController = Get.find<AuthController>();
    final cartController = Get.isRegistered<CartController>() ? Get.find<CartController>() : null;

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final tomorrowStr = DateFormat('EEE, dd MMM').format(tomorrow);

    return Container(
      color: AppColors.lightBg,
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP HEADER & SERVICE TABS (Deep Wine / Maroon)
            _buildTopWineHeader(context, authController, cartController, controller),

            // 2. SEARCH & SUB-CATEGORIES SECTION (Vibrant Crimson)
            _buildCrimsonSearchAndOffers(context, controller),

            // 3. MAIN BODY CONTENT (Soft Light / Clean)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BOLT 15-MINS / 12:30 PM EXPRESS BANNER
                  _buildBoltBanner(context, tomorrowStr),
                  const SizedBox(height: 18),

                  // DAILY DELIVERY & CUTOFF STATUS PILL
                  _buildCutoffStatusCard(controller, tomorrowStr),
                  const SizedBox(height: 18),

                  // QUICK FILTER CHIPS
                  _buildQuickFilterChips(controller),
                  const SizedBox(height: 20),

                  // MENU SECTION TITLE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Lunch Specials',
                              style: GoogleFonts.poppins(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              'Fresh authentic Kerala meals for your workplace',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.menuCatalog),
                        child: Text(
                          'See All',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.swiggyCrimson,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // MEAL CARDS LIST (SWIGGY FOOD STYLE)
                  Obx(() {
                    final mealsList = controller.filteredMeals;
                    if (mealsList.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(
                              'No meals match your filter.',
                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: mealsList.map((meal) {
                        return _buildFoodCard(context, meal);
                      }).toList(),
                    );
                  }),
                  const SizedBox(height: 20),

                  // CUSTOMER SERVICES & SUPPORT ROW
                  _buildServicesRow(context, controller),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 1. TOP HEADER & SERVICE TABS (Dark Wine #3D001A)
  Widget _buildTopWineHeader(
    BuildContext context,
    AuthController authController,
    CartController? cartController,
    HomeController controller,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.swiggyDarkWine, AppColors.swiggyPlum],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Location & Profile Row
              Row(
                children: [
                  // User Location with Chevron
                  Expanded(
                    child: GestureDetector(
                      onTap: () => ChangeLocationDialog.show(context),
                      behavior: HitTestBehavior.opaque,
                      child: Obx(() {
                        final user = authController.currentUser.value;
                        final name = user?.name.isNotEmpty == true ? user!.name : 'Customer';
                        final firstName = name.split(' ').first;
                        final comp = user?.defaultCompanyName.isNotEmpty == true
                            ? user!.defaultCompanyName
                            : 'iSquare CoWorking Space';
                        final cp = user?.defaultCollectionPointName.isNotEmpty == true
                            ? user!.defaultCollectionPointName
                            : 'iSquare Thrikkakara';

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  firstName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ],
                            ),
                            const SizedBox(height: 1),
                            Text(
                              '$comp, $cp',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.75),
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),

                  // Free / Cart Badge Pill
                  if (cartController != null)
                    Obx(() {
                      final count = cartController.totalItemsCount;
                      return GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.cart),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.offerGold,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  count > 0 ? '$count' : 'FREE',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                      );
                    }),

                  // Rinus Official Logo Emblem Badge
                  Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.offerGold, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        AppAssets.rinusBadgeLogo,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, color: Colors.white, size: 20),
                      ),
                    ),
                  ),

                  // Menu Drawer Button
                  Builder(
                    builder: (ctx) => GestureDetector(
                      onTap: () => Scaffold.of(ctx).openDrawer(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                        ),
                        child: const Center(
                          child: Icon(Icons.menu_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Segmented Service Tabs: [ Food ] [ Daily Lunch ] [ Corporate ]
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Tab 1: Food (Active Curved Tab)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: const BoxDecoration(
                        color: AppColors.swiggyBrightRed,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.lunch_dining_rounded, color: Colors.white, size: 22),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Food',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Tab 2: Daily Lunch (Pre-Order)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.menuCatalog),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.logoOrange,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Tomorrow',
                                style: GoogleFonts.poppins(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Icon(Icons.inventory_2_outlined, color: Colors.white70, size: 20),
                            const SizedBox(height: 2),
                            Text(
                              'Pre-Order',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Tab 3: Corporate Catering
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.menuCatalog),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 15),
                            const Icon(Icons.room_service_outlined, color: Colors.white70, size: 20),
                            const SizedBox(height: 2),
                            Text(
                              'Corporate',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 2. SEARCH & SUB-CATEGORIES SECTION (Vibrant Crimson #D60052)
  Widget _buildCrimsonSearchAndOffers(BuildContext context, HomeController controller) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.swiggyBrightRed,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar & Veg Filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                // White Pill Search Box
                Expanded(
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: Color(0xFF6B7280), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            onChanged: (val) => controller.searchQuery.value = val,
                            style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF1F2937)),
                            decoration: InputDecoration(
                              hintText: "Search for 'Sadya', 'Biryani'...",
                              hintStyle: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF9CA3AF)),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                          ),
                        ),
                        Container(
                          height: 20,
                          width: 1,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.mic_rounded, color: AppColors.boltOrange, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // VEG Toggle Pill
                Obx(() {
                  final isVeg = controller.isVegOnly.value;
                  return GestureDetector(
                    onTap: () => controller.isVegOnly.value = !isVeg,
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isVeg ? AppColors.vegGreen : Colors.grey.shade300,
                          width: isVeg ? 1.5 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'VEG',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isVeg ? AppColors.vegGreen : const Color(0xFF4B5563),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isVeg ? AppColors.vegGreen : Colors.grey.shade500,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isVeg ? AppColors.vegGreen : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Sub-Category Tabs (ALL, STORE, OFFERS, BOLT)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() {
              final selected = controller.selectedSubCategory.value;
              return Row(
                children: [
                  _buildSubCategoryTab('ALL', Icons.apps_rounded, selected == 'ALL', () {
                    controller.selectedSubCategory.value = 'ALL';
                  }),
                  _buildSubCategoryTab('STORE', Icons.storefront_rounded, selected == 'STORE', () {
                    controller.selectedSubCategory.value = 'STORE';
                  }),
                  _buildSubCategoryTab('OFFERS', Icons.local_offer_rounded, selected == 'OFFERS', () {
                    controller.selectedSubCategory.value = 'OFFERS';
                  }),
                  _buildSubCategoryTab('BOLT', Icons.bolt_rounded, selected == 'BOLT', () {
                    controller.selectedSubCategory.value = 'BOLT';
                  }),
                ],
              );
            }),
          ),
          const SizedBox(height: 16),

          // "Welcome, foodie!" Section with 3-Card Offer Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                    children: [
                      const TextSpan(text: 'Welcome, '),
                      TextSpan(
                        text: 'foodie!',
                        style: GoogleFonts.caveat(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: AppColors.offerGold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 3-Card Offer Grid
                SizedBox(
                  height: 190,
                  child: Row(
                    children: [
                      // Card 1 (Left Tall Card): 70% OFF
                      Expanded(
                        flex: 11,
                        child: GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.menuCatalog),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.offerCard1,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Get 70% OFF',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.offerGold,
                                  ),
                                ),
                                Text(
                                  'On your cravings!',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                ),
                                const Spacer(),
                                Center(
                                  child: Image.asset(
                                    AppAssets.riceLunch,
                                    height: 90,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.lunch_dining_rounded,
                                      color: Colors.white54,
                                      size: 60,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Card 2 & 3 Column (Right)
                      Expanded(
                        flex: 10,
                        child: Column(
                          children: [
                            // Card 2: Free Delivery
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.offerCard2,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Free Delivery',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.offerGold,
                                            ),
                                          ),
                                          Text(
                                            'At ₹0 With one',
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: const BoxDecoration(
                                        color: AppColors.boltOrange,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.published_with_changes_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Card 3: 60 / 99 Store
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Get.toNamed(AppRoutes.menuCatalog),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.offerCard3,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.offerGold,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '60 store',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Meals At ₹60',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Image.asset(
                                        AppAssets.mealsVeg,
                                        width: 44,
                                        height: 44,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.fastfood_rounded,
                                          color: Colors.white54,
                                          size: 32,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoryTab(String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        padding: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.offerGold : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? AppColors.offerGold : Colors.white70, size: 14),
            const SizedBox(width: 4),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.offerGold : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 3. BOLT 15-MINS / 12:30 PM EXPRESS BANNER (Dark Plum Card)
  Widget _buildBoltBanner(BuildContext context, String tomorrowStr) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.boltDarkBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  flex: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Bolt',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const Icon(Icons.bolt_rounded, color: AppColors.boltOrange, size: 20),
                          Container(
                            height: 12,
                            width: 1,
                            color: Colors.white24,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                          Flexible(
                            child: Text(
                              'Lunch By 12:30 PM!',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fresh, hot & authentic Kerala delights delivered directly to your office desk.',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.75),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: () => Get.toNamed(AppRoutes.menuCatalog),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.boltOrange,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'ORDER NOW',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 8,
                  child: Image.asset(
                    AppAssets.showcase,
                    height: 100,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Image.asset(
                      AppAssets.keralaLunchHero,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 4. CUTOFF STATUS CARD
  Widget _buildCutoffStatusCard(HomeController controller, String tomorrowStr) {
    return Obx(() {
      final settings = controller.settings.value;
      final isOpen = settings?.lunchAvailability ?? true;
      final cutoff = settings?.orderCutoffTime ?? '11:30 PM';

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOpen ? Colors.green.shade200 : Colors.amber.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isOpen ? Colors.green.shade50 : Colors.amber.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOpen ? Icons.restaurant_rounded : Icons.schedule_rounded,
                size: 18,
                color: isOpen ? AppColors.vegGreen : Colors.amber.shade800,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ordering for: $tomorrowStr',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    isOpen
                        ? 'Ordering open • Cutoff tonight at $cutoff'
                        : 'Ordering closed for tomorrow • Cutoff was $cutoff',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 5. QUICK FILTER CHIPS
  Widget _buildQuickFilterChips(HomeController controller) {
    final filters = ['ALL', 'MIN Rs. 100 OFF', 'FAST DELIVERY', 'KERALA SADYA', 'PURE GHEE'];

    return Obx(() {
      final current = controller.selectedFilterPill.value;
      return SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final f = filters[index];
            final isSelected = current == f;
            return GestureDetector(
              onTap: () {
                controller.selectedFilterPill.value = isSelected ? 'ALL' : f;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.swiggyDarkWine : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.swiggyDarkWine : Colors.grey.shade300,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    f,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : const Color(0xFF374151),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  /// 6. FOOD CARD WIDGET (Swiggy Food / Delivery Item Style)
  Widget _buildFoodCard(BuildContext context, MealModel meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Food Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Veg / Non-Veg Indicator Icon
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: meal.isVeg ? AppColors.vegGreen : AppColors.nonVegRed,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: meal.isVeg ? AppColors.vegGreen : AppColors.nonVegRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Meal Name
                Text(
                  meal.name,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111827),
                  ),
                ),

                // Price
                Text(
                  '₹${meal.basePrice.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),

                // Star Rating & Badge
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      '4.8 (120+)',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Description
                Text(
                  meal.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF6B7280),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Right: Food Image with ADD Button
          SizedBox(
            width: 104,
            height: 120,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Dish Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    meal.imageUrl,
                    width: 104,
                    height: 94,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 104,
                      height: 94,
                      color: const Color(0xFFF3F4F6),
                      child: const Icon(Icons.restaurant, color: Colors.grey),
                    ),
                  ),
                ),

                // Swiggy-Style "ADD +" Floating Button
                Positioned(
                  bottom: 2,
                  child: GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.productDetails, arguments: meal);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ADD',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.vegGreen,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.add_rounded,
                            size: 15,
                            color: AppColors.vegGreen,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 7. SERVICES & SUPPORT ROW
  Widget _buildServicesRow(BuildContext context, HomeController controller) {
    return Row(
      children: [
        _buildServiceTile(
          icon: Icons.play_circle_fill_rounded,
          label: 'Watch Video',
          onTap: () {
            final url = controller.banner.value?.videoUrl ?? 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
            launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          },
        ),
        const SizedBox(width: 10),
        _buildServiceTile(
          icon: Icons.headset_mic_rounded,
          label: 'Support',
          onTap: () async {
            final phone = controller.settings.value?.supportPhone ?? '+919995226139';
            final uri = Uri.parse('tel:$phone');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          },
        ),
        const SizedBox(width: 10),
        _buildServiceTile(
          icon: Icons.card_giftcard_rounded,
          label: 'Weekly Pass',
          onTap: () => Get.toNamed(AppRoutes.cart),
        ),
      ],
    );
  }

  Widget _buildServiceTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.swiggyBrightRed, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
