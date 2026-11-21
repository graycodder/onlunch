class AddonCategoryModel {
  final String id;
  final String name;
  final String description;
  final String selectionMode; // 'Single' or 'Multiple'
  final String status; // 'Active' or 'Inactive'
  final int displayOrder;

  AddonCategoryModel({
    required this.id,
    required this.name,
    this.description = '',
    this.selectionMode = 'Multiple',
    this.status = 'Active',
    this.displayOrder = 1,
  });

  bool get isActive => status.toLowerCase() == 'active';
  bool get isSingleSelection => selectionMode.toLowerCase() == 'single';

  factory AddonCategoryModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return AddonCategoryModel(
      id: id,
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      selectionMode: map['selectionMode']?.toString() ?? 'Multiple',
      status: map['status']?.toString() ?? 'Active',
      displayOrder: (map['displayOrder'] is num)
          ? (map['displayOrder'] as num).toInt()
          : int.tryParse(map['displayOrder']?.toString() ?? '1') ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'selectionMode': selectionMode,
      'status': status,
      'displayOrder': displayOrder,
    };
  }
}

