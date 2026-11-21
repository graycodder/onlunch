class UserModel {
  final String uid;
  final String name;
  final String mobile;
  final String email;
  final String address;
  final String defaultCompanyId;
  final String defaultCompanyName;
  final String defaultCollectionPointId;
  final String defaultCollectionPointName;
  final String defaultDeliveryTime;
  final String defaultDeliveryAddress;
  final bool isAdmin;
  final dynamic createdAt;
  final dynamic updatedAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.mobile,
    this.email = '',
    this.address = '',
    this.defaultCompanyId = '',
    this.defaultCompanyName = '',
    this.defaultCollectionPointId = '',
    this.defaultCollectionPointName = '',
    this.defaultDeliveryTime = '12:30 PM',
    this.defaultDeliveryAddress = '',
    this.isAdmin = false,
    this.createdAt,
    this.updatedAt,
  });

  bool get hasLocation => defaultCompanyId.isNotEmpty && defaultCollectionPointId.isNotEmpty;

  factory UserModel.fromMap(Map<dynamic, dynamic> map, String uid) {
    final mob = map['mobile']?.toString() ?? '';
    final isOwnerOrAdmin = mob.contains('9995226139') || (map['isAdmin'] == true);

    return UserModel(
      uid: uid,
      name: map['name']?.toString() ?? 'Customer',
      mobile: mob,
      email: map['email']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      defaultCompanyId: map['defaultCompanyId']?.toString() ?? '',
      defaultCompanyName: map['defaultCompanyName']?.toString() ?? '',
      defaultCollectionPointId: map['defaultCollectionPointId']?.toString() ?? '',
      defaultCollectionPointName: map['defaultCollectionPointName']?.toString() ?? '',
      defaultDeliveryTime: map['defaultDeliveryTime']?.toString() ?? '12:30 PM',
      defaultDeliveryAddress: map['defaultDeliveryAddress']?.toString() ?? '',
      isAdmin: isOwnerOrAdmin,
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'mobile': mobile,
      'email': email,
      'address': address,
      'defaultCompanyId': defaultCompanyId,
      'defaultCompanyName': defaultCompanyName,
      'defaultCollectionPointId': defaultCollectionPointId,
      'defaultCollectionPointName': defaultCollectionPointName,
      'defaultDeliveryTime': defaultDeliveryTime,
      'defaultDeliveryAddress': defaultDeliveryAddress,
      'isAdmin': isAdmin,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  UserModel copyWith({
    String? name,
    String? mobile,
    String? email,
    String? address,
    String? defaultCompanyId,
    String? defaultCompanyName,
    String? defaultCollectionPointId,
    String? defaultCollectionPointName,
    String? defaultDeliveryTime,
    String? defaultDeliveryAddress,
    bool? isAdmin,
    dynamic updatedAt,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      address: address ?? this.address,
      defaultCompanyId: defaultCompanyId ?? this.defaultCompanyId,
      defaultCompanyName: defaultCompanyName ?? this.defaultCompanyName,
      defaultCollectionPointId: defaultCollectionPointId ?? this.defaultCollectionPointId,
      defaultCollectionPointName: defaultCollectionPointName ?? this.defaultCollectionPointName,
      defaultDeliveryTime: defaultDeliveryTime ?? this.defaultDeliveryTime,
      defaultDeliveryAddress: defaultDeliveryAddress ?? this.defaultDeliveryAddress,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
