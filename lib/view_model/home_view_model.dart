import 'package:akilli_ajanda_front/model/event_request.dart';
import 'package:akilli_ajanda_front/model/event_response.dart';
import 'package:akilli_ajanda_front/model/importance_level.dart';
import 'package:akilli_ajanda_front/model/user_settings_response.dart';
import 'package:flutter/material.dart';
import '../model/category_response.dart';
import '../model/task_response.dart';
import '../service/api_service.dart';

class HomeViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<CategoryResponse> _categories = [];
  List<TaskResponse> _tasks = [];
  List<EventResponse> _events = [];
  UserSettingsResponse? _userSettings;
  bool _isLoading = false;
  int? _selectedCategoryId;

  List<CategoryResponse> get categories => _categories;
  List<TaskResponse> get tasks => _tasks;
  List<EventResponse> get events => _events;
  UserSettingsResponse? get userSettings => _userSettings;
  bool get isLoading => _isLoading;
  int? get selectedCategoryId => _selectedCategoryId;

  HomeViewModel() {
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.getCategories(),
        _apiService.getTasks(), // Initially load all tasks
        _apiService.getEvents(),
        _apiService.getUserSettings(),
      ]);
      _categories = results[0] as List<CategoryResponse>;
      _tasks = results[1] as List<TaskResponse>;
      _events = results[2] as List<EventResponse>;
      _userSettings = results[3] as UserSettingsResponse?;
      if (_userSettings == null) {
        _userSettings = UserSettingsResponse(startDayOfWeek: 'MONDAY');
      }
    } catch (e) {
      print('Error fetching initial data: $e');
      _userSettings = UserSettingsResponse(startDayOfWeek: 'MONDAY');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectCategory(int? categoryId) async {
    if (_selectedCategoryId == categoryId) {
      _selectedCategoryId = null;
    } else {
      _selectedCategoryId = categoryId;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _apiService.getTasks(categoryId: _selectedCategoryId);
      _events = await _apiService.getEvents(categoryId: _selectedCategoryId);
    } catch (e) {
      print('Error fetching tasks for category: $e');
      _tasks = [];
      _events = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(String name) async {
    try {
      final newCategory = await _apiService.addCategory(name);
      if (newCategory != null) {
        _categories.add(newCategory);
        notifyListeners();
      }
    } catch (e) {
      print('Error adding category: $e');
    }
  }

  Future<bool> addTask(String title, String description, int categoryId, ImportanceLevel importanceLevel, DateTime? startTime, DateTime? endTime) async {
    try {
      final newTask = await _apiService.addTask(title, description, categoryId, importanceLevel, startTime, endTime);
      if (newTask != null) {
        if (_selectedCategoryId == null || newTask.categoryId == _selectedCategoryId) {
          _tasks.insert(0, newTask);
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding task: $e');
      return false;
    }
  }

  Future<bool> addEvent(EventRequest request) async {
    try {
      final newEvent = await _apiService.createEvent(request);
      if (newEvent != null) {
        if (_selectedCategoryId == null || newEvent.categoryId == _selectedCategoryId) {
          _events.insert(0, newEvent);
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding event: $e');
      return false;
    }
  }
}
