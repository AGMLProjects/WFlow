import 'package:flutter/material.dart';

class LoginTitle extends StatelessWidget {
  const LoginTitle({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(this.text,
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
          fontSize: 32.0,
        ));
  }
}
