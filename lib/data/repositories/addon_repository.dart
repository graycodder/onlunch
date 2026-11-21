import 'package:firebase_database/firebase_database.dart';
import '../../firebase/firebase_service.dart';
import '../models/addon_category_model.dart';
import '../models/addon_item_model.dart';

class AddonRepository {
  final FirebaseService _fb = FirebaseService();
  DatabaseReference get _categoriesRef => _fb.addonCategoriesRef;
  DatabaseReference get _itemsRef => _fb.addonItemsRef;

  Stream<List<AddonCategoryModel>> getCategoriesStream() {
    return _categoriesRef.onValue.map((event) {
      final List<AddonCategoryModel> categories = [];
      final data = event.snapshot.value;
      if (data is Map) {
        data.forEach((key, val) {
          if (val is Map) {
            categories.add(AddonCategoryModel.fromMap(val, key.toString()));
          }
        });
      }
      categories.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      return categories;
    });
  }

  Stream<List<AddonItemModel>> getItemsStream() {
    return _itemsRef.onValue.map((event) {
      final List<AddonItemModel> items = [];
      final data = event.snapshot.value;
      if (data is Map) {
        data.forEach((key, val) {
          if (val is Map) {
            items.add(AddonItemModel.fromMap(val, key.toString()));
          }
        });
      }
      items.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      return items;
    });
  }

  Future<List<AddonItemModel>> getItemsForMeal(String mealType) async {
    final snapshot = await _itemsRef.get();
    final List<AddonItemModel> items = [];
    if (snapshot.exists && snapshot.value is Map) {
      (snapshot.value as Map).forEach((key, val) {
        if (val is Map) {
          final item = AddonItemModel.fromMap(val, key.toString());
          if (item.isAvailable && (item.applicableMealTypes.contains(mealType) || item.applicableMealTypes.contains('All'))) {
            items.add(item);
          }
        }
      });
    }
    items.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return items;
  }

  Future<void> saveCategory(AddonCategoryModel cat) async {
    await _categoriesRef.child(cat.id).set(cat.toMap());
  }

  Future<void> deleteCategory(String catId) async {
    await _categoriesRef.child(catId).remove();
  }

  Future<void> saveItem(AddonItemModel item) async {
    await _itemsRef.child(item.id).set(item.toMap());
  }

  Future<void> updateItemPrice(String itemId, double price) async {
    await _itemsRef.child(itemId).update({'price': price});
  }

  Future<void> toggleItemAvailability(String itemId, bool isAvailable) async {
    await _itemsRef.child(itemId).update({'isAvailable': isAvailable});
  }

  Future<void> deleteItem(String itemId) async {
    await _itemsRef.child(itemId).remove();
  }
}

