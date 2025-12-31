
import 'dart:convert';
import 'package:akilli_ajanda_front/model/importance_level.dart';
import 'package:akilli_ajanda_front/model/task_status.dart';
import 'package:http/http.dart' as http;
import '../model/auth/register_request.dart';
import '../model/auth/login_request.dart';
import '../model/auth/auth_response.dart';
import '../model/category_request.dart';
import '../model/category_response.dart';
import '../model/event_request.dart';
import '../model/event_response.dart';
import '../model/user_settings_request.dart';
import '../model/user_settings_response.dart';
import '../model/task_request.dart';
import '../model/task_response.dart';
import '../model/notification_request.dart';
import '../model/notification_response.dart';
import 'storage_service.dart';

class ApiService {
  final String _baseUrl = "http://10.0.2.2:8080/api";
  final StorageService _storageService = StorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }
  
  Future<void> updateDeviceToken(String deviceToken) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/users/update-device-token'),
        headers: await _getHeaders(),
        body: deviceToken,
      );
    } catch (e) {
      print('Device token update failed: $e');
    }
  }

  // --- Auth ---
  Future<AuthResponse?> register(RegisterRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      print('Register failed: ${response.body}');
      return null;
    }
  }

  Future<AuthResponse?> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      print('Login failed: ${response.body}');
      return null;
    }
  }

  // --- User Settings ---
  Future<UserSettingsResponse?> getUserSettings() async {
    final response = await http.get(Uri.parse('$_baseUrl/user-settings'), headers: await _getHeaders());
    if (response.statusCode == 200) {
      return UserSettingsResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      print('Get UserSettings failed: ${response.body}');
      return null;
    }
  }

  Future<UserSettingsResponse?> createUserSettings(UserSettingsRequest request) async {
    final response = await http.post(Uri.parse('$_baseUrl/user-settings'), headers: await _getHeaders(), body: jsonEncode(request.toJson()));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return UserSettingsResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      print('Create UserSettings failed: ${response.body}');
      return null;
    }
  }

  Future<UserSettingsResponse?> updateUserSettings(UserSettingsRequest request) async {
    final response = await http.put(Uri.parse('$_baseUrl/user-settings'), headers: await _getHeaders(), body: jsonEncode(request.toJson()));
    if (response.statusCode == 200) {
      return UserSettingsResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      print('Update UserSettings failed: ${response.body}');
      return null;
    }
  }

  Future<void> deleteUserSettings() async {
    final response = await http.delete(Uri.parse('$_baseUrl/user-settings'), headers: await _getHeaders());
    if (response.statusCode != 204) {
      print('Delete UserSettings failed: ${response.body}');
    }
  }

  // --- Categories ---
  Future<List<CategoryResponse>> getCategories() async {
    final response = await http.get(Uri.parse('$_baseUrl/categories'), headers: await _getHeaders());
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => CategoryResponse.fromJson(json)).toList();
    } else {
      print('Get Categories failed: ${response.body}');
      return [];
    }
  }

  Future<CategoryResponse?> addCategory(String name) async {
    final request = CategoryRequest(name: name);
    return await createCategory(request);
  }

  Future<CategoryResponse?> createCategory(CategoryRequest request) async {
    final response = await http.post(Uri.parse('$_baseUrl/categories'), headers: await _getHeaders(), body: jsonEncode(request.toJson()));
    if (response.statusCode == 201 || response.statusCode == 200) {
      return CategoryResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      print('Create Category failed: ${response.body}');
      return null;
    }
  }

  Future<CategoryResponse?> updateCategory(int id, CategoryRequest request) async {
    final response = await http.put(Uri.parse('$_baseUrl/categories/$id'), headers: await _getHeaders(), body: jsonEncode(request.toJson()));
    if (response.statusCode == 200) {
      return CategoryResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      print('Update Category failed: ${response.body}');
      return null;
    }
  }

  Future<void> deleteCategory(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/categories/$id'), headers: await _getHeaders());
    if (response.statusCode != 204) {
      print('Delete Category failed: ${response.body}');
    }
  }

  // --- Tasks ---
  Future<List<TaskResponse>> getTasks({int? categoryId}) async {
    String url = '$_baseUrl/tasks';
    if (categoryId != null) {
      url += '?categoryId=$categoryId';
    }
    final response = await http.get(Uri.parse(url), headers: await _getHeaders());
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => TaskResponse.fromJson(json)).toList();
    } else {
      print('Get Tasks failed: ${response.body}');
      return [];
    }
  }
  
  Future<TaskResponse?> getTaskById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/tasks/$id'), headers: await _getHeaders());
    if (response.statusCode == 200) {
      return TaskResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      print('Get Task failed: ${response.body}');
      return null;
    }
  }

  Future<TaskResponse?> addTask(String title, String description, int categoryId, ImportanceLevel importanceLevel, DateTime? startTime, DateTime? endTime) async {
    final request = TaskRequest(
      title: title,
      description: description,
      categoryId: categoryId,
      status: TaskStatus.PENDING,
      importanceLevel: importanceLevel,
      startTime: startTime,
      endTime: endTime,
    );
    return await createTask(request);
  }

  Future<TaskResponse?> createTask(TaskRequest request) async {
    final response = await http.post(Uri.parse('$_baseUrl/tasks'), headers: await _getHeaders(), body: jsonEncode(request.toJson()));
    if (response.statusCode == 201 || response.statusCode == 200) {
      return TaskResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      print('Create Task failed: ${response.body}');
      return null;
    }
  }

  Future<TaskResponse?> updateTask(int id, TaskRequest request) async {
    final response = await http.put(Uri.parse('$_baseUrl/tasks/$id'), headers: await _getHeaders(), body: jsonEncode(request.toJson()));
    if (response.statusCode == 200) {
      return TaskResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      print('Update Task failed: ${response.body}');
      return null;
    }
  }

  Future<void> deleteTask(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/tasks/$id'), headers: await _getHeaders());
    if (response.statusCode != 204) {
      print('Delete Task failed: ${response.body}');
    }
  }

  // --- Events ---
  Future<List<EventResponse>> getEvents({int? categoryId}) async {
    String url = '$_baseUrl/events';
    if (categoryId != null) {
      url += '?categoryId=$categoryId';
    }
    final response = await http.get(Uri.parse(url), headers: await _getHeaders());
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => EventResponse.fromJson(json)).toList();
    } else {
      print('Get Events failed: ${response.body}');
      return [];
    }
  }

  Future<EventResponse?> getEventById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/events/$id'), headers: await _getHeaders());
    if (response.statusCode == 200) {
      return EventResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      print('Get Event failed: ${response.body}');
      return null;
    }
  }

  Future<EventResponse?> createEvent(EventRequest request) async {
    final response = await http.post(Uri.parse('$_baseUrl/events'), headers: await _getHeaders(), body: jsonEncode(request.toJson()));
    if (response.statusCode == 201 || response.statusCode == 200) {
      return EventResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      print('Create Event failed: ${response.body}');
      return null;
    }
  }

  Future<EventResponse?> updateEvent(int id, EventRequest request) async {
    final response = await http.put(Uri.parse('$_baseUrl/events/$id'), headers: await _getHeaders(), body: jsonEncode(request.toJson()));
    if (response.statusCode == 200) {
      return EventResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      print('Update Event failed: ${response.body}');
      return null;
    }
  }

  Future<void> deleteEvent(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/events/$id'), headers: await _getHeaders());
    if (response.statusCode != 204) {
      print('Delete Event failed: ${response.body}');
    }
  }
}
