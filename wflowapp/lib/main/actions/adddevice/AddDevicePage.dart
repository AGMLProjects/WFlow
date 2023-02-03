import 'package:flutter/material.dart';

class AddDevicePage extends StatefulWidget {
  const AddDevicePage({super.key});

  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: drawAppBar(),
      body: drawBody(),
    );
  }

  AppBar drawAppBar() {
    return AppBar(title: const Text('Add Device'));
  }

  Widget drawBody() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/scan');
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Scan',
                  style: TextStyle(fontSize: 22.0),
                ),
              ),
              style: ElevatedButton.styleFrom(shape: StadiumBorder()),
            ),
            SizedBox(
              height: 40.0,
            ),
            drawInstructions()
          ],
        ),
      ),
    );
  }

  Widget drawInstructions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 16.0,
            ),
            children: <TextSpan>[
              TextSpan(text: '1 • Every house is paired to one or more '),
              TextSpan(
                  text: 'main devices',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: '.'),
            ],
          ),
        ),
        SizedBox(height: 6.0),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 16.0,
            ),
            children: <TextSpan>[
              TextSpan(text: '2 • You will find a '),
              TextSpan(
                  text: 'QR code',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' on the back of the '),
              TextSpan(
                  text: 'main device',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: '.'),
            ],
          ),
        ),
        SizedBox(height: 6.0),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 16.0,
            ),
            children: <TextSpan>[
              TextSpan(text: '3 • Click on the '),
              TextSpan(
                  text: 'scan ', style: TextStyle(fontStyle: FontStyle.italic)),
              TextSpan(text: ' button to scan the '),
              TextSpan(
                  text: 'QR code',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' and associate a device to the house!'),
            ],
          ),
        ),
      ],
    );
  }
}
