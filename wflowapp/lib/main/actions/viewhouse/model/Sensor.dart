class Sensor {
  final int sensorId;
  final String sensorType;

  Sensor({required this.sensorId, required this.sensorType});

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      sensorId: json['sensor_id'],
      sensorType: json['sensor_type'],
    );
  }
}
