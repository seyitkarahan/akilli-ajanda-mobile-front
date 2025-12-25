
class EventRequest {
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final int? categoryId;

  EventRequest({
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.categoryId,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': location,
      'categoryId': categoryId,
    };
  }
}
