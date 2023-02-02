import 'package:wflowapp/config/AppConfig.dart';

class House {
  final String id;
  final String name;
  final double consumes;
  int color;

  House(
      {required this.id,
      required this.name,
      this.consumes = 0,
      this.color = AppConfig.COLOR_DEFAULT});
}
