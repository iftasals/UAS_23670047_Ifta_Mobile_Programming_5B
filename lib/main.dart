import 'package:flutter/material.dart';
import 'login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RasaRia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFB6C1),
          primary: const Color(0xFFFFB6C1),
          secondary: const Color(0xFF98FB98),
          background: const Color(0xFFFFF5EE),
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}