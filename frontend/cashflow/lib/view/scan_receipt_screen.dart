import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cashflow/entities/transaction.dart';
import 'package:cashflow/model/providers/auth_provider.dart';
import 'package:cashflow/model/services/ocr_service.dart';
import 'package:cashflow/view/add_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ScanReceiptScreen extends StatefulWidget {
  const ScanReceiptScreen({super.key, required this.camera});

  final CameraDescription camera;

  @override
  ScanReceiptScreenState createState() => ScanReceiptScreenState();
}

class ScanReceiptScreenState extends State<ScanReceiptScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  final ImagePicker _picker = ImagePicker();
  late String? _token;

  @override
  void initState() {
    super.initState();
    // Initialize the CameraController with the given camera and resolution.
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    // Initialize the controller and store the Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      if (!mounted) return;

      // Navigate to the DisplayPictureScreen to display the captured image.
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(imagePath: image.path),
        ),
      );
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        Transaction transaction =
            await OCRService().scanReceipt(image.path, _token!);
        // Navigate to the DisplayPictureScreen to display the selected image.
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => NewTransactionScreen(
              scannedTransaction: transaction,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'An error occured while scanning the receipt, please enter the content manually')),
      );
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NewTransactionScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _token = authProvider.jwtToken;

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Receipt')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                // Container for the camera preview.
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    width: double.infinity,
                    child: CameraPreview(_controller),
                  ),
                ),
                // Two buttons: one for taking a picture and one for picking from the library.
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _takePicture,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Take Photo'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Select from Library'),
                      ),
                    ],
                  ),
                )
              ],
            );
          } else {
            // If the controller is still initializing, show a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

// A widget that displays the picture taken or selected by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display Picture')),
      body: Center(child: Image.file(File(imagePath))),
    );
  }
}
