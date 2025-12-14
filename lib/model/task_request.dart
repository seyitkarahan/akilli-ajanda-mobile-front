import 'importance_level.dart';
import 'task_status.dart';

class TaskRequest {
  final String title;
  final String? description;
  final TaskStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final ImportanceLevel importanceLevel;
  final int? categoryId;
  final int? recurringRuleId;

  TaskRequest({
    required this.title,
    this.description,
    required this.status,
    this.startTime,
    this.endTime,
    required this.importanceLevel,
    this.categoryId,
    this.recurringRuleId,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'status': status.toString().split('.').last,
    'startTime': startTime?.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'importanceLevel': importanceLevel.toString().split('.').last,
    'categoryId': categoryId,
    'recurringRuleId': recurringRuleId,
  };
}
