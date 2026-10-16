import 'package:flutter/material.dart';

class AppColors {
  static const black = Color(0xFF0B0B0F);
  static const white = Colors.white;
  static const yellow = Color(0xFFFFC21A);
  static const orange = Color(0xFFFF7A18);
  static const sky = Color(0xFF4FC3F7);
  static const lemon = Color(0xFFFFF44F);

  static const brandGradient = LinearGradient(
    colors: [yellow, orange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}