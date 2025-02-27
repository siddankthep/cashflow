import 'dart:convert';
import 'package:cashflow/entities/category.dart';
import 'package:http/http.dart' as http;

class CategoryService {
  final String baseUrl = 'http://10.0.2.2:8080/categories';

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
