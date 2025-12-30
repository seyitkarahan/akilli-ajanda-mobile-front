
class EventNotificationResponse {
  final int id;
  final DateTime notifyAt;
  final bool isSent;
  final int eventId;

  EventNotificationResponse({
    required this.id,
    required this.notifyAt,
    required this.isSent,
    required this.eventId,
  });

  factory EventNotificationResponse.fromJson(Map<String, dynamic> json) {
    return EventNotificationResponse(
      id: json['id'],
      notifyAt: DateTime.parse(json['notifyAt']),
      isSent: json['sent'],
      eventId: json['eventId'],
    );
  }
}
