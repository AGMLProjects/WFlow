import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wflowapp/config/AppConfig.dart';
import 'package:wflowapp/main/profile/client/ProfileClient.dart';
import 'package:wflowapp/main/profile/client/ProfileResponse.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final emailController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final cityController = TextEditingController();

  final ProfileClient profileClient = ProfileClient(
      url: AppConfig.getBaseUrl(), path: AppConfig.getUsersPath());

  Future<ProfileResponse>? _futureProfileResponse;
  Future<ProfileResponse>? _futureProfileResponsePut;

  @override
  void initState() {
    super.initState();
    String? key = AppConfig.getUserToken();
    log(name: 'CONFIG', 'Read user key from config: ${key!}');
    _futureProfileResponse = profileClient.getUserInfo(key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: drawAppBar(),
      body: drawBody(),
    );
  }

  AppBar drawAppBar() {
    return AppBar(title: const Text('Profile'));
  }

  Widget drawBody() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(child: buildProfileInfo()),
          ),
        ],
      ),
    );
  }

  FutureBuilder<ProfileResponse> buildProfileInfo() {
    return FutureBuilder<ProfileResponse>(
      future: _futureProfileResponse,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.code != 200) {
            return const SizedBox.shrink();
          }
          emailController.text = snapshot.data!.email;
          firstNameController.text = snapshot.data!.first_name;
          lastNameController.text = snapshot.data!.last_name;
          dateOfBirthController.text = snapshot.data!.date_of_birth;
          cityController.text = snapshot.data!.city;
          double spaceBetween = 24.0;
          return Column(
            children: [
              SizedBox(height: spaceBetween),
              TextField(
                enabled: false,
                controller: emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Email",
                ),
              ),
              SizedBox(height: spaceBetween),
              TextField(
                enabled: true,
                controller: firstNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "First Name",
                ),
              ),
              SizedBox(height: spaceBetween),
              TextField(
                enabled: true,
                controller: lastNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Last Name",
                ),
              ),
              SizedBox(height: spaceBetween),
              TextField(
                enabled: true,
                controller: dateOfBirthController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Date of birth",
                ),
              ),
              SizedBox(height: spaceBetween),
              TextField(
                enabled: true,
                controller: cityController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "City",
                ),
              ),
              SizedBox(height: spaceBetween * 2),
              buildSaveButton()
            ],
          );
        } else if (snapshot.hasError) {
          return const SizedBox.shrink();
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget buildSaveButton() {
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
            String email = emailController.text;
            String first_name = firstNameController.text;
            String last_name = lastNameController.text;
            String date_of_birth = dateOfBirthController.text;
            String city = cityController.text;
            String? key = AppConfig.getUserToken();
            log(name: 'CONFIG', 'Read user key from config: ${key!}');
            _futureProfileResponsePut = profileClient.setUserInfo(key, email,
                first_name, last_name, date_of_birth, city, 'EMP', 'ENG', 1);
            emailController.text = email;
            firstNameController.text = first_name;
            lastNameController.text = last_name;
            dateOfBirthController.text = date_of_birth;
            cityController.text = city;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                "Successfully saved user information",
                textAlign: TextAlign.center,
              ),
            ));
          },
          child: const Text('SAVE')),
    );
  }
}
