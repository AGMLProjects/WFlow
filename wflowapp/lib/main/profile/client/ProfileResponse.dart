import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart';

class ProfileResponse {
  final int code;
  final String email;
  String first_name = '';
  String last_name = '';
  int age = 0;
  String occupation = '';
  String date_of_birth = '';
  String city = '';
  String status = '';
  int family_members = 1;

  ProfileResponse({required this.code, required this.email});

  factory ProfileResponse.fromResponse(Response response) {
    dynamic json = jsonDecode(response.body);
    log(json.toString());
    ProfileResponse res =
        ProfileResponse(code: response.statusCode, email: json['email']);
    if (json['first_name'] != null) {
      res.first_name = json['first_name'];
    }
    if (json['last_name'] != null) {
      res.last_name = json['last_name'];
    }
    if (json['age'] != null) {
      res.age = json['age'];
    }
    if (json['occupation'] != null) {
      res.occupation = json['occupation'];
    }
    if (json['date_of_birth'] != null) {
      res.date_of_birth = json['date_of_birth'];
    }
    if (json['city'] != null) {
      res.city = json['city'];
    }
    if (json['status'] != null) {
      res.status = json['status'];
    }
    if (json['family_members'] != null) {
      res.family_members = json['family_members'];
    }
    return res;
  }
}
