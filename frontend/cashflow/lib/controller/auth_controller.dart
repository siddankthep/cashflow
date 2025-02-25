import 'package:cashflow/entities/user.dart';
import 'package:cashflow/model/services/auth_service.dart';
import 'package:cashflow/model/providers/auth_provider.dart';
import 'package:cashflow/model/services/user_service.dart';
import 'package:cashflow/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthController {
  final _formKey = GlobalKey<FormState>();
  AuthenticationService _authService = AuthenticationService();
  UserService _userService = UserService();

  // Handle login submission
  Future<void> login(context, String username, String password) async {
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    try {
      print("Email: $username");
      print("Password: $password");
      String token = await _authService.login(username, password);
      print("Token: $token");
      User user = await _userService.getUser(context, token);
      print("User: ${user.toString()}");
      authProvider.setUser(user);
      authProvider.setToken(token);
      return;
    } catch (error) {
      // Catch any errors here
      print("Login failed: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
        ),
      );
      return;
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
