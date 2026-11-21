class SelectedAddonItem {
  final String addonId;
  final String addonName;
  final double price;
  final int quantity;
  final String categoryName;

  SelectedAddonItem({
    required this.addonId,
    required this.addonName,
    required this.price,
    this.quantity = 1,
    this.categoryName = '',
  });

  double get subtotal => price * quantity;
  String get name => addonName;

  factory SelectedAddonItem.fromMap(Map<dynamic, dynamic> map) {
    return SelectedAddonItem(
      addonId: map['addonId']?.toString() ?? '',
      addonName: map['addonName']?.toString() ?? '',
      price: (map['price'] is num)
          ? (map['price'] as num).toDouble()
          : double.tryParse(map['price']?.toString() ?? '0') ?? 0.0,
      quantity: (map['quantity'] is num)
          ? (map['quantity'] as num).toInt()
          : int.tryParse(map['quantity']?.toString() ?? '1') ?? 1,
      categoryName: map['categoryName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'addonId': addonId,
      'addonName': addonName,
      'price': price,
      'quantity': quantity,
      'categoryName': categoryName,
    };
  }
}

class MealCustomizationModel {
  final String configurationId;
  final String mealId;
  final String mealName;
  final String mealType;
  final double basePrice;
  final String imageUrl;
  final String selectedRice;
  final String selectedGravy;
  final List<SelectedAddonItem> selectedAddons;
  int mealQuantity;

  MealCustomizationModel({
    required this.configurationId,
    required this.mealId,
    required this.mealName,
    this.mealType = 'Veg',
    required this.basePrice,
    this.imageUrl = '',
    this.selectedRice = 'Kerala Matta Rice',
    this.selectedGravy = 'Sambar',
    this.selectedAddons = const [],
    this.mealQuantity = 1,
  });

  double get addonsSubtotal {
    double sum = 0.0;
    for (var addon in selectedAddons) {
      sum += addon.subtotal;
    }
    return sum;
  }

  double get singleBoxTotal => basePrice + addonsSubtotal;

  double get finalTotal => singleBoxTotal * mealQuantity;

  double get totalPrice => finalTotal;
  String get riceChoice => selectedRice;
  String get gravyChoice => selectedGravy;
  List<SelectedAddonItem> get addons => selectedAddons;
  int get quantity => mealQuantity;

  String get addonsSummary {
    if (selectedAddons.isEmpty) return 'Standard meal';
    return selectedAddons.map((a) => '${a.addonName} (x${a.quantity})').join(', ');
  }

  factory MealCustomizationModel.fromMap(Map<dynamic, dynamic> map, String id) {
    final List<SelectedAddonItem> addons = [];
    final rawAddons = map['selectedAddons'];
    if (rawAddons is List) {
      for (var a in rawAddons) {
        if (a is Map) addons.add(SelectedAddonItem.fromMap(a));
      }
    } else if (rawAddons is Map) {
      rawAddons.forEach((_, val) {
        if (val is Map) addons.add(SelectedAddonItem.fromMap(val));
      });
    }

    return MealCustomizationModel(
      configurationId: id,
      mealId: map['mealId']?.toString() ?? '',
      mealName: map['mealName']?.toString() ?? '',
      mealType: map['mealType']?.toString() ?? 'Veg',
      basePrice: (map['basePrice'] is num)
          ? (map['basePrice'] as num).toDouble()
          : double.tryParse(map['basePrice']?.toString() ?? '0') ?? 60.0,
      imageUrl: map['imageUrl']?.toString() ?? '',
      selectedRice: map['selectedRice']?.toString() ?? 'Kerala Matta Rice',
      selectedGravy: map['selectedGravy']?.toString() ?? 'Sambar',
      selectedAddons: addons,
      mealQuantity: (map['mealQuantity'] is num)
          ? (map['mealQuantity'] as num).toInt()
          : int.tryParse(map['mealQuantity']?.toString() ?? '1') ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'configurationId': configurationId,
      'mealId': mealId,
      'mealName': mealName,
      'mealType': mealType,
      'basePrice': basePrice,
      'imageUrl': imageUrl,
      'selectedRice': selectedRice,
      'selectedGravy': selectedGravy,
      'selectedAddons': selectedAddons.map((a) => a.toMap()).toList(),
      'mealQuantity': mealQuantity,
      'addonsSubtotal': addonsSubtotal,
      'singleBoxTotal': singleBoxTotal,
      'finalTotal': finalTotal,
    };
  }
}
