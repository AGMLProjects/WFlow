class WeeklyConsume {
  final double avg;
  final double current;

  WeeklyConsume({required this.avg, required this.current});

  factory WeeklyConsume.fromJson(Map<String, dynamic> json) {
    return WeeklyConsume(
      avg: json['avg'],
      current: json['current'],
    );
  }
}
