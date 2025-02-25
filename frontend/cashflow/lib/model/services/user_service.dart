import 'dart:convert';
import 'package:cashflow/entities/user.dart';
import 'package:http/http.dart' as http;
import 'package:cashflow/model/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class UserService {
  final String baseUrl = 'http://10.0.2.2:8080/users/me';

  Future<User> getUser(BuildContext context, String token) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${token}',
      },
    );

    int status = response.statusCode;
    print('Status Code: $status');
    print('Token: ${authProvider.jwtToken}');
    print('User: ${response.body}');
    if (status == 200) {
      print("Successfully retrieved transactions");
      final body = jsonDecode(response.body);
      return User.fromJson(body);
    } else if (status == 403) {
      throw Exception('Invalid credentials');
    } else {
      throw Exception('Failed to login');
    }
  }
}
