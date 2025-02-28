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
  bool _isScanning = false;

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
    setState(() {
      _isScanning = true; // Start showing the progress indicator
    });
    try {
      await _initializeControllerFuture;
      Transaction? transaction =
          await _scanController.captureImage(_controller, _token!);
      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                NewTransactionScreen(scannedTransaction: transaction),
          ),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while scanning the receipt'),
        ),
      );
    } finally {
      setState(() {
        _isScanning = false; // Stop showing the progress indicator
      });
    }
  }

  Future<void> _pickImage() async {
    setState(() {
      _isScanning = true; // Start showing the progress indicator
    });
    try {
      Transaction? transaction = await _scanController.scanImage(_token!);
      if (transaction != null) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                NewTransactionScreen(scannedTransaction: transaction),
          ),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'An error occurred while scanning the receipt. Please enter the details manually.'),
        ),
      );
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NewTransactionScreen(),
        ),
      );
    } finally {
      setState(() {
        _isScanning = false; // Stop showing the progress indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _token = authProvider.jwtToken;

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Receipt')),
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Column(
                  children: [
                    Expanded(
                        child: RotatedBox(
                      quarterTurns: 1,
                      child: CameraPreview(_controller),
                    )),
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
                            // Disable the button while scanning
                            onPressed: _isScanning ? null : _pickImage,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Select from Library'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          // Overlay loading indicator when scanning
          if (_isScanning)
            Container(
              color: Colors.black54, // Semi-transparent background
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Scanning receipt...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewTransactionScreen()),
          );
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
