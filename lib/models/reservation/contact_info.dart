class ContactInfo {
  final String lastName;
  final String firstName;
  final String cin;
  final String email;
  final String phone;
  final String city;
  final String countryCode;

  const ContactInfo({
    required this.lastName,
    required this.firstName,
    required this.cin,
    required this.email,
    required this.phone,
    required this.city,
    required this.countryCode,
  });

  Map<String, dynamic> toJson() => {
    'lastName': lastName,
    'firstName': firstName,
    'cin': cin,
    'email': email,
    'phone': phone,
    'city': city,
    'countryCode': countryCode,
  };

  ContactInfo copyWith({
    String? lastName,
    String? firstName,
    String? cin,
    String? email,
    String? phone,
    String? city,
    String? countryCode,
  }) {
    return ContactInfo(
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      cin: cin ?? this.cin,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      countryCode: countryCode ?? this.countryCode,
    );
  }
}
