import 'dart:developer';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wflowapp/config/AppConfig.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    AppConfig.setUserToken('AAAA'); // TODO: remove this
    String? savedToken = AppConfig.getUserToken();
    log(name: 'CONFIG', 'Read saved token: $savedToken');
    bool validToken = savedToken != null;
    // TODO: other checks on token...
    if (validToken) {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, 'main');
      });
    } else {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, 'login');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text('Loading...'),
        ),
      ),
    );
  }
}
