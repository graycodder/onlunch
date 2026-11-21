import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/constants.dart';
import '../../models/corporate_lunch_order.dart';
import '../../providers/lunch_order_provider.dart';
import '../../services/auth_service.dart';
import '../../services/lunch_ordering_service.dart';
import '../corporate_enquiry/corporate_enquiry_screen.dart';
import '../orders/my_orders_screen.dart';
import '../profile/profile_screen.dart';
import '../weekly/weekly_booking_screen.dart';
import 'widgets/collection_point_picker.dart';
import 'widgets/meal_customizer_widget.dart';
import 'widgets/order_summary_bottom_sheet.dart';

class DailyOrderScreen extends StatefulWidget {
  const DailyOrderScreen({super.key});

  @override
  State<DailyOrderScreen> createState() => _DailyOrderScreenState();
}

class _DailyOrderScreenState extends State<DailyOrderScreen> {
  late final LunchOrderProvider _orderProvider;
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _orderProvider = LunchOrderProvider();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final profile = await AuthService().getCachedUserProfile();
    if (mounted) {
      setState(() => _userProfile = profile);
    }
  }

  void _onLocationSaved() {
    if (_userProfile != null) {
      final corp = _orderProvider.selectedCorporate;
      final cp = _orderProvider.selectedCollectionPoint;
      if (corp != null && cp != null) {
        AuthService().saveUserProfile(
          phone: _userProfile!['phone'] ?? '',
          name: _userProfile!['name'] ?? '',
          email: _userProfile!['email'] ?? '',
          defaultCorporateId: corp.corporateId,
          defaultCorporateName: corp.companyName,
          defaultCollectionPointId: cp.collectionPointId,
          defaultCollectionPointName: cp.name,
        );
      }
    }
    setState(() {});
  }

  void _showOrderSuccessDialog(CorporateLunchOrder order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 38),
            ),
            const SizedBox(height: 16),
            Text(
              'Order Confirmed!',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Order #${order.orderId}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your lunch delivery for ${order.lunchDate} has been confirmed. It will arrive at ${order.collectionPointName} by 12:30 PM.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MyOrdersScreen(
                        customerMobile: _userProfile?['phone'] ?? '',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('View My Orders', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customerName = _userProfile?['name'] ?? 'Colleague';
    final customerPhone = _userProfile?['phone'] ?? '';
    final customerEmail = _userProfile?['email'] ?? '';

    return AnimatedBuilder(
      animation: _orderProvider,
      builder: (context, _) {
        final settings = _orderProvider.settings;
        final cutoffTime = settings.lunchOrderCutoffTime;
        final isTomorrowLocked = TimezoneHelper.isTomorrowOrderingClosed(cutoffTime);
        final pricing = _orderProvider.currentPricing;

        return Scaffold(
          backgroundColor: AppColors.background,
          drawer: _buildAppDrawer(context),
          body: CustomScrollView(
            slivers: [
              // 1. IMMERSIVE TOP APP BAR & LOCATION BANNER (Rich Forest Green)
              SliverAppBar(
                expandedHeight: 180,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.primaryGreen,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.darkGreen, AppColors.primaryGreen],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 50, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Greeting Row with Rinus Logo Badge
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.logoGold, width: 1.5),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(9),
                                child: Image.asset(
                                  'assets/images/rinus_logo_badge.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.restaurant_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome, $customerName',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Fresh authentic Kerala meals at your office',
                                    maxLines: 1,
                                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Delivery Location Picker Banner
                        CollectionPointPicker(
                          provider: _orderProvider,
                          onLocationChanged: _onLocationSaved,
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.receipt_long_rounded, color: Colors.white),
                    tooltip: 'My Orders',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MyOrdersScreen(customerMobile: customerPhone),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.date_range_rounded, color: AppColors.logoGold),
                    tooltip: 'Weekly Booking',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => WeeklyBookingScreen(
                            provider: _orderProvider,
                            customerName: customerName,
                            customerPhone: customerPhone,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // 2. MAIN BODY CONTENT
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CUTOFF & AVAILABILITY STATUS CARD
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isTomorrowLocked ? Colors.amber.shade300 : Colors.green.shade200,
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
                                color: isTomorrowLocked ? Colors.amber.shade50 : Colors.green.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isTomorrowLocked ? Icons.lock_clock_rounded : Icons.check_circle_rounded,
                                color: isTomorrowLocked ? Colors.amber.shade800 : AppColors.vegGreen,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Delivery Date: ${_orderProvider.selectedLunchDate}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  Text(
                                    isTomorrowLocked
                                        ? 'Ordering for tomorrow is closed (Cutoff was $cutoffTime IST). Ordering for ${_orderProvider.selectedLunchDate}.'
                                        : 'Ordering open for tomorrow until $cutoffTime IST tonight.',
                                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // WEEKLY BOOKING PROMO BANNER
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => WeeklyBookingScreen(
                                provider: _orderProvider,
                                customerName: customerName,
                                customerPhone: customerPhone,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF03260E), Color(0xFF074620)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.logoGold,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'WEEKLY PASS',
                                        style: GoogleFonts.poppins(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.darkGreen,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Book for the Entire Week',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Lock your daily lunch delivered hassle-free Mon-Fri',
                                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // MEAL CUSTOMIZER (VEG / NON-VEG, RICE, GRAVY, ADD-ONS, QUANTITY)
                      MealCustomizerWidget(provider: _orderProvider),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // BOTTOM CHECKOUT BAR
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
            child: SafeArea(
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Price',
                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      Text(
                        '₹${pricing.totalAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          OrderSummaryBottomSheet.show(
                            context,
                            provider: _orderProvider,
                            customerName: customerName,
                            customerPhone: customerPhone,
                            customerEmail: customerEmail,
                            onOrderPlaced: (order) => _showOrderSuccessDialog(order),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Proceed to Checkout',
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
            color: AppColors.primaryGreen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.logoGold, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset('assets/images/rinus_logo_badge.png', fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppConstants.appName,
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'By ${AppConstants.companyName}',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.logoGold),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lunch_dining_rounded, color: AppColors.primaryGreen),
            title: Text('Daily Ordering', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            leading: const Icon(Icons.date_range_rounded, color: AppColors.primaryGreen),
            title: Text('Weekly Bookings', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WeeklyBookingScreen(
                    provider: _orderProvider,
                    customerName: _userProfile?['name'] ?? 'Colleague',
                    customerPhone: _userProfile?['phone'] ?? '',
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_rounded, color: AppColors.primaryGreen),
            title: Text('My Orders & History', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MyOrdersScreen(customerMobile: _userProfile?['phone'] ?? ''),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.business_rounded, color: AppColors.logoOrange),
            title: Text('Register New Corporate Office', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CorporateEnquiryScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_rounded, color: AppColors.primaryGreen),
            title: Text('My Profile', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          const Spacer(),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'OneLunch v1.0.0\nRinus Food Products',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
