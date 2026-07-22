import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/screens/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JSON Demo',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}



