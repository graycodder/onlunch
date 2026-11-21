import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/assets.dart';
import '../../../core/constants/strings.dart';
import '../../common/widgets/custom_header.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/leaf_background.dart';
import '../controllers/product_details_controller.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductDetailsController());

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      appBar: const CustomHeader(
        title: AppStrings.foodDetails,
        showBackButton: true,
      ),
      body: LeafBackground(
        child: Column(
          children: [
            // 1. Large Top Hero Food Photography
            SizedBox(
              width: double.infinity,
              height: 240,
              child: Image.asset(
                controller.product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  AppAssets.foodDetailsBanner,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.softLightGreen,
                    child: const Icon(Icons.lunch_dining_rounded, size: 80, color: AppColors.primaryGreen),
                  ),
                ),
              ),
            ),

            // 2. Product Details Sheet Content
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      controller.product.name,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Price
                    Text(
                      '₹ ${controller.product.price.toInt()}',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Description
                    Text(
                      controller.product.description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stepper: [ - ]   quantity   [ + ]
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18, color: AppColors.textPrimary),
                              onPressed: controller.decrement,
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 40),
                              alignment: Alignment.center,
                              child: Obx(() => Text(
                                '${controller.quantity.value}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              )),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18, color: AppColors.textPrimary),
                              onPressed: controller.increment,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Add to Cart Button
                    CustomButton(
                      text: AppStrings.addToCart,
                      icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                      onPressed: controller.addToCart,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

