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
    List<Sensor> sensors = [
      Sensor(sensorId: 1, sensorType: "TYPE1"),
      Sensor(sensorId: 2, sensorType: "TYPE2")
    ];
    if (json['sensors'] != null) {
      var sensorsList = json['sensors'] as List;
      sensors = sensorsList.map((item) => Sensor.fromJson(item)).toList();
    }

    String type = '';
    if (json['type'] != null) {
      type = json['type'];
    }

    return Device(
        deviceId: json['device_id'],
        name: json['name'],
        type: type,
        sensors: sensors);
  }
}
