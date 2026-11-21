import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../cart/controllers/cart_controller.dart';

class ProductDetailsController extends GetxController {
  late ProductModel product;
  final RxInt quantity = 1.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is ProductModel) {
      product = args;
    } else {
      product = ProductModel(
        id: 'prod_rice_lunch',
        name: 'Rice Lunch',
        description: 'Traditional Kerala lunch with rice, curry and side dishes.',
        price: 80,
        imageUrl: 'assets/images/food_details_banner.png',
        isAvailable: true,
      );
    }
  }

  void increment() {
    quantity.value++;
  }

  void decrement() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  double get subtotal => product.price * quantity.value;

  void addToCart() {
    final cart = Get.find<CartController>();
    cart.addItem(product, quantity.value);
    Get.back();
  }
}

