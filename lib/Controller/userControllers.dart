import 'package:flutter/material.dart';
class UserState extends ChangeNotifier {
  dynamic credentials;
  bool isConnecting = false;
  bool isConnected = false;

  void setCredentials(dynamic credentials) {
    this.credentials = credentials;
    notifyListeners();
  }

  void setIsConnecting(bool value) {
    isConnecting = value;
    notifyListeners();
  }

  void setIsConnected(bool value) {
    isConnected = value;
    notifyListeners();
  }
}