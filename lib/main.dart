import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'theme.dart';

void main() => runApp(const SekureDeliveryApp());

class SekureDeliveryApp extends StatelessWidget {
  const SekureDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sekure Delivery',
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