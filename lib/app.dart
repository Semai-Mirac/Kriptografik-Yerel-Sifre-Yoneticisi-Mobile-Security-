import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'localization/app_localizations.dart';
import 'helpers/database_helper.dart';
import 'constants/storage_keys.dart';
import 'screens/splash_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, String languageCode) {
    final state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(Locale(languageCode));
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('tr');

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final languageCode = await DatabaseHelper.instance.getSetting(
      kLanguageCodeSettingKey,
    );

    if (!mounted || languageCode == null) {
      return;
    }

    const supported = {'tr', 'en', 'it', 'ko'};
    if (!supported.contains(languageCode)) {
      return;
    }

    setState(() {
      _locale = Locale(languageCode);
    });
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    DatabaseHelper.instance.setSetting(
      kLanguageCodeSettingKey,
      locale.languageCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    const borealisBackground = Color(0xFF050B16);
    const borealisSurface = Color(0xFF0A1424);
    const borealisPrimary = Color(0xFF4FE3C1);
    const borealisSecondary = Color(0xFF8B7CFF);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CipherGuard',
      locale: _locale,
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
        Locale('it'),
        Locale('ko'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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
