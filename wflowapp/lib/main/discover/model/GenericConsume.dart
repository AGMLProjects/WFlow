class GenericConsume {
  final String region;
  final double water_consume;
  final double gas_consume;

  GenericConsume(
      {required this.region,
      required this.water_consume,
      required this.gas_consume});

  factory GenericConsume.fromJson(Map<String, dynamic> json) {
    String region = '';
    if (json['region'] != null) {
      region = json['region'];
    }
    double water_consume = 0.0;
    if (json['water_consume'] > 0) {
      water_consume = json['water_consume'];
    }
    double gas_consume = 0.0;
    if (json['gas_consume'] > 0) {
      gas_consume = json['gas_consume'];
    }
    return GenericConsume(
        region: region, water_consume: water_consume, gas_consume: gas_consume);
  }
}
