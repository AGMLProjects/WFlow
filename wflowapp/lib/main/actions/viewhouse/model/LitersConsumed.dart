class LitersConsumed {
  final String x;
  final dynamic y;
  final bool predicted;

  LitersConsumed({required this.x, required this.y, required this.predicted});

  factory LitersConsumed.fromJson(Map<String, dynamic> json) {
    return LitersConsumed(
      x: json['x'],
      y: json['y'],
      predicted: json['predicted'],
    );
  }
}
