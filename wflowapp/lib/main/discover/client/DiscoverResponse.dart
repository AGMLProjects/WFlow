import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart';

class DiscoverResponse {
  final int code;
  final String email;

  DiscoverResponse({required this.code, required this.email});

  factory DiscoverResponse.fromResponse(Response response) {
    dynamic json = jsonDecode(response.body);
    log(json.toString());
    DiscoverResponse res =
        DiscoverResponse(code: response.statusCode, email: json['email']);

    return res;
  }
}
