import 'package:wflowapp/main/actions/viewhouse/model/Device.dart';
import 'package:wflowapp/main/actions/viewhouse/model/GasConsumed.dart';
import 'package:wflowapp/main/actions/viewhouse/model/LitersConsumed.dart';

class House {
  final String house_id;
  final String name;
  final double totalConsumes;
  final String location;
  final List<LitersConsumed> litersConsumes;
  final int totalLitersConsumed;
  final int totalLitersPredicted;
  final List<GasConsumed> gasConsumed;
  final int totalGasConsumed;
  final int totalGasPredicted;
  final List<Device> devices;

  House({
    required this.house_id,
    required this.name,
    required this.totalConsumes,
    required this.location,
    required this.litersConsumes,
    required this.totalLitersConsumed,
    required this.totalLitersPredicted,
    required this.gasConsumed,
    required this.totalGasConsumed,
    required this.totalGasPredicted,
    required this.devices,
  });

  factory House.fromJson(Map<String, dynamic> json) {
    var litersConsumesList = json['litersConsumes'] as List;
    List<LitersConsumed> litersConsumes = litersConsumesList
        .map((item) => LitersConsumed.fromJson(item))
        .toList();

    var gasConsumedList = json['gasConsumed'] as List;
    List<GasConsumed> gasConsumed =
        gasConsumedList.map((item) => GasConsumed.fromJson(item)).toList();

    var devicesList = json['devices'] as List;
    List<Device> devices =
        devicesList.map((item) => Device.fromJson(item)).toList();

    return House(
      house_id: json['house_id'],
      name: json['name'],
      totalConsumes: json['totalConsumes'],
      location: json['location'],
      litersConsumes: litersConsumes,
      totalLitersConsumed: json['totalLitersConsumed'],
      totalLitersPredicted: json['totalLitersPredicted'],
      gasConsumed: gasConsumed,
      totalGasConsumed: json['totalGasConsumed'],
      totalGasPredicted: json['totalGasPredicted'],
      devices: devices,
    );
  }
}
