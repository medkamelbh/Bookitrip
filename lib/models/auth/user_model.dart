class UserModel {
  final String id;
  final String name;
  final String prenom;
  final String email;
  final String? phone;
  final String? city;
  final String? country;
  final String? photo;
  final String? status;

  const UserModel({
    required this.id,
    required this.name,
    required this.prenom,
    required this.email,
    this.phone,
    this.city,
    this.country,
    this.photo,
    this.status,
  });

  String get fullName => '$name $prenom'.trim();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      prenom: json['prenom']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['tel']?.toString(),
      city: json['city']?.toString() ?? json['ville']?.toString(),
      country: json['country']?.toString(),
      photo: json['photo']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'prenom': prenom,
        'email': email,
        'phone': phone,
        'city': city,
        'country': country,
        'photo': photo,
        'status': status,
      };

  UserModel copyWith({
    String? name,
    String? prenom,
    String? phone,
    String? city,
    String? country,
    String? photo,
  }) {
    return UserModel(
      id: id,
      email: email,
      status: status,
      name: name ?? this.name,
      prenom: prenom ?? this.prenom,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      country: country ?? this.country,
      photo: photo ?? this.photo,
    );
  }
}
