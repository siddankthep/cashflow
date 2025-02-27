import 'package:camera/camera.dart';
import 'package:cashflow/entities/transaction.dart';
import 'package:cashflow/model/services/ocr_service.dart';
import 'package:image_picker/image_picker.dart';

class ScanReceiptController {
  final ImagePicker _picker = ImagePicker();

  /// Captures an image using the provided camera controller.
  Future<Transaction?> captureImage(
      CameraController controller, String token) async {
    try {
      // Assumes the controller is already initialized.
      final image = await controller.takePicture();
      Transaction transaction =
          await OCRService().scanReceipt(image.path, token);
      return transaction;
      // return image.path;
    } catch (e) {
      print('Error capturing image: $e');
    }
    return null;
  }

  /// Picks an image from the gallery and scans it using the OCR service.
  Future<Transaction?> scanImage(String token) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        Transaction transaction =
            await OCRService().scanReceipt(image.path, token);
        return transaction;
      }
    } catch (e) {
      print('Error picking or scanning image: $e');
    }
    return null;
  }
}
