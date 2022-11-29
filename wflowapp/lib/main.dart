import 'package:flutter/material.dart';
import 'package:wflowapp/mainpage/home/ui/HomePage.dart';
import 'package:wflowapp/mainpage/ui/MainPage.dart';
import 'package:wflowapp/register/ui/RegisterPage.dart';
import 'login/ui/LoginPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      initialRoute: 'login',
      routes: {
        'login': (context) => const LoginPage(),
        'register': (context) => const RegisterPage(),
        'main': (context) => const MainPage()
      },
    );
  }
}
