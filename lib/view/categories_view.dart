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
              titleTextStyle: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade300,
                    Colors.blue.shade400,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: viewModel.categories.isEmpty
                    ? const Center(
                  child: Text(
                    'Hiç kategori yok.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: viewModel.categories.length,
                  itemBuilder: (context, index) {
                    final category = viewModel.categories[index];
                    return _buildCategoryCard(
                        context, viewModel, category);
                  },
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () =>
                  _showCategoryDialog(context, viewModel),
              child: Icon(Icons.add,
                  color: Colors.deepPurple.shade400),
            ),
          );
        },
      ),
    );
  }

  /// 🧊 Category Card
  Widget _buildCategoryCard(
      BuildContext context,
      CategoryViewModel viewModel,
      CategoryResponse category,
      ) {
    return Card(
      color: Colors.white.withOpacity(0.15),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CategoryDetailView(category: category),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.label_outline,
                  color: Colors.white70),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    color: Colors.white70),
                color: Colors.deepPurple.shade600,
                onSelected: (value) {
                  if (value == 'edit') {
                    _showCategoryDialog(
                      context,
                      viewModel,
                      category: category,
                    );
                  } else if (value == 'delete') {
                    _showDeleteConfirmationDialog(
                        context, viewModel, category);
                  }
                },
                itemBuilder: (_) => [
                  _popupItem(
                      Icons.edit_outlined, 'Düzenle', 'edit'),
                  _popupItem(Icons.delete_outline,
                      'Sil', 'delete'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _popupItem(
      IconData icon, String text, String value) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  /// ✏️ Create / Update Dialog
  void _showCategoryDialog(
      BuildContext context,
      CategoryViewModel viewModel, {
        CategoryResponse? category,
      }) {
    final nameController =
    TextEditingController(text: category?.name ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor:
          Colors.deepPurple.shade300.withOpacity(0.95),
          title: Text(
            category == null
                ? 'Yeni Kategori'
                : 'Kategoriyi Düzenle',
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Kategori Adı',
              labelStyle:
              const TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide:
                BorderSide(color: Colors.white.withOpacity(0.5)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext),
              child: const Text('İptal',
                  style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.deepPurple.shade300,
              ),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final request =
                  CategoryRequest(name: nameController.text);
                  if (category == null) {
                    viewModel.addCategory(request);
                  } else {
                    viewModel.updateCategory(
                        category.id, request);
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

  /// 🗑 Delete Dialog
  void _showDeleteConfirmationDialog(
      BuildContext context,
      CategoryViewModel viewModel,
      CategoryResponse category,
      ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor:
          Colors.deepPurple.shade300.withOpacity(0.95),
          title: const Text(
            'Kategoriyi Sil',
            style:
            TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "'${category.name}' kategorisini silmek istediğinizden emin misiniz?",
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext),
              child: const Text('İptal',
                  style: TextStyle(color: Colors.white70)),
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
