class LitersConsumedWeekly {
  final double avg;
  final double current;

  LitersConsumedWeekly({required this.avg, required this.current});

  factory LitersConsumedWeekly.fromJson(Map<String, dynamic> json) {
    return LitersConsumedWeekly(
      avg: json['avg'],
      current: json['current'],
    );
  }
}
