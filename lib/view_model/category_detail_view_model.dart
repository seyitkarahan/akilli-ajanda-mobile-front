import 'package:akilli_ajanda_front/model/event_response.dart';
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
}
