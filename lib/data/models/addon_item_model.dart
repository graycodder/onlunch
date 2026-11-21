class AddonItemModel {
  final String id;
  final String categoryId;
  final String categoryName;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final bool isVeg;
  final List<String> applicableMealTypes; // ['Veg', 'Non-Veg', 'Special']
  final int maxQty;
  final bool isAvailable;
  final int displayOrder;

  AddonItemModel({
    required this.id,
    required this.categoryId,
    this.categoryName = '',
    required this.name,
    this.description = '',
    this.imageUrl = '',
    required this.price,
    this.isVeg = true,
    this.applicableMealTypes = const ['Veg', 'Non-Veg'],
    this.maxQty = 5,
    this.isAvailable = true,
    this.displayOrder = 1,
  });

  factory AddonItemModel.fromMap(Map<dynamic, dynamic> map, String id) {
    List<String> meals = ['Veg', 'Non-Veg'];
    if (map['applicableMealTypes'] is List) {
      meals = (map['applicableMealTypes'] as List).map((e) => e.toString()).toList();
    }

    return AddonItemModel(
      id: id,
      categoryId: map['categoryId']?.toString() ?? '',
      categoryName: map['categoryName']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      price: (map['price'] is num)
          ? (map['price'] as num).toDouble()
          : double.tryParse(map['price']?.toString() ?? '0') ?? 0.0,
      isVeg: map['isVeg'] == null ? true : (map['isVeg'] as bool),
      applicableMealTypes: meals,
      maxQty: (map['maxQty'] is num)
          ? (map['maxQty'] as num).toInt()
          : int.tryParse(map['maxQty']?.toString() ?? '5') ?? 5,
      isAvailable: map['isAvailable'] == null ? true : (map['isAvailable'] as bool),
      displayOrder: (map['displayOrder'] is num)
          ? (map['displayOrder'] as num).toInt()
          : int.tryParse(map['displayOrder']?.toString() ?? '1') ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'isVeg': isVeg,
      'applicableMealTypes': applicableMealTypes,
      'maxQty': maxQty,
      'isAvailable': isAvailable,
      'displayOrder': displayOrder,
    };
  }

  AddonItemModel copyWith({
    String? categoryId,
    String? categoryName,
    String? name,
    String? description,
    String? imageUrl,
    double? price,
    bool? isVeg,
    List<String>? applicableMealTypes,
    int? maxQty,
    bool? isAvailable,
    int? displayOrder,
  }) {
    return AddonItemModel(
      id: id,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      isVeg: isVeg ?? this.isVeg,
      applicableMealTypes: applicableMealTypes ?? this.applicableMealTypes,
      maxQty: maxQty ?? this.maxQty,
      isAvailable: isAvailable ?? this.isAvailable,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }
}

