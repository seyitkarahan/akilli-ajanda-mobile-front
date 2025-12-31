
import 'package:akilli_ajanda_front/model/task_notification_request.dart';
import 'package:akilli_ajanda_front/model/task_notification_response.dart';
import 'package:akilli_ajanda_front/service/task_notification_service.dart';
import 'package:flutter/material.dart';

class TaskNotificationViewModel extends ChangeNotifier {
  final TaskNotificationService _taskNotificationService = TaskNotificationService();

  List<TaskNotificationResponse> _notifications = [];
  List<TaskNotificationResponse> get notifications => _notifications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchAllTaskNotifications() async {
    _setLoading(true);
    try {
      _notifications = await _taskNotificationService.getAllTaskNotifications();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createTaskNotification(TaskNotificationRequest request) async {
    _setLoading(true);
    try {
      await _taskNotificationService.createTaskNotification(request);
      await fetchAllTaskNotifications();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateTaskNotification(int id, TaskNotificationRequest request) async {
    _setLoading(true);
    try {
      await _taskNotificationService.updateTaskNotification(id, request);
      await fetchAllTaskNotifications();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteTaskNotification(int id) async {
    try {
      await _taskNotificationService.deleteTaskNotification(id);
      _notifications.removeWhere((notification) => notification.id == id);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
}
