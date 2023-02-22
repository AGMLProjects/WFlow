import 'dart:developer';

import 'package:flutter/material.dart';
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
  String? _currentAddress;
  Position? _currentPosition;
  String? houseType;
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
    houseType = 'Flat';
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
            SizedBox(height: 20.0),
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
                SizedBox(width: 10.0),
                DropdownButton(
                  items: const [
                    DropdownMenuItem(child: Text('Flat'), value: 'Flat'),
                    DropdownMenuItem(
                        child: Text('Detached House'), value: 'Detached House'),
                    DropdownMenuItem(
                        child: Text('Seaside House'), value: 'Seaside House'),
                    DropdownMenuItem(
                        child: Text('Mountain House'), value: 'Mountain House')
                  ],
                  value: houseType,
                  onChanged: dropDownCallback,
                  style: TextStyle(fontSize: 18),
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
                    shape: MaterialStateProperty.all(CircleBorder()),
                    padding: MaterialStateProperty.all(EdgeInsets.all(16.0)),
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
                  style: ElevatedButton.styleFrom(shape: StadiumBorder()),
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
            if (_futureAddHouseResponse != null) drawAddHouseResponse(),
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
          if (snapshot.data!.code != 200) {
            return Text(snapshot.data!.message,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ));
          }
          log(name: 'DEBUG', 'New house ID: ${snapshot.data!.house}');
          AppConfig.setHouseColor(snapshot.data!.house, houseColor);
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
              title: Text('Pick a color!'),
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
