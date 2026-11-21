import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/company_model.dart';
import '../../../data/models/collection_point_model.dart';
import '../../../data/repositories/company_repository.dart';
import '../../../data/repositories/collection_point_repository.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../common/widgets/custom_button.dart';

class ChangeLocationDialog extends StatefulWidget {
  const ChangeLocationDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ChangeLocationDialog(),
    );
  }

  @override
  State<ChangeLocationDialog> createState() => _ChangeLocationDialogState();
}

class _ChangeLocationDialogState extends State<ChangeLocationDialog> {
  final CompanyRepository _companyRepo = CompanyRepository();
  final CollectionPointRepository _cpRepo = CollectionPointRepository();

  List<CompanyModel> _companies = [];
  List<CollectionPointModel> _collectionPoints = [];

  CompanyModel? _selectedCompany;
  CollectionPointModel? _selectedPoint;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final auth = Get.find<AuthController>();
    final currentCompId = auth.currentUser.value?.defaultCompanyId ?? '';
    final currentCpId = auth.currentUser.value?.defaultCollectionPointId ?? '';

    final comps = await _companyRepo.getActiveCompanies();
    setState(() {
      _companies = comps;
      if (comps.isNotEmpty) {
        _selectedCompany = comps.firstWhere(
          (c) => c.id == currentCompId,
          orElse: () => comps.first,
        );
      }
    });

    if (_selectedCompany != null) {
      final points = await _cpRepo.getActivePointsForCompany(_selectedCompany!.id);
      setState(() {
        _collectionPoints = points;
        if (points.isNotEmpty) {
          _selectedPoint = points.firstWhere(
            (p) => p.id == currentCpId,
            orElse: () => points.first,
          );
        }
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _onCompanySelected(CompanyModel company) async {
    setState(() {
      _selectedCompany = company;
      _isLoading = true;
      _selectedPoint = null;
    });

    final points = await _cpRepo.getActivePointsForCompany(company.id);
    setState(() {
      _collectionPoints = points;
      if (points.isNotEmpty) {
        _selectedPoint = points.first;
      }
      _isLoading = false;
    });
  }

  void _saveLocation() async {
    if (_selectedCompany == null || _selectedPoint == null) {
      Get.snackbar('Select Location', 'Please select both your company and collection point');
      return;
    }

    final auth = Get.find<AuthController>();
    await auth.updateDeliveryLocation(
      companyId: _selectedCompany!.id,
      companyName: _selectedCompany!.name,
      collectionPointId: _selectedPoint!.id,
      collectionPointName: _selectedPoint!.name,
      deliveryTime: _selectedPoint!.deliveryTime,
      deliveryAddress: _selectedPoint!.address,
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: _isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Delivery Location',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Corporate Campus & Collection Point',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Step 1: Select Company
                  Text(
                    '1. Select Company / Tech Park',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.creamBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<CompanyModel>(
                        value: _selectedCompany,
                        isExpanded: true,
                        icon: const Icon(Icons.business_rounded, color: AppColors.primaryGreen),
                        items: _companies.map((c) {
                          return DropdownMenuItem<CompanyModel>(
                            value: c,
                            child: Text(
                              c.name,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (comp) {
                          if (comp != null) _onCompanySelected(comp);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Step 2: Select Collection Point
                  Text(
                    '2. Select Collection Point',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (_collectionPoints.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'No active collection points configured for this company yet.',
                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.amber.shade900),
                      ),
                    )
                  else
                    ..._collectionPoints.map((cp) {
                      final isSelected = _selectedPoint?.id == cp.id;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedPoint = cp),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.softLightGreen.withOpacity(0.5) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryGreen : AppColors.borderLight,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: isSelected ? AppColors.primaryGreen : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cp.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      cp.address,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.schedule, size: 14, color: AppColors.primaryGreen),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Delivery by ${cp.deliveryTime}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primaryGreen,
                                          ),
                                        ),
                                        if (cp.deliveryInstructions.isNotEmpty) ...[
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '• ${cp.deliveryInstructions}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),

                  const SizedBox(height: 20),

                  // Important Note
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.creamBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 18, color: AppColors.primaryGreen),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your saved collection point will be used as default for future lunch deliveries.',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  CustomButton(
                    text: 'Confirm Delivery Location',
                    icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                    onPressed: _saveLocation,
                  ),
                ],
              ),
            ),
    );
  }
}
