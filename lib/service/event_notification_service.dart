
import 'package:akilli_ajanda_front/model/event_notification_request.dart';
import 'package:akilli_ajanda_front/model/event_notification_response.dart';
import 'package:akilli_ajanda_front/service/storage_service.dart';
import 'package:dio/dio.dart';

class EventNotificationService {
  final Dio _dio = Dio();
  final StorageService _storageService = StorageService();
  static const String _baseUrl = 'http://10.0.2.2:8082/api/notifications/events';

  Future<Options> _getOptions() async {
    final token = await _storageService.getToken();
    if (token == null) {
      throw Exception('Token not found');
    }
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<EventNotificationResponse>> getAllEventNotifications() async {
    try {
      final response = await _dio.get(
        _baseUrl,
        options: await _getOptions(),
      );
      return (response.data as List)
          .map((json) => EventNotificationResponse.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get event notifications: $e');
    }
  }

  Future<EventNotificationResponse> getEventNotificationById(int id) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/$id',
        options: await _getOptions(),
      );
      return EventNotificationResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get event notification: $e');
    }
  }

  Future<EventNotificationResponse> createEventNotification(EventNotificationRequest request) async {
    try {
      final response = await _dio.post(
        _baseUrl,
        data: request.toJson(),
        options: await _getOptions(),
      );
      return EventNotificationResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create event notification: $e');
    }
  }

  Future<EventNotificationResponse> updateEventNotification(int id, EventNotificationRequest request) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/$id',
        data: request.toJson(),
        options: await _getOptions(),
      );
      return EventNotificationResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update event notification: $e');
    }
  }

  Future<void> deleteEventNotification(int id) async {
    try {
      await _dio.delete(
        '$_baseUrl/$id',
        options: await _getOptions(),
      );
    } catch (e) {
      throw Exception('Failed to delete event notification: $e');
    }
  }
}
