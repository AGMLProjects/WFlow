class Consume {
  final int year;
  final int month;
  final double consume;
  String region;
  String city;

  Consume(
      {required this.year,
      required this.month,
      required this.consume,
      required this.region,
      required this.city});

  factory Consume.fromJson(Map<String, dynamic> json) {
    String region = '';
    if (json['region'] != null) {
      region = json['region'];
    }
    String city = '';
    if (json['city'] != null) {
      city = json['city'];
    }
    double consume = 0.0;
    if (json['consume'] != 0) {
      consume = json['consume'];
    }
    return Consume(
        year: json['year'],
        month: json['month'],
        consume: consume,
        region: region,
        city: city);
  }
}
