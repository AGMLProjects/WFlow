import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wflowapp/mainpage/addhouse/rest/AddHouseClient.dart';
import 'package:wflowapp/mainpage/addhouse/rest/AddHouseResponse.dart';

import '../../../config/AppConfig.dart';

class AddHousePage extends StatefulWidget {
  const AddHousePage({super.key});

  @override
  State<AddHousePage> createState() => _AddHousePageState();
}

class _AddHousePageState extends State<AddHousePage> {
  Color houseColor = Colors.blue;
  String? _currentAddress;
  Position? _currentPosition;
  final nameController = TextEditingController();
  final locationController = TextEditingController();

  final AddHouseClient addHousesClient =
      const AddHouseClient(url: AppConfig.BASE_URL, path: '/houses/add');

  Future<AddHouseResponse>? _futureAddHouseResponse;

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
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
              decoration: InputDecoration(
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
                    controller: locationController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Location',
                        hintText: 'Location'),
                  ),
                ),
                SizedBox(width: 10.0),
                ElevatedButton(
                  onPressed: getCurrentPosition,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 20.0,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'House color: ',
                  style: TextStyle(fontSize: 18.0),
                ),
                ElevatedButton(
                  onPressed: () => showColorPickerDialog(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                  ),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(CircleBorder()),
                    padding: MaterialStateProperty.all(EdgeInsets.all(16.0)),
                    backgroundColor: MaterialStateProperty.all(houseColor),
                  ),
                ),
              ],
            ),
            SizedBox(height: 70.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => performRequest(),
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'Done',
                        style: TextStyle(fontSize: 20.0),
                      )),
                  style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            if (_futureAddHouseResponse != null) drawAddHouseResponse(),
          ],
        ),
      ),
    );
  }

  void performRequest() {
    setState(() {
      //validate
      String name = nameController.text;
      String location = locationController.text;
      _futureAddHouseResponse = addHousesClient.addHouse(
          AppConfig.TOKEN, name, location, houseColor.toString());
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
          log('New house ID: ${snapshot.data!.house}');
          Future.delayed(Duration.zero, () {
            Navigator.pushReplacementNamed(context, 'main');
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
