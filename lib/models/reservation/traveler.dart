class Traveler {
  final String civility; // 'Mr', 'Mme', 'Enfant'
  final String firstName;
  final String lastName;
  final int? age; // Null for adults, int for children
  final bool isHolder;

  const Traveler({
    required this.civility,
    required this.firstName,
    required this.lastName,
    this.age,
    this.isHolder = false,
  });

  Traveler copyWith({
    String? civility,
    String? firstName,
    String? lastName,
    int? age,
    bool? isHolder,
  }) {
    return Traveler(
      civility: civility ?? this.civility,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      isHolder: isHolder ?? this.isHolder,
    );
  }

  Map<String, dynamic> toTgtAdultJson() => {
    "Civility": civility,
    "Name": firstName,
    "Surname": lastName,
    "Holder": isHolder
  };
  
  Map<String, dynamic> toTgtChildJson() => {
    "Age": age,
    "Civility": civility,
    "Name": firstName,
    "Surname": lastName
  };
  
  Map<String, dynamic> toBhrJson() => {
    "civility": civility,
    "first_name": firstName,
    "last_name": lastName
  };
}
