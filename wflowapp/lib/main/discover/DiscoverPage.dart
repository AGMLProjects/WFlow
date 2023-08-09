import 'dart:convert';
import 'dart:developer';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wflowapp/config/AppConfig.dart';
import 'package:wflowapp/main/discover/client/DiscoverClient.dart';
import 'package:wflowapp/main/discover/client/DiscoverResponse.dart';

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

  final DiscoverClient discoverClient = DiscoverClient(
      url: AppConfig.getBaseUrl(), path: AppConfig.getDiscoverPath());

  Future<DiscoverResponse>? _futureResponse;

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
              "Lombardia",
              "Lazio",
              "Campania",
              "Veneto",
              "Sicilia",
              "Emilia-Romagna",
              "Piemonte",
              "Puglia",
              "Toscana",
              "Calabria",
              "Sardegna",
              "Liguria",
              "Marche",
              "Abruzzo",
              "Friuli-Venezia Giulia",
              "Trentino-Alto Adige",
              "Umbria",
              "Basilicata",
              "Molise",
              "Valle d'Aosta"
            ],
            showSearchBox: true,
            onChanged: (value) async {
              if (value != null) {
                _selectedRegion = value;
                var data = await rootBundle.loadString('assets/locations.json');
                final citiesInJson = json.decode(data);
                log('Selected region: $_selectedRegion');
                setState(() {
                  cities =
                      List<String>.from(citiesInJson[_selectedRegion] as List);
                });
                if (_selectedRegion.toUpperCase() != value.toUpperCase()) {
                  setState(() {
                    _selectedCity = cities.first;
                  });
                }
                if (checksOnValues()) {
                  _futureResponse = discoverClient.getStatistics(token,
                      _selectedRegion, _selectedCity, _selectedStatistic[0]);
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
                child: Text('City (comune)'),
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
                _futureResponse = discoverClient.getStatistics(token,
                    _selectedRegion, _selectedCity, _selectedStatistic[0]);
              }
            },
          ),
          const SizedBox(height: 20),
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
                _futureResponse = discoverClient.getStatistics(token,
                    _selectedRegion, _selectedCity, _selectedStatistic[0]);
              }
            },
          ),
          const SizedBox(height: 40),
          buildStatistics()
        ],
      );
    }
  }

  bool checksOnValues() {
    return (_selectedCity != 'Not selected' &&
        _selectedRegion != 'Not selected');
  }

  Widget buildStatistics() {
    if (_selectedRegion == 'Not selected' || _selectedCity == 'Not selected') {
      return const SizedBox.shrink();
    }
    return _buildStatistics();
  }

  FutureBuilder<DiscoverResponse> _buildStatistics() {
    return FutureBuilder<DiscoverResponse>(
      future: _futureResponse,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.code != 200) {
            return const SizedBox.shrink();
          }
          String email = snapshot.data!.email;
          return Text('Stats');
        } else if (snapshot.hasError) {
          return const SizedBox.shrink();
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
