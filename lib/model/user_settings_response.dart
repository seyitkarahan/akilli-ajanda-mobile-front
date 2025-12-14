class UserSettingsResponse {
  final int id;
  final String notificationPrefence;
  final String timezone;
  final int userId;

  UserSettingsResponse({
    required this.id,
    required this.notificationPrefence,
    required this.timezone,
    required this.userId,
  });

  factory UserSettingsResponse.fromJson(Map<String, dynamic> json) {
    return UserSettingsResponse(
      id: json['id'],
      notificationPrefence: json['notificationPrefence'],
      timezone: json['timezone'],
      userId: json['userId'],
    );
  }
}
