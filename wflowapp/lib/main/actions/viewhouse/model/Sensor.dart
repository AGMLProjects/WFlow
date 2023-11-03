class Sensor {
  final int sensor_id;
  final String sensor_type;
  bool automatic = false;
  bool set = false;

  Sensor({required this.sensor_id, required this.sensor_type});

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      sensor_id: json['sensor_id'],
      sensor_type: json['sensor_type'],
    );
  }
}
