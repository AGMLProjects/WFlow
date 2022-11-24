import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:wflowapp/login/ui/login_text_box.dart';
import 'package:wflowapp/login/ui/login_title.dart';
import 'package:wflowapp/login/rest/LoginClient.dart';
import 'package:wflowapp/login/rest/LoginResponse.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
            // Login button
            buildLoginButton(),
            SizedBox(height: 15.0),
            const Text('Not registered? Click here',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.normal,
                  fontSize: 14.0,
                )),
            SizedBox(height: 60.0),
            if (_futureLogin != null) buildFutureBuilder(),
          ],
        ),
      ),
    );
  }

  Widget buildLoginButton() {
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
          child: const Text('LOGIN')),
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
