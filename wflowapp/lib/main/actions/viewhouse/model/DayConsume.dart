class DayConsume {
  final String date;
  final int total_water_liters;
  final int total_gas_volumes;

  DayConsume(
      {required this.date,
      required this.total_water_liters,
      required this.total_gas_volumes});

  factory DayConsume.fromJson(Map<String, dynamic> json) {
    return DayConsume(
        date: json['data'],
        total_water_liters: json['total_water_liters'],
        total_gas_volumes: json['total_gas_volumes']);
  }
}
