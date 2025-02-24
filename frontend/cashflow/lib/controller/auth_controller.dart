import 'package:cashflow/model/auth_service.dart';
import 'package:cashflow/view/login_screen.dart';
import 'package:flutter/material.dart';

class AuthController {
  final _formKey = GlobalKey<FormState>();
  AuthenticationService _authService = AuthenticationService();

  // Handle login submission
  Future<String> login(context, String username, String password) async {
    try {
      print("Email: $username");
      print("Password: $password");
      String token = await _authService.login(username, password);
      print("Token: $token");
      return token;
    } catch (error) {
      // Catch any errors here
      print("Login failed: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
        ),
      );
      return '';
    }
  }

  // Handle registration submission
  Future<bool> register(BuildContext context, username, String email,
      String password, String firstName, String lastName) {
    print("Username: $username");
    print("Email: $email");
    print("Password: $password");

    return _authService
        .register(firstName, lastName, email, username, password)
        .then((_) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
      return true;
    }).catchError((error) {
      // Catch any errors here
      print("Registration failed: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    });
  }

  get formKey => _formKey;
}
