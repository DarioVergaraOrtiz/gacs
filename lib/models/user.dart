class User {
  final String name;
  final String lastName;

  User({required this.name, required this.lastName});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'lastName': lastName,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'] ?? '',
      lastName: map['lastName'] ?? '',
    );
  }
}