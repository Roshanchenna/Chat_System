import 'package:flutter/material.dart';

class ChatState extends ChangeNotifier {
  String _chatCode = '';

  String get chatCode => _chatCode;

  void setChatCode(String code) {
    _chatCode = code;
    notifyListeners();
  }
}
