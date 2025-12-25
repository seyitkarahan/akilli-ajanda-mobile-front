import 'package:flutter/material.dart';
import '../model/event_request.dart';
import '../model/event_response.dart';
import '../service/api_service.dart';

class EventViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<EventResponse> _events = [];

  List<EventResponse> get events => _events;

  Future<void> fetchEvents() async {
    _events = await _apiService.getEvents();
    notifyListeners();
  }

  Future<void> createEvent(EventRequest request) async {
    final event = await _apiService.createEvent(request);
    if (event != null) {
      _events.add(event);
      notifyListeners();
    }
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
