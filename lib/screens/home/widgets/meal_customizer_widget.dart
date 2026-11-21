import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/constants.dart';
import '../../../providers/lunch_order_provider.dart';

class MealCustomizerWidget extends StatelessWidget {
  final LunchOrderProvider provider;

  const MealCustomizerWidget({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final settings = provider.settings;
    final isVeg = provider.mealType == 'VEG';
    final pricing = provider.currentPricing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. MEAL TYPE SELECTOR: VEG vs NON-VEG
        Text(
          'Select Meal Type',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Veg Option Card
            Expanded(
              child: GestureDetector(
                onTap: () => provider.setMealType('VEG'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  decoration: BoxDecoration(
                    color: isVeg ? Colors.green.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isVeg ? AppColors.vegGreen : AppColors.borderLight,
                      width: isVeg ? 2.0 : 1.0,
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
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.vegGreen, width: 1.5),
                        ),
                        child: const Center(
                          child: Icon(Icons.circle, size: 9, color: AppColors.vegGreen),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Veg Sadya',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isVeg ? AppColors.vegGreen : AppColors.textDark,
                              ),
                            ),
                            Text(
                              '₹${(settings.vegLunchPrice ?? settings.corporateLunchPrice).toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Non-Veg Option Card
            Expanded(
              child: GestureDetector(
                onTap: () => provider.setMealType('NON_VEG'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  decoration: BoxDecoration(
                    color: !isVeg ? Colors.red.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: !isVeg ? AppColors.nonVegRed : AppColors.borderLight,
                      width: !isVeg ? 2.0 : 1.0,
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
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.nonVegRed, width: 1.5),
                        ),
                        child: const Center(
                          child: Icon(Icons.circle, size: 9, color: AppColors.nonVegRed),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Non-Veg Meal',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: !isVeg ? AppColors.nonVegRed : AppColors.textDark,
                              ),
                            ),
                            Text(
                              '₹${(settings.nonVegLunchPrice ?? settings.corporateLunchPrice).toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 2. RICE PORTION (Regular vs Less)
        Text(
          'Rice Portion',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildChoiceChip(
              label: 'Regular Rice (Standard)',
              isSelected: provider.riceQuantity == 'REGULAR',
              onTap: () => provider.setRiceQuantity('REGULAR'),
            ),
            const SizedBox(width: 10),
            _buildChoiceChip(
              label: 'Less Rice (Light)',
              isSelected: provider.riceQuantity == 'LESS',
              onTap: () => provider.setRiceQuantity('LESS'),
            ),
          ],
        ),

        // 3. GRAVY SELECTION (if available)
        if (provider.gravyOptions.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Gravy / Chaaru',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: provider.gravyOptions.map((gravy) {
              final isSel = provider.selectedGravyId == gravy.optionId;
              return _buildChoiceChip(
                label: gravy.name + (gravy.price > 0 ? ' (+₹${gravy.price.toInt()})' : ''),
                isSelected: isSel,
                onTap: () => provider.setGravy(gravy.optionId),
              );
            }).toList(),
          ),
        ],

        // 4. FRY SELECTION (if available)
        if (provider.fryOptions.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Fry / Mezhukkupuratti',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: provider.fryOptions.map((fry) {
              final isSel = provider.selectedFryId == fry.optionId;
              return _buildChoiceChip(
                label: fry.name + (fry.price > 0 ? ' (+₹${fry.price.toInt()})' : ''),
                isSelected: isSel,
                onTap: () => provider.setFry(fry.optionId),
              );
            }).toList(),
          ),
        ],

        // 5. CURRY SELECTION (if available)
        if (provider.curryOptions.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Special Curry',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: provider.curryOptions.map((curry) {
              final isSel = provider.selectedCurryId == curry.optionId;
              return _buildChoiceChip(
                label: curry.name + (curry.price > 0 ? ' (+₹${curry.price.toInt()})' : ''),
                isSelected: isSel,
                onTap: () => provider.setCurry(curry.optionId),
              );
            }).toList(),
          ),
        ],

        // 6. ADD-ONS LIST
        if (provider.addonOptions.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Add-ons & Sides',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: provider.addonOptions.map((addon) {
              final isChecked = provider.selectedAddonIds.contains(addon.optionId);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isChecked ? AppColors.primaryGreen : AppColors.borderLight,
                    width: isChecked ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      activeColor: AppColors.primaryGreen,
                      onChanged: (_) => provider.toggleAddon(addon.optionId),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            addon.name,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          if (addon.description != null && addon.description!.isNotEmpty)
                            Text(
                              addon.description!,
                              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '+₹${addon.price.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],

        const SizedBox(height: 20),

        // 7. QUANTITY SELECTOR & PROMOTION BADGE
        Container(
          padding: const EdgeInsets.all(16),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Number of Meals',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          'For your office team or colleagues',
                          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: provider.paidQuantity > 1
                            ? () => provider.setPaidQuantity(provider.paidQuantity - 1)
                            : null,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.primaryGreen, size: 28),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '${provider.paidQuantity}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => provider.setPaidQuantity(provider.paidQuantity + 1),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.add_circle, color: AppColors.primaryGreen, size: 28),
                      ),
                    ],
                  ),
                ],
              ),

              // Promotion Callout: "Order 20 Meals, Get 1 Free!"
              if (settings.promotionEnabled) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.logoGold.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.logoGold),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.celebration_rounded, color: AppColors.logoOrange, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          pricing.freeQuantity > 0
                              ? 'Order ${settings.promotionBuyQuantity} Meals, Get ${settings.promotionFreeQuantity} Free! 🎉 You get ${pricing.freeQuantity} free meal(s)!'
                              : 'Order ${settings.promotionBuyQuantity} Meals, Get ${settings.promotionFreeQuantity} Free! Add ${settings.promotionBuyQuantity - (provider.paidQuantity % settings.promotionBuyQuantity)} more to unlock!',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}
