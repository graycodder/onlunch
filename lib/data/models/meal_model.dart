class MealModel {
  final String id;
  final String name;
  final String description;
  final String mealType; // 'Veg' or 'Non-Veg'
  final double basePrice;
  final String imageUrl;
  final String availableDate; // 'All' or specific date
  final bool isAvailable;
  final int displayOrder;
  final List<String> associatedCategories;

  MealModel({
    required this.id,
    required this.name,
    this.description = '',
    this.mealType = 'Veg',
    required this.basePrice,
    required this.imageUrl,
    this.availableDate = 'All',
    this.isAvailable = true,
    this.displayOrder = 1,
    this.associatedCategories = const ['cat_rice', 'cat_gravy', 'cat_side', 'cat_fry', 'cat_extra'],
  });

  bool get isVeg => mealType.toLowerCase() == 'veg';

  factory MealModel.fromMap(Map<dynamic, dynamic> map, String id) {
    List<String> cats = ['cat_rice', 'cat_gravy', 'cat_side', 'cat_fry', 'cat_extra'];
    if (map['associatedCategories'] is List) {
      cats = (map['associatedCategories'] as List).map((e) => e.toString()).toList();
    }

    return MealModel(
      id: id,
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      mealType: map['mealType']?.toString() ?? 'Veg',
      basePrice: (map['basePrice'] is num)
          ? (map['basePrice'] as num).toDouble()
          : double.tryParse(map['basePrice']?.toString() ?? '0') ?? 60.0,
      imageUrl: map['imageUrl']?.toString() ?? '',
      availableDate: map['availableDate']?.toString() ?? 'All',
      isAvailable: map['isAvailable'] == null ? true : (map['isAvailable'] as bool),
      displayOrder: (map['displayOrder'] is num)
          ? (map['displayOrder'] as num).toInt()
          : int.tryParse(map['displayOrder']?.toString() ?? '1') ?? 1,
      associatedCategories: cats,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'mealType': mealType,
      'basePrice': basePrice,
      'imageUrl': imageUrl,
      'availableDate': availableDate,
      'isAvailable': isAvailable,
      'displayOrder': displayOrder,
      'associatedCategories': associatedCategories,
    };
  }

  MealModel copyWith({
    String? name,
    String? description,
    String? mealType,
    double? basePrice,
    String? imageUrl,
    String? availableDate,
    bool? isAvailable,
    int? displayOrder,
    List<String>? associatedCategories,
  }) {
    return MealModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      mealType: mealType ?? this.mealType,
      basePrice: basePrice ?? this.basePrice,
      imageUrl: imageUrl ?? this.imageUrl,
      availableDate: availableDate ?? this.availableDate,
      isAvailable: isAvailable ?? this.isAvailable,
      displayOrder: displayOrder ?? this.displayOrder,
      associatedCategories: associatedCategories ?? this.associatedCategories,
    );
  }
}

