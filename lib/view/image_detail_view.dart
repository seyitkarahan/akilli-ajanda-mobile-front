
import 'package:akilli_ajanda_front/model/image_response.dart';
import 'package:flutter/material.dart';

class ImageDetailView extends StatelessWidget {
  final ImageResponse image;

  const ImageDetailView({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(image.fileName, style: const TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.black.withOpacity(0.4),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 1.0,
          maxScale: 4.0,
          child: Image.network(
            'http://10.0.2.2:8080/uploads/' + image.fileName,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              return progress == null ? child : const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.broken_image, color: Colors.white70, size: 60);
            },
          ),
        ),
      ),
    );
  }
}
