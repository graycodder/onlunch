class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String categoryId;
  final bool isAvailable;
  final dynamic createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.categoryId = 'daily_lunch',
    this.isAvailable = true,
    this.createdAt,
  });

  factory ProductModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return ProductModel(
      id: id,
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      price: (map['price'] is num) ? (map['price'] as num).toDouble() : double.tryParse(map['price']?.toString() ?? '0') ?? 0.0,
      imageUrl: map['imageUrl']?.toString() ?? '',
      categoryId: map['categoryId']?.toString() ?? 'daily_lunch',
      isAvailable: map['isAvailable'] == null ? true : (map['isAvailable'] as bool),
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'isAvailable': isAvailable,
      'createdAt': createdAt,
    };
  }
}

