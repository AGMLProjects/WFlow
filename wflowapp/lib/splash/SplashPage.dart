import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:wflowapp/config/AppConfig.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    AppConfig.setUserKey('AAAA'); // TODO: remove this
    String? savedToken = AppConfig.getUserToken();
    log(name: 'CONFIG', 'Read saved token: $savedToken');
    bool validToken = savedToken != null;
    // TODO: other checks on token...
    if (validToken) {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, '/main');
      });
    } else {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Loading...'),
      ),
    );
  }
}
