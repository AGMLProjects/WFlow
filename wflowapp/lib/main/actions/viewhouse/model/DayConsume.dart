class DayConsume {
  final String date;
  final double total_water_liters;
  final double total_gas_volume;

  DayConsume(
      {required this.date,
      required this.total_water_liters,
      required this.total_gas_volume});

  factory DayConsume.fromJson(Map<String, dynamic> json) {
    double water = 0.0;
    if (json['total_water_liters'] != null) {
      water = json['total_water_liters'];
    }
    double gas = 0.0;
    if (json['total_gas_volume'] != null) {
      gas = json['total_gas_volume'];
    }
    return DayConsume(
        date: json['date'], total_water_liters: water, total_gas_volume: gas);
  }
}
