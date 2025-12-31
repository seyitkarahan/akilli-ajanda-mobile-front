import 'package:akilli_ajanda_front/view/home_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../service/api_service.dart';
import '../service/storage_service.dart';
import '../model/auth/login_request.dart';

class LoginViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    if (_isLoading) return;

    _setLoading(true);

    final request = LoginRequest(
      email: emailController.text,
      password: passwordController.text,
    );

    final response = await _apiService.login(request);

    if (response != null) {
      await _storageService.saveToken(response.token);
      
      // Cihaz token'ını al ve sunucuya gönder
      try {
        String? token = await _firebaseMessaging.getToken();
        if (token != null) {
          await _apiService.updateDeviceToken(token);
        }
      } catch (e) {
        print("Failed to get or update device token: $e");
      }
      
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Giriş başarısız oldu")),
        );
      }
    }

    _setLoading(false);
  }
}
