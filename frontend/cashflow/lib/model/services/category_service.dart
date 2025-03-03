import 'dart:convert';
import 'package:cashflow/entities/category.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CategoryService {
  final String baseUrl;

  // Constructor that takes the baseUrl
  CategoryService({required this.baseUrl});

  // Factory constructor that loads the URL from environment variables
  factory CategoryService.fromEnv() {
    return CategoryService(
      baseUrl: '${dotenv.env['API_BASE_URL']}/categories',
    );
  }

  Future<List<Category>> getAllCategories(String? token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    int status = response.statusCode;
    print('Status Code: $status');
    print('Token: $token');
    print('Categories: ${response.body}');
    if (status == 200) {
      print("Successfully retrieved transactions");

      final body = jsonDecode(utf8.decode(response.bodyBytes));
      List<Category> categories = [];
      for (var item in body) {
        categories.add(Category.fromJson(item));
      }
      return categories;
    } else if (status == 403) {
      throw Exception('Invalid credentials');
    } else {
      throw Exception('Failed to login');
    }
  }
}
