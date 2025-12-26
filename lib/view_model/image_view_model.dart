
import 'dart:io';
import 'package:akilli_ajanda_front/model/image_response.dart';
import 'package:akilli_ajanda_front/service/image_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageViewModel extends ChangeNotifier {
  final ImageService _imageService = ImageService();

  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  List<ImageResponse> _images = [];
  List<ImageResponse> get images => _images;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> init() async {
    await fetchMyImages();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _selectedImage = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<bool> uploadImage({int? taskId, int? eventId}) async {
    if (_selectedImage == null) return false;
    _setLoading(true);
    try {
      final newImage = await _imageService.uploadImage(_selectedImage!, taskId: taskId, eventId: eventId);
      _images.insert(0, newImage); // Add to the beginning of the list
      _selectedImage = null;
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMyImages() async {
    _setLoading(true);
    try {
      _images = await _imageService.getMyImages();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteImage(int imageId) async {
    // No loading indicator for a smoother experience
    try {
      await _imageService.deleteImage(imageId);
      _images.removeWhere((image) => image.id == imageId);
      notifyListeners(); // Update UI immediately
    } catch (e) {
      _setError(e.toString());
    }
  }

  void clearImage() {
    _selectedImage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
}
