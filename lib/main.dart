import 'package:flutter/material.dart';
import 'package:quick_aid_app/components/theme_notifier.dart';
import 'package:quick_aid_app/pages/home_page.dart';
import 'package:quick_aid_app/pages/intro_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool hasLaunched = prefs.getBool('hasLaunched') ?? false;

  runApp(
    ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(),
      child: MyApp(startOnIntro: !hasLaunched),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool startOnIntro;

  const MyApp({super.key, required this.startOnIntro});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.light(
          primary: Colors.red,
          secondary: Colors.redAccent,
          background: Colors.white,
          surface: Colors.white,
          onBackground: Colors.black,
          onSurface: Colors.black,
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(
          primary: Colors.red,
          secondary: Colors.redAccent,
          background: Colors.black,
          surface: Color(0xFF1E1E1E),
          onBackground: Colors.white,
          onSurface: Colors.white,
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),

        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),

      home: startOnIntro ? const IntroPage() : const HomePage(),
    );
  }
}
