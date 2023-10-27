class Event {
  final int sensor_id;
  final String start_timestamp;
  final String end_timestamp;
  final double water_liters;
  final double gas_volume;

  Event(
      {required this.sensor_id,
      required this.start_timestamp,
      required this.end_timestamp,
      required this.water_liters,
      required this.gas_volume});

  factory Event.fromJson(Map<String, dynamic> json) {
    double water_liters = -1.0;
    if (json['values']['water_liters'] != null) {
      water_liters = json['values']['water_liters'];
    }
    double gas_volume = -1.0;
    if (json['values']['gas_volume'] != null) {
      gas_volume = json['values']['gas_volume'];
    }
    return Event(
        sensor_id: json['sensor_id'],
        start_timestamp: json['start_timestamp'],
        end_timestamp: json['end_timestamp'],
        water_liters: water_liters,
        gas_volume: gas_volume);
  }
}
