import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../common/widgets/custom_header.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/leaf_background.dart';
import '../controllers/cart_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../home/screens/change_location_dialog.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final authController = Get.find<AuthController>();
    final RxString selectedPaymentMethod = 'Prepaid Online (UPI / Card)'.obs;
    final RxBool isWeeklyBooking = false.obs;

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      appBar: const CustomHeader(
        title: 'Review Lunch Order',
        showBackButton: true,
        showCart: false,
      ),
      body: LeafBackground(
        child: Obx(() {
          final hasCustom = cartController.customizedMeals.isNotEmpty;
          final hasLegacy = cartController.items.isNotEmpty;

          if (!hasCustom && !hasLegacy) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 72, color: AppColors.textSecondary.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'Your OneLunch cart is empty',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a meal from the menu and customize your add-ons',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Explore Lunch Menu',
                    width: 220,
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            );
          }

          final user = authController.currentUser.value;
          final compName = user?.defaultCompanyName ?? 'iSquare CoWorking Space';
          final cpName = user?.defaultCollectionPointName ?? 'iSquare Thrikkakara';
          final cpTime = user?.defaultDeliveryTime ?? '12:30 PM';

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Delivery Location Banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.softLightGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.location_on, color: AppColors.primaryGreen, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Delivering to: ',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      compName,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  cpName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Delivery Tomorrow by $cpTime',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppColors.primaryGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => ChangeLocationDialog.show(context),
                            child: Text(
                              'Change',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Delivery Schedule Type Selector (Daily vs Weekly)
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => isWeeklyBooking.value = false,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !isWeeklyBooking.value ? AppColors.primaryGreen : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.primaryGreen),
                              ),
                              child: Center(
                                child: Text(
                                  'Daily Order (Tomorrow)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: !isWeeklyBooking.value ? Colors.white : AppColors.primaryGreen,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              isWeeklyBooking.value = true;
                              _showWeeklyDatePicker(context, cartController);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isWeeklyBooking.value ? AppColors.primaryGreen : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.primaryGreen),
                              ),
                              child: Center(
                                child: Text(
                                  'Weekly Booking',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isWeeklyBooking.value ? Colors.white : AppColors.primaryGreen,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Customized Meals Heading
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Configured Meals (${cartController.totalBoxesCount} Boxes)',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          cartController.selectedDeliveryDate.value,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // List of Customized Meals
                    ...cartController.customizedMeals.map((meal) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: meal.mealType.toLowerCase() == 'veg' ? Colors.green.shade50 : Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: meal.mealType.toLowerCase() == 'veg' ? Colors.green : Colors.red,
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    meal.mealType.toUpperCase(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: meal.mealType.toLowerCase() == 'veg' ? Colors.green.shade800 : Colors.red.shade800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    meal.mealName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                  onPressed: () => cartController.removeCustomizedMeal(meal.configurationId),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Inclusions: Rice & Gravy
                            Text(
                              '• ${meal.selectedRice} • ${meal.selectedGravy}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            // Selected Add-ons List
                            if (meal.selectedAddons.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: meal.selectedAddons.map((addon) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.softLightGreen,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '+ ${addon.addonName} (x${addon.quantity}) ₹${addon.subtotal.toStringAsFixed(0)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                            const Divider(height: 18),

                            // Box Quantity and Subtotal
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '₹${meal.singleBoxTotal.toStringAsFixed(0)} / box',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.creamBg,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppColors.borderLight),
                                      ),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () => cartController.updateCustomizedMealQty(meal.configurationId, -1),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              child: Icon(Icons.remove, size: 14, color: AppColors.primaryGreen),
                                            ),
                                          ),
                                          Text(
                                            '${meal.mealQuantity}',
                                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold),
                                          ),
                                          GestureDetector(
                                            onTap: () => cartController.updateCustomizedMealQty(meal.configurationId, 1),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              child: Icon(Icons.add, size: 14, color: AppColors.primaryGreen),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '₹${meal.finalTotal.toStringAsFixed(0)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),

                    // Legacy items if any
                    ...cartController.items.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.productName} (x${item.quantity})',
                                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              '₹${item.subtotal.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),

                    // Payment Method Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Method',
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 8),
                          _buildPaymentRadio(
                            title: 'Prepaid Online (UPI / GPay / Cards)',
                            subtitle: 'Instant secure corporate checkout',
                            value: 'Prepaid Online (UPI / Card)',
                            groupValue: selectedPaymentMethod.value,
                            onChanged: (val) => selectedPaymentMethod.value = val!,
                          ),
                          _buildPaymentRadio(
                            title: 'Pay on Delivery (Campus Desk)',
                            subtitle: 'Pay at collection point upon pickup',
                            value: 'Cash on Delivery',
                            groupValue: selectedPaymentMethod.value,
                            onChanged: (val) => selectedPaymentMethod.value = val!,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bill Summary Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bill Details',
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const Divider(height: 16),
                          _buildBillRow('Base Meals Total', '₹${cartController.baseMealsTotal.toStringAsFixed(0)}'),
                          _buildBillRow('Add-ons Total', '₹${cartController.addonsTotal.toStringAsFixed(0)}'),
                          _buildBillRow('Corporate Campus Delivery', 'FREE', isHighlight: true),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'To Pay',
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              Text(
                                '₹${cartController.totalAmount.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Bottom Action Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: CustomButton(
                    text: 'Pay ₹${cartController.totalAmount.toStringAsFixed(0)} & Confirm Order',
                    isLoading: cartController.isPlacingOrder.value,
                    icon: const Icon(Icons.check_circle, color: Colors.white, size: 20),
                    onPressed: () {
                      cartController.confirmCorporateOrder(
                        paymentMethod: selectedPaymentMethod.value,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _showWeeklyDatePicker(BuildContext context, CartController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final List<DateTime> nextDays = List.generate(
          5,
          (i) => DateTime.now().add(Duration(days: i + 1)),
        );

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Delivery Date',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...nextDays.map((d) {
                final formatted = DateFormat('EEE, dd MMM yyyy').format(d);
                return ListTile(
                  title: Text(formatted, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.primaryGreen),
                  onTap: () {
                    controller.selectedDeliveryDate.value = formatted;
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentRadio({
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    return RadioListTile<String>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppColors.primaryGreen,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildBillRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              color: isHighlight ? AppColors.primaryGreen : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
