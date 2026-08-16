import 'package:flutter/material.dart';
import 'package:listen_then_task/pages/pages_home.dart';

import 'app/app_theme.dart';
import 'auth/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.instance.init();
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
