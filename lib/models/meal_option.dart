// ignore_for_file: constant_identifier_names

enum MealCategory { MEAL_TYPE, GRAVY, FRY, CURRY, ADDON }

class LunchMealOption {
  final String optionId;
  final MealCategory category;
  final String name;
  final String? description;
  final bool active;
  final int sortOrder;
  final double price;

  LunchMealOption({
    required this.optionId,
    required this.category,
    required this.name,
    this.description,
    required this.active,
    required this.sortOrder,
    required this.price,
  });

  factory LunchMealOption.fromMap(String key, Map<dynamic, dynamic> map) {
    return LunchMealOption(
      optionId: key,
      category: MealCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => MealCategory.ADDON,
      ),
      name: map['name'] ?? '',
      description: map['description'],
      active: map['active'] ?? true,
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() => {
    'category': category.name,
    'name': name,
    if (description != null) 'description': description,
    'active': active,
    'sortOrder': sortOrder,
    'price': price,
  };
}

class MealSelectionSnapshot {
  final String mealType; // "VEG" | "NON_VEG"
  final String mealTypeName;
  final String riceQuantity; // "REGULAR" | "LESS"
  final String riceQuantityName;
  final String? gravyId;
  final String? gravyName;
  final String? fryId;
  final String? fryName;
  final String? curryId;
  final String? curryName;
  final List<Map<String, dynamic>>? customAddons;

  MealSelectionSnapshot({
    required this.mealType,
    required this.mealTypeName,
    this.riceQuantity = 'REGULAR',
    this.riceQuantityName = 'Regular Rice',
    this.gravyId,
    this.gravyName,
    this.fryId,
    this.fryName,
    this.curryId,
    this.curryName,
    this.customAddons,
  });

  Map<String, dynamic> toMap() => {
    'mealType': mealType,
    'mealTypeName': mealTypeName,
    'riceQuantity': riceQuantity,
    'riceQuantityName': riceQuantityName,
    'gravyId': gravyId,
    'gravyName': gravyName,
    'fryId': fryId,
    'fryName': fryName,
    'curryId': curryId,
    'curryName': curryName,
    'customAddons': customAddons ?? [],
  };

  factory MealSelectionSnapshot.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return MealSelectionSnapshot(mealType: 'VEG', mealTypeName: 'Standard Veg');
    return MealSelectionSnapshot(
      mealType: map['mealType'] ?? 'VEG',
      mealTypeName: map['mealTypeName'] ?? 'Standard Veg',
      riceQuantity: map['riceQuantity'] ?? 'REGULAR',
      riceQuantityName: map['riceQuantityName'] ?? 'Regular Rice',
      gravyId: map['gravyId'],
      gravyName: map['gravyName'],
      fryId: map['fryId'],
      fryName: map['fryName'],
      curryId: map['curryId'],
      curryName: map['curryName'],
      customAddons: (map['customAddons'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
  }
}
