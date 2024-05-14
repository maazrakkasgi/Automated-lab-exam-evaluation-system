import 'package:flutter/material.dart';

class User {
  final String role;
  final String uid;

  User({required this.role, required this.uid});
}

class CurrentUser with ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }
}
