import 'package:wflowapp/main/actions/viewhouse/model/Sensor.dart';

class Device {
  final int deviceId;
  final String name;
  final String type;
  final List<Sensor> sensors;

  Device({
    required this.deviceId,
    required this.name,
    required this.type,
    required this.sensors,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    var sensorsList = json['sensors'] as List;
    List<Sensor> sensors =
        sensorsList.map((item) => Sensor.fromJson(item)).toList();

    return Device(
        deviceId: json['device_id'],
        name: json['name'],
        type: json['type'],
        sensors: sensors);
  }
}
