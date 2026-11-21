import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/constants.dart';
import '../../services/lunch_ordering_service.dart';

class CorporateEnquiryScreen extends StatefulWidget {
  const CorporateEnquiryScreen({super.key});

  @override
  State<CorporateEnquiryScreen> createState() => _CorporateEnquiryScreenState();
}

class _CorporateEnquiryScreenState extends State<CorporateEnquiryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  final _employeeCountController = TextEditingController();
  final _mealsController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _companyController.dispose();
    _contactPersonController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _employeeCountController.dispose();
    _mealsController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await LunchOrderingService().submitCorporateEnquiry(
        companyName: _companyController.text.trim(),
        contactPerson: _contactPersonController.text.trim(),
        mobile: _mobileController.text.trim(),
        email: _emailController.text.trim(),
        officeLocation: _locationController.text.trim(),
        employeeCount: int.tryParse(_employeeCountController.text.trim()) ?? 50,
        expectedDailyMeals: int.tryParse(_mealsController.text.trim()) ?? 20,
        message: _messageController.text.trim(),
      );

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
                'Enquiry Submitted!',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Thank you for reaching out. The Rinus Food Products corporate team will contact you within 24 hours to set up your office collection point.',
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
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Register Corporate Office',
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
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bring OneLunch to Your Office',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 4),
              Text(
                'Provide your company details below. We set up daily hot lunch drop-offs at zero infrastructure cost to your company.',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Company Name
              _buildField(
                label: 'Company / Organization Name',
                controller: _companyController,
                hint: 'e.g. Infopark Tech Solutions',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),

              // Contact Person
              _buildField(
                label: 'HR / Admin / Contact Person',
                controller: _contactPersonController,
                hint: 'e.g. Anand Kumar',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),

              // Mobile
              _buildField(
                label: 'Official Contact Mobile',
                controller: _mobileController,
                hint: 'e.g. 9876543210',
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                validator: (v) => v == null || v.length != 10 ? 'Enter 10-digit mobile' : null,
              ),

              // Email
              _buildField(
                label: 'Official Email',
                controller: _emailController,
                hint: 'e.g. hr@company.com',
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v == null || !v.contains('@') ? 'Valid email required' : null,
              ),

              // Office Location
              _buildField(
                label: 'Office Building & Campus Area',
                controller: _locationController,
                hint: 'e.g. Phase 2, Infopark, Kakkanad, Kochi',
                validator: (v) => v == null || v.isEmpty ? 'Location required' : null,
              ),

              // Counts Row
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      label: 'Total Staff',
                      controller: _employeeCountController,
                      hint: 'e.g. 150',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      label: 'Expected Daily Meals',
                      controller: _mealsController,
                      hint: 'e.g. 40',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              // Message
              _buildField(
                label: 'Additional Remarks / Timing Requirements',
                controller: _messageController,
                hint: 'e.g. Lunch break is 12:45 PM to 1:30 PM',
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                      : Text('Submit Corporate Enquiry', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    String hint = '',
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMuted),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
            ),
          ),
        ],
      ),
    );
  }
}

