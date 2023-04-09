class Event {
  final String description;
  final String timestamp;

  Event({required this.description, required this.timestamp});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
        description: json['description'], timestamp: json['timestamp']);
  }
}
