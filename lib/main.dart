import 'package:flutter/material.dart';
import 'login_page.dart';

void main() => runApp(const NyctoryxApp());

class NyctoryxApp extends StatelessWidget {
  const NyctoryxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nyctoryx',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
    );
  }
}
