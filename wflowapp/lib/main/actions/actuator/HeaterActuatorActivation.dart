import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class HeaterActuatorActivation extends StatefulWidget {
  HeaterActuatorActivation(
      {super.key,
      required this.index,
      required this.temperature,
      required this.start_timestamp,
      required this.end_timestamp,
      required this.to_delete});

  final int index;
  int temperature;
  DateTime start_timestamp;
  DateTime end_timestamp;
  bool to_delete;

  @override
  _HeaterActuatorActivationState createState() =>
      _HeaterActuatorActivationState(
          index: index,
          temperature: temperature,
          start_timestamp: start_timestamp,
          end_timestamp: end_timestamp,
          to_delete: to_delete);
}

class _HeaterActuatorActivationState extends State<HeaterActuatorActivation> {
  _HeaterActuatorActivationState(
      {required this.index,
      required this.temperature,
      required this.start_timestamp,
      required this.end_timestamp,
      required this.to_delete});

  final int index;
  int temperature;
  DateTime start_timestamp;
  DateTime end_timestamp;
  bool to_delete;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        to_delete = true;
        widget.to_delete = true;
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 1.0,
        child: buildActivation(),
      ),
    );
  }

  Widget buildActivation() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 10),
            Text(
              index.toString(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 20),
            Column(
              children: [
                const Row(
                  children: [
                    Text(
                      'Temperature',
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Column(
                  children: [
                    Row(
                      children: [
                        NumberPicker(
                            value: temperature,
                            minValue: 10,
                            maxValue: 45,
                            step: 1,
                            itemHeight: 25,
                            itemWidth: 30,
                            itemCount: 3,
                            axis: Axis.vertical,
                            haptics: true,
                            textStyle: const TextStyle(fontSize: 14),
                            selectedTextStyle: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            onChanged: (value) => setState(() {
                                  temperature = value;
                                  widget.temperature = temperature;
                                })),
                      ],
                    )
                  ],
                )
              ],
            ),
            const SizedBox(width: 20),
            Column(
              children: [
                const Row(
                  children: [
                    Text(
                      'Start',
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Column(
                  children: [
                    Row(
                      children: [
                        NumberPicker(
                            value: start_timestamp.hour,
                            minValue: 0,
                            maxValue: 23,
                            step: 1,
                            itemHeight: 25,
                            itemWidth: 30,
                            itemCount: 3,
                            zeroPad: true,
                            axis: Axis.vertical,
                            haptics: true,
                            textStyle: const TextStyle(fontSize: 14),
                            selectedTextStyle: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            onChanged: (value) => setState(() {
                                  start_timestamp = DateTime(
                                      start_timestamp.year,
                                      start_timestamp.month,
                                      start_timestamp.day,
                                      value,
                                      start_timestamp.minute,
                                      start_timestamp.second);
                                  widget.start_timestamp = DateTime(
                                      start_timestamp.year,
                                      start_timestamp.month,
                                      start_timestamp.day,
                                      value,
                                      start_timestamp.minute,
                                      start_timestamp.second);
                                })),
                        const Text(
                          ':',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        NumberPicker(
                            value: start_timestamp.minute,
                            minValue: 0,
                            maxValue: 59,
                            step: 1,
                            itemHeight: 25,
                            itemWidth: 30,
                            itemCount: 3,
                            zeroPad: true,
                            axis: Axis.vertical,
                            haptics: true,
                            textStyle: const TextStyle(fontSize: 14),
                            selectedTextStyle: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            onChanged: (value) => setState(() {
                                  start_timestamp = DateTime(
                                      start_timestamp.year,
                                      start_timestamp.month,
                                      start_timestamp.day,
                                      start_timestamp.hour,
                                      value,
                                      start_timestamp.second);
                                  widget.start_timestamp = DateTime(
                                      start_timestamp.year,
                                      start_timestamp.month,
                                      start_timestamp.day,
                                      start_timestamp.hour,
                                      value,
                                      start_timestamp.second);
                                })),
                      ],
                    )
                  ],
                )
              ],
            ),
            const SizedBox(width: 20),
            Column(
              children: [
                const Row(
                  children: [
                    Text(
                      'End',
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Column(
                  children: [
                    Row(
                      children: [
                        NumberPicker(
                            value: end_timestamp.hour,
                            minValue: 0,
                            maxValue: 23,
                            step: 1,
                            itemHeight: 25,
                            itemWidth: 30,
                            itemCount: 3,
                            zeroPad: true,
                            axis: Axis.vertical,
                            haptics: true,
                            textStyle: const TextStyle(fontSize: 14),
                            selectedTextStyle: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            onChanged: (value) => setState(() {
                                  end_timestamp = DateTime(
                                      end_timestamp.year,
                                      end_timestamp.month,
                                      end_timestamp.day,
                                      value,
                                      end_timestamp.minute,
                                      end_timestamp.second);
                                  widget.end_timestamp = DateTime(
                                      end_timestamp.year,
                                      end_timestamp.month,
                                      end_timestamp.day,
                                      value,
                                      end_timestamp.minute,
                                      end_timestamp.second);
                                })),
                        const Text(
                          ':',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        NumberPicker(
                            value: end_timestamp.minute,
                            minValue: 0,
                            maxValue: 59,
                            step: 1,
                            itemHeight: 25,
                            itemWidth: 30,
                            itemCount: 3,
                            zeroPad: true,
                            axis: Axis.vertical,
                            haptics: true,
                            textStyle: const TextStyle(fontSize: 14),
                            selectedTextStyle: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            onChanged: (value) => setState(() {
                                  end_timestamp = DateTime(
                                      end_timestamp.year,
                                      end_timestamp.month,
                                      end_timestamp.day,
                                      end_timestamp.hour,
                                      value,
                                      end_timestamp.second);
                                  widget.end_timestamp = DateTime(
                                      end_timestamp.year,
                                      end_timestamp.month,
                                      end_timestamp.day,
                                      end_timestamp.hour,
                                      value,
                                      end_timestamp.second);
                                })),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12)
      ],
    );
  }
}
