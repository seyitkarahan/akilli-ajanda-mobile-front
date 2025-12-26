
import 'dart:io';
import 'package:akilli_ajanda_front/model/image_response.dart';
import 'package:akilli_ajanda_front/view_model/image_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImageUploadView extends StatelessWidget {
  const ImageUploadView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ImageViewModel(),
      child: Consumer<ImageViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: const Text('Resim Yükle'),
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
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (viewModel.selectedImage != null)
                            Container(
                              height: 200,
                              width: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                  image: FileImage(viewModel.selectedImage!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          else
                            const Text(
                              'Lütfen bir resim seçin.',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: viewModel.pickImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.deepPurple.shade300,
                            ),
                            child: const Text('Resim Seç'),
                          ),
                          if (viewModel.selectedImage != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    final response = await viewModel.uploadImage();
                                    if (response != null && context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Resim ${response.fileName} başarıyla yüklendi')),
                                      );
                                    } else if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Resim yüklenemedi.')),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.deepPurple.shade300,
                                  ),
                                  child: const Text('Yükle'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: viewModel.clearImage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Temizle'),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    if (viewModel.isLoading)
                      Container(
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
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
}
