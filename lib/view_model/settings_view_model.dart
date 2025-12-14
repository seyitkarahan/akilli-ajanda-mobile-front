import 'package:akilli_ajanda_front/model/user_settings_request.dart';
import 'package:flutter/material.dart';
import '../service/api_service.dart';
import '../model/user_settings_response.dart';

class SettingsViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  final TextEditingController notificationController = TextEditingController();
  final TextEditingController timezoneController = TextEditingController();

  bool get isLoading => _isLoading;

  SettingsViewModel() {
    loadSettings();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> loadSettings() async {
    _setLoading(true);
    final settings = await _apiService.getUserSettings();
    if (settings != null) {
      notificationController.text = settings.notificationPrefence;
      timezoneController.text = settings.timezone;
    }
    _setLoading(false);
  }

  Future<bool> saveSettings() async {
    _setLoading(true);
    final request = UserSettingsRequest(
      notificationPrefence: notificationController.text,
      timezone: timezoneController.text,
    );
    
    // Try to update first, if it fails, try to create.
    var response = await _apiService.updateUserSettings(request);
    if (response == null) {
      response = await _apiService.createUserSettings(request);
    }

    _setLoading(false);
    return response != null;
  }

  Future<bool> deleteSettings() async {
    _setLoading(true);
    try {
      await _apiService.deleteUserSettings();
      notificationController.clear();
      timezoneController.clear();
      _setLoading(false);
      return true;
    } catch (e) {
      print('Error deleting settings: $e');
      _setLoading(false);
      return false;
    }
  }
}
