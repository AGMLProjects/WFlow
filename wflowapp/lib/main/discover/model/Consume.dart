class Consume {
  final int year;
  final int month;
  final int consume;
  String region;

  Consume(
      {required this.year,
      required this.month,
      required this.consume,
      required this.region});

  factory Consume.fromJson(Map<String, dynamic> json) {
    String region = "";
    if (json['region'] != null) {
      region = json['region'];
    }
    return Consume(
      year: json['year'],
      month: json['month'],
      consume: json['consume'],
      region: region,
    );
  }
}
