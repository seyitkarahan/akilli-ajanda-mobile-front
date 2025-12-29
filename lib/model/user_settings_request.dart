class UserSettingsRequest {
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

  UserSettingsRequest({
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
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (theme != null) data['theme'] = theme;
    if (language != null) data['language'] = language;
    if (startDayOfWeek != null) data['startDayOfWeek'] = startDayOfWeek;
    if (dateFormat != null) data['dateFormat'] = dateFormat;
    if (is24HourFormat != null) data['is24HourFormat'] = is24HourFormat;
    if (emailNotificationsEnabled != null) {
      data['emailNotificationsEnabled'] = emailNotificationsEnabled;
    }
    if (pushNotificationsEnabled != null) {
      data['pushNotificationsEnabled'] = pushNotificationsEnabled;
    }
    if (defaultTaskReminderMinutes != null) {
      data['defaultTaskReminderMinutes'] = defaultTaskReminderMinutes;
    }
    if (defaultEventReminderMinutes != null) {
      data['defaultEventReminderMinutes'] = defaultEventReminderMinutes;
    }
    if (timezone != null) data['timezone'] = timezone;
    return data;
  }
}
