import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthenticationService {
  // final String baseUrl = 'http://localhost:8080/auth';
  final String baseUrl = 'http://10.0.2.2:8080/auth';

  Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    int status = response.statusCode;
    print('Status Code: $status');
    if (status == 200) {
      print("Logged in successfully!");
      return jsonDecode(response.body)['token'];
    } else if (status == 403) {
      throw Exception('Invalid credentials');
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<void> register(String firstName, String lastName, String email,
      String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to register');
    }
    print("User registered successfully");
  }
}
