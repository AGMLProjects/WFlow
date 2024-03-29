class House {
  final int house_id;
  final int user_id;
  final String name;
  final String address;
  final String city;
  final String region;
  final String country;
  final String house_type;

  House(
      {required this.house_id,
      required this.user_id,
      required this.name,
      required this.address,
      required this.city,
      required this.region,
      required this.country,
      required this.house_type});

  factory House.fromJson(Map<String, dynamic> json) {
    return House(
        house_id: json['house_id'],
        user_id: json['user_id'],
        name: json['name'],
        address: json['address'],
        city: json['city'],
        region: json['region'],
        country: json['country'],
        house_type: json['house_type']);
  }
}
