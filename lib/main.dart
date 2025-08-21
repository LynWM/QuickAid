import 'package:flutter/material.dart';
import 'package:quick_aid_app/components/theme_notifier.dart';
import 'package:quick_aid_app/pages/intro_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:quick_aid_app/services/authgate_page.dart';
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
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: startOnIntro? const IntroPage() : const AuthGate(),
    );
  }
}
