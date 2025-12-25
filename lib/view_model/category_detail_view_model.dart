import 'package:akilli_ajanda_front/model/event_request.dart';
import 'package:akilli_ajanda_front/model/event_response.dart';
import 'package:akilli_ajanda_front/model/task_request.dart';
import 'package:akilli_ajanda_front/model/task_response.dart';
import 'package:akilli_ajanda_front/service/api_service.dart';
import 'package:flutter/material.dart';

class CategoryDetailViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<TaskResponse> _tasks = [];
  List<EventResponse> _events = [];

  List<TaskResponse> get tasks => _tasks;
  List<EventResponse> get events => _events;

  Future<void> fetchTasksAndEvents(int categoryId) async {
    _tasks = await _apiService.getTasks(categoryId: categoryId);
    _events = await _apiService.getEvents(categoryId: categoryId);
    notifyListeners();
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

  Future<void> updateEvent(int id, EventRequest request) async {
    final event = await _apiService.updateEvent(id, request);
    if (event != null) {
      final index = _events.indexWhere((element) => element.id == id);
      if (index != -1) {
        _events[index] = event;
        notifyListeners();
      }
    }
  }

  Future<void> deleteEvent(int id) async {
    await _apiService.deleteEvent(id);
    _events.removeWhere((element) => element.id == id);
    notifyListeners();
  }
}
