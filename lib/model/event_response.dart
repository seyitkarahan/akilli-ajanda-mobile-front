
class EventResponse {
  final int id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final int userId;
  final int? categoryId;

  EventResponse({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.userId,
    this.categoryId,
  });

  factory EventResponse.fromJson(Map<String, dynamic> json) {
    return EventResponse(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      location: json['location'],
      userId: json['userId'],
      categoryId: json['categoryId'],
    );
  }
}
