
class EventNotificationRequest {
  final DateTime notifyAt;
  final int eventId;

  EventNotificationRequest({
    required this.notifyAt,
    required this.eventId,
  });

  Map<String, dynamic> toJson() {
    return {
      'notifyAt': notifyAt.toIso8601String(),
      'eventId': eventId,
    };
  }
}
