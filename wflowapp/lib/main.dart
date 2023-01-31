import 'package:flutter/material.dart';
import 'package:wflowapp/mainpage/addhouse/ui/EditHousePage.dart';
import 'package:wflowapp/mainpage/addhouse/ui/ScannerPage.dart';
import 'package:wflowapp/mainpage/home/ui/HomePage.dart';
import 'package:wflowapp/mainpage/ui/MainPage.dart';
import 'package:wflowapp/register/ui/RegisterPage.dart';
import 'package:wflowapp/splash/SplashScreenPage.dart';
import 'login/ui/LoginPage.dart';
import 'mainpage/addhouse/ui/AddHousePage.dart';
import 'mainpage/house/ui/HousePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreenPage(),
      initialRoute: 'splash',
      routes: {
        'splash': (context) => const SplashScreenPage(),
        'login': (context) => const LoginPage(),
        'register': (context) => const RegisterPage(),
        'main': (context) => const MainPage(),
        'addHouse': (context) => const AddHousePage(),
        'scan': (context) => const ScannerPage(),
        'editHouse': (context) => const EditHousePage(),
        'house': (context) => const HousePage(),
      },
    );
  }
}
