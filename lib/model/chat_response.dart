import 'event_response.dart';
import 'task_response.dart';

class ChatResponse {
  final String response;
  final TaskResponse? createdTask;
  final EventResponse? createdEvent;
  final List<TaskResponse>? listedTasks;
  final List<EventResponse>? listedEvents;

  ChatResponse({
    required this.response,
    this.createdTask,
    this.createdEvent,
    this.listedTasks,
    this.listedEvents,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      response: json['response'] ?? '',
      createdTask: json['createdTask'] != null
          ? TaskResponse.fromJson(json['createdTask'] as Map<String, dynamic>)
          : null,
      createdEvent: json['createdEvent'] != null
          ? EventResponse.fromJson(json['createdEvent'] as Map<String, dynamic>)
          : null,
      listedTasks: json['listedTasks'] != null
          ? (json['listedTasks'] as List<dynamic>)
              .map((e) => TaskResponse.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      listedEvents: json['listedEvents'] != null
          ? (json['listedEvents'] as List<dynamic>)
              .map((e) => EventResponse.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}
