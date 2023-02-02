import 'package:wflowapp/config/AppConfig.dart';

class House {
  final String id;
  final String name;
  final double totalConsumes;
  final String location;
  // other stuffs
  int color;

  House(
      {required this.id,
      required this.name,
      this.totalConsumes = 0,
      required this.location,
      this.color = AppConfig.COLOR_DEFAULT});
}
