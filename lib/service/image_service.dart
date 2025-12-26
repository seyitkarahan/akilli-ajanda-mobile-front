
import 'dart:io';
import 'package:akilli_ajanda_front/model/image_response.dart';
import 'package:akilli_ajanda_front/service/storage_service.dart';
import 'package:dio/dio.dart';

class ImageService {
  final Dio _dio = Dio();
  final StorageService _storageService = StorageService();
  static const String _baseUrl = 'http://10.0.2.2:8080/api/images';

  Future<Options> _getOptions() async {
    final token = await _storageService.getToken();
    if (token == null) {
      throw Exception('Token not found');
    }
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<ImageResponse> uploadImage(File image, {int? taskId, int? eventId}) async {
    String fileName = image.path.split('/').last;
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(image.path, filename: fileName),
      if (taskId != null) 'taskId': taskId,
      if (eventId != null) 'eventId': eventId,
    });

    try {
      final response = await _dio.post(
        '$_baseUrl/upload',
        data: formData,
        options: await _getOptions(),
      );
      return ImageResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  Future<List<ImageResponse>> getMyImages() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/my',
        options: await _getOptions(),
      );
      return (response.data as List)
          .map((json) => ImageResponse.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get images: $e');
    }
  }

  Future<void> deleteImage(int imageId) async {
    try {
      await _dio.delete(
        '$_baseUrl/$imageId',
        options: await _getOptions(),
      );
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }
}
