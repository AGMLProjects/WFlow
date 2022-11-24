import 'package:flutter/material.dart';

class LoginTextBox extends StatelessWidget {
  const LoginTextBox({super.key, required this.text, required this.obscure});

  final String text;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: TextField(
      obscureText: this.obscure,
      decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: this.text,
          hintText: this.text),
    ));
  }
}
