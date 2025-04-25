import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:global_talk_app/screens/signinOrSignUp/auth_gate.dart';
import 'firebase_options.dart';
import 'screens/welcome/welcome_screen.dart';
import 'theme.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.appAttest, // For iOS
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global Talk',
      debugShowCheckedModeBanner: false,

      theme: lightThemeData(context),
      darkTheme: darkThemeData(context),
      themeMode: ThemeMode.light,
      // home: const WelcomeScreen(),
      home: const WelcomeScreen(),
    );
  }
}