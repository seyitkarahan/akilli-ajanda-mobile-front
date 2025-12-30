import 'dart:io';
import 'package:akilli_ajanda_front/view/image_detail_view.dart';
import 'package:akilli_ajanda_front/view_model/image_view_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ImageGalleryView extends StatelessWidget {
  const ImageGalleryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ImageViewModel()..init(),
      child: Consumer<ImageViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: const Text('Resim Galerisi'),
              elevation: 0,
              backgroundColor: Colors.transparent,
              titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade300, Colors.blue.shade400],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    _buildImageUploaderSection(context, viewModel),
                    const SizedBox(height: 20),
                    Expanded(
                      child: _buildImageGridSection(context, viewModel),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageUploaderSection(BuildContext context, ImageViewModel viewModel) {
    return Card(
      color: Colors.white.withOpacity(0.15),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Resim Yükle',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (viewModel.selectedImage != null)
              Center(
                child: Container(
                  height: 150,
                  width: 150,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: FileImage(viewModel.selectedImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ) else Center(
                child: ElevatedButton.icon(
                  onPressed: () => _showImageSourceDialog(context, viewModel),
                  icon: const Icon(Icons.add_a_photo, color: Colors.deepPurple),
                  label: const Text('Resim Seç', style: TextStyle(color: Colors.deepPurple)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
            if (viewModel.selectedImage != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final success = await viewModel.uploadImage();
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Resim başarıyla yüklendi.'), backgroundColor: Colors.green),
                          );
                          viewModel.clearImage(); // Clear image after successful upload
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Resim yüklenemedi: ${viewModel.error}'), backgroundColor: Colors.red),
                          );
                        }
                      },
                      icon: const Icon(Icons.cloud_upload, color: Colors.white),
                      label: const Text('Yükle', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade600,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: viewModel.clearImage,
                      icon: const Icon(Icons.cancel, color: Colors.white),
                      label: const Text('İptal', style: TextStyle(color: Colors.white)),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0), side: const BorderSide(color: Colors.white54)),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGridSection(BuildContext context, ImageViewModel viewModel) {
    return Card(
      color: Colors.white.withOpacity(0.15),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Yüklenen Resimler',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: _buildImageGrid(context, viewModel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context, ImageViewModel viewModel) {
    if (viewModel.isLoading && viewModel.images.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (viewModel.error != null && viewModel.images.isEmpty) {
      return Center(child: Text(viewModel.error!, style: const TextStyle(color: Colors.white)));
    }

    if (viewModel.images.isEmpty) {
      return const Center(child: Text('Henüz hiç resim yüklemediniz.', style: TextStyle(color: Colors.white, fontSize: 16)));
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      padding: const EdgeInsets.all(4),
      itemCount: viewModel.images.length,
      itemBuilder: (context, index) {
        final image = viewModel.images[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ImageDetailView(image: image),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0), // Rounded corners for grid items
            child: GridTile(
              footer: GridTileBar(
                backgroundColor: Colors.black54,
                leading: Icon(Icons.photo, color: Colors.white, size: 16), // Added icon
                title: Text(
                  image.fileName.length > 15 ? image.fileName.substring(0, 12) + '...' : image.fileName, // Truncate long file names
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                  onPressed: () => _showDeleteConfirmationDialog(context, viewModel, image.id),
                ),
              ),
              child: Hero(
                tag: image.id, // For smooth transition to detail view
                child: Image.network(
                  'http://10.0.2.2:8080/uploads/' + image.fileName,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                            : null,
                        color: Colors.white,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image, color: Colors.white70, size: 40);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showImageSourceDialog(BuildContext context, ImageViewModel viewModel) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          backgroundColor: Colors.deepPurple.shade700.withOpacity(0.9),
          title: const Text('Resim Kaynağını Seçin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text('Galeriden Seç', style: TextStyle(color: Colors.white)),
                onTap: () {
                  viewModel.pickImage(ImageSource.gallery);
                  Navigator.pop(dialogContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text('Kameradan Çek', style: TextStyle(color: Colors.white)),
                onTap: () {
                  viewModel.pickImage(ImageSource.camera);
                  Navigator.pop(dialogContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, ImageViewModel viewModel, int imageId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          backgroundColor: Colors.deepPurple.shade700.withOpacity(0.9),
          title: const Text('Resmi Sil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('Bu resmi silmek istediğinizden emin misiniz?', style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              onPressed: () {
                viewModel.deleteImage(imageId);
                Navigator.pop(dialogContext);
              },
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );
  }
}