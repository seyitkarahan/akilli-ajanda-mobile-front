class UserSettingsResponse {
  int? id;
  String? theme;
  String? language;
  String? startDayOfWeek;
  String? dateFormat;
  bool? is24HourFormat;
  bool? emailNotificationsEnabled;
  bool? pushNotificationsEnabled;
  int? defaultTaskReminderMinutes;
  int? defaultEventReminderMinutes;
  String? timezone;
  int? userId;

  UserSettingsResponse({
    this.id,
    this.theme,
    this.language,
    this.startDayOfWeek,
    this.dateFormat,
    this.is24HourFormat,
    this.emailNotificationsEnabled,
    this.pushNotificationsEnabled,
    this.defaultTaskReminderMinutes,
    this.defaultEventReminderMinutes,
    this.timezone,
    this.userId,
  });

  factory UserSettingsResponse.fromJson(Map<String, dynamic> json) {
    return UserSettingsResponse(
      id: json['id'],
      theme: json['theme'],
      language: json['language'],
      startDayOfWeek: json['startDayOfWeek'],
      dateFormat: json['dateFormat'],
      is24HourFormat: json['is24HourFormat'],
      emailNotificationsEnabled: json['emailNotificationsEnabled'],
      pushNotificationsEnabled: json['pushNotificationsEnabled'],
      defaultTaskReminderMinutes: json['defaultTaskReminderMinutes'],
      defaultEventReminderMinutes: json['defaultEventReminderMinutes'],
      timezone: json['timezone'],
      userId: json['userId'],
    );
  }
}
