import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../common/widgets/custom_header.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/leaf_background.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/cart_item_model.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    OrderModel order;
    final args = Get.arguments;
    if (args is OrderModel) {
      order = args;
    } else {
      order = OrderModel(
        orderId: 'OL1001',
        userId: 'user_default',
        customerName: 'OneLunch',
        mobile: '+91 98765 43210',
        items: [
          CartItemModel(
            productId: 'prod_rice_lunch',
            productName: 'Rice Lunch',
            price: 80,
            imageUrl: 'assets/images/rice_lunch.png',
            quantity: 1,
          )
        ],
        totalAmount: 80,
        orderStatus: 'Pending',
        paymentStatus: 'PAID',
        createdAt: '07 Nov 2026, 12:30 PM',
      );
    }

    final hasCustomMeals = order.customizedMeals.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      appBar: const CustomHeader(
        title: AppStrings.orderDetails,
        showBackButton: true,
        showCart: false,
      ),
      body: LeafBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),

                // 1. Status Visual: Green Circular Clock Icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: AppColors.softLightGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      order.orderStatus.toLowerCase() == 'completed'
                          ? Icons.check_circle_rounded
                          : Icons.access_time_rounded,
                      size: 42,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Order Confirmed Title
                Text(
                  order.orderStatus.toLowerCase() == 'completed'
                      ? 'Order Delivered'
                      : AppStrings.orderConfirmed,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),

                // Subtitle
                Text(
                  order.orderStatus.toLowerCase() == 'completed'
                      ? 'Thank you for ordering with OneLunch!'
                      : AppStrings.orderConfirmedSub,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Light Green Rounded Order ID Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.badgeGreen.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accentGreen.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Order #${order.orderId}',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: order.orderStatus.toLowerCase() == 'completed'
                                  ? AppColors.statusCompletedBg
                                  : AppColors.statusPendingBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              order.orderStatus,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: order.orderStatus.toLowerCase() == 'completed'
                                    ? AppColors.statusCompletedText
                                    : AppColors.statusPendingText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.createdAt,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Corporate Delivery Location Snapshot Card
                if (order.collectionPointName.isNotEmpty || order.companyName.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight.withOpacity(0.8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: AppColors.primaryGreen, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Delivery Campus & Collection Point',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        if (order.companyName.isNotEmpty) ...[
                          Text(
                            order.companyName,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                        if (order.collectionPointName.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Point: ${order.collectionPointName}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                        if (order.deliveryDate.isNotEmpty || order.deliveryTime.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                '${order.deliveryDate.isNotEmpty ? "${order.deliveryDate} • " : ""}${order.deliveryTime.isNotEmpty ? order.deliveryTime : "12:30 PM - 01:15 PM"}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (order.deliveryAddress.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            order.deliveryAddress,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 4. Meal Items Section Header
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    hasCustomMeals ? 'Configured Lunch Boxes' : 'Items',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // If customized meals are present
                if (hasCustomMeals) ...[
                  ...order.customizedMeals.map((meal) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderLight.withOpacity(0.8)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: meal.mealType == 'Veg' ? Colors.green : Colors.red,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: meal.mealType == 'Veg' ? Colors.green : Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        meal.mealName,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '₹ ${meal.totalPrice.toInt()}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Rice: ${meal.riceChoice}  •  Gravy: ${meal.gravyChoice}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (meal.addons.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: meal.addons.map((a) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.badgeGreen.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.accentGreen.withOpacity(0.2)),
                                  ),
                                  child: Text(
                                    '${a.name} x${a.quantity} (+₹${(a.price * a.quantity).toInt()})',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Qty: ${meal.quantity} box${meal.quantity > 1 ? "es" : ""}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ] else ...[
                  // Fallback for standard/legacy items
                  ...order.items.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderLight.withOpacity(0.8)),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 52,
                              height: 52,
                              child: Image.asset(
                                item.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: AppColors.softLightGreen,
                                  child: const Icon(Icons.lunch_dining, color: AppColors.primaryGreen),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '₹ ${item.price.toInt()}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'x ${item.quantity}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],

                const SizedBox(height: 12),

                // 5. Total Row Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight.withOpacity(0.8)),
                  ),
                  child: Column(
                    children: [
                      if (order.baseMealsTotal > 0 || order.addonsTotal > 0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Base Meals Total',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '₹ ${order.baseMealsTotal.toInt()}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Add-ons Total',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '₹ ${order.addonsTotal.toInt()}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.totalAmount,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '₹ ${order.totalAmount.toInt()}',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Payment Mode',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.badgeGreen,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              order.paymentStatus == 'PAID' ? 'ONLINE PREPAID (PAID)' : order.paymentStatus,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // 6. Back to Home Button
                CustomButton(
                  text: AppStrings.backToHome,
                  isOutlined: true,
                  icon: const Icon(Icons.home_outlined, color: AppColors.primaryGreen, size: 20),
                  onPressed: () {
                    Get.offAllNamed(AppRoutes.home);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

