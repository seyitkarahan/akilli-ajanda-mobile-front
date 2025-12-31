
import 'package:akilli_ajanda_front/model/task_notification_request.dart';
import 'package:akilli_ajanda_front/model/task_notification_response.dart';
import 'package:akilli_ajanda_front/service/storage_service.dart';
import 'package:dio/dio.dart';

class TaskNotificationService {
  final Dio _dio = Dio();
  final StorageService _storageService = StorageService();
  static const String _baseUrl = 'http://10.0.2.2:8080/api/notifications/tasks';

  Future<Options> _getOptions() async {
    final token = await _storageService.getToken();
    if (token == null) {
      throw Exception('Token not found');
    }
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<TaskNotificationResponse>> getAllTaskNotifications() async {
    try {
      final response = await _dio.get(
        _baseUrl,
        options: await _getOptions(),
      );
      return (response.data as List)
          .map((json) => TaskNotificationResponse.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get task notifications: $e');
    }
  }

  Future<TaskNotificationResponse> getTaskNotificationById(int id) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/$id',
        options: await _getOptions(),
      );
      return TaskNotificationResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get task notification: $e');
    }
  }

  Future<TaskNotificationResponse> createTaskNotification(TaskNotificationRequest request) async {
    try {
      final response = await _dio.post(
        _baseUrl,
        data: request.toJson(),
        options: await _getOptions(),
      );
      return TaskNotificationResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create task notification: $e');
    }
  }

  Future<TaskNotificationResponse> updateTaskNotification(int id, TaskNotificationRequest request) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/$id',
        data: request.toJson(),
        options: await _getOptions(),
      );
      return TaskNotificationResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update task notification: $e');
    }
  }

  Future<void> deleteTaskNotification(int id) async {
    try {
      await _dio.delete(
        '$_baseUrl/$id',
        options: await _getOptions(),
      );
    } catch (e) {
      throw Exception('Failed to delete task notification: $e');
    }
  }
}
