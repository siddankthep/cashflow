class Category {
  final String id;
  final String name;
  final String? icon;
  final String? color;

  Category({
    required this.id,
    required this.name,
    this.icon,
    this.color,
  });

  /// Creates a Category instance from a JSON map.
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      // Check if 'user' is null before trying to parse it.
      name: json['name'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );
  }

  /// Converts the Category instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "icon": icon,
      "color": color,
    };
  }

  @override
  String toString() {
    return 'Category{id: $id, name: $name, icon: $icon, color: $color}';
  }
}
