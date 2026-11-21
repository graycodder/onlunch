import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../../core/routes/app_routes.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool isHome;
  final VoidCallback? onMenuPressed;
  final bool showCart;

  const CustomHeader({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.isHome = false,
    this.onMenuPressed,
    this.showCart = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    CartController? cartController;
    try {
      cartController = Get.find<CartController>();
    } catch (_) {}

    return AppBar(
      backgroundColor: AppColors.primaryGreen,
      elevation: 0,
      centerTitle: true,
      leading: isHome
          ? IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
              onPressed: onMenuPressed ?? () {},
            )
          : (showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  onPressed: () => Get.back(),
                )
              : null),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      ),
      actions: [
        if (showCart)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: cartController != null
                ? Obx(() {
                    final count = cartController!.totalItemsCount;
                    return Badge(
                      isLabelVisible: count > 0,
                      label: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: AppColors.cartBadgeRed,
                      offset: const Offset(-4, 4),
                      child: IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 24),
                        onPressed: () => Get.toNamed(AppRoutes.cart),
                      ),
                    );
                  })
                : IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 24),
                    onPressed: () => Get.toNamed(AppRoutes.cart),
                  ),
          )
        else
          const SizedBox(width: 48),
      ],
    );
  }
}

