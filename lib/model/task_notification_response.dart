
class TaskNotificationResponse {
  final int id;
  final DateTime notifyAt;
  final bool isSent;
  final int taskId;

  TaskNotificationResponse({
    required this.id,
    required this.notifyAt,
    required this.isSent,
    required this.taskId,
  });

  factory TaskNotificationResponse.fromJson(Map<String, dynamic> json) {
    return TaskNotificationResponse(
      id: json['id'],
      notifyAt: DateTime.parse(json['notifyAt']),
      isSent: json['sent'],
      taskId: json['taskId'],
    );
  }
}
