import 'user.dart';

class Category {
  final String id;
  final User? user; // Now nullable
  final String name;
  final String? icon;
  final String? color;
  final DateTime createdAt;

  Category({
    required this.id,
    this.user,
    required this.name,
    this.icon,
    this.color,
    required this.createdAt,
  });

  /// Creates a Category instance from a JSON map.
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      // Check if 'user' is null before trying to parse it.
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Converts the Category instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user": user?.toJson(), // Use null-aware operator
      "name": name,
      "icon": icon,
      "color": color,
      "createdAt": createdAt.toIso8601String(),
    };
  }
}
