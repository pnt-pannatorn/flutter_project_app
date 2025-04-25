import 'package:flutter/material.dart';
import 'package:flutter_project_app/menu_tab.dart';
import 'package:flutter_project_app/splash_screen.dart';
import 'package:flutter_project_app/login.dart';
import 'package:flutter_project_app/editProfile.dart';
import 'package:flutter_project_app/resetpassword.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Air Quality Monitor',
        theme: ThemeData(
            appBarTheme: const AppBarTheme(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white)),
        home: const SplashScreen(), 
        routes: {
          '/login': (context) => const LoginPage(),
          '/menuTab': (context) => const TabMenu(),
          // '/profile': (context) => const ProfilePage(),
          '/editProfile': (context) => const EditProfilePage(),
          '/resetPassword': (context) => const ResetPasswordPage(),
        });
  }
}
