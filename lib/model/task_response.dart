import 'importance_level.dart';
import 'task_status.dart';

class TaskResponse {
  final int id;
  final String title;
  final String? description;
  final TaskStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final ImportanceLevel importanceLevel;
  final int userId;
  final int? categoryId;
  final int? recurringRuleId;

  TaskResponse({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    this.startTime,
    this.endTime,
    required this.importanceLevel,
    required this.userId,
    this.categoryId,
    this.recurringRuleId,
  });

  factory TaskResponse.fromJson(Map<String, dynamic> json) {
    return TaskResponse(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: TaskStatus.values.byName(json['status']),
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      importanceLevel: ImportanceLevel.values.byName(json['importanceLevel']),
      userId: json['userId'],
      categoryId: json['categoryId'],
      recurringRuleId: json['recurringRuleId'],
    );
  }
}
