import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/constants.dart';
import '../../models/corporate_lunch_order.dart';

class OrderTrackingScreen extends StatelessWidget {
  final CorporateLunchOrder order;

  const OrderTrackingScreen({super.key, required this.order});

  int get _stepIndex {
    switch (order.deliveryStatus) {
      case 'UNASSIGNED':
      case 'ASSIGNED':
        return 0; // Order Confirmed & In Kitchen
      case 'OUT_FOR_DELIVERY':
        return 1; // On the way
      case 'ARRIVED':
        return 2; // Arrived at desk / collection point
      case 'DELIVERED':
        return 3; // Completed
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _stepIndex;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Track Order #${order.orderId}',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delivery Date: ${order.lunchDate}',
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: order.orderStatus == 'CONFIRMED' ? Colors.green.shade50 : Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          order.deliveryStatus,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: order.orderStatus == 'CONFIRMED' ? AppColors.vegGreen : Colors.amber.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Drop-off: ${order.corporateName} • ${order.collectionPointName}',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Tracking Steps
                  _buildTrackingStep(
                    stepNumber: 1,
                    title: 'Order Confirmed',
                    subtitle: 'Kitchen is preparing authentic fresh Kerala meal',
                    isCompleted: step >= 0,
                    isCurrent: step == 0,
                  ),
                  _buildTrackingStep(
                    stepNumber: 2,
                    title: 'Out for Delivery',
                    subtitle: 'Driver partner dispatched with temperature-controlled box',
                    isCompleted: step >= 1,
                    isCurrent: step == 1,
                  ),
                  _buildTrackingStep(
                    stepNumber: 3,
                    title: 'Arrived at Collection Point',
                    subtitle: 'Meal dropped at ${order.collectionPointName}',
                    isCompleted: step >= 2,
                    isCurrent: step == 2,
                  ),
                  _buildTrackingStep(
                    stepNumber: 4,
                    title: 'Delivered / Collected',
                    subtitle: 'Meal received and enjoyed by customer',
                    isCompleted: step >= 3,
                    isCurrent: step == 3,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Order Details Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meal Details',
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${order.meal.mealTypeName} • ${order.meal.riceQuantityName}',
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                  ),
                  if (order.meal.gravyName != null)
                    Text('Gravy: ${order.meal.gravyName}', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                  if (order.meal.fryName != null)
                    Text('Fry: ${order.meal.fryName}', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                  if (order.meal.curryName != null)
                    Text('Curry: ${order.meal.curryName}', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Quantity: ${order.totalQuantity} meal(s)', style: GoogleFonts.poppins(fontSize: 12)),
                      Text('₹${order.totalAmount.toStringAsFixed(0)} (${order.paymentMethod})', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingStep({
    required int stepNumber,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isCurrent,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.primaryGreen : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Text('$stepNumber', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white)),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 42,
                color: isCompleted ? AppColors.primaryGreen : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                  color: isCurrent ? AppColors.primaryGreen : AppColors.textDark,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

