import 'package:flutter/material.dart';
import 'package:wflowapp/config/AppConfig.dart';
import 'package:wflowapp/user/client/RegisterClient.dart';
import 'package:wflowapp/user/client/RegisterResponse.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final RegisterClient client =
      RegisterClient(url: AppConfig.getBaseUrl(), path: '/user/register');
  Future<RegisterResponse>? _futureRegister;
  String emailErrorText = '';
  String passwordErrorText = '';
  String confirmPasswordErrorText = '';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
            const Text('wFlow',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 32.0,
                )),
            SizedBox(height: 60.0),
            // Email
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(emailErrorText, style: TextStyle(color: Colors.red)),
                SizedBox(height: 8.0),
                TextField(
                  controller: emailController,
                  obscureText: false,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Email",
                      hintText: "Email"),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            // Password
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(passwordErrorText, style: TextStyle(color: Colors.red)),
                SizedBox(height: 8.0),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Password",
                      hintText: "Password"),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            // Confirm password
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(confirmPasswordErrorText,
                    style: TextStyle(color: Colors.red)),
                SizedBox(height: 8.0),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Confirm password",
                      hintText: "Confirm password"),
                ),
              ],
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
                    Navigator.pushNamed(context, 'login');
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
            if (_futureRegister != null) buildFutureBuilder(),
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
              String confirmPassword = confirmPasswordController.text;
              if (!validateInputs(email, password, confirmPassword)) {
                return;
              }
              _futureRegister = client.register(email, password);
            });
          },
          child: const Text('REGISTER')),
    );
  }

  bool validateInputs(String email, String password, String confirmPassword) {
    bool ret = true;
    if (email.isEmpty) {
      emailErrorText = 'Email required';
      ret = false;
    } else {
      emailErrorText = '';
    }
    if (password.isEmpty) {
      passwordErrorText = 'Password required';
      ret = false;
    } else {
      passwordErrorText = '';
    }
    if (confirmPassword.isEmpty) {
      confirmPasswordErrorText = 'Password confirmation required';
      ret = false;
    } else {
      confirmPasswordErrorText = '';
    }
    if (ret == true) {
      if (password != confirmPassword) {
        confirmPasswordErrorText = 'The passwords don\'t match';
        ret = false;
      }
    }
    return ret;
  }

  FutureBuilder<RegisterResponse> buildFutureBuilder() {
    return FutureBuilder<RegisterResponse>(
      future: _futureRegister,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.code != 200) {
            return Text(snapshot.data!.message,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ));
          }
          Future.delayed(Duration.zero, () {
            Navigator.pushNamed(context, 'main');
          });
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
