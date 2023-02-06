import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wflowapp/main/actions/edithouse/client/EditHouseClient.dart';
import 'package:wflowapp/main/actions/edithouse/client/EditHouseResponse.dart';

import '../../../config/AppConfig.dart';

class EditHousePage extends StatefulWidget {
  const EditHousePage({super.key});

  @override
  State<EditHousePage> createState() => _EditHousePageState();
}

class _EditHousePageState extends State<EditHousePage> {
  String? token;
  String id = '';
  String name = '';
  String location = '';
  Color? houseColor;

  String? _currentAddress;
  Position? _currentPosition;
  final nameController = TextEditingController();
  final locationController = TextEditingController();

  final EditHouseClient editHousesClient =
      EditHouseClient(url: AppConfig.getBaseUrl(), path: '/house/edit');

  Future<EditHouseResponse>? _futureEditHouseResponse;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      AppConfig.setUserToken('AAAA'); // TODO: remove this
      token = AppConfig.getUserToken();
      log(name: 'CONFIG', 'Token: ${token!}');
      log(name: 'CONFIG', 'House ID: $id');
      log(name: 'CONFIG', 'Current house name: $name');
      log(name: 'CONFIG', 'Current house location: $location');
      houseColor = AppConfig.getHouseColor(id);
      nameController.text = name;
      locationController.text = location;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)!.settings.arguments as Map;
    id = arg['id'];
    name = arg['name'];
    location = arg['location'];
    houseColor ??= AppConfig.getHouseColor(id);

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
                    controller: locationController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Location',
                        hintText: 'Location'),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'House color: ',
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
            if (_futureEditHouseResponse != null) drawAddHouseResponse(),
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
      _futureEditHouseResponse =
          editHousesClient.editHouse(token!, id, name, location);
    });
  }

  FutureBuilder<EditHouseResponse> drawAddHouseResponse() {
    return FutureBuilder<EditHouseResponse>(
      future: _futureEditHouseResponse,
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
          AppConfig.setHouseColor(snapshot.data!.house, houseColor!);
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
                  pickerColor: houseColor!,
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
