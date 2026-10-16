import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'theme.dart';

void main() => runApp(const SekureCourierApp());

class SekureCourierApp extends StatelessWidget {
  const SekureCourierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sekure Courier',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppColors.orange,
        scaffoldBackgroundColor: AppColors.black,
      ),
      home: const SplashScreen(),
    );
  }
}