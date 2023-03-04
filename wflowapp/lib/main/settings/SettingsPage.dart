import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wflowapp/config/AppConfig.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _sendPersonalData = false;

  @override
  void initState() {
    super.initState();
    String? key = AppConfig.getUserToken();
    log(name: 'CONFIG', 'Read user key from config: ${key!}');
    if (AppConfig.getSendPersonalData() == null) {
      AppConfig.setSendPersonalData(false);
    }
    _sendPersonalData = AppConfig.getSendPersonalData()!;
    log(name: 'CONFIG', 'Send personal data: $_sendPersonalData');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: drawAppBar(),
      body: drawBody(),
    );
  }

  AppBar drawAppBar() {
    return AppBar(title: const Text('Settings'));
  }

  Widget drawBody() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
                child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('SendData'),
                    Switch(
                      value: _sendPersonalData,
                      onChanged: (value) {
                        setState(() {
                          _sendPersonalData = value;
                          AppConfig.setSendPersonalData(_sendPersonalData);
                        });
                        _toggleSwitch(value);
                      },
                    )
                  ],
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }

  void _toggleSwitch(bool value) {
    if (_sendPersonalData) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmation'),
            content: const Text(
                'The system will collect some of your personal data (for example, the number of people in your house, or your occupation). The purpose is to study the behaviours of people relating to water and gas consumption. \nYou can always disable this function later.'),
            actions: <Widget>[
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  setState(() {
                    _sendPersonalData = false;
                    AppConfig.setSendPersonalData(_sendPersonalData);
                  });
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () {
                  setState(() {
                    _sendPersonalData = value;
                    AppConfig.setSendPersonalData(_sendPersonalData);
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
