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
      if (jsonDecode(response.body).length == 0) {
        return HeaterActuatorResponseGet(
            code: response.statusCode,
            status: false,
            automatic: true,
            temperatures: List.empty(),
            starts: List.empty(),
            ends: List.empty());
      }
      dynamic json = jsonDecode(response.body)[0];
      log(json.toString());
      List<double> temperatures = [];
      for (double str in json['values']['temperature']) {
        temperatures.add(str);
      }
      List<DateTime> starts = [];
      for (String str in json['values']['time_start']) {
        starts.add(DateTime.parse(str));
      }
      List<DateTime> ends = [];
      for (String str in json['values']['time_end']) {
        ends.add(DateTime.parse(str));
      }
      HeaterActuatorResponseGet res = HeaterActuatorResponseGet(
          code: response.statusCode,
          status: json['values']['status'],
          automatic: json['values']['automatic'],
          temperatures: temperatures,
          starts: starts,
          ends: ends);
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
