import 'package:flutter/material.dart';

class UserData extends ChangeNotifier {
  String? userId;
  UserType? userType;

  void setUser(String id, UserType type) {
    userId = id;
    userType = type;
    notifyListeners();
  }
}

enum UserType { student, supervisor }
