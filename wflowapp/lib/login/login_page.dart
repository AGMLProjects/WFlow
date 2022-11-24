import 'package:flutter/material.dart';
import 'package:wflowapp/login/components/login_text_box.dart';
import 'package:wflowapp/login/components/login_title.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Logo
            SizedBox(height: 40.0),
            LoginTitle(text: 'SMARTAP'),
            SizedBox(height: 60.0),
            // Email
            LoginTextBox(text: 'Email', obscure: false),
            SizedBox(height: 20.0),
            // Password
            LoginTextBox(text: 'Password', obscure: true),
            SizedBox(height: 20.0),
            // Login button
            Container(
              height: 40.0,
              width: 140.0,
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20.0)),
              child: TextButton(onPressed: null, child: Text('LOGIN')),
            )
          ],
        ),
      ),
    );
  }
}
