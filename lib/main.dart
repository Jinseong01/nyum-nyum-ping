import 'package:flutter/material.dart';
import 'package:nyum_nyum_ping/HomeScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: "nyum nyum ping",

      home: Homescreen(),
    );
  }
}
