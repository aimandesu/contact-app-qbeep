import 'dart:async';

import 'package:flutter/material.dart';

class AppDefault {
  static final AppDefault _instance = AppDefault._internal();

  factory AppDefault() {
    return _instance;
  }

  AppDefault._internal();

  static const Color themeColor = Color(0xFFB90A5D);
  static const String defaultImage =
      'https://img.freepik.com/premium-vector/vector-flat-illustration-grayscale-avatar-user-profile-person-icon-profile-picture-business-profile-woman-suitable-social-media-profiles-icons-screensavers-as-templatex9_719432-1328.jpg?semt=ais_hybrid';
}

class Debounce {
  Debounce({this.milliseconds = 500});
  final int milliseconds;

  Timer? _timer;

  void run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
