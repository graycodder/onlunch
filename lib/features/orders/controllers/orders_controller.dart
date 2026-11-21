import 'package:get/get.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../auth/controllers/auth_controller.dart';

class OrdersController extends GetxController {
  final OrderRepository _orderRepo = OrderRepository();

  final RxInt selectedTab = 0.obs; // 0: Pending, 1: Completed
  final RxList<OrderModel> allOrders = <OrderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadSampleAndListen();
  }

  void _loadSampleAndListen() {
    // Initial sample orders matching exactly the mockup screen 5:
    // #OL1001 - Pending - 07 Nov 2026, 12:30 PM - ₹ 80
    // #OL0999 - Completed - 05 Nov 2026, 12:20 PM - ₹ 100
    allOrders.assignAll([
      OrderModel(
        orderId: 'OL1001',
        userId: 'user_default',
        customerName: 'OneLunch',
        mobile: '+91 98765 43210',
        items: [
          CartItemModel(
            productId: 'prod_rice_lunch',
            productName: 'Rice Lunch',
            price: 80,
            imageUrl: 'assets/images/rice_lunch.png',
            quantity: 1,
          )
        ],
        totalAmount: 80,
        orderStatus: 'Pending',
        paymentStatus: 'PAID',
        paymentMethod: 'Cash on Delivery',
        createdAt: '07 Nov 2026, 12:30 PM',
        timestamp: 1730960000000,
      ),
      OrderModel(
        orderId: 'OL0999',
        userId: 'user_default',
        customerName: 'OneLunch',
        mobile: '+91 98765 43210',
        items: [
          CartItemModel(
            productId: 'prod_meals_nonveg',
            productName: 'Meals (Non-Veg)',
            price: 100,
            imageUrl: 'assets/images/meals_nonveg.png',
            quantity: 1,
          )
        ],
        totalAmount: 100,
        orderStatus: 'Completed',
        paymentStatus: 'PAID',
        paymentMethod: 'Online Payment',
        createdAt: '05 Nov 2026, 12:20 PM',
        timestamp: 1730780000000,
      ),
    ]);

    try {
      final auth = Get.find<AuthController>();
      if (auth.isLoggedIn.value && auth.currentUser.value != null) {
        allOrders.bindStream(_orderRepo.getUserOrdersStream(auth.currentUser.value!.uid));
      }
    } catch (_) {}
  }

  List<OrderModel> get pendingOrders =>
      allOrders.where((o) => o.isPending).toList();

  List<OrderModel> get completedOrders =>
      allOrders.where((o) => o.isCompleted).toList();
}

