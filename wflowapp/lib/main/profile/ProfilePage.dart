import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
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
  String? occupation;
  String? status;
  int? family_members;

  final ProfileClient profileClient = ProfileClient(
      url: AppConfig.getBaseUrl(), path: AppConfig.getUsersPath());

  Future<ProfileResponse>? _futureProfileResponse;
  Future<ProfileResponse>? _futureProfileResponsePut;

  @override
  void initState() {
    super.initState();
    String? key = AppConfig.getUserToken();
    log(name: 'CONFIG', 'Read user key from config: ${key!}');
    family_members = -1;
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

          if (snapshot.data!.occupation.isEmpty) {
            occupation ??= 'NON';
          } else {
            occupation ??= snapshot.data!.occupation;
          }

          if (snapshot.data!.status.isEmpty) {
            status ??= 'NON';
          } else {
            status ??= snapshot.data!.status;
          }

          if (family_members == -1) {
            family_members = snapshot.data!.family_members;
          }

          List<DropdownMenuItem<String>> familyMembersItems = [];
          for (int i = 1; i <= 10; i++) {
            DropdownMenuItem<String> item = DropdownMenuItem(
              value: i.toString(),
              child: Text(i.toString()),
            );
            familyMembersItems.add(item);
          }

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
              SizedBox(height: spaceBetween),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'Occupation: ',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  const SizedBox(width: 10.0),
                  DropdownButton(
                    items: const [
                      DropdownMenuItem(
                        value: 'NON',
                        child: Text('None'),
                      ),
                      DropdownMenuItem(
                        value: 'EMP',
                        child: Text('Employee'),
                      ),
                      DropdownMenuItem(
                        value: 'UNE',
                        child: Text('Unemployed'),
                      ),
                      DropdownMenuItem(
                        value: 'STU',
                        child: Text('Student'),
                      ),
                      DropdownMenuItem(
                        value: 'RET',
                        child: Text('Retired'),
                      ),
                      DropdownMenuItem(
                        value: 'ENT',
                        child: Text('Entepreneur'),
                      ),
                      DropdownMenuItem(
                        value: 'FRE',
                        child: Text('Freelancer'),
                      ),
                    ],
                    value: occupation,
                    onChanged: dropDownCallbackOccupation,
                    style: const TextStyle(fontSize: 18),
                  )
                ],
              ),
              SizedBox(height: spaceBetween),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'Status: ',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  const SizedBox(width: 10.0),
                  DropdownButton(
                    items: const [
                      DropdownMenuItem(
                        value: 'NON',
                        child: Text('None'),
                      ),
                      DropdownMenuItem(
                        value: 'SIN',
                        child: Text('Single'),
                      ),
                      DropdownMenuItem(
                        value: 'REL',
                        child: Text('In a relationship'),
                      ),
                      DropdownMenuItem(
                        value: 'ENG',
                        child: Text('Engaged'),
                      ),
                      DropdownMenuItem(
                        value: 'MAR',
                        child: Text('Married'),
                      ),
                    ],
                    value: status,
                    onChanged: dropDownCallbackStatus,
                    style: const TextStyle(fontSize: 18),
                  )
                ],
              ),
              SizedBox(height: spaceBetween),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'Family members: ',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  const SizedBox(width: 10.0),
                  DropdownButton(
                    items: familyMembersItems,
                    value: family_members.toString(),
                    onChanged: dropDownCallbackFamilyMembers,
                    style: const TextStyle(fontSize: 18),
                  )
                ],
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

  void dropDownCallbackOccupation(String? selectedValue) {
    if (selectedValue is String) {
      setState(() {
        occupation = selectedValue;
      });
    }
  }

  void dropDownCallbackStatus(String? selectedValue) {
    if (selectedValue is String) {
      setState(() {
        status = selectedValue;
      });
    }
  }

  void dropDownCallbackFamilyMembers(String? selectedValue) {
    if (selectedValue is String) {
      setState(() {
        family_members = int.parse(selectedValue);
      });
    }
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
            _futureProfileResponsePut = profileClient.setUserInfo(
                key,
                email,
                first_name,
                last_name,
                date_of_birth,
                city,
                occupation!,
                status!,
                family_members!);
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
