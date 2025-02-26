import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cashflow/controller/scan_receipt_controller.dart';
import 'package:cashflow/entities/transaction.dart';
import 'package:cashflow/model/providers/auth_provider.dart';
import 'package:cashflow/view/add_transaction_screen.dart';
import 'package:flutter/material.dart';
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
  late String? _token;

  // Instantiate the controller.
  late ScanReceiptController _scanController;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
    _scanController = ScanReceiptController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Uses the controller to capture an image and then navigates to the display screen.
  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final imagePath = await _scanController.captureImage(_controller);
      if (imagePath != null && mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DisplayPictureScreen(imagePath: imagePath),
          ),
        );
      }
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  /// Uses the controller to pick an image, scan it via OCR, and then navigate to the add transaction screen.
  Future<void> _pickImage() async {
    try {
      Transaction? transaction = await _scanController.scanImage(_token!);
      if (transaction != null) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                NewTransactionScreen(scannedTransaction: transaction),
          ),
        );
      } else {
        throw Exception('Failed to scan receipt.');
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'An error occurred while scanning the receipt, please enter the content manually'),
        ),
      );
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const NewTransactionScreen(),
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
                // Two buttons: one for taking a picture and one for picking from the gallery.
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
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

/// A simple view to display the captured image.
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
