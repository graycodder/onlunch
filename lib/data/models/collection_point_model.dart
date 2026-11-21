class CollectionPointModel {
  final String id;
  final String companyId;
  final String companyName;
  final String name;
  final String address;
  final String mapUrl;
  final String contactPerson;
  final String contactNumber;
  final String deliveryTime;
  final String deliveryInstructions;
  final String assignedDriverId;
  final String assignedDriverName;
  final int maxCapacity;
  final String status; // 'Active' or 'Inactive'
  final dynamic createdAt;

  CollectionPointModel({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.name,
    required this.address,
    this.mapUrl = '',
    this.contactPerson = '',
    this.contactNumber = '',
    this.deliveryTime = '12:30 PM',
    this.deliveryInstructions = '',
    this.assignedDriverId = '',
    this.assignedDriverName = '',
    this.maxCapacity = 150,
    this.status = 'Active',
    this.createdAt,
  });

  bool get isActive => status.toLowerCase() == 'active';

  factory CollectionPointModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return CollectionPointModel(
      id: id,
      companyId: map['companyId']?.toString() ?? '',
      companyName: map['companyName']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      mapUrl: map['mapUrl']?.toString() ?? '',
      contactPerson: map['contactPerson']?.toString() ?? '',
      contactNumber: map['contactNumber']?.toString() ?? '',
      deliveryTime: map['deliveryTime']?.toString() ?? '12:30 PM',
      deliveryInstructions: map['deliveryInstructions']?.toString() ?? '',
      assignedDriverId: map['assignedDriverId']?.toString() ?? '',
      assignedDriverName: map['assignedDriverName']?.toString() ?? '',
      maxCapacity: (map['maxCapacity'] is num)
          ? (map['maxCapacity'] as num).toInt()
          : int.tryParse(map['maxCapacity']?.toString() ?? '150') ?? 150,
      status: map['status']?.toString() ?? 'Active',
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyId': companyId,
      'companyName': companyName,
      'name': name,
      'address': address,
      'mapUrl': mapUrl,
      'contactPerson': contactPerson,
      'contactNumber': contactNumber,
      'deliveryTime': deliveryTime,
      'deliveryInstructions': deliveryInstructions,
      'assignedDriverId': assignedDriverId,
      'assignedDriverName': assignedDriverName,
      'maxCapacity': maxCapacity,
      'status': status,
      'createdAt': createdAt,
    };
  }

  CollectionPointModel copyWith({
    String? companyId,
    String? companyName,
    String? name,
    String? address,
    String? mapUrl,
    String? contactPerson,
    String? contactNumber,
    String? deliveryTime,
    String? deliveryInstructions,
    String? assignedDriverId,
    String? assignedDriverName,
    int? maxCapacity,
    String? status,
  }) {
    return CollectionPointModel(
      id: id,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      name: name ?? this.name,
      address: address ?? this.address,
      mapUrl: mapUrl ?? this.mapUrl,
      contactPerson: contactPerson ?? this.contactPerson,
      contactNumber: contactNumber ?? this.contactNumber,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      assignedDriverId: assignedDriverId ?? this.assignedDriverId,
      assignedDriverName: assignedDriverName ?? this.assignedDriverName,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}

