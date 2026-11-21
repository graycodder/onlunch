class CompanyModel {
  final String id;
  final String name;
  final String address;
  final String contactPerson;
  final String contactNumber;
  final String email;
  final String status; // 'Active' or 'Inactive'
  final dynamic createdAt;

  CompanyModel({
    required this.id,
    required this.name,
    required this.address,
    this.contactPerson = '',
    this.contactNumber = '',
    this.email = '',
    this.status = 'Active',
    this.createdAt,
  });

  bool get isActive => status.toLowerCase() == 'active';

  factory CompanyModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return CompanyModel(
      id: id,
      name: map['name']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      contactPerson: map['contactPerson']?.toString() ?? '',
      contactNumber: map['contactNumber']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      status: map['status']?.toString() ?? 'Active',
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'contactPerson': contactPerson,
      'contactNumber': contactNumber,
      'email': email,
      'status': status,
      'createdAt': createdAt,
    };
  }

  CompanyModel copyWith({
    String? name,
    String? address,
    String? contactPerson,
    String? contactNumber,
    String? email,
    String? status,
  }) {
    return CompanyModel(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      contactPerson: contactPerson ?? this.contactPerson,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}

