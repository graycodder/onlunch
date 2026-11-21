import '../../firebase/firebase_service.dart';
import '../models/product_model.dart';

class ProductRepository {
  final FirebaseService _fb = FirebaseService();

  List<ProductModel> get defaultProducts => [
    ProductModel(
      id: 'prod_rice_lunch',
      name: 'Rice Lunch',
      description: 'Traditional Kerala lunch with rice, curry, thoran, pickle and side dishes.',
      price: 80,
      imageUrl: 'assets/images/rice_lunch.png',
      categoryId: 'daily_lunch',
      isAvailable: true,
    ),
    ProductModel(
      id: 'prod_meals_veg',
      name: 'Meals (Veg)',
      description: 'Pure vegetarian authentic Kerala sadhya meals with sambar, avial and payasam.',
      price: 70,
      imageUrl: 'assets/images/meals_veg.png',
      categoryId: 'daily_lunch',
      isAvailable: true,
    ),
    ProductModel(
      id: 'prod_meals_nonveg',
      name: 'Meals (Non-Veg)',
      description: 'Special Kerala non-veg lunch served with delicious fish curry and chicken roast.',
      price: 100,
      imageUrl: 'assets/images/meals_nonveg.png',
      categoryId: 'daily_lunch',
      isAvailable: true,
    ),
  ];

  /// Stream of products from onelunch/products
  Stream<List<ProductModel>> getProductsStream() {
    return _fb.productsRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) {
        return defaultProducts;
      }
      final List<ProductModel> list = [];
      if (data is Map) {
        data.forEach((key, val) {
          if (val is Map) {
            list.add(ProductModel.fromMap(val, key.toString()));
          }
        });
      } else if (data is List) {
        for (var i = 0; i < data.length; i++) {
          if (data[i] is Map) {
            list.add(ProductModel.fromMap(data[i] as Map, 'prod_$i'));
          }
        }
      }
      return list.isNotEmpty ? list : defaultProducts;
    });
  }

  /// Get single product by ID
  Future<ProductModel?> getProductById(String id) async {
    try {
      final snapshot = await _fb.productsRef.child(id).get();
      if (snapshot.exists && snapshot.value is Map) {
        return ProductModel.fromMap(snapshot.value as Map, id);
      }
    } catch (_) {}
    return defaultProducts.firstWhere(
      (p) => p.id == id,
      orElse: () => defaultProducts.first,
    );
  }
}
