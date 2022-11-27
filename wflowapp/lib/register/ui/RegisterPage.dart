import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:wflowapp/login/ui/LoginPage.dart';
import 'package:wflowapp/login/ui/login_text_box.dart';
import 'package:wflowapp/login/ui/login_title.dart';
import 'package:wflowapp/login/rest/LoginClient.dart';
import 'package:wflowapp/login/rest/LoginResponse.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final LoginClient client = LoginClient(
      url: 'https://49c13ba9-40e6-426b-be3c-21acf8b4f1d4.mock.pstmn.io',
      path: '/user/login');
  Future<LoginResponse>? _futureLogin;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Logo
            SizedBox(height: 40.0),
            LoginTitle(text: 'wFlow'),
            SizedBox(height: 60.0),
            // Email
            TextField(
              controller: emailController,
              obscureText: false,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Email",
                  hintText: "Email"),
            ),
            SizedBox(height: 30.0),
            // Password
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Password",
                  hintText: "Password"),
            ),
            SizedBox(height: 30.0),
            // Password
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Confirm password",
                  hintText: "Confirm password"),
            ),
            SizedBox(height: 30.0),
            // Register button
            buildRegisterButton(),
            SizedBox(height: 15.0),
            // Login text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()));
                  },
                  child: Text(
                    ' Click here',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                )
              ],
            ),
            SizedBox(height: 60.0),
            if (_futureLogin != null) buildFutureBuilder(),
          ],
        ),
      ),
    );
  }

  Widget buildRegisterButton() {
    return Container(
      height: 40.0,
      width: 140.0,
      decoration: BoxDecoration(
          color: Colors.blue, borderRadius: BorderRadius.circular(20.0)),
      child: ElevatedButton(
          style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.blue)))),
          onPressed: () {
            setState(() {
              String email = emailController.text;
              String password = passwordController.text;
              _futureLogin = client.login(email, password);
            });
          },
          child: const Text('REGISTER')),
    );
  }

  FutureBuilder<LoginResponse> buildFutureBuilder() {
    return FutureBuilder<LoginResponse>(
      future: _futureLogin,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data!.message);
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}',
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ));
        }

        return const CircularProgressIndicator();
      },
    );
  }
}
