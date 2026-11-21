import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../config/constants.dart';
import '../../models/weekly_booking.dart';
import '../../providers/lunch_order_provider.dart';
import '../../services/firebase_service.dart';
import '../../services/lunch_ordering_service.dart';

class WeeklyBookingScreen extends StatefulWidget {
  final LunchOrderProvider provider;
  final String customerName;
  final String customerPhone;
  final String customerEmail;

  const WeeklyBookingScreen({
    super.key,
    required this.provider,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail = '',
  });

  @override
  State<WeeklyBookingScreen> createState() => _WeeklyBookingScreenState();
}

class _WeeklyBookingScreenState extends State<WeeklyBookingScreen> {
  final Set<String> _selectedDates = {};
  String _mealType = 'VEG';
  String _ricePortion = 'REGULAR';
  int _mealsPerDay = 1;
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _preselectUpcomingWorkweek();
  }

  void _preselectUpcomingWorkweek() {
    final now = TimezoneHelper.getKolkataNow();
    DateTime cur = now.add(const Duration(days: 1));
    int added = 0;
    while (added < 5) {
      if (cur.weekday != DateTime.saturday && cur.weekday != DateTime.sunday) {
        _selectedDates.add(DateFormat('yyyy-MM-dd').format(cur));
        added++;
      }
      cur = cur.add(const Duration(days: 1));
    }
  }

  List<DateTime> _generateUpcomingDays() {
    final now = TimezoneHelper.getKolkataNow();
    final List<DateTime> list = [];
    DateTime cur = now.add(const Duration(days: 1));
    for (int i = 0; i < 28; i++) {
      if (cur.weekday != DateTime.saturday && cur.weekday != DateTime.sunday) {
        list.add(cur);
      }
      cur = cur.add(const Duration(days: 1));
    }
    return list;
  }

  void _onToggleDate(String dateStr) {
    setState(() {
      if (_selectedDates.contains(dateStr)) {
        if (_selectedDates.length > 1) {
          _selectedDates.remove(dateStr);
        }
      } else {
        _selectedDates.add(dateStr);
      }
    });
  }

  void _onConfirmBooking() async {
    if (_selectedDates.isEmpty) {
      setState(() => _errorText = 'Please select at least 1 delivery date.');
      return;
    }

    final corp = widget.provider.selectedCorporate;
    final cp = widget.provider.selectedCollectionPoint;
    if (corp == null || cp == null) {
      setState(() => _errorText = 'Please select your corporate office and collection point.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      final sortedDates = _selectedDates.toList()..sort();
      final firstDate = sortedDates.first;
      final wbId = LunchOrderingService().generateWeeklyBookingId(firstDate);
      final now = DateTime.now().toIso8601String();
      final settings = widget.provider.settings;

      final unitPrice = _mealType == 'VEG'
          ? (settings.vegLunchPrice ?? settings.corporateLunchPrice)
          : (settings.nonVegLunchPrice ?? settings.corporateLunchPrice);

      final totalDays = sortedDates.length;
      final totalMeals = totalDays * _mealsPerDay;
      final totalAmount = totalMeals * unitPrice;
      final paymentId = 'PAY-$wbId';

      final List<String> childOrderIds = [];

      // Create child daily orders for each selected date
      widget.provider.setMealType(_mealType);
      widget.provider.setRiceQuantity(_ricePortion);
      for (final dateStr in sortedDates) {
        final pricing = LunchOrderingService().calculatePricing(
          settings: settings,
          mealType: _mealType,
          selectedAddons: [],
          paidQuantity: _mealsPerDay,
        );

        final snapshot = widget.provider.buildSnapshot();

        final order = await LunchOrderingService().createDailyOrder(
          customerId: 'user_${widget.customerPhone}',
          customerName: widget.customerName,
          customerMobile: widget.customerPhone,
          customerEmail: widget.customerEmail,
          corporate: corp,
          collectionPoint: cp,
          lunchDate: dateStr,
          meal: snapshot,
          pricing: pricing,
          paymentMethod: 'COD',
          paymentStatus: 'PENDING',
          orderStatus: 'CONFIRMED',
        );

        childOrderIds.add(order.orderId);
      }

      // Create parent weekly booking record
      final booking = WeeklyBooking(
        weeklyBookingId: wbId,
        customerId: 'user_${widget.customerPhone}',
        customerName: widget.customerName,
        customerMobile: widget.customerPhone,
        customerEmail: widget.customerEmail,
        corporateId: corp.corporateId,
        corporateName: corp.companyName,
        collectionPointId: cp.collectionPointId,
        collectionPointName: cp.name,
        bookingDates: sortedDates,
        childOrderIds: childOrderIds,
        totalDays: totalDays,
        mealsPerDay: _mealsPerDay,
        totalMeals: totalMeals,
        totalAmount: totalAmount,
        paymentId: paymentId,
        paymentMethod: 'COD',
        paymentStatus: 'PENDING',
        status: 'CONFIRMED',
        createdAt: now,
        updatedAt: now,
      );

      await FirebaseService().weeklyBookingRef(wbId).set(booking.toMap());

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 54),
              const SizedBox(height: 14),
              Text(
                'Weekly Pass Confirmed!',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Booking ID: $wbId',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
              ),
              const SizedBox(height: 8),
              Text(
                'You have booked $totalMeals lunches across $totalDays working days. Deliveries will arrive at ${cp.name} daily by 12:30 PM.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorText = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final upcomingDays = _generateUpcomingDays();
    final settings = widget.provider.settings;
    final unitPrice = _mealType == 'VEG'
        ? (settings.vegLunchPrice ?? settings.corporateLunchPrice)
        : (settings.nonVegLunchPrice ?? settings.corporateLunchPrice);

    final totalDays = _selectedDates.length;
    final totalMeals = totalDays * _mealsPerDay;
    final totalAmount = totalMeals * unitPrice;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Weekly Lunch Booking',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Intro Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.darkGreen, AppColors.primaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.date_range_rounded, color: AppColors.logoGold, size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Multi-Day Office Pass',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Select your working days for the upcoming weeks. Cancel or update anytime.',
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Select Delivery Dates
            Text(
              'Select Delivery Dates ($totalDays days selected)',
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: upcomingDays.map((dt) {
                final dateStr = DateFormat('yyyy-MM-dd').format(dt);
                final isSelected = _selectedDates.contains(dateStr);
                final dayName = DateFormat('EEE').format(dt);
                final dateNum = DateFormat('dd MMM').format(dt);

                return GestureDetector(
                  onTap: () => _onToggleDate(dateStr),
                  child: Container(
                    width: 76,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryGreen : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryGreen : AppColors.borderLight,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          dayName,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.logoGold : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateNum,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Default Meal Selection
            Text(
              'Default Meal Type',
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _mealType = 'VEG'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _mealType == 'VEG' ? Colors.green.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _mealType == 'VEG' ? AppColors.vegGreen : AppColors.borderLight,
                          width: _mealType == 'VEG' ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '🟢 Veg Sadya',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _mealType == 'VEG' ? AppColors.vegGreen : AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _mealType = 'NON_VEG'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _mealType == 'NON_VEG' ? Colors.red.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _mealType == 'NON_VEG' ? AppColors.nonVegRed : AppColors.borderLight,
                          width: _mealType == 'NON_VEG' ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '🔴 Non-Veg Meal',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _mealType == 'NON_VEG' ? AppColors.nonVegRed : AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Text(
              'Rice Portion',
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _ricePortion = 'REGULAR'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _ricePortion == 'REGULAR' ? AppColors.primaryGreen : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _ricePortion == 'REGULAR' ? AppColors.primaryGreen : AppColors.borderLight),
                      ),
                      child: Center(
                        child: Text(
                          'Regular Rice',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _ricePortion == 'REGULAR' ? Colors.white : AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _ricePortion = 'LESS'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _ricePortion == 'LESS' ? AppColors.primaryGreen : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _ricePortion == 'LESS' ? AppColors.primaryGreen : AppColors.borderLight),
                      ),
                      child: Center(
                        child: Text(
                          'Less Rice (Light)',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _ricePortion == 'LESS' ? Colors.white : AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Meals Per Day Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Meals Per Day',
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _mealsPerDay > 1 ? () => setState(() => _mealsPerDay--) : null,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.primaryGreen),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '$_mealsPerDay',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _mealsPerDay++),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.add_circle, color: AppColors.primaryGreen),
                    ),
                  ],
                ),
              ],
            ),

            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorText!,
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.nonVegRed),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
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
                    'Weekly Total ($totalMeals Meals)',
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  Text(
                    '₹${totalAmount.toStringAsFixed(0)}',
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
                    onPressed: _isSubmitting ? null : _onConfirmBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                          )
                        : Text('Confirm Weekly Booking', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
