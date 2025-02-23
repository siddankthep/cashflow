class User {
  final String id;
  final String email;
  final String username;
  final String passwordHash;
  final String firstName;
  final String lastName;
  final String preferredCurrency;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.passwordHash,
    required this.firstName,
    required this.lastName,
    this.preferredCurrency = "VND",
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [User] instance from a JSON map.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      passwordHash: json['passwordHash'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      preferredCurrency: json['preferredCurrency'] as String? ?? "VND",
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Converts the [User] instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "email": email,
      "username": username,
      "passwordHash": passwordHash,
      "firstName": firstName,
      "lastName": lastName,
      "preferredCurrency": preferredCurrency,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }
}
