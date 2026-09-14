import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';

class KrishiSaarthiApp extends StatelessWidget {
  const KrishiSaarthiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'कृषि-सारथी | Krishi-Saarthi',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      themeMode: ThemeMode.light,
      home: const HomeScreen(),
      // Localization
      locale: const Locale('hi', 'IN'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('hi', 'IN'),
        Locale('en', 'US'),
      ],
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1B4332), // Stitch Deep Forest Emerald
        primary: const Color(0xFF1B4332),
        secondary: const Color(0xFF8B5A2B), // Stitch Warm Earth Ochre
        surface: const Color(0xFFFFFFFF),
        error: const Color(0xFFB91C1C),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F7F4), // Stitch Crisp Warm Off-White
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Color(0xFFF8F7F4),
        foregroundColor: Color(0xFF1B4332),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE7E4DC)),
        ),
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF1B4332),
        unselectedItemColor: Color(0xFF6E756F),
        elevation: 8,
      ),
    );
  }
}
