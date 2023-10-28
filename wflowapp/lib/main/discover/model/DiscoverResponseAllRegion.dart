import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart';
import 'package:wflowapp/main/discover/model/Consume.dart';
import 'package:wflowapp/main/discover/model/GenericConsume.dart';

class DiscoverResponseAllRegion {
  final int code;
  final int current_month;
  final int current_year;
  final List<GenericConsume> region_consumes;

  DiscoverResponseAllRegion(
      {required this.code,
      required this.current_month,
      required this.current_year,
      required this.region_consumes});

  factory DiscoverResponseAllRegion.fromResponse(Response response) {
    dynamic json;
    try {
      json = jsonDecode(response.body);
    } catch (e) {
      //
    }
    log(json.toString());

    var list = json['region_consumes'] as List;
    List<GenericConsume> region_consumes =
        list.map((item) => GenericConsume.fromJson(item)).toList();

    DiscoverResponseAllRegion res = DiscoverResponseAllRegion(
        code: response.statusCode,
        region_consumes: region_consumes,
        current_month: json['current_month'],
        current_year: json['current_year']);

    return res;
  }
}
