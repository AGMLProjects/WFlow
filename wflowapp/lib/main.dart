import 'package:flutter/material.dart';
import 'package:wflowapp/mainpage/house/device/ui/ScannerPage.dart';
import 'package:wflowapp/mainpage/house/device/ui/AddDevicePage.dart';
import 'package:wflowapp/mainpage/house/edithouse/ui/EditHousePage.dart';
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
      home: const SplashScreenPage(),
      initialRoute: 'splash',
      routes: {
        'splash': (context) => const SplashScreenPage(),
        'login': (context) => const LoginPage(),
        'register': (context) => const RegisterPage(),
        'main': (context) => const MainPage(),
        'addHouse': (context) => const AddHousePage(),
        'scan': (context) => const ScannerPage(),
        'house': (context) => const HousePage(),
        'editHouse': (context) => const EditHousePage(),
        'addDevice': (context) => const AddDevicePage()
      },
    );
  }
}
