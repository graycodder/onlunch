import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/constants.dart';
import '../../../models/corporate_models.dart';
import '../../../providers/lunch_order_provider.dart';

class CollectionPointPicker extends StatelessWidget {
  final LunchOrderProvider provider;
  final VoidCallback onLocationChanged;

  const CollectionPointPicker({
    super.key,
    required this.provider,
    required this.onLocationChanged,
  });

  void _showPickerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Delivery Location',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                'Choose your corporate office and delivery collection point',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              // 1. Corporate Office Dropdown
              Text(
                'Corporate Company / Office',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                  color: AppColors.background,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Corporate>(
                    isExpanded: true,
                    value: provider.selectedCorporate,
                    hint: Text('Select Corporate Office', style: GoogleFonts.poppins(fontSize: 13)),
                    items: provider.corporates.map((corp) {
                      return DropdownMenuItem<Corporate>(
                        value: corp,
                        child: Text(
                          corp.companyName,
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                    onChanged: (c) {
                      if (c != null) {
                        provider.setCorporate(c);
                        Navigator.of(ctx).pop();
                        _showPickerModal(context);
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 2. Collection Point Dropdown
              Text(
                'Drop-Off / Collection Point',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                  color: AppColors.background,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<CollectionPoint>(
                    isExpanded: true,
                    value: provider.selectedCollectionPoint,
                    hint: Text('Select Drop-off Point', style: GoogleFonts.poppins(fontSize: 13)),
                    items: provider.collectionPoints.map((cp) {
                      return DropdownMenuItem<CollectionPoint>(
                        value: cp,
                        child: Text(
                          '${cp.name} (${cp.deliveryTime})',
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                    onChanged: (cp) {
                      if (cp != null) {
                        provider.setCollectionPoint(cp);
                        onLocationChanged();
                        Navigator.of(ctx).pop();
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    onLocationChanged();
                    Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Confirm Location', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final corp = provider.selectedCorporate;
    final cp = provider.selectedCollectionPoint;

    return GestureDetector(
      onTap: () => _showPickerModal(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: const BoxDecoration(
                color: AppColors.logoGold,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_on_rounded, color: AppColors.darkGreen, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          corp?.companyName ?? 'Select Corporate Office',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 18),
                    ],
                  ),
                  Text(
                    cp != null ? '${cp.name} • Arrives ${cp.deliveryTime}' : 'Tap to choose collection point',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.8),
                    ),
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

