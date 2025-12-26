
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

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _selectedImage = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<ImageResponse?> uploadImage({int? taskId, int? eventId}) async {
    if (_selectedImage == null) return null;
    _setLoading(true);
    ImageResponse? response;
    try {
      response = await _imageService.uploadImage(_selectedImage!, taskId: taskId, eventId: eventId);
      _selectedImage = null;
      // After uploading, refresh the list of images
      await fetchMyImages();
    } catch (e) {
      _setError(e.toString());
      response = null;
    } finally {
      _setLoading(false);
    }
    return response;
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
    _setLoading(true);
    try {
      await _imageService.deleteImage(imageId);
      // Remove the image from the local list
      _images.removeWhere((image) => image.id == imageId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
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
