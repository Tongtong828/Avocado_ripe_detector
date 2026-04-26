import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'homepage.dart';

void main() {
  runApp(const AvocadoApp());
}

class AvocadoApp extends StatelessWidget {
  const AvocadoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Avocado Ripeness Detector',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7FBF5),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7BAE5D)),
      ),
      home: const SplashScreen(
        nextScreen: HomePage(),
      ),
    );
  }
}