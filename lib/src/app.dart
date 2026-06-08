import 'package:flutter/material.dart';

import 'home_screen.dart';

/// Brand palette tuned to match a native iOS LaunchScreen.storyboard, so the
/// Flutter first frame is visually identical to the storyboard the OS shows
/// during launch (no white flash / no layout jump).
class BrandColors {
  static const Color background = Color(0xFF0B1020);
  static const Color surface = Color(0xFF151B30);
  static const Color accent = Color(0xFF4F8CFF);
  static const Color accentAlt = Color(0xFF7C5CFF);
}

class LaunchSharePerfApp extends StatelessWidget {
  const LaunchSharePerfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iOS Launch / Share / Perf',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: BrandColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: BrandColors.accent,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
