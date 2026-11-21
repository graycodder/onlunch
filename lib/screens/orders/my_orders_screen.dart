import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/constants.dart';
import '../../models/corporate_lunch_order.dart';
import '../../services/auth_service.dart';
import '../../services/lunch_ordering_service.dart';
import 'order_tracking_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  final String? customerMobile;

  const MyOrdersScreen({super.key, this.customerMobile});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _mobile = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initMobile();
  }

  void _initMobile() async {
    if (widget.customerMobile != null && widget.customerMobile!.isNotEmpty) {
      setState(() => _mobile = widget.customerMobile!);
    } else {
      final cached = await AuthService().getCachedUserProfile();
      if (mounted && cached != null) {
        setState(() => _mobile = cached['phone'] ?? '');
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'My Lunch Orders',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.logoGold,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Confirmed Orders'),
            Tab(text: 'Payment Pending'),
          ],
        ),
      ),
      body: _mobile.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : StreamBuilder<List<CorporateLunchOrder>>(
              stream: LunchOrderingService().streamCustomerOrders(_mobile),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
                }

                final allOrders = snapshot.data ?? [];

                final confirmedOrders = allOrders
                    .where((o) => o.orderStatus == 'CONFIRMED' || o.paymentStatus == 'PAID')
                    .toList();
                final pendingOrders = allOrders
                    .where((o) => o.orderStatus == 'PENDING_PAYMENT' && o.paymentStatus == 'PENDING')
                    .toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOrdersList(confirmedOrders, isPending: false),
                    _buildOrdersList(pendingOrders, isPending: true),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildOrdersList(List<CorporateLunchOrder> orders, {required bool isPending}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPending ? Icons.check_circle_outline_rounded : Icons.restaurant_rounded,
              size: 54,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              isPending ? 'No pending orders' : 'No confirmed orders yet',
              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order, isPending);
      },
    );
  }

  Widget _buildOrderCard(CorporateLunchOrder order, bool isPending) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order.orderId}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'For Date: ${order.lunchDate}',
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPending ? Colors.amber.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isPending ? 'PENDING' : order.deliveryStatus,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isPending ? Colors.amber.shade800 : AppColors.vegGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Order Details
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${order.meal.mealTypeName} (${order.meal.riceQuantityName}) x ${order.totalQuantity} meal(s)',
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                ),
                Text(
                  'Destination: ${order.corporateName} • ${order.collectionPointName}',
                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ₹${order.totalAmount.toStringAsFixed(0)} (${order.paymentMethod})',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    if (isPending)
                      ElevatedButton(
                        onPressed: () async {
                          // Switch to COD
                          final cps = await LunchOrderingService().streamCollectionPoints().first;
                          if (cps.isEmpty) return;
                          final matchCp = cps.firstWhere(
                            (c) => c.collectionPointId == order.collectionPointId,
                            orElse: () => cps.first,
                          );
                          await LunchOrderingService().switchOrderToCod(order.orderId, matchCp);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Switched to Cash on Delivery successfully!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.logoOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: Text(
                          'Switch to COD',
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      )
                    else
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => OrderTrackingScreen(order: order),
                            ),
                          );
                        },
                        icon: const Icon(Icons.near_me_rounded, size: 16, color: AppColors.primaryGreen),
                        label: Text(
                          'Track',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
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
        ],
      ),
    );
  }
}
