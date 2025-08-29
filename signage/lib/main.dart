import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(SignAgeApp());
}

class SignAgeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SignAge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.deepPurple,
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurpleAccent,
          secondary: Colors.purpleAccent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          centerTitle: true,
          elevation: 4,
        ),
        fontFamily: 'Roboto',
      ),
      home: SplashScreen(),
    );
  }
}
