// filepath: lib/model/notification_response.dart

class NotificationResponse {
  final int id;
  final DateTime notifyAt;
  final bool isSent;
  final int taskId;

  NotificationResponse({
    required this.id,
    required this.notifyAt,
    required this.isSent,
    required this.taskId,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      id: json['id'],
      notifyAt: DateTime.parse(json['notifyAt']),
      isSent: json['isSent'] ?? (json['is_sent'] ?? false),
      taskId: json['taskId'] ?? (json['task_id'] ?? 0),
    );
  }
}

