import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:wflowapp/main/profile/client/ProfileResponse.dart';

class ProfileClient {
  final String url;
  final String path;

  const ProfileClient({required this.url, required this.path});

  Future<ProfileResponse> getUserInfo(String key) async {
    Uri uri = Uri.https(url, path);
    log(name: 'HTTP', 'Calling $uri');
    final response = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $key'
      },
    );
    log(name: 'HTTP', 'Response from $path: ${response.statusCode}');
    return ProfileResponse.fromResponse(response);
  }

  Future<ProfileResponse> setUserInfo(
      String key,
      String email,
      String first_name,
      String last_name,
      String date_of_birth,
      String city,
      String occupation,
      String status,
      int family_members) async {
    String body = jsonEncode(<String, dynamic>{
      'email': email,
      'first_name': first_name,
      'last_name': last_name,
      'city': city,
      'occupation': occupation,
      'status': status,
      'family_members': family_members
    });
    Uri uri = Uri.https(url, path);
    log(name: 'HTTP', 'Calling $uri');
    log(name: 'HTTP', 'Body: $body');
    final response = await http.put(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $key'
        },
        body: body);
    log(name: 'HTTP', 'Response from $path: ${response.statusCode}');
    return ProfileResponse.fromResponse(response);
  }
}
