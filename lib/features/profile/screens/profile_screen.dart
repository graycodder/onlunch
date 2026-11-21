import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../common/widgets/custom_header.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/leaf_background.dart';
import '../controllers/profile_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../home/screens/change_location_dialog.dart';

class ProfileScreen extends StatelessWidget {
  final bool isTab;

  const ProfileScreen({super.key, this.isTab = false});

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: Icon(icon, color: AppColors.primaryGreen, size: 22),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSecondary, size: 14),
          onTap: onTap,
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AuthController auth) {
    final nameController = TextEditingController(text: auth.currentUser.value?.name ?? 'OneLunch');
    final addressController = TextEditingController(text: auth.currentUser.value?.address ?? '');
    final emailController = TextEditingController(text: auth.currentUser.value?.email ?? '');

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Profile Details',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Customer / Corporate Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Delivery / Corporate Address'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email Address (Optional)'),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Save Changes',
                onPressed: () {
                  auth.updateProfile(
                    name: nameController.text.trim(),
                    address: addressController.text.trim(),
                    email: emailController.text.trim(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileController = Get.put(ProfileController());
    final authController = Get.find<AuthController>();

    final content = LeafBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 10),

                // 1. Profile Avatar & Name Section
                Obx(() {
                  final user = authController.currentUser.value;
                  final name = user?.name.isNotEmpty == true ? user!.name : 'OneLunch';
                  final mobile = user?.mobile.isNotEmpty == true ? user!.mobile : '+91 98765 43210';

                  return Column(
                    children: [
                      // Avatar with edit badge
                      Stack(
                        children: [
                          Container(
                            width: 86,
                            height: 86,
                            decoration: const BoxDecoration(
                              color: AppColors.softLightGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.person_rounded,
                                size: 54,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _showEditProfileDialog(context, authController),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Center(
                                  child: Icon(Icons.edit, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Name
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Mobile Number
                      Text(
                        mobile,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 28),

                // 2. Menu Items List
                _buildMenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'Delivery Campus & Collection Point',
                  onTap: () => ChangeLocationDialog.show(context),
                ),
                _buildMenuItem(
                  icon: Icons.history_rounded,
                  title: AppStrings.orderHistory,
                  onTap: () => Get.toNamed(AppRoutes.myOrders),
                ),
                _buildMenuItem(
                  icon: Icons.person_outline_rounded,
                  title: AppStrings.personalDetails,
                  onTap: () => _showEditProfileDialog(context, authController),
                ),
                _buildMenuItem(
                  icon: Icons.lock_outline_rounded,
                  title: AppStrings.changeAccount,
                  onTap: () {
                    profileController.showInfoDialog(
                      'Account Security',
                      'Your OneLunch account is secured via Firebase Phone Authentication OTP. No passwords are required.',
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.description_outlined,
                  title: AppStrings.terms,
                  onTap: () {
                    profileController.showInfoDialog(
                      'Terms and Conditions',
                      'OneLunch is operated by Rinus Food Products. Daily lunch orders must be placed before the cutoff time (11:30 AM). All meals are freshly prepared and dispatched for hot delivery.',
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.shield_outlined,
                  title: AppStrings.privacy,
                  onTap: () {
                    profileController.showInfoDialog(
                      'Privacy Policy',
                      'Your data is protected and secured under Rinus Food Products. Mobile numbers are used exclusively for OTP verification and order delivery updates.',
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.headset_mic_outlined,
                  title: 'Customer Support',
                  onTap: profileController.openCustomerSupport,
                ),

                const SizedBox(height: 28),

                // 3. Logout Button (Forest Green Pill Button)
                CustomButton(
                  text: AppStrings.logout,
                  icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                  onPressed: profileController.confirmLogout,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );

    if (isTab) return content;
    return Scaffold(
      backgroundColor: AppColors.creamBg,
      appBar: const CustomHeader(
        title: AppStrings.profile,
        showBackButton: true,
        showCart: false,
      ),
      body: content,
    );
  }
}

