import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/models/meal_customization_model.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/routes/app_routes.dart';

class CartController extends GetxController {
  final CartRepository _cartRepo = CartRepository();
  final OrderRepository _orderRepo = OrderRepository();

  final RxList<MealCustomizationModel> customizedMeals = <MealCustomizationModel>[].obs;
  final RxList<CartItemModel> items = <CartItemModel>[].obs;
  final RxBool isPlacingOrder = false.obs;

  // Selected delivery schedule: Tomorrow (default) or weekly booking dates
  final RxString selectedDeliveryDate = ''.obs;
  final RxList<String> weeklyBookingDates = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    selectedDeliveryDate.value = DateFormat('EEE, dd MMM yyyy').format(tomorrow);
  }

  int get totalBoxesCount {
    final customCount = customizedMeals.fold(0, (sum, m) => sum + m.mealQuantity);
    final legacyCount = items.fold(0, (sum, i) => sum + i.quantity);
    return customCount + legacyCount;
  }

  int get totalItemsCount => totalBoxesCount;

  void addItem(dynamic product, [int quantity = 1]) {
    if (product is CartItemModel) {
      final index = items.indexWhere((i) => i.productId == product.productId);
      if (index >= 0) {
        items[index].quantity += product.quantity;
      } else {
        items.add(product);
      }
    } else {
      final String id = product.id?.toString() ?? '';
      final String name = product.name?.toString() ?? '';
      final double price = (product.price is num)
          ? (product.price as num).toDouble()
          : double.tryParse(product.price?.toString() ?? '0') ?? 0.0;
      final String img = product.imageUrl?.toString() ?? 'assets/images/rice_lunch.png';
      final index = items.indexWhere((i) => i.productId == id);
      if (index >= 0) {
        items[index].quantity += quantity;
      } else {
        items.add(CartItemModel(
          productId: id,
          productName: name,
          price: price,
          imageUrl: img,
          quantity: quantity,
        ));
      }
    }
    items.refresh();
    _syncWithFirebase();
  }

  double get baseMealsTotal {
    return customizedMeals.fold(0.0, (sum, m) => sum + (m.basePrice * m.mealQuantity));
  }

  double get addonsTotal {
    return customizedMeals.fold(0.0, (sum, m) => sum + (m.addonsSubtotal * m.mealQuantity));
  }

  double get legacySubtotal {
    return items.fold(0.0, (sum, i) => sum + i.subtotal);
  }

  double get subtotal => baseMealsTotal + addonsTotal + legacySubtotal;

  double get deliveryFee => 0.0; // Free campus delivery

  double get totalAmount => subtotal + deliveryFee;

  void addCustomizedMeal(MealCustomizationModel meal) {
    customizedMeals.add(meal);
    _syncWithFirebase();
    Get.snackbar(
      'Meal Added',
      '${meal.mealName} (x${meal.mealQuantity}) added with your selected add-ons',
      backgroundColor: Colors.white,
      colorText: const Color(0xFF075B25),
      snackPosition: SnackPosition.BOTTOM,
      icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF075B25)),
    );
  }

  void updateCustomizedMealQty(String configId, int delta) {
    final index = customizedMeals.indexWhere((m) => m.configurationId == configId);
    if (index >= 0) {
      final newQty = customizedMeals[index].mealQuantity + delta;
      if (newQty <= 0) {
        customizedMeals.removeAt(index);
      } else {
        customizedMeals[index].mealQuantity = newQty;
        customizedMeals.refresh();
      }
      _syncWithFirebase();
    }
  }

  void removeCustomizedMeal(String configId) {
    customizedMeals.removeWhere((m) => m.configurationId == configId);
    _syncWithFirebase();
  }

  // Legacy item support
  void removeItem(String productId) {
    items.removeWhere((i) => i.productId == productId);
    _syncWithFirebase();
  }

  void clearCart() {
    customizedMeals.clear();
    items.clear();
    _syncWithFirebase();
  }

  void _syncWithFirebase() {
    try {
      final auth = Get.find<AuthController>();
      if (auth.isLoggedIn.value && auth.currentUser.value != null) {
        _cartRepo.syncCart(auth.currentUser.value!.uid, items);
      }
    } catch (_) {}
  }

  /// Places the Corporate Order and navigates to Order Details screen
  Future<void> confirmCorporateOrder({
    String paymentMethod = 'Prepaid Online',
  }) async {
    if (isPlacingOrder.value) return; // Prevent double tap
    if (customizedMeals.isEmpty && items.isEmpty) {
      Get.snackbar('Cart is Empty', 'Please customize and add meals to your cart before ordering');
      return;
    }

    try {
      isPlacingOrder.value = true;
      final auth = Get.find<AuthController>();
      final user = auth.currentUser.value;

      final uid = user?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';
      final name = user?.name ?? 'OneLunch Customer';
      final mobile = user?.mobile ?? '+91 99952 26139';

      final compId = user?.defaultCompanyId ?? 'comp_isquare';
      final compName = user?.defaultCompanyName ?? 'iSquare CoWorking Space';
      final cpId = user?.defaultCollectionPointId ?? 'cp_isquare_thrikkakara';
      final cpName = user?.defaultCollectionPointName ?? 'iSquare Thrikkakara';
      final delTime = user?.defaultDeliveryTime ?? '12:30 PM';
      final delAddr = user?.defaultDeliveryAddress ?? 'Ground Floor Cafe Area';

      final OrderModel order = await _orderRepo.placeCorporateOrder(
        userId: uid,
        customerName: name,
        mobile: mobile,
        companyId: compId,
        companyName: compName,
        collectionPointId: cpId,
        collectionPointName: cpName,
        deliveryAddress: delAddr,
        deliveryTime: delTime,
        deliveryDate: selectedDeliveryDate.value,
        customizedMeals: List.from(customizedMeals),
        baseMealsTotal: baseMealsTotal,
        addonsTotal: addonsTotal,
        discount: 0.0,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        paymentStatus: 'PAID',
        paymentRef: 'OL_PAY_${DateTime.now().millisecondsSinceEpoch}',
      );

      // Clear the cart
      clearCart();

      // Navigate to Order Details
      Get.offNamed(AppRoutes.orderDetails, arguments: order);
    } catch (e) {
      Get.snackbar(
        'Order Placement Error',
        'Could not complete order: $e',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
    } finally {
      isPlacingOrder.value = false;
    }
  }
}
