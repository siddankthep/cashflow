import 'package:cashflow/model/providers/camera_provider.dart';
import 'package:cashflow/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:cashflow/model/providers/auth_provider.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;

import 'package:camera/camera.dart';

Future<void> main() async {
  // Load the .env file
  // await dotenv.load(fileName: ".env");
  String? apiUrl = Platform.environment['API_URL'];
  print('API URL: $apiUrl');

  // Existing initialization code
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  CameraDescription? firstCamera;
  if (cameras.isNotEmpty) {
    firstCamera = cameras.first;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
            create: (_) => CameraProvider()..setFirstCamera(firstCamera!)),
      ],
      child: MyApp(),
    ),
  );
}

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
