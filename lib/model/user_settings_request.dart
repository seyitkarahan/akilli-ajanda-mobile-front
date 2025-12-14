class UserSettingsRequest {
  final String notificationPrefence;
  final String timezone;

  UserSettingsRequest({required this.notificationPrefence, required this.timezone});

  Map<String, dynamic> toJson() {
    return {
      'notificationPrefence': notificationPrefence,
      'timezone': timezone,
    };
  }
}
