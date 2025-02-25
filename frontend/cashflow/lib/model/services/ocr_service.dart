import 'package:cashflow/entities/transaction.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OCRService {
  final String baseUrl = 'http://10.0.2.2:8080/ocr';

  Future<Transaction> scanReceipt(String photoPath, String bearerToken) async {
    final url = Uri.parse('$baseUrl/scan');

    // Create a multipart request.
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $bearerToken';

    // Attach the image file using the key 'image'.
    request.files.add(await http.MultipartFile.fromPath('image', photoPath));

    try {
      // Send the request.
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        print('Upload successful: $responseBody');
        final Map<String, dynamic> data = json.decode(responseBody);
        print('Finished decoding JSON');
        final Transaction transaction = Transaction.fromJson(data);
        print('Finished converting from JSON to Transaction');
        return transaction;
      } else {
        print('Upload failed with status: ${response.statusCode}');
        throw Exception('Failed to upload photo');
      }
    } catch (e) {
      print('Error sending photo: $e');
      throw Exception('An error occurred while uploading the photo');
    }
  }
}
