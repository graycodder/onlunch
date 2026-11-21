import 'package:firebase_database/firebase_database.dart';
import '../../firebase/firebase_service.dart';
import '../models/cart_item_model.dart';

class CartRepository {
  final FirebaseService _fb = FirebaseService();

  /// Stream of user cart items
  Stream<List<CartItemModel>> getCartStream(String uid) {
    return _fb.cartRef(uid).child('items').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];
      final List<CartItemModel> items = [];
      if (data is Map) {
        data.forEach((key, val) {
          if (val is Map) {
            items.add(CartItemModel.fromMap(val, key.toString()));
          }
        });
      }
      return items;
    });
  }

  /// Sync full cart to Firebase Realtime Database
  Future<void> syncCart(String uid, List<CartItemModel> items) async {
    final Map<String, dynamic> itemsMap = {};
    double total = 0;
    for (final item in items) {
      itemsMap[item.productId] = item.toMap();
      total += item.subtotal;
    }
    await _fb.cartRef(uid).set({
      'items': itemsMap,
      'totalAmount': total,
      'updatedAt': ServerValue.timestamp,
    });
  }

  /// Clear cart
  Future<void> clearCart(String uid) async {
    await _fb.cartRef(uid).remove();
  }
}

