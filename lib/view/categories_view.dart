import 'package:akilli_ajanda_front/model/category_request.dart';
import 'package:akilli_ajanda_front/view/category_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/category_view_model.dart';
import '../model/category_response.dart';

class CategoriesView extends StatelessWidget {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategoryViewModel()..fetchCategories(),
      child: Consumer<CategoryViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: const Text('Kategoriler'),
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
                child: ListView.builder(
                  itemCount: viewModel.categories.length,
                  itemBuilder: (context, index) {
                    final category = viewModel.categories[index];
                    return Card(
                      elevation: 4,
                      color: Colors.white.withOpacity(0.25),
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: const Icon(Icons.label_outline, color: Colors.white),
                        title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryDetailView(category: category),
                            ),
                          );
                        },
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showCategoryDialog(context, viewModel, category: category);
                            } else if (value == 'delete') {
                              _showDeleteConfirmationDialog(context, viewModel, category);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(children: [Icon(Icons.edit_outlined), SizedBox(width: 8), Text('Düzenle')]),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(children: [Icon(Icons.delete_outline), SizedBox(width: 8), Text('Sil')]),
                            ),
                          ],
                          icon: const Icon(Icons.more_vert, color: Colors.white70),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showCategoryDialog(context, viewModel),
              backgroundColor: Colors.white,
              child: Icon(Icons.add, color: Colors.deepPurple.shade300),
            ),
          );
        },
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, CategoryViewModel viewModel, {CategoryResponse? category}) {
    final nameController = TextEditingController(text: category?.name ?? '');
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          backgroundColor: Colors.deepPurple.shade300.withOpacity(0.9),
          title: Text(category == null ? 'Yeni Kategori' : 'Kategoriyi Düzenle', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Kategori Adı',
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('İptal', style: TextStyle(color: Colors.white70))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.deepPurple.shade300,
              ),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final request = CategoryRequest(name: nameController.text);
                  if (category == null) {
                    viewModel.addCategory(request);
                  } else {
                    viewModel.updateCategory(category.id, request);
                  }
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, CategoryViewModel viewModel, CategoryResponse category) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          backgroundColor: Colors.deepPurple.shade300.withOpacity(0.9),
          title: const Text('Kategoriyi Sil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(
            "'${category.name}' kategorisini silmek istediğinizden emin misiniz?",
            style: const TextStyle(color: Colors.white),
          ),
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
                viewModel.deleteCategory(category.id);
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
