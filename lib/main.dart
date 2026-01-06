import 'package:flutter/material.dart';
import 'package:flutter_web_qr_generator/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qr Generator',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.redAccent)),
      home: const HomePage(),
    );
  }
}
