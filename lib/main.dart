import 'package:flutter/material.dart';

import 'screens/opening_login_screen.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const LincolnLifeApp());
}

class LincolnLifeApp extends StatelessWidget {
  const LincolnLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LincolnLife',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.loaderEdge,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.amber,
          brightness: Brightness.dark,
        ),
      ),
      home: const OpeningLoginScreen(),
    );
  }
}
