import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  /// Creates a Category instance from a JSON map.
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      // Check if 'user' is null before trying to parse it.
      name: json['name'] as String,
      icon: _getIconDataFromCodePointString((json['icon'])),
      color: Color(json['color']),
    );
  }

  /// Converts the Category instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "icon": _getIconCodePoint(icon),
      "color": _getColorCode(color),
    };
  }

  @override
  String toString() {
    return 'Category{id: $id, name: $name, icon: $icon, color: $color}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

IconData _getIconDataFromCodePointString(String? codePointString) {
  if (codePointString == null) {
    return Icons.help_outline;
  }

  // Remove potential "0x" prefix and parse the hexadecimal value.
  final hexString = codePointString.startsWith('0x')
      ? codePointString.substring(2)
      : codePointString;
  final codePoint =
      int.tryParse(hexString, radix: 16) ?? Icons.help_outline.codePoint;
  return IconData(codePoint, fontFamily: 'MaterialIcons');
}

String _getIconCodePoint(IconData iconData, {bool withPrefix = false}) {
  final codePointHex = iconData.codePoint.toRadixString(16);
  return withPrefix ? '0x$codePointHex' : codePointHex;
}

int _getColorCode(Color color) {
  return color.toARGB32();
}
