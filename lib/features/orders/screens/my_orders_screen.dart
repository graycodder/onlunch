import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../common/widgets/custom_header.dart';
import '../../common/widgets/leaf_background.dart';
import '../controllers/orders_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/order_model.dart';

class MyOrdersScreen extends StatelessWidget {
  final bool isTab;

  const MyOrdersScreen({super.key, this.isTab = false});

  Widget _buildOrderCard(OrderModel order) {
    final isPending = order.isPending;
    final totalMeals = order.customizedMeals.isNotEmpty
        ? order.customizedMeals.fold<int>(0, (sum, m) => sum + m.quantity)
        : (order.items.isNotEmpty ? order.items.fold<int>(0, (sum, i) => sum + i.quantity) : 1);

    String thumbImage = 'assets/images/rice_lunch.png';
    if (order.customizedMeals.isNotEmpty) {
      final first = order.customizedMeals.first;
      thumbImage = first.mealType == 'Veg' ? 'assets/images/meals_veg.png' : 'assets/images/meals_nonveg.png';
    } else if (order.items.isNotEmpty) {
      thumbImage = order.items.first.imageUrl;
    }

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.orderDetails, arguments: order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight.withOpacity(0.8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Food Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 60,
                height: 60,
                child: Image.asset(
                  thumbImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.softLightGreen,
                    child: const Icon(Icons.lunch_dining, color: AppColors.primaryGreen, size: 28),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Order ID & Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '#${order.orderId}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: isPending ? AppColors.statusPendingBg : AppColors.statusCompletedBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          order.orderStatus,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isPending ? AppColors.statusPendingText : AppColors.statusCompletedText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  if (order.collectionPointName.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 12, color: AppColors.primaryGreen),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            order.collectionPointName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    '${order.deliveryDate.isNotEmpty ? "${order.deliveryDate} • " : ""}$totalMeals Box${totalMeals > 1 ? "es" : ""}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Price & Chevron
            Row(
              children: [
                Text(
                  '₹ ${order.totalAmount.toInt()}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrdersController());

    final content = LeafBackground(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Segmented Pill Tabs: [ Pending (2) ] [ Completed ]
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Obx(() {
                final selected = controller.selectedTab.value;
                final pendingCount = controller.pendingOrders.length;

                return Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      // Pending Tab
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.selectedTab.value = 0,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selected == 0 ? AppColors.primaryGreen : Colors.transparent,
                              borderRadius: BorderRadius.circular(26),
                            ),
                            child: Text(
                              'Pending ($pendingCount)',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected == 0 ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Completed Tab
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.selectedTab.value = 1,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selected == 1 ? AppColors.primaryGreen : Colors.transparent,
                              borderRadius: BorderRadius.circular(26),
                            ),
                            child: Text(
                              AppStrings.completed,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected == 1 ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Orders List
            Expanded(
              child: Obx(() {
                final isPendingSelected = controller.selectedTab.value == 0;
                final list = isPendingSelected ? controller.pendingOrders : controller.completedOrders;

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.4)),
                        const SizedBox(height: 12),
                        Text(
                          isPendingSelected ? 'No pending orders' : 'No completed orders',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return _buildOrderCard(list[index]);
                  },
                );
              }),
            ),
          ],
        ),
      );

    if (isTab) return content;
    return Scaffold(
      backgroundColor: AppColors.creamBg,
      appBar: const CustomHeader(
        title: AppStrings.myOrders,
        showBackButton: true,
      ),
      body: content,
    );
  }
}

