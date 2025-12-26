
import 'package:akilli_ajanda_front/view_model/image_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyImagesView extends StatelessWidget {
  const MyImagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ImageViewModel()..fetchMyImages(),
      child: Consumer<ImageViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: const Text('Resimlerim'),
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
                child: Builder(
                  builder: (context) {
                    if (viewModel.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (viewModel.error != null) {
                      return Center(child: Text(viewModel.error!, style: const TextStyle(color: Colors.white)));
                    }

                    if (viewModel.images.isEmpty) {
                      return const Center(child: Text('Hiç resim bulunamadı.', style: TextStyle(color: Colors.white, fontSize: 16)));
                    }

                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      padding: const EdgeInsets.all(8),
                      itemCount: viewModel.images.length,
                      itemBuilder: (context, index) {
                        final image = viewModel.images[index];
                        return GridTile(
                          footer: GridTileBar(
                            backgroundColor: Colors.black45,
                            title: Text(image.fileName, overflow: TextOverflow.ellipsis),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.white),
                              onPressed: () => _showDeleteConfirmationDialog(context, viewModel, image.id),
                            ),
                          ),
                          child: Image.network(
                            'http://10.0.2.2:8080/uploads/' + image.fileName, // Adjust if your filePath is different
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, ImageViewModel viewModel, int imageId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          backgroundColor: Colors.deepPurple.shade300.withOpacity(0.9),
          title: const Text('Resmi Sil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('Bu resmi silmek istediğinizden emin misiniz?', style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
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
