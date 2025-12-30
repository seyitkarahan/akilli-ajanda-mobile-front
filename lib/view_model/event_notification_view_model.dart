
import 'package:akilli_ajanda_front/model/event_notification_request.dart';
import 'package:akilli_ajanda_front/model/event_notification_response.dart';
import 'package:akilli_ajanda_front/service/event_notification_service.dart';
import 'package:flutter/material.dart';

class EventNotificationViewModel extends ChangeNotifier {
  final EventNotificationService _eventNotificationService = EventNotificationService();

  List<EventNotificationResponse> _notifications = [];
  List<EventNotificationResponse> get notifications => _notifications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchAllEventNotifications() async {
    _setLoading(true);
    try {
      _notifications = await _eventNotificationService.getAllEventNotifications();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createEventNotification(EventNotificationRequest request) async {
    _setLoading(true);
    try {
      await _eventNotificationService.createEventNotification(request);
      await fetchAllEventNotifications();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateEventNotification(int id, EventNotificationRequest request) async {
    _setLoading(true);
    try {
      await _eventNotificationService.updateEventNotification(id, request);
      await fetchAllEventNotifications();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteEventNotification(int id) async {
    try {
      await _eventNotificationService.deleteEventNotification(id);
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

