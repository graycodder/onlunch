class CartItemModel {
  final String productId;
  final String productName;
  final double price;
  final String imageUrl;
  int quantity;

  CartItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  double get subtotal => price * quantity;

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      productId: productId,
      productName: productName,
      price: price,
      imageUrl: imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }

  factory CartItemModel.fromMap(Map<dynamic, dynamic> map, String productId) {
    return CartItemModel(
      productId: productId,
      productName: map['productName']?.toString() ?? '',
      price: (map['price'] is num) ? (map['price'] as num).toDouble() : double.tryParse(map['price']?.toString() ?? '0') ?? 0.0,
      imageUrl: map['imageUrl']?.toString() ?? '',
      quantity: (map['quantity'] is num) ? (map['quantity'] as num).toInt() : int.tryParse(map['quantity']?.toString() ?? '1') ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }
}

