import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart';
import 'package:wflowapp/main/discover/model/Consume.dart';

class DiscoverResponseCityRegion {
  final int code;
  final List<Consume> month_city_consume;
  final List<Consume> month_region_consume;

  DiscoverResponseCityRegion(
      {required this.code,
      required this.month_city_consume,
      required this.month_region_consume});

  factory DiscoverResponseCityRegion.fromResponse(Response response) {
    dynamic json;
    try {
      json = jsonDecode(response.body);
    } catch (e) {
      //
    }
    log(json.toString());

    var list = json['month_city_consume'] as List;
    List<Consume> month_city_consume =
        list.map((item) => Consume.fromJson(item)).toList();
    list = json['month_region_consume'] as List;
    List<Consume> month_region_consume =
        list.map((item) => Consume.fromJson(item)).toList();

    DiscoverResponseCityRegion res = DiscoverResponseCityRegion(
        code: response.statusCode,
        month_city_consume: month_city_consume,
        month_region_consume: month_region_consume);

    return res;
  }
}
