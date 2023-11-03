class GasConsumed {
  final String x;
  final dynamic y;
  final bool predicted;

  GasConsumed({required this.x, required this.y, required this.predicted});

  factory GasConsumed.fromJson(Map<String, dynamic> json) {
    return GasConsumed(
      x: json['x'],
      y: json['y'],
      predicted: json['predicted'],
    );
  }
}
