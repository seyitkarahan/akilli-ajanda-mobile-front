
class TaskNotificationRequest {
  final DateTime notifyAt;
  final int taskId;

  TaskNotificationRequest({
    required this.notifyAt,
    required this.taskId,
  });

  Map<String, dynamic> toJson() {
    return {
      'notifyAt': notifyAt.toIso8601String(),
      'taskId': taskId,
    };
  }
}
