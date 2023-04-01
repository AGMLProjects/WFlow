import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wflowapp/config/AppConfig.dart';
import 'package:wflowapp/main/actions/edithouse/client/EditHouseClient.dart';
import 'package:wflowapp/main/actions/edithouse/client/EditHouseResponse.dart';

class EditHousePage extends StatefulWidget {
  const EditHousePage({super.key});

  @override
  State<EditHousePage> createState() => _EditHousePageState();
}

class _EditHousePageState extends State<EditHousePage> {
  String? token;
  int id = -1;
  String name = '';
  String city = '';
  String address = '';
  String houseType = '';

  Color houseColor = AppConfig.getDefaultColor();
  String? _currentAddress;
  Position? _currentPosition;
  final nameController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();

  final EditHouseClient editHousesClient = EditHouseClient(
      url: AppConfig.getBaseUrl(), path: AppConfig.getEditHousePath());

  Future<EditHouseResponse>? _futureEditHouseResponse;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      token = AppConfig.getUserToken();
      log(name: 'CONFIG', 'Token: ${token!}');
      log(name: 'CONFIG', 'House ID: $id');
      log(name: 'CONFIG', 'House name: $name');
      log(name: 'CONFIG', 'House type: $houseType');
      houseColor = AppConfig.getHouseColor(id)!;
      nameController.text = name;
      cityController.text = city;
      addressController.text = address;
    });
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
    final arg = ModalRoute.of(context)!.settings.arguments as Map;
    id = arg['id'];
    name = arg['name'];
    city = arg['city'];
    address = arg['address'];
    if (houseType.isEmpty) {
      houseType = arg['type'];
    }

    return Scaffold(
      appBar: drawAppBar(),
      body: drawBody(),
    );
  }

  AppBar drawAppBar() {
    return AppBar(title: const Text('Edit House'));
  }

  Widget drawBody() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name',
                  hintText: 'Name'),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    controller: cityController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'City',
                        hintText: 'City'),
                  ),
                ),
                const SizedBox(width: 10.0),
                ElevatedButton(
                  onPressed: getCurrentPosition,
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 20.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Address',
                  hintText: 'Address'),
            ),
            const SizedBox(height: 20.0),
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
                      child: Text('Apartment'),
                    ),
                    DropdownMenuItem(
                      value: 'SFH',
                      child: Text('Single-Family House'),
                    ),
                    DropdownMenuItem(
                      value: 'SDH',
                      child: Text('Semi-Detached House'),
                    ),
                    DropdownMenuItem(
                      value: 'MFH',
                      child: Text('Multifamily House'),
                    ),
                    DropdownMenuItem(
                      value: 'CON',
                      child: Text('Condominium'),
                    ),
                    DropdownMenuItem(
                      value: 'COP',
                      child: Text('Co-Op'),
                    ),
                    DropdownMenuItem(
                      value: 'TIN',
                      child: Text('Tiny House'),
                    ),
                    DropdownMenuItem(
                      value: 'MAN',
                      child: Text('Manufactured Home'),
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
                    padding:
                        MaterialStateProperty.all(const EdgeInsets.all(16.0)),
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
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('Delete this house',
                    style: TextStyle(
                        fontSize: 14.0,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold))
              ],
            ),
            const SizedBox(height: 20.0),
            if (_futureEditHouseResponse != null) drawAddHouseResponse(),
          ],
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
      String type = houseType;
      //AppConfig.setHouseColor(id, houseColor);
      editHousesClient.path =
          editHousesClient.path.replaceAll('{id}', id.toString());
      _futureEditHouseResponse =
          editHousesClient.editHouse(token!, id, name, city, address, type);
    });
  }

  FutureBuilder<EditHouseResponse> drawAddHouseResponse() {
    return FutureBuilder<EditHouseResponse>(
      future: _futureEditHouseResponse,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.code != 200) {
            return const Text('Error',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ));
          }
          AppConfig.setHouseColor(id, houseColor);
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
                  onColorChanged: (Color picked) {
                    setState(() {
                      houseColor = picked;
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

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> getCurrentPosition() async {
    final hasPermission = await handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }
}
