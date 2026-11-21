import 'package:firebase_database/firebase_database.dart';
import '../../firebase/firebase_service.dart';
import '../models/meal_model.dart';

class MealRepository {
  final FirebaseService _fb = FirebaseService();
  DatabaseReference get _mealsRef => _fb.mealsRef;

  Stream<List<MealModel>> getMealsStream() {
    return _mealsRef.onValue.map((event) {
      final List<MealModel> meals = [];
      final data = event.snapshot.value;
      if (data is Map) {
        data.forEach((key, val) {
          if (val is Map) {
            meals.add(MealModel.fromMap(val, key.toString()));
          }
        });
      }
      meals.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      return meals;
    });
  }

  Future<List<MealModel>> getAvailableMeals() async {
    final snapshot = await _mealsRef.get();
    final List<MealModel> meals = [];
    if (snapshot.exists && snapshot.value is Map) {
      (snapshot.value as Map).forEach((key, val) {
        if (val is Map) {
          final m = MealModel.fromMap(val, key.toString());
          if (m.isAvailable) meals.add(m);
        }
      });
    }
    meals.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return meals;
  }

  Future<void> saveMeal(MealModel meal) async {
    await _mealsRef.child(meal.id).set(meal.toMap());
    // Also keep productsRef in sync
    await _fb.productsRef.child(meal.id).set(meal.toMap());
  }

  Future<void> updateMealPrice(String mealId, double newPrice) async {
    await _mealsRef.child(mealId).update({'basePrice': newPrice});
    await _fb.productsRef.child(mealId).update({'price': newPrice});
  }

  Future<void> toggleMealAvailability(String mealId, bool isAvailable) async {
    await _mealsRef.child(mealId).update({'isAvailable': isAvailable});
    await _fb.productsRef.child(mealId).update({'isAvailable': isAvailable});
  }

  Future<void> deleteMeal(String mealId) async {
    await _mealsRef.child(mealId).remove();
    await _fb.productsRef.child(mealId).remove();
  }
}

