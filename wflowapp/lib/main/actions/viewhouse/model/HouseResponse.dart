import 'package:wflowapp/main/actions/viewhouse/model/DayConsume.dart';
import 'package:wflowapp/main/actions/viewhouse/model/Device.dart';
import 'package:wflowapp/main/actions/viewhouse/model/Event.dart';
import 'package:wflowapp/main/actions/viewhouse/model/GasConsumed.dart';
import 'package:wflowapp/main/actions/viewhouse/model/House.dart';
import 'package:wflowapp/main/actions/viewhouse/model/LitersConsumed.dart';
import 'package:wflowapp/main/actions/viewhouse/model/WeeklyConsume.dart';

class HouseResponse {
  final House house;
  final List<DayConsume> sensor_data;
  final List<DayConsume> predicted_data;
  final List<Device> devices;
  final List<Event> last_events;

  HouseResponse(
      {required this.house,
      required this.sensor_data,
      required this.predicted_data,
      required this.devices,
      required this.last_events});

  factory HouseResponse.fromJson(Map<String, dynamic> json) {
    House house = House.fromJson(json['house']);

    var list = json['sensor_data'] as List;
    List<DayConsume> sensor_data =
        list.map((item) => DayConsume.fromJson(item)).toList();

    list = json['predicted_data'] as List;
    List<DayConsume> predicted_data =
        list.map((item) => DayConsume.fromJson(item)).toList();

    list = json['devices'] as List;
    List<Device> devices = list.map((item) => Device.fromJson(item)).toList();

    list = json['last_events'] as List;
    List<Event> last_events = list.map((item) => Event.fromJson(item)).toList();

    return HouseResponse(
        house: house,
        sensor_data: sensor_data,
        predicted_data: predicted_data,
        devices: devices,
        last_events: last_events);
  }
}
