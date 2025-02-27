import 'package:cashflow/model/providers/camera_provider.dart';
import 'package:cashflow/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:cashflow/model/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import 'package:camera/camera.dart';

import 'package:flutter/material.dart';

/// Converts a hex string (with or without a leading "#") into a Color.
/// If the hex string doesn't include an alpha value, it assumes full opacity.
Color getColorFromHex(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor; // add opacity if not provided
  }
  return Color(int.parse(hexColor, radix: 16));
}

/// Returns the hexadecimal string representation of the [iconData]'s code point.
///
/// If [withPrefix] is true, the returned string will be prefixed with "0x".
String getIconCodePoint(IconData iconData, {bool withPrefix = false}) {
  final codePointHex = iconData.codePoint.toRadixString(16);
  return withPrefix ? '0x$codePointHex' : codePointHex;
}

/// Creates an Icon widget from a stored code point string.
Icon getIconFromCodePointString(String? codePointString,
    {Color color = Colors.black, double size = 24.0}) {
  if (codePointString == null) {
    return Icon(Icons.help_outline, color: color, size: size);
  }

  // Remove a potential "0x" prefix and parse the hexadecimal value.
  final hexString = codePointString.startsWith('0x')
      ? codePointString.substring(2)
      : codePointString;
  final codePoint =
      int.tryParse(hexString, radix: 16) ?? Icons.help_outline.codePoint;
  return Icon(IconData(codePoint, fontFamily: 'MaterialIcons'),
      color: color, size: size);
}

void main() {
  // Example usage:
  // Suppose we stored the code point for the restaurant icon as "e56c"
  // String storedHexColor = "#0000FF";
  Color color = Colors.orange[300]!;
  int storedHexColor = color.toARGB32();
  print(storedHexColor);
  String storedCodePoint = getIconCodePoint(Icons.sports_basketball_rounded);
  final restaurantIcon = getIconFromCodePointString(storedCodePoint,
      // color: getColorFromHex(storedHexColor), size: 50);
      color: color,
      size: 50);

  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text("Code Point Icon Example")),
      body: Center(
          child: Column(
        children: [
          restaurantIcon,
          Text(storedCodePoint),
          Text(color.toARGB32().toString()),
        ],
      )),
    ),
  ));
}

// Future<void> main() async {
//   // Ensure that plugin services are initialized so that `availableCameras()`
//   // can be called before `runApp()`
//   WidgetsFlutterBinding.ensureInitialized();

//   // Obtain a list of the available cameras on the device.
//   final cameras = await availableCameras();

//   // Get a specific camera from the list of available cameras.
//   final firstCamera = cameras.first;

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//         ChangeNotifierProvider(
//             create: (_) => CameraProvider()..setFirstCamera(firstCamera)),
//       ],
//       child: MyApp(),
//     ),
//   );
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cashflow',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}
