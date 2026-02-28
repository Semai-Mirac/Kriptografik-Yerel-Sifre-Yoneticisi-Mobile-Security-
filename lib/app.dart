import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const borealisBackground = Color(0xFF050B16);
    const borealisSurface = Color(0xFF0A1424);
    const borealisPrimary = Color(0xFF4FE3C1);
    const borealisSecondary = Color(0xFF8B7CFF);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CipherGuard',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: borealisBackground,
        colorScheme: const ColorScheme.dark(
          primary: borealisPrimary,
          secondary: borealisSecondary,
          surface: borealisSurface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: borealisSurface,
          foregroundColor: Colors.white,
        ),
        cardColor: borealisSurface,
      ),
      home: const SplashScreen(),
    );
  }
}
