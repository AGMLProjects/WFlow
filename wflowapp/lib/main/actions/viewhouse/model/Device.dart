import 'package:wflowapp/main/actions/viewhouse/model/Sensor.dart';

class Device {
  final int device_id;
  final String name;
  final List<Sensor> sensors;

  Device({
    required this.device_id,
    required this.name,
    required this.sensors,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    List<Sensor> sensors = List.empty();
    if (json['sensors'] != null) {
      var sensorsList = json['sensors'] as List;
      sensors = sensorsList.map((item) => Sensor.fromJson(item)).toList();
    }

    String type = '';
    if (json['type'] != null) {
      type = json['type'];
    }

    return Device(
        device_id: json['device_id'], name: json['name'], sensors: sensors);
  }
}
