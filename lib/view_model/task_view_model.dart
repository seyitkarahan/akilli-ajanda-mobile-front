import 'package:akilli_ajanda_front/model/task_status.dart';
import 'package:flutter/material.dart';
import '../model/task_request.dart';
import '../model/task_response.dart';
import '../service/api_service.dart';

class TaskViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<TaskResponse> _tasks = [];

  List<TaskResponse> get tasks => _tasks;

  Future<void> fetchTasks() async {
    _tasks = await _apiService.getTasks();
    notifyListeners();
  }

  Future<void> createTask(TaskRequest request) async {
    final task = await _apiService.createTask(request);
    if (task != null) {
      _tasks.add(task);
      notifyListeners();
    }
  }

  Future<void> updateTask(int id, TaskRequest request) async {
    final task = await _apiService.updateTask(id, request);
    if (task != null) {
      final index = _tasks.indexWhere((element) => element.id == id);
      if (index != -1) {
        _tasks[index] = task;
        notifyListeners();
      }
    }
  }

  Future<void> deleteTask(int id) async {
    await _apiService.deleteTask(id);
    _tasks.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  Future<void> updateTaskStatus(TaskResponse task, TaskStatus newStatus) async {
    final request = TaskRequest(
      title: task.title,
      description: task.description,
      status: newStatus,
      startTime: task.startTime,
      endTime: task.endTime,
      importanceLevel: task.importanceLevel,
      categoryId: task.categoryId,
      recurringRuleId: task.recurringRuleId,
    );
    await updateTask(task.id, request);
  }
}
