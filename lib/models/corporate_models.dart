class Corporate {
  final String corporateId; // e.g. "CORP-0001"
  final String companyName;
  final String address;
  final String area;
  final String status; // "ACTIVE" | "INACTIVE"

  Corporate({
    required this.corporateId,
    required this.companyName,
    required this.address,
    required this.area,
    required this.status,
  });

  factory Corporate.fromMap(String id, Map<dynamic, dynamic> map) {
    return Corporate(
      corporateId: id,
      companyName: map['companyName'] ?? map['name'] ?? '',
      address: map['address'] ?? '',
      area: map['area'] ?? '',
      status: map['status'] ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toMap() => {
    'corporateId': corporateId,
    'companyName': companyName,
    'address': address,
    'area': area,
    'status': status,
  };
}

class CollectionPoint {
  final String collectionPointId;
  final String corporateId;
  final String name;
  final String address;
  final String area;
  final String deliveryTime; // e.g. "12:30 PM"
  final String verificationPin; // 4-digit PIN
  final bool active;

  CollectionPoint({
    required this.collectionPointId,
    required this.corporateId,
    required this.name,
    required this.address,
    required this.area,
    required this.deliveryTime,
    required this.verificationPin,
    required this.active,
  });

  factory CollectionPoint.fromMap(String id, Map<dynamic, dynamic> map) {
    return CollectionPoint(
      collectionPointId: id,
      corporateId: map['corporateId'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      area: map['area'] ?? '',
      deliveryTime: map['deliveryTime'] ?? '12:30 PM',
      verificationPin: map['verificationPin']?.toString() ?? '1234',
      active: map['active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
    'collectionPointId': collectionPointId,
    'corporateId': corporateId,
    'name': name,
    'address': address,
    'area': area,
    'deliveryTime': deliveryTime,
    'verificationPin': verificationPin,
    'active': active,
  };
}

