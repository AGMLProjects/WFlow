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

class _SplashScreenPageState extends State<SplashScreenPage>
    with AfterLayoutMixin<SplashScreenPage> {
  Future checkToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', 'AAAA');
    String? savedToken = prefs.getString('token');
    log('Read saved token: $savedToken');
    bool validToken = savedToken != null;
    // TODO: other checks on token...
    if (validToken) {
      AppConfig.TOKEN = savedToken;
      Navigator.pushReplacementNamed(context, 'main');
    } else {
      Navigator.pushReplacementNamed(context, 'login');
    }
  }

  @override
  void afterFirstLayout(BuildContext context) => checkToken();

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
