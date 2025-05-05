import 'dart:convert';
import 'package:cashflow/entities/user.dart';
import 'package:http/http.dart' as http;
import 'package:cashflow/model/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserService {
  final String baseUrl;

  // Constructor that takes the baseUrl
  UserService({required this.baseUrl});

  // Factory constructor that loads the URL from environment variables
  factory UserService.fromEnv() {
    return UserService(
      baseUrl: '${dotenv.env['API_BASE_URL']}/users/me',
    );
  }

  Future<User> getUser(BuildContext context, String token) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    int status = response.statusCode;
    print('Status Code: $status');
    print('Token: ${authProvider.jwtToken}');
    print('User: ${response.body}');
    if (status == 200) {
      print("Successfully retrieved transactions");
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      return User.fromJson(body);
    } else if (status == 403) {
      throw Exception('Invalid credentials');
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<User> updateUserBalance(
      BuildContext context, String token, double balance) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String balanceUrl = '${baseUrl}/update_balance';
    final response = await http.post(
      Uri.parse(balanceUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: balance.toString(),
    );

    int status = response.statusCode;
    print('Status Code: $status');
    print('Token: ${authProvider.jwtToken}');
    print('User: ${response.body}');
    if (status == 200) {
      print("Successfully updated user balance");
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      return User.fromJson(body);
    } else if (status == 403) {
      throw Exception('Invalid credentials');
    } else {
      throw Exception('Failed to update user balance');
    }
  }
}
