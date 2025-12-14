class NotificationRequest {
  final DateTime? notifyAt;
  final int? taskId;

  NotificationRequest({this.notifyAt, this.taskId});

  Map<String, dynamic> toJson() => {
        if (notifyAt != null) 'notifyAt': notifyAt!.toIso8601String(),
        if (taskId != null) 'taskId': taskId,
      };
}
