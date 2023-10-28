import 'dart:convert';
import 'dart:developer';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wflowapp/config/AppConfig.dart';
import 'package:wflowapp/main/actions/viewhouse/charts/Indicator.dart';
import 'package:wflowapp/main/discover/charts/ConsumesLineChart.dart';
import 'package:wflowapp/main/discover/charts/ConsumesPieChart.dart';
import 'package:wflowapp/main/discover/client/DiscoverClientAllRegion.dart';
import 'package:wflowapp/main/discover/model/Consume.dart';
import 'package:wflowapp/main/discover/model/DiscoverResponseAllRegion.dart';
import 'package:wflowapp/main/discover/model/GenericConsume.dart';

import 'client/DiscoverClientRegionCity.dart';
import 'model/DiscoverResponseCityRegion.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  String token = '';

  List<String> cities = [];
  String _selectedRegion = 'Not selected';
  String _selectedCity = 'Not selected';
  String _selectedStatistic = 'Water';

  final DiscoverClientRegionCity discoverClientCityRegion =
      DiscoverClientRegionCity(
          url: AppConfig.getBaseUrl(),
          path: AppConfig.getDiscoverCityRegionPath());

  final DiscoverClientAllRegion discoverClientAllRegion =
      DiscoverClientAllRegion(
          url: AppConfig.getBaseUrl(),
          path: AppConfig.getDiscoverAllRegionPath());

  Future<DiscoverResponseCityRegion>? _futureResponseCityRegion;
  Future<DiscoverResponseAllRegion>? _futureResponseAllRegion;

  @override
  void initState() {
    super.initState();
    token = AppConfig.getUserToken()!;
    log(name: 'CONFIG', 'Read user key from config: $token');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: drawAppBar(),
      body: drawBody(),
    );
  }

  AppBar drawAppBar() {
    return AppBar(title: const Text('Discover'));
  }

  Widget drawBody() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(child: buildDiscoverPage()),
          ),
        ],
      ),
    );
  }

  Widget buildDiscoverPage() {
    if (AppConfig.getSendPersonalData() == false) {
      return const Text(
        'To enable the discover page, you need to allow the "Personal data" from the settings',
        style: TextStyle(fontSize: 18),
      );
    } else {
      return Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 4, bottom: 4),
                child: Text('Region'),
              ),
            ],
          ),
          DropdownSearch<String>(
            selectedItem: _selectedRegion,
            mode: Mode.BOTTOM_SHEET,
            showSelectedItems: true,
            items: const [
              "LOMBARDIA",
              "LAZIO",
              "CAMPANIA",
              "VENETO",
              "SICILIA",
              "EMILIA-ROMAGNA",
              "PIEMONTE",
              "PUGLIA",
              "TOSCANA",
              "CALABRIA",
              "SARDEGNA",
              "LIGURIA",
              "MARCHE",
              "ABRUZZO",
              "FRIULI-VENEZIA GIULA",
              "TRENTINO-ALTO ADIGE",
              "UMBRIA",
              "BASILICATA",
              "MOLISE",
              "VALLE D'AOSTA"
            ],
            showSearchBox: true,
            onChanged: (value) async {
              if (value != null) {
                _selectedRegion = value;
                var data = await rootBundle.loadString('assets/locations.json');
                final citiesInJson = json.decode(data);
                log('Selected region: $_selectedRegion');
                setState(() {
                  cities = List<String>.from(
                      citiesInJson[_selectedRegion.toUpperCase()] as List);
                });
                if (_selectedRegion.toUpperCase() != value.toUpperCase()) {
                  setState(() {
                    _selectedCity = cities.first;
                  });
                }
                if (checksOnValues()) {
                  setState(() {
                    _futureResponseCityRegion =
                        discoverClientCityRegion.getStatistics(token,
                            _selectedRegion, _selectedCity, _selectedStatistic);
                    _futureResponseAllRegion =
                        discoverClientAllRegion.getStatistics();
                  });
                }
              }
            },
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 4, bottom: 4),
                child: Text('City'),
              ),
            ],
          ),
          DropdownSearch<String>(
            selectedItem: _selectedCity,
            mode: Mode.BOTTOM_SHEET,
            items: cities,
            showSearchBox: true,
            filterFn: (item, filter) {
              return item!.toUpperCase().startsWith(filter!.toUpperCase());
            },
            onChanged: (value) {
              if (value != null) {
                _selectedCity = value;
              }
              log('Selected city: $value');
              if (checksOnValues()) {
                setState(() {
                  _futureResponseCityRegion =
                      discoverClientCityRegion.getStatistics(token,
                          _selectedRegion, _selectedCity, _selectedStatistic);
                  _futureResponseAllRegion =
                      discoverClientAllRegion.getStatistics();
                });
              }
            },
          ),
          const SizedBox(height: 30),
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 4, bottom: 4),
                child: Text('Statistics about'),
              ),
            ],
          ),
          DropdownSearch<String>(
            selectedItem: _selectedStatistic,
            mode: Mode.BOTTOM_SHEET,
            items: const ['Water', 'Gas'],
            onChanged: (value) {
              if (value != null) {
                _selectedStatistic = value;
              }
              log('Selected statistics: $value');
              if (checksOnValues()) {
                setState(() {
                  _futureResponseCityRegion =
                      discoverClientCityRegion.getStatistics(token,
                          _selectedRegion, _selectedCity, _selectedStatistic);
                  _futureResponseAllRegion =
                      discoverClientAllRegion.getStatistics();
                });
              }
            },
          ),
          const SizedBox(height: 40),
          buildCityRegionStatistics(),
          buildAllRegionStatistics()
        ],
      );
    }
  }

  bool checksOnValues() {
    return (_selectedCity != 'Not selected' &&
        _selectedRegion != 'Not selected');
  }

  Widget buildCityRegionStatistics() {
    if (_selectedRegion == 'Not selected' || _selectedCity == 'Not selected') {
      return const SizedBox.shrink();
    }
    return _buildCityRegionStatistics();
  }

  Widget buildAllRegionStatistics() {
    if (_selectedRegion == 'Not selected' || _selectedCity == 'Not selected') {
      return const SizedBox.shrink();
    }
    return _buildAllRegionStatistics();
  }

  FutureBuilder<DiscoverResponseCityRegion> _buildCityRegionStatistics() {
    return FutureBuilder<DiscoverResponseCityRegion>(
      future: _futureResponseCityRegion,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.code != 200) {
            return const SizedBox.shrink();
          }
          return _buildChartsCityRegion(snapshot);
        } else if (snapshot.hasError) {
          return const SizedBox.shrink();
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  FutureBuilder<DiscoverResponseAllRegion> _buildAllRegionStatistics() {
    return FutureBuilder<DiscoverResponseAllRegion>(
      future: _futureResponseAllRegion,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.code != 200) {
            return const SizedBox.shrink();
          }
          return _buildChartsAllRegion(snapshot);
        } else if (snapshot.hasError) {
          return const SizedBox.shrink();
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildChartsCityRegion(var snapshot) {
    List<Consume> month_city_consume = snapshot.data!.month_city_consume;
    List<Consume> month_region_consume = snapshot.data!.month_region_consume;
    //List<Consume> regionConsume = snapshot.data!.regionConsume;
    //List<Consume> averageCountryConsume = snapshot.data!.averageCountryConsume;
    //List<Consume> monthRegionConsume = snapshot.data!.monthRegionConsume;
    //List<Consume> regionsToConsider = filterRegions(_selectedRegion, monthRegionConsume);
    String zone = getRegionZone(_selectedRegion);
    String measurement = _selectedStatistic == 'Water' ? 'L' : 'm3';
    return Column(
      children: [
        Text(
          '$_selectedStatistic consumes by city ($measurement)',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 20),
        ConsumesLineChart(
            consumes1: month_city_consume, consumes2: month_region_consume),
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 20),
          child: Column(
            children: [
              Indicator(
                  color: Colors.cyan,
                  text: 'Consumes in $_selectedCity',
                  isSquare: true),
              const SizedBox(height: 4.0),
              Indicator(
                  color: Colors.grey,
                  text: 'Average consumes in $_selectedRegion',
                  isSquare: true),
            ],
          ),
        ),
        const SizedBox(height: 40),
        /*
        Text(
          '$_selectedStatistic consumes by region ($measurement)',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 20),
        ConsumesLineChart(
            consumes1: regionConsume, consumes2: averageCountryConsume),
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 20),
          child: Column(
            children: [
              Indicator(
                  color: Colors.cyan,
                  text: 'Consumes in $_selectedRegion',
                  isSquare: true),
              const SizedBox(height: 4.0),
              const Indicator(
                  color: Colors.grey,
                  text: 'Average consumes in Italy',
                  isSquare: true),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Text(
          '$_selectedStatistic consumes in $zone Italy',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 20),
        ConsumesPieChart(consumes: regionsToConsider)
        */
      ],
    );
  }

  Widget _buildChartsAllRegion(var snapshot) {
    List<GenericConsume> region_consumes = snapshot.data!.region_consumes;
    List<GenericConsume> regions =
        filterRegions(_selectedRegion, region_consumes);
    String zone = getRegionZone(_selectedRegion);
    String measurement = _selectedStatistic == 'Water' ? 'L' : 'm3';
    return Column(
      children: [
        Text(
          '$_selectedStatistic consumes in $zone Italy',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 20),
        ConsumesPieChart(consumes: regions, statistics: _selectedStatistic)
      ],
    );
  }

  List<GenericConsume> filterRegions(
      String selectedRegion, List<GenericConsume> regions) {
    List<GenericConsume> subList = [];
    String zone = getRegionZone(selectedRegion);
    for (GenericConsume consume in regions) {
      if (getRegionZone(consume.region) == zone) {
        subList.add(consume);
      }
    }
    return subList;
  }

  String getRegionZone(String region) {
    switch (region) {
      case "VALLE D'AOSTA":
      case "LIGURIA":
      case "LOMBARDIA":
      case "PIEMONTE":
        return "Nord-ovest";
      case "TRENTINO-ALTO ADIGE":
      case "VENETO":
      case "FRIULI-VENEZIA GIULIA":
      case "EMILIA-ROMAGNA":
        return "Nord-est";
      case "TOSCANA":
      case "UMBRIA":
      case "MARCHE":
      case "LAZIO":
      case "ABRUZZO":
        return "Centro";
      case "MOLISE":
      case "CAMPANIA":
      case "PUGLIA":
      case "BASILICATA":
      case "CALABRIA":
      case "SICILIA":
        return "Sud";
      default:
        return "";
    }
  }
}
