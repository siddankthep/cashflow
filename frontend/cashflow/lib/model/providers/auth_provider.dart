import 'package:cashflow/entities/user.dart';
import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  String? _jwtToken;
  User? _user;

  String? get jwtToken => _jwtToken;
  User? get user => _user;

  void setToken(String token) {
    _jwtToken = token;
    notifyListeners(); // Notifies any listeners about the change.
  }

  void clearToken() {
    _jwtToken = null;
    notifyListeners();
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
