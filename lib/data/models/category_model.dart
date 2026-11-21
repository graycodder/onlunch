class CategoryModel {
  final String id;
  final String name;
  final int sortOrder;

  CategoryModel({
    required this.id,
    required this.name,
    this.sortOrder = 0,
  });

  factory CategoryModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      name: map['name']?.toString() ?? '',
      sortOrder: (map['sortOrder'] is num) ? (map['sortOrder'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sortOrder': sortOrder,
    };
  }
}

