import 'package:flutter/material.dart';
import 'package:listen_then_task/pages/pages_home.dart';

import 'app/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ListenThenTask',
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}
