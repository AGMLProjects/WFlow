import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart';
import 'package:wflowapp/main/discover/model/Consume.dart';

class DiscoverResponse {
  final int code;
  final List<Consume> cityConsume;
  final List<Consume> averageRegionConsume;
  final List<Consume> regionConsume;
  final List<Consume> averageCountryConsume;
  final List<Consume> monthRegionConsume;

  DiscoverResponse(
      {required this.code,
      required this.cityConsume,
      required this.averageRegionConsume,
      required this.regionConsume,
      required this.averageCountryConsume,
      required this.monthRegionConsume});

  factory DiscoverResponse.fromResponse(Response response) {
    dynamic json;
    try {
      json = jsonDecode(response.body);
    } catch (e) {
      //
    }
    // log(json.toString());
    json = jsonDecode(
        "{\"city_consume\":[{\"year\":2023,\"month\":3,\"consume\":130},{\"year\":2023,\"month\":4,\"consume\":150},{\"year\":2023,\"month\":5,\"consume\":125},{\"year\":2023,\"month\":6,\"consume\":150},{\"year\":2023,\"month\":7,\"consume\":145},{\"year\":2023,\"month\":8,\"consume\":110}],\"avg_region_consume\":[{\"year\":2023,\"month\":3,\"consume\":140},{\"year\":2023,\"month\":4,\"consume\":110},{\"year\":2023,\"month\":5,\"consume\":120},{\"year\":2023,\"month\":6,\"consume\":130},{\"year\":2023,\"month\":7,\"consume\":150},{\"year\":2023,\"month\":8,\"consume\":110}],\"region_consume\":[{\"year\":2023,\"month\":3,\"consume\":140},{\"year\":2023,\"month\":4,\"consume\":150},{\"year\":2023,\"month\":5,\"consume\":150},{\"year\":2023,\"month\":6,\"consume\":150},{\"year\":2023,\"month\":7,\"consume\":150},{\"year\":2023,\"month\":8,\"consume\":110}],\"avg_country_consume\":[	{\"year\":2023,\"month\":3,\"consume\":140},{\"year\":2023,\"month\":4,\"consume\":150},{\"year\":2023,\"month\":5,\"consume\":150},{\"year\":2023,\"month\":6,\"consume\":150},{\"year\":2023,\"month\":7,\"consume\":150},{\"year\":2023,\"month\":8,\"consume\":110}],\"month_region_consume\":[{\"region\":\"Lombardia\",\"year\":2023,\"month\":8,\"consume\":100},{\"region\":\"Veneto\",\"year\":2023,\"month\":8,\"consume\":110},{\"region\":\"Liguria\",\"year\":2023,\"month\":8,\"consume\":110},{\"region\":\"Valle d'Aosta\",\"year\":2023,\"month\":8,\"consume\":110},{\"region\":\"Piemonte\",\"year\":2023,\"month\":8,\"consume\":110}]}");
    var consumeList = json['city_consume'] as List;
    List<Consume> cityConsume =
        consumeList.map((item) => Consume.fromJson(item)).toList();
    consumeList = json['avg_region_consume'] as List;
    List<Consume> averageRegionConsume =
        consumeList.map((item) => Consume.fromJson(item)).toList();
    consumeList = json['region_consume'] as List;
    List<Consume> regionConsume =
        consumeList.map((item) => Consume.fromJson(item)).toList();
    consumeList = json['avg_country_consume'] as List;
    List<Consume> averageCountryConsume =
        consumeList.map((item) => Consume.fromJson(item)).toList();
    consumeList = json['month_region_consume'] as List;
    List<Consume> monthRegionConsume =
        consumeList.map((item) => Consume.fromJson(item)).toList();

    DiscoverResponse res = DiscoverResponse(
        //code: response.statusCode,
        code: 200,
        cityConsume: cityConsume,
        averageRegionConsume: averageRegionConsume,
        regionConsume: regionConsume,
        averageCountryConsume: averageCountryConsume,
        monthRegionConsume: monthRegionConsume);

    return res;
  }
}
