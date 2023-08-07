class Sensor {
  final int id;
  final String type;
  bool automatic = false;
  bool set = false;

  Sensor({required this.id, required this.type});

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      id: json['sensor_id'],
      type: json['sensor_type'],
    );
  }
}
