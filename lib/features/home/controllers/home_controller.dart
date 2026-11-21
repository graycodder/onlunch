import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/meal_model.dart';
import '../../../data/models/banner_model.dart';
import '../../../data/models/settings_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/meal_repository.dart';
import '../../../data/repositories/banner_repository.dart';
import '../../../data/repositories/settings_repository.dart';

class HomeController extends GetxController {
  final ProductRepository _productRepo = ProductRepository();
  final MealRepository _mealRepo = MealRepository();
  final BannerRepository _bannerRepo = BannerRepository();
  final SettingsRepository _settingsRepo = SettingsRepository();

  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<MealModel> meals = <MealModel>[].obs;
  final Rxn<BannerModel> banner = Rxn<BannerModel>();
  final Rxn<SettingsModel> settings = Rxn<SettingsModel>();

  // Interactive filters matching the Swiggy-style design
  final RxString selectedMainTab = 'Food'.obs; // 'Food', 'Instamart', 'Dineout'
  final RxString searchQuery = ''.obs;
  final RxBool isVegOnly = false.obs;
  final RxString selectedSubCategory = 'ALL'.obs; // 'ALL', 'STORE', 'OFFERS', 'BOLT'
  final RxString selectedFilterPill = 'ALL'.obs; // 'MIN Rs. 100 OFF', 'FAST DELIVERY', etc.

  final RxInt selectedNavIndex = 0.obs;
  final RxBool isLoading = false.obs;

  List<MealModel> get filteredMeals {
    return meals.where((meal) {
      if (isVegOnly.value && !meal.isVeg) return false;
      if (searchQuery.value.trim().isNotEmpty) {
        final q = searchQuery.value.trim().toLowerCase();
        final matchName = meal.name.toLowerCase().contains(q);
        final matchDesc = meal.description.toLowerCase().contains(q);
        if (!matchName && !matchDesc) return false;
      }
      if (selectedSubCategory.value == 'STORE') {
        return meal.basePrice <= 80;
      } else if (selectedSubCategory.value == 'BOLT') {
        return meal.mealType == 'Non-Veg';
      } else if (selectedSubCategory.value == 'OFFERS') {
        return meal.basePrice < 100;
      }
      return true;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _initDataStreams();
  }

  void _initDataStreams() {
    // Initial fallback data
    products.assignAll(_productRepo.defaultProducts);
    meals.assignAll([
      MealModel(
        id: 'meal_veg',
        name: 'Veg Lunch',
        description: 'Authentic Kerala sadhya meal with rice, sambar, rasam, thoran and pickle.',
        mealType: 'Veg',
        basePrice: 60,
        imageUrl: 'assets/images/meals_veg.png',
        displayOrder: 1,
      ),
      MealModel(
        id: 'meal_nonveg',
        name: 'Non-Veg Lunch',
        description: 'Traditional Kerala non-veg lunch with rice, fish gravy, chicken roast & thoran.',
        mealType: 'Non-Veg',
        basePrice: 80,
        imageUrl: 'assets/images/meals_nonveg.png',
        displayOrder: 2,
      ),
      MealModel(
        id: 'meal_special',
        name: 'Special Sadya Lunch',
        description: 'Royal Kerala sadya on banana leaf with payasam & 12 accompaniments.',
        mealType: 'Veg',
        basePrice: 120,
        imageUrl: 'assets/images/rice_lunch.png',
        displayOrder: 3,
      ),
    ]);
    banner.value = _bannerRepo.defaultBanner;
    settings.value = _settingsRepo.defaultSettings;

    // Listen to Firebase Realtime Database
    products.bindStream(_productRepo.getProductsStream());
    meals.bindStream(_mealRepo.getMealsStream());
    banner.bindStream(_bannerRepo.getActiveBannerStream());
    settings.bindStream(_settingsRepo.getSettingsStream());
  }

  void switchTab(int index) {
    selectedNavIndex.value = index;
  }
}
