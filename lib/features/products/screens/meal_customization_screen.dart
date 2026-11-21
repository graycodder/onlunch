import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/meal_model.dart';
import '../../../data/models/addon_category_model.dart';
import '../../../data/models/addon_item_model.dart';
import '../../../data/models/meal_customization_model.dart';
import '../../../data/repositories/addon_repository.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../../core/routes/app_routes.dart';

class MealCustomizationScreen extends StatefulWidget {
  const MealCustomizationScreen({super.key});

  @override
  State<MealCustomizationScreen> createState() => _MealCustomizationScreenState();
}

class _MealCustomizationScreenState extends State<MealCustomizationScreen> {
  final AddonRepository _addonRepo = AddonRepository();
  late MealModel _meal;

  String _selectedRice = 'Kerala Matta Rice (Default)';
  String _selectedGravy = 'Authentic Kerala Sambar';

  // Map of addonId -> quantity selected
  final Map<String, int> _selectedAddonQtys = {};
  List<AddonCategoryModel> _categories = [];
  List<AddonItemModel> _allItems = [];
  bool _isLoading = true;
  int _boxQuantity = 1;

  @override
  void initState() {
    super.initState();
    // Retrieve passed meal or fallback default
    if (Get.arguments is MealModel) {
      _meal = Get.arguments as MealModel;
    } else {
      _meal = MealModel(
        id: 'meal_veg',
        name: 'Veg Lunch',
        description: 'Authentic Kerala sadhya meal with rice, sambar, rasam, thoran and pickle.',
        mealType: 'Veg',
        basePrice: 60,
        imageUrl: 'assets/images/meals_veg.png',
      );
    }

    if (_meal.mealType.toLowerCase() == 'non-veg') {
      _selectedGravy = 'Kottayam Fish Curry Gravy';
    }

    _loadAddons();
  }

  void _loadAddons() async {
    final cats = await _addonRepo.getCategoriesStream().first;
    final items = await _addonRepo.getItemsForMeal(_meal.mealType);

    setState(() {
      _categories = cats;
      _allItems = items;
      _isLoading = false;
    });
  }

  double get _addonsSubtotal {
    double sum = 0.0;
    _selectedAddonQtys.forEach((itemId, qty) {
      if (qty > 0) {
        final item = _allItems.firstWhereOrNull((i) => i.id == itemId);
        if (item != null) {
          sum += (item.price * qty);
        }
      }
    });
    return sum;
  }

  double get _singleBoxPrice => _meal.basePrice + _addonsSubtotal;

  double get _finalTotalPrice => _singleBoxPrice * _boxQuantity;

  void _incrementAddon(AddonItemModel item) {
    final current = _selectedAddonQtys[item.id] ?? 0;
    if (current < item.maxQty) {
      setState(() {
        _selectedAddonQtys[item.id] = current + 1;
      });
    } else {
      Get.snackbar('Maximum Limit', 'Maximum ${item.maxQty} portions allowed for ${item.name}');
    }
  }

  void _decrementAddon(AddonItemModel item) {
    final current = _selectedAddonQtys[item.id] ?? 0;
    if (current > 0) {
      setState(() {
        if (current - 1 == 0) {
          _selectedAddonQtys.remove(item.id);
        } else {
          _selectedAddonQtys[item.id] = current - 1;
        }
      });
    }
  }

