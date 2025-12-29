import 'package:flutter/material.dart';
import '../service/api_service.dart';
import '../model/user_settings_response.dart';
import '../model/user_settings_request.dart';

class SettingsViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  UserSettingsResponse? _userSettings;
  bool _isLoading = false;

  UserSettingsResponse? get userSettings => _userSettings;
  bool get isLoading => _isLoading;

  // Controllers for text fields
  final TextEditingController defaultTaskReminderMinutesController = TextEditingController();
  final TextEditingController defaultEventReminderMinutesController = TextEditingController();

  SettingsViewModel() {
    loadSettings();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> loadSettings() async {
    _setLoading(true);
    _userSettings = await _apiService.getUserSettings();
    if (_userSettings == null) {
      // Create default settings if they don't exist on the server
      _userSettings = UserSettingsResponse(
        theme: 'SYSTEM',
        language: 'tr',
        startDayOfWeek: 'MONDAY',
        dateFormat: 'dd/MM/yyyy',
        is24HourFormat: true,
        emailNotificationsEnabled: true,
        pushNotificationsEnabled: true,
        defaultTaskReminderMinutes: 30,
        defaultEventReminderMinutes: 60,
        timezone: 'Europe/Istanbul',
      );
    }

    // Populate controllers from the userSettings object (either fetched or default)
    defaultTaskReminderMinutesController.text = _userSettings!.defaultTaskReminderMinutes?.toString() ?? '';
    defaultEventReminderMinutesController.text = _userSettings!.defaultEventReminderMinutes?.toString() ?? '';

    _setLoading(false);
  }

  Future<bool> saveSettings() async {
    if (_userSettings == null) return false;

    _setLoading(true);

    final request = UserSettingsRequest(
      theme: _userSettings!.theme,
      language: _userSettings!.language,
      startDayOfWeek: _userSettings!.startDayOfWeek,
      dateFormat: _userSettings!.dateFormat,
      is24HourFormat: _userSettings!.is24HourFormat,
      emailNotificationsEnabled: _userSettings!.emailNotificationsEnabled,
      pushNotificationsEnabled: _userSettings!.pushNotificationsEnabled,
      defaultTaskReminderMinutes: int.tryParse(defaultTaskReminderMinutesController.text),
      defaultEventReminderMinutes: int.tryParse(defaultEventReminderMinutesController.text),
      timezone: _userSettings!.timezone,
    );

    UserSettingsResponse? response;
    if (_userSettings!.id == null) {
      // If ID is null, settings don't exist on the server, so create them
      response = await _apiService.createUserSettings(request);
    } else {
      // Otherwise, update existing settings
      response = await _apiService.updateUserSettings(request);
    }

    if (response != null) {
      // Update local settings with the response from the server (e.g., to get the new ID)
      _userSettings = response;
       // Re-populate controllers in case the server changed a value
      defaultTaskReminderMinutesController.text = _userSettings!.defaultTaskReminderMinutes?.toString() ?? '';
      defaultEventReminderMinutesController.text = _userSettings!.defaultEventReminderMinutes?.toString() ?? '';
      notifyListeners();
    }

    _setLoading(false);
    return response != null;
  }

  void updateTheme(String? theme) {
    if (_userSettings != null) {
      _userSettings!.theme = theme;
      notifyListeners();
    }
  }

  void updateLanguage(String? language) {
    if (_userSettings != null) {
      _userSettings!.language = language;
      notifyListeners();
    }
  }

  void updateStartDayOfWeek(String? startDayOfWeek) {
    if (_userSettings != null) {
      _userSettings!.startDayOfWeek = startDayOfWeek;
      notifyListeners();
    }
  }

  void updateDateFormat(String? dateFormat) {
    if (_userSettings != null) {
      _userSettings!.dateFormat = dateFormat;
      notifyListeners();
    }
  }

  void updateIs24HourFormat(bool? is24HourFormat) {
    if (_userSettings != null) {
      _userSettings!.is24HourFormat = is24HourFormat;
      notifyListeners();
    }
  }

  void updateEmailNotificationsEnabled(bool? enabled) {
    if (_userSettings != null) {
      _userSettings!.emailNotificationsEnabled = enabled;
      notifyListeners();
    }
  }

  void updatePushNotificationsEnabled(bool? enabled) {
    if (_userSettings != null) {
      _userSettings!.pushNotificationsEnabled = enabled;
      notifyListeners();
    }
  }

  void updateTimezone(String? timezone) {
    if (_userSettings != null) {
      _userSettings!.timezone = timezone;
      notifyListeners();
    }
  }
}
