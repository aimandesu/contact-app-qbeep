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
