import 'package:flutter/material.dart';

class ConnectionStateNotifier extends ChangeNotifier {
  bool _isConnecting = false;
  bool _isConnected = false;

  bool get isConnecting => _isConnecting;
  bool get isConnected => _isConnected;


  void setConnecting(bool value) {
    _isConnecting = value;
    notifyListeners();
  }

  void setConnected(bool value) {
    _isConnected = value;
    notifyListeners();
  }
}
