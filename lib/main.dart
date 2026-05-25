import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const FieldReportingApp());
}

class FieldReportingApp extends StatelessWidget {
  const FieldReportingApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Field Reporting System',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );

  }
}