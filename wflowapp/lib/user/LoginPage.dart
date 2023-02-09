import 'package:flutter/material.dart';
import 'package:wflowapp/config/AppConfig.dart';
import 'package:wflowapp/user/client/LoginClient.dart';
import 'package:wflowapp/user/client/LoginResponse.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final LoginClient client =
      LoginClient(url: AppConfig.getBaseUrl(), path: '/user/login');
  Future<LoginResponse>? _futureLogin;
  String emailErrorText = '';
  String passwordErrorText = '';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: drawAppBar(),
      body: drawBody(),
    );
  }

  AppBar drawAppBar() {
    return AppBar(title: const Text('Login'));
  }

  Widget drawBody() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          children: [
            // Logo
            const SizedBox(height: 40.0),
            const Text('wFlow',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 32.0,
                )),
            const SizedBox(height: 60.0),
            // Email
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(emailErrorText, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8.0),
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
            const SizedBox(height: 10.0),
            // Password
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(passwordErrorText,
                    style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8.0),
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
            const SizedBox(height: 30.0),
            // Login button
            buildLoginButton(),
            const SizedBox(height: 15.0),
            // Register text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Not registered yet?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text(
                    ' Click here',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                )
              ],
            ),
            const SizedBox(height: 60.0),
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
                      side: const BorderSide(color: Colors.blue)))),
          onPressed: () {
            setState(() {
              String email = emailController.text;
              String password = passwordController.text;
              if (!validateInputs(email, password)) return;
              _futureLogin = client.login(email, password);
            });
          },
          child: const Text('LOGIN')),
    );
  }

  bool validateInputs(String email, String password) {
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
    return ret;
  }

  FutureBuilder<LoginResponse> buildFutureBuilder() {
    return FutureBuilder<LoginResponse>(
      future: _futureLogin,
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
            Navigator.pushNamed(context, '/main');
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
