class ChatRequest {
  final String message;
  final DateTime? date;

  ChatRequest({required this.message, this.date});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'message': message};
    if (date != null) {
      map['date'] = date!.toIso8601String().split('T').first;
    }
    return map;
  }
}
