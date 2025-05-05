import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthenticationService {
  final String baseUrl;

  // Constructor that takes the baseUrl
  AuthenticationService({required this.baseUrl});

  // Factory constructor that loads the URL from environment variables
  factory AuthenticationService.fromEnv() {
    return AuthenticationService(
      baseUrl: '${dotenv.env['API_BASE_URL']}/auth',
    );
  }

  Future<String> login(String username, String password) async {
    print('API URL: $baseUrl');
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json',
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
      return jsonDecode(utf8.decode(response.bodyBytes))['token'];
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
        'Content-Type': 'application/json',
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
