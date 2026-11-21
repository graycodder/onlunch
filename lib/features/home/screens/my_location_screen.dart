import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/leaf_background.dart';
import 'change_location_dialog.dart';

class MyLocationScreen extends StatelessWidget {
  final bool isTab;

  const MyLocationScreen({super.key, this.isTab = false});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    final content = LeafBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
            child: Obx(() {
              final user = authController.currentUser.value;
              final compName = user?.defaultCompanyName.isNotEmpty == true
                  ? user!.defaultCompanyName
                  : 'iSquare CoWorking Space';
              final cpName = user?.defaultCollectionPointName.isNotEmpty == true
                  ? user!.defaultCollectionPointName
                  : 'iSquare Thrikkakara';
              final cpTime = user?.defaultDeliveryTime.isNotEmpty == true
                  ? user!.defaultDeliveryTime
                  : '12:30 PM';
              final cpAddr = user?.defaultDeliveryAddress.isNotEmpty == true
                  ? user!.defaultDeliveryAddress
                  : 'Ground Floor Cafe Area, iSquare Thrikkakara, Kochi';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active Campus Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.softLightGreen,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.business_rounded, color: AppColors.primaryGreen, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selected Company',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    compName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 28),

                        Text(
                          'COLLECTION POINT',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cpName,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cpAddr,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 14),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.creamBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.schedule, color: AppColors.primaryGreen, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Daily delivery expected by $cpTime',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Info Notice
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, size: 20, color: AppColors.primaryGreen),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Moving to a new office or branch? You can change your company and collection point anytime. Past confirmed orders will always retain their original delivery location.',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Change Location Button
                  CustomButton(
                    text: 'Change Delivery Location',
                    icon: const Icon(Icons.edit_location_alt_rounded, color: Colors.white, size: 18),
                    onPressed: () => ChangeLocationDialog.show(context),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),
          ),
        ),
      );

    if (isTab) return content;
    return Scaffold(
      backgroundColor: AppColors.creamBg,
      appBar: AppBar(
        title: Text(
          'My Delivery Location',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryGreen,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: content,
    );
  }
}
