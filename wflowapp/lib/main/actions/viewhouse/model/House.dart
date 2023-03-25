import 'package:wflowapp/main/actions/viewhouse/model/Device.dart';
import 'package:wflowapp/main/actions/viewhouse/model/GasConsumed.dart';
import 'package:wflowapp/main/actions/viewhouse/model/LitersConsumed.dart';

class House {
  final int house_id;
  final String name;
  final String location;
  final List<LitersConsumed> litersConsumes;
  final double totalLitersConsumed;
  final double totalLitersPredicted;
  final List<GasConsumed> gasConsumes;
  final double totalGasConsumed;
  final double totalGasPredicted;
  final List<Device> devices;

  House({
    required this.house_id,
    required this.name,
    required this.location,
    required this.litersConsumes,
    required this.totalLitersConsumed,
    required this.totalLitersPredicted,
    required this.gasConsumes,
    required this.totalGasConsumed,
    required this.totalGasPredicted,
    required this.devices,
  });

  factory House.fromJson(Map<String, dynamic> json) {
    var litersConsumesList = json['literConsumes'] as List;
    List<LitersConsumed> litersConsumes = litersConsumesList
        .map((item) => LitersConsumed.fromJson(item))
        .toList();

    var gasConsumedList = json['gasConsumes'] as List;
    List<GasConsumed> gasConsumes =
        gasConsumedList.map((item) => GasConsumed.fromJson(item)).toList();

    List<Device> devices = List.empty();
    if (json['devices'] != null) {
      var devicesList = json['devices'] as List;
      devices = devicesList.map((item) => Device.fromJson(item)).toList();
    }

    return House(
      house_id: json['house_id'],
      name: json['name'],
      location: json['address'],
      litersConsumes: litersConsumes,
      totalLitersConsumed: json['total_liters'],
      totalLitersPredicted: json['future_total_liters'],
      gasConsumes: gasConsumes,
      totalGasConsumed: json['total_gas'],
      totalGasPredicted: json['future_total_gas'],
      devices: devices,
    );
  }
}
