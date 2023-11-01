import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';

class HeaterActuatorResponseGet {
  final int code;
  final bool status;
  final bool automatic;
  final List<double> temperatures;
  final List<DateTime> starts;
  final List<DateTime> ends;

  HeaterActuatorResponseGet(
      {required this.code,
      required this.status,
      required this.automatic,
      required this.temperatures,
      required this.starts,
      required this.ends});

  factory HeaterActuatorResponseGet.fromResponse(Response response) {
    if (response.statusCode == 200) {
      dynamic json = jsonDecode(response.body);
      log(json.toString());
      HeaterActuatorResponseGet res = HeaterActuatorResponseGet(
          code: response.statusCode,
          status: json['values']['status'],
          automatic: json['values']['automatic'],
          temperatures: json['values']['temperature'],
          starts: json['values']['time_start'],
          ends: json['values']['time_end']);
      return res;
    } else {
      bool status = true, automatic = true;
      List<double> temperatures = [24.0, 26.0, 24.0];
      List<DateTime> starts = [
        DateTime(2023, 1, 1, 8, 0),
        DateTime(2023, 1, 1, 17, 30),
        DateTime(2023, 1, 1, 20, 0),
      ];
      List<DateTime> ends = [
        DateTime(2023, 1, 1, 8, 30),
        DateTime(2023, 1, 1, 18, 30),
        DateTime(2023, 1, 1, 21, 0),
      ];
      HeaterActuatorResponseGet res = HeaterActuatorResponseGet(
          code: 200,
          status: status,
          automatic: automatic,
          temperatures: temperatures,
          starts: starts,
          ends: ends);
      return res;
    }
  }
}
