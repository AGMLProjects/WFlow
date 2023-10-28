class DayConsume {
  final String date;
  final double total_water_liters;
  final double total_gas_volumes;

  DayConsume(
      {required this.date,
      required this.total_water_liters,
      required this.total_gas_volumes});

  factory DayConsume.fromJson(Map<String, dynamic> json) {
    // TODO
    double gas = 0;
    return DayConsume(
        date: json['date'],
        total_water_liters: json['total_water_liters'],
        total_gas_volumes: gas);
  }
}
