import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/constants.dart';
import '../../../models/corporate_lunch_order.dart';
import '../../../providers/lunch_order_provider.dart';
import '../../../services/cashfree_payment_service.dart';

class OrderSummaryBottomSheet extends StatefulWidget {
  final LunchOrderProvider provider;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final Function(CorporateLunchOrder order) onOrderPlaced;

  const OrderSummaryBottomSheet({
    super.key,
    required this.provider,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail = '',
    required this.onOrderPlaced,
  });

  static void show(
    BuildContext context, {
    required LunchOrderProvider provider,
    required String customerName,
    required String customerPhone,
    String customerEmail = '',
    required Function(CorporateLunchOrder order) onOrderPlaced,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OrderSummaryBottomSheet(
        provider: provider,
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: customerEmail,
        onOrderPlaced: onOrderPlaced,
      ),
    );
  }

  @override
  State<OrderSummaryBottomSheet> createState() => _OrderSummaryBottomSheetState();
}

class _OrderSummaryBottomSheetState extends State<OrderSummaryBottomSheet> {
  String _selectedPaymentMethod = 'CASHFREE'; // "CASHFREE" | "COD"
  bool _isProcessing = false;
  String? _errorMessage;

  void _onCheckout() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    final provider = widget.provider;
    final isCod = _selectedPaymentMethod == 'COD';

    final order = await provider.placeOrder(
      customerId: 'user_${widget.customerPhone}',
      customerName: widget.customerName,
      customerMobile: widget.customerPhone,
      customerEmail: widget.customerEmail,
      paymentMethod: _selectedPaymentMethod,
    );

    if (order == null) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _errorMessage = provider.errorMessage ?? 'Failed to place order';
      });
      return;
    }

    if (isCod) {
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onOrderPlaced(order);
    } else {
      // Cashfree Online Payment Session via Cloud Functions proxy
      final cashfreeRes = await CashfreePaymentService().createPaymentSession(
        orderId: order.orderId,
        orderAmount: order.totalAmount,
        customerId: order.customerId,
        customerPhone: order.customerMobile,
        customerName: order.customerName,
        customerEmail: order.customerEmail,
      );

      if (!mounted) return;

      if (cashfreeRes.success && cashfreeRes.paymentSessionId != null) {
        final env = provider.settings.cashfreeEnvironment;

        await CashfreePaymentService().startCheckout(
          orderId: order.orderId,
          paymentSessionId: cashfreeRes.paymentSessionId!,
          environment: env,
          onVerify: (verifiedOrderId) async {
            debugPrint('Cashfree payment completed for order $verifiedOrderId');
            await CashfreePaymentService().recordPaymentSuccess(
              order: order,
              referenceId: verifiedOrderId,
            );
            if (!mounted) return;
            Navigator.of(context).pop();
            widget.onOrderPlaced(order);
          },
          onError: (error) {
            debugPrint('Cashfree payment failed: $error');
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Payment cancelled or failed. Order placed as Pending.',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                backgroundColor: AppColors.nonVegRed,
                duration: const Duration(seconds: 4),
              ),
            );
            Navigator.of(context).pop();
            widget.onOrderPlaced(order);
          },
        );
      } else {
        setState(() {
          _isProcessing = false;
          _errorMessage = cashfreeRes.errorMessage ?? 'Could not initialize payment gateway';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final pricing = provider.currentPricing;
    final settings = provider.settings;
    final corp = provider.selectedCorporate;
    final cp = provider.selectedCollectionPoint;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Order Breakdown',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          Text(
            'Delivery to ${corp?.companyName ?? ''} • ${cp?.name ?? ''}',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // Itemized Line Items
          _buildSummaryRow(
            label: '${provider.mealType == "VEG" ? "Veg Sadya" : "Non-Veg Meal"} (x${pricing.paidQuantity})',
            value: '₹${(pricing.unitPrice * pricing.paidQuantity).toStringAsFixed(0)}',
          ),

          if (pricing.addOnPrice > 0)
            _buildSummaryRow(
              label: 'Selected Add-ons (x${pricing.paidQuantity})',
              value: '+₹${(pricing.addOnPrice * pricing.paidQuantity).toStringAsFixed(0)}',
              isAccent: true,
            ),

          if (pricing.freeQuantity > 0)
            _buildSummaryRow(
              label: 'Free Promo Meals (20+1 Offer)',
              value: '+${pricing.freeQuantity} FREE',
              valueColor: AppColors.vegGreen,
            ),

          if (pricing.discountPerMeal > 0)
            _buildSummaryRow(
              label: 'Introductory Special Discount',
              value: '-₹${(pricing.discountPerMeal * pricing.paidQuantity).toStringAsFixed(0)}',
              valueColor: AppColors.vegGreen,
            ),

          _buildSummaryRow(
            label: 'Delivery Fee',
            value: 'FREE (Corporate Drop-Off)',
            valueColor: AppColors.primaryGreen,
          ),

          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),

          // Grand Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Payable Amount',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    '${pricing.totalQuantity} total meals for ${provider.selectedLunchDate}',
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
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

          const SizedBox(height: 20),

          // Payment Method Selector
          Text(
            'Select Payment Method',
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              if (settings.enableCashfreePayment)
                Expanded(
                  child: _buildPaymentMethodTile(
                    title: 'Online Pay',
                    subtitle: 'UPI / Cards',
                    icon: Icons.credit_card_rounded,
                    isSelected: _selectedPaymentMethod == 'CASHFREE',
                    onTap: () => setState(() => _selectedPaymentMethod = 'CASHFREE'),
                  ),
                ),
              if (settings.enableCashfreePayment && settings.enableCodPayment)
                const SizedBox(width: 10),
              if (settings.enableCodPayment)
                Expanded(
                  child: _buildPaymentMethodTile(
                    title: 'Cash on Delivery',
                    subtitle: 'Pay at Desk',
                    icon: Icons.payments_outlined,
                    isSelected: _selectedPaymentMethod == 'COD',
                    onTap: () => setState(() => _selectedPaymentMethod = 'COD'),
                  ),
                ),
            ],
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.nonVegRed),
            ),
          ],

          const SizedBox(height: 24),

          // Pay Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _selectedPaymentMethod == 'COD'
                          ? 'Confirm COD Order • ₹${pricing.totalAmount.toStringAsFixed(0)}'
                          : 'Pay with Cashfree • ₹${pricing.totalAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    Color? valueColor,
    bool isAccent = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isAccent ? AppColors.textDark : AppColors.textSecondary,
              fontWeight: isAccent ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.borderLight,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primaryGreen : AppColors.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
