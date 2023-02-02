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
    _loadConfig();
  }

  void _loadConfig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', 'AAAA'); // TODO: remove
    String? savedToken = prefs.getString('token');
    log('Read saved token: $savedToken');
    bool validToken = savedToken != null;
    // TODO: other checks on token...
    if (validToken) {
      Navigator.pushReplacementNamed(context, 'main');
    } else {
      Navigator.pushReplacementNamed(context, 'login');
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
