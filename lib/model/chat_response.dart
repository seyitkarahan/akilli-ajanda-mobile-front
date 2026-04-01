import 'event_response.dart';
import 'task_response.dart';

class ChatResponse {
  final String response;
  final TaskResponse? createdTask;
  final EventResponse? createdEvent;

  ChatResponse({
    required this.response,
    this.createdTask,
    this.createdEvent,
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
    );
  }
}
