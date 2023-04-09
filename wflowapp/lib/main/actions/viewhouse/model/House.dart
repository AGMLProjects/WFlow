import 'package:wflowapp/main/actions/viewhouse/model/Device.dart';
import 'package:wflowapp/main/actions/viewhouse/model/Event.dart';
import 'package:wflowapp/main/actions/viewhouse/model/GasConsumed.dart';
import 'package:wflowapp/main/actions/viewhouse/model/LitersConsumed.dart';
import 'package:wflowapp/main/actions/viewhouse/model/WeeklyConsume.dart';

class House {
  final int house_id;
  final String name;
  final String location;
  final List<LitersConsumed> litersConsumes;
  final List<WeeklyConsume> weeklyLitersConsumes;
  final dynamic totalLitersConsumed;
  final dynamic totalLitersPredicted;
  final List<GasConsumed> gasConsumes;
  final List<WeeklyConsume> weeklyGasConsumes;
  final dynamic totalGasConsumed;
  final dynamic totalGasPredicted;
  final List<Event> recentEvents;
  final List<Device> devices;

  House({
    required this.house_id,
    required this.name,
    required this.location,
    required this.litersConsumes,
    required this.weeklyLitersConsumes,
    required this.totalLitersConsumed,
    required this.totalLitersPredicted,
    required this.gasConsumes,
    required this.weeklyGasConsumes,
    required this.totalGasConsumed,
    required this.totalGasPredicted,
    required this.recentEvents,
    required this.devices,
  });

  factory House.fromJson(Map<String, dynamic> json) {
    var litersConsumesList = json['literConsumes'] as List;
    List<LitersConsumed> litersConsumes = litersConsumesList
        .map((item) => LitersConsumed.fromJson(item))
        .toList();

    List<WeeklyConsume> weeklyLitersConsumes = [];
    if (json['weeklyLiterConsumes'] != null) {
      var weeklyLitersConsumesList = json['weeklyLiterConsumes'] as List;
      weeklyLitersConsumes = weeklyLitersConsumesList
          .map((item) => WeeklyConsume.fromJson(item))
          .toList();
    } else {
      weeklyLitersConsumes.add(WeeklyConsume(avg: 12, current: 13));
      weeklyLitersConsumes.add(WeeklyConsume(avg: 13, current: 10));
      weeklyLitersConsumes.add(WeeklyConsume(avg: 11, current: 11));
      weeklyLitersConsumes.add(WeeklyConsume(avg: 4, current: 5));
      weeklyLitersConsumes.add(WeeklyConsume(avg: 10, current: 10));
      weeklyLitersConsumes.add(WeeklyConsume(avg: 12, current: 13));
      weeklyLitersConsumes.add(WeeklyConsume(avg: 14, current: 11));
    }

    var gasConsumedList = json['gasConsumes'] as List;
    List<GasConsumed> gasConsumes =
        gasConsumedList.map((item) => GasConsumed.fromJson(item)).toList();

    List<WeeklyConsume> weeklyGasConsumes = [];
    if (json['weeklyGasConsumes'] != null) {
      var weeklyGasConsumesList = json['weeklyGasConsumes'] as List;
      weeklyGasConsumes = weeklyGasConsumesList
          .map((item) => WeeklyConsume.fromJson(item))
          .toList();
    } else {
      weeklyGasConsumes.add(WeeklyConsume(avg: 12, current: 13));
      weeklyGasConsumes.add(WeeklyConsume(avg: 13, current: 10));
      weeklyGasConsumes.add(WeeklyConsume(avg: 11, current: 11));
      weeklyGasConsumes.add(WeeklyConsume(avg: 4, current: 5));
      weeklyGasConsumes.add(WeeklyConsume(avg: 10, current: 10));
      weeklyGasConsumes.add(WeeklyConsume(avg: 12, current: 13));
      weeklyGasConsumes.add(WeeklyConsume(avg: 14, current: 11));
    }

    List<Event> recentEvents = [];
    if (json['recentEvents'] != null) {
      var recentEventsList = json['recentEvents'] as List;
      recentEvents =
          recentEventsList.map((item) => Event.fromJson(item)).toList();
    } else {
      recentEvents.add(Event(
          description: 'description1 of event 1', timestamp: '202304101040'));
      recentEvents.add(Event(
          description: 'description2 of event 2', timestamp: '202304101039'));
      recentEvents.add(Event(
          description: 'description3 asdfghjklò', timestamp: '202304101038'));
      recentEvents.add(
          Event(description: 'description4 aaa', timestamp: '202304101037'));
      recentEvents.add(Event(
          description: 'description5 water consuption',
          timestamp: '202304101036'));
    }

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
      weeklyLitersConsumes: weeklyLitersConsumes,
      totalLitersConsumed: json['total_liters'],
      totalLitersPredicted: json['future_total_liters'],
      gasConsumes: gasConsumes,
      weeklyGasConsumes: weeklyGasConsumes,
      totalGasConsumed: json['total_gas'],
      totalGasPredicted: json['future_total_gas'],
      recentEvents: recentEvents,
      devices: devices,
    );
  }
}
