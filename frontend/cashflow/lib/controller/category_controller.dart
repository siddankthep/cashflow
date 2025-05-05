import 'package:flutter/material.dart';
import 'package:cashflow/model/services/category_service.dart';

class CategoryController {
  CategoryService _categoryService = CategoryService.fromEnv();

  /// Converts a hex string (with or without a leading "#") into a Color.
  /// If the hex string doesn't include an alpha value, it assumes full opacity.
  Color _getColorFromCode(int colorCode) {
    return Color(colorCode);
  }

  int _getColorCode(Color color) {
    return color.toARGB32();
  }

  /// Returns the hexadecimal string representation of the [iconData]'s code point.
  ///
  /// If [withPrefix] is true, the returned string will be prefixed with "0x".
  String _getIconCodePoint(IconData iconData, {bool withPrefix = false}) {
    final codePointHex = iconData.codePoint.toRadixString(16);
    return withPrefix ? '0x$codePointHex' : codePointHex;
  }

  /// Returns an IconData from a stored code point string.
  /// If the [codePointString] is null, returns the IconData for help_outline.
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
}
