import 'dart:convert';
import 'dart:developer';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wflowapp/config/AppConfig.dart';
import 'package:wflowapp/main/actions/addhouse/client/AddHouseClient.dart';
import 'package:wflowapp/main/actions/addhouse/client/AddHouseResponse.dart';

class AddHousePage extends StatefulWidget {
  const AddHousePage({super.key});

  @override
  State<AddHousePage> createState() => _AddHousePageState();
}

class _AddHousePageState extends State<AddHousePage> {
  String? token;

  Color houseColor = AppConfig.getDefaultColor();
  String? houseType;

  String _selectedRegion = '';
  List<String> cities = [];
  String _selectedCity = '';

  final nameController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();

  final AddHouseClient addHousesClient = AddHouseClient(
      url: AppConfig.getBaseUrl(), path: AppConfig.getAddHousePath());

  Future<AddHouseResponse>? _futureAddHouseResponse;

  @override
  void initState() {
    super.initState();
    token = AppConfig.getUserToken();
    log(name: 'CONFIG', 'Token: ${token!}');
    houseType = 'APA';
  }

  @override
  void dispose() {
    nameController.dispose();
    cityController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: drawAppBar(),
      body: drawBody(),
    );
  }

  AppBar drawAppBar() {
    return AppBar(title: const Text('Add House'));
  }

  Widget drawBody() {
    return SingleChildScrollView(
      child: Expanded(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                TextField(
                  enabled: true,
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "House name",
                  ),
                ),
                const SizedBox(height: 40),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 4),
                      child: Text('Country'),
                    ),
                  ],
                ),
                DropdownSearch<String>(
                  mode: Mode.BOTTOM_SHEET,
                  showSelectedItems: true,
                  items: const ["Italy"],
                  showSearchBox: true,
                  selectedItem: "Italy",
                ),
                const SizedBox(height: 20),
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
                  showClearButton: true,
                  onChanged: (value) async {
                    if (_selectedRegion.toUpperCase() != value!.toUpperCase()) {
                      setState(() {
                        _selectedCity = '';
                      });
                    }
                    _selectedRegion = value.toUpperCase();
                    var data =
                        await rootBundle.loadString('assets/locations.json');
                    final citiesInJson = json.decode(data);
                    log('Selected region: $_selectedRegion');
                    setState(() {
                      cities = List<String>.from(
                          citiesInJson[_selectedRegion] as List);
                    });
                    log('Selected city: $_selectedCity');
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
                  showClearButton: true,
                  filterFn: (item, filter) {
                    return item!
                        .toUpperCase()
                        .startsWith(filter!.toUpperCase());
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      'House type: ',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    const SizedBox(width: 10.0),
                    DropdownButton(
                      items: const [
                        DropdownMenuItem(
                          value: 'APA',
                          child: Text(
                            'Apartment',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'SFH',
                          child: Text(
                            'Single-Family House',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'SDH',
                          child: Text(
                            'Semi-Detached House',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'MFH',
                          child: Text(
                            'Multifamily House',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'CON',
                          child: Text(
                            'Condominium',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'COP',
                          child: Text(
                            'Co-Op',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'TIN',
                          child: Text(
                            'Tiny House',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'MAN',
                          child: Text(
                            'Manufactured Home',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                      value: houseType,
                      onChanged: dropDownCallback,
                      style: const TextStyle(fontSize: 18),
                    )
                  ],
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      'Color: ',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    ElevatedButton(
                      onPressed: () => showColorPickerDialog(),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(const CircleBorder()),
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.all(16.0)),
                        backgroundColor: MaterialStateProperty.all(houseColor),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 70.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => performRequest(),
                      style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder()),
                      child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            'Done',
                            style: TextStyle(fontSize: 20.0),
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Delete this house',
                        style: TextStyle(
                            fontSize: 14.0,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold))
                  ],
                ),
                const SizedBox(height: 20.0)
              ],
            ),
          ),
        ),
      ),
    );
  }

  void dropDownCallback(String? selectedValue) {
    if (selectedValue is String) {
      setState(() {
        houseType = selectedValue;
      });
    }
  }

  void performRequest() {
    setState(() {
      //validate
      String name = nameController.text;
      String city = cityController.text;
      String address = addressController.text;
      String type = houseType!;
      _futureAddHouseResponse =
          addHousesClient.addHouse(token!, name, city, address, type);
    });
  }

  FutureBuilder<AddHouseResponse> drawAddHouseResponse() {
    return FutureBuilder<AddHouseResponse>(
      future: _futureAddHouseResponse,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.code != 201) {
            return const Text('Error',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ));
          }
          log(name: 'DEBUG', 'New house ID: ${snapshot.data!.house.house_id}');
          AppConfig.setHouseColor(snapshot.data!.house.house_id, houseColor);
          Future.delayed(Duration.zero, () {
            Navigator.pushReplacementNamed(context, '/main');
          });
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}',
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ));
        }
        return const CircularProgressIndicator();
      },
    );
  }

  void showColorPickerDialog() {
    Future.delayed(Duration.zero, () {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Pick a color!'),
              content: SingleChildScrollView(
                child: MaterialPicker(
                  pickerColor: houseColor,
                  onColorChanged: (Color color) {
                    setState(() {
                      houseColor = color;
                    });
                  },
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text('Done'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    });
  }
}
