import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';

class HeaterActuatorResponsePost {
  final int code;
  final String message;

  HeaterActuatorResponsePost({required this.code, required this.message});

  factory HeaterActuatorResponsePost.fromResponse(Response response) {
    dynamic json = jsonDecode(response.body);
    log(json.toString());
    HeaterActuatorResponsePost res = HeaterActuatorResponsePost(
        code: response.statusCode, message: json['message']);
    return res;
  }
}