  void _addToCartAndProceed() {
    final List<SelectedAddonItem> addonsList = [];
    _selectedAddonQtys.forEach((itemId, qty) {
      if (qty > 0) {
        final item = _allItems.firstWhereOrNull((i) => i.id == itemId);
        if (item != null) {
          addonsList.add(SelectedAddonItem(
            addonId: item.id,
            addonName: item.name,
            price: item.price,
            quantity: qty,
            categoryName: item.categoryName,
          ));
        }
      }
    });

    final customizedMeal = MealCustomizationModel(
      configurationId: 'cfg_${DateTime.now().millisecondsSinceEpoch}',
      mealId: _meal.id,
      mealName: _meal.name,
      mealType: _meal.mealType,
      basePrice: _meal.basePrice,
      imageUrl: _meal.imageUrl,
      selectedRice: _selectedRice,
      selectedGravy: _selectedGravy,
      selectedAddons: addonsList,
      mealQuantity: _boxQuantity,
    );

    final cartController = Get.find<CartController>();
    cartController.addCustomizedMeal(customizedMeal);

    Get.toNamed(AppRoutes.cart);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        title: Text(
          'Customize ${_meal.name}',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Meal Header Card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.asset(
                                  _meal.imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 80,
                                    height: 80,
                                    color: AppColors.softLightGreen,
                                    child: const Icon(Icons.restaurant, color: AppColors.primaryGreen),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _meal.isVeg ? Colors.green.shade50 : Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: _meal.isVeg ? Colors.green : Colors.red,
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            _meal.mealType.toUpperCase(),
                                            style: GoogleFonts.poppins(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: _meal.isVeg ? Colors.green.shade800 : Colors.red.shade800,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '₹${_meal.basePrice.toStringAsFixed(0)}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _meal.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      _meal.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // 1. Rice Selection
                        _buildSectionHeader('1. Rice Preference', 'Choose rice for your box (Included)'),
                        const SizedBox(height: 8),
                        _buildRadioOption(
                          title: 'Kerala Matta Rice (Default)',
                          subtitle: 'Traditional boiled red rice',
                          isSelected: _selectedRice.contains('Matta'),
                          onTap: () => setState(() => _selectedRice = 'Kerala Matta Rice (Default)'),
                        ),
                        _buildRadioOption(
                          title: 'White Rice',
                          subtitle: 'Soft steamed ponni white rice',
                          isSelected: _selectedRice.contains('White'),
                          onTap: () => setState(() => _selectedRice = 'White Rice'),
                        ),
                        const SizedBox(height: 18),

                        // 2. Gravy Selection
                        _buildSectionHeader('2. Primary Gravy', 'Select one gravy of your choice (Included)'),
                        const SizedBox(height: 8),
                        _buildRadioOption(
                          title: 'Authentic Kerala Sambar',
                          subtitle: 'Lentil & drumstick vegetable curry',
                          isSelected: _selectedGravy.contains('Sambar'),
                          onTap: () => setState(() => _selectedGravy = 'Authentic Kerala Sambar'),
                        ),
                        _buildRadioOption(
                          title: 'Kottayam Fish Curry Gravy',
                          subtitle: 'Spicy kudampuli fish gravy',
                          isSelected: _selectedGravy.contains('Fish'),
                          onTap: () => setState(() => _selectedGravy = 'Kottayam Fish Curry Gravy'),
                        ),
                        _buildRadioOption(
                          title: 'Seasoned Moru / Pulissery',
                          subtitle: 'Tempered spiced buttermilk curry',
                          isSelected: _selectedGravy.contains('Moru'),
                          onTap: () => setState(() => _selectedGravy = 'Seasoned Moru / Pulissery'),
                        ),
                        const SizedBox(height: 20),

                        // 3. Multi-Select Add-ons Sections
                        ..._categories.where((cat) => cat.id != 'cat_rice' && cat.id != 'cat_gravy').map((cat) {
                          final itemsInCat = _allItems.where((i) => i.categoryId == cat.id).toList();
                          if (itemsInCat.isEmpty) return const SizedBox.shrink();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(
                                cat.name,
                                cat.description.isNotEmpty ? cat.description : 'Select multiple items as you like',
                              ),
                              const SizedBox(height: 8),
                              ...itemsInCat.map((item) => _buildAddonCard(item)),
                              const SizedBox(height: 16),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                // Bottom Sticky Price & Action Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Box: ₹${_singleBoxPrice.toStringAsFixed(0)} '
                                  '(${_meal.basePrice.toStringAsFixed(0)} + ₹${_addonsSubtotal.toStringAsFixed(0)} add-ons)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  'Total: ₹${_finalTotalPrice.toStringAsFixed(0)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ],
                            ),

                            // Quantity Selector for Box
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.softLightGreen,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove, size: 18, color: AppColors.primaryGreen),
                                        onPressed: () {
                                          if (_boxQuantity > 1) {
                                            setState(() => _boxQuantity--);
                                          }
                                        },
                                      ),
                                      Text(
                                        '$_boxQuantity',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 18, color: AppColors.primaryGreen),
                                        onPressed: () {
                                          setState(() => _boxQuantity++);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _addToCartAndProceed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Add to Order & View Cart',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.softLightGreen.withOpacity(0.5) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primaryGreen : Colors.grey,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'FREE',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddonCard(AddonItemModel item) {
    final qty = _selectedAddonQtys[item.id] ?? 0;
    final isSelected = qty > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.softLightGreen.withOpacity(0.35) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? AppColors.primaryGreen : AppColors.borderLight,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.isVeg ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: item.isVeg ? Colors.green : Colors.red,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        item.isVeg ? 'VEG' : 'NON-VEG',
                        style: GoogleFonts.poppins(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: item.isVeg ? Colors.green.shade800 : Colors.red.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.name,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '+₹${item.price.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Quantity controls [-] qty [+]
          if (qty == 0)
            ElevatedButton(
              onPressed: () => _incrementAddon(item),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.softLightGreen,
                foregroundColor: AppColors.primaryGreen,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'ADD',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _decrementAddon(item),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Icon(Icons.remove, size: 16, color: Colors.white),
                    ),
                  ),
                  Text(
                    '$qty',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _incrementAddon(item),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Icon(Icons.add, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

