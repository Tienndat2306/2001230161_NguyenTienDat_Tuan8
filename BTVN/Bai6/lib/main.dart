import 'package:flutter/material.dart';
import 'screens/user_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3D3A8C),
          primary: const Color(0xFF3D3A8C),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const UserListScreen(),
    );
  }
}