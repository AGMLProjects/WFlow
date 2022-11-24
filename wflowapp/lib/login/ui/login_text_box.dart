import 'package:flutter/material.dart';

class LoginTextBox extends StatelessWidget {
  LoginTextBox(
      {super.key,
      required this.text,
      required this.obscure,
      required this.controller});

  final String text;
  final bool obscure;
  final TextEditingController controller;

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
