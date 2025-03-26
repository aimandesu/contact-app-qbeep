import 'package:flutter/material.dart';

class AppColor {
  static final AppColor _instance = AppColor._internal();

  factory AppColor() {
    return _instance;
  }

  AppColor._internal();

  static const Color themeColor = Color(0xFFB90A5D);
}
