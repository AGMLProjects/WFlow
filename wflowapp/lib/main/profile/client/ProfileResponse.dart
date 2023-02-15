import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart';
import 'package:wflowapp/main/home/model/House.dart';

class ProfileResponse {
  final int code;
  final String email;
  final String username;
  final String first_name;
  final String last_name;
  final int age;
  final String occupation;
  final String date_of_birth;
  final String city;

  const ProfileResponse(
      {required this.code,
      required this.email,
      required this.username,
      required this.first_name,
      required this.last_name,
      required this.age,
      required this.occupation,
      required this.date_of_birth,
      required this.city});

  factory ProfileResponse.fromResponse(Response response) {
    dynamic json = jsonDecode(response.body);
    return ProfileResponse(
      code: response.statusCode,
      email: json['email'],
      username: json['username'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      age: json['age'],
      occupation: json['occupation'],
      date_of_birth: json['date_of_birth'],
      city: json['city'],
    );
  }
}
