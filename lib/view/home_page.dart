import 'package:akilli_ajanda_front/model/category_response.dart';
import 'package:akilli_ajanda_front/model/importance_level.dart';
import 'package:akilli_ajanda_front/model/task_status.dart';
import 'package:akilli_ajanda_front/service/storage_service.dart';
import 'package:akilli_ajanda_front/view/categories_view.dart';
import 'package:akilli_ajanda_front/view/login_view.dart';
import 'package:akilli_ajanda_front/view/settings_view.dart';
import 'package:akilli_ajanda_front/view/tasks_view.dart';
import 'package:akilli_ajanda_front/widgets/custom_button.dart';
import 'package:akilli_ajanda_front/widgets/custom_gtextfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/home_view_model.dart';
import 'dart:ui';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  void logout(BuildContext context) async {
    await StorageService().removeToken();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
          (route) => false,
    );
  }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel()..fetchInitialData(),
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: const Text('Akıllı Ajanda'),
              elevation: 0,
              backgroundColor: Colors.transparent,
              titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
              iconTheme: const IconThemeData(color: Colors.white), // For Drawer icon
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () => _showLogoutConfirmationDialog(context),
                )
              ],
            ),
            drawer: Drawer(
              backgroundColor: Colors.transparent,
              child: Container(
                color: Colors.transparent,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 300,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85), // Arkaplan rengine karışmaz
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.deepPurple.shade300, Colors.deepPurple.shade400],
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.menu, color: Colors.white, size: 28),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Menü',
                                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ListTile(
                                leading: Icon(Icons.category, color: Colors.deepPurple.shade600),
                                title: Text('Kategoriler', style: TextStyle(color: Colors.black87)),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const CategoriesView()),
                                  ).then((_) => viewModel.fetchInitialData());
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.task, color: Colors.deepPurple.shade600),
                                title: Text('Görevler', style: TextStyle(color: Colors.black87)),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const TasksView()),
                                  ).then((_) => viewModel.fetchInitialData());
                                },
                              ),
                              const Divider(),
                              ListTile(
                                leading: Icon(Icons.settings, color: Colors.deepPurple.shade600),
                                title: Text('Ayarlar', style: TextStyle(color: Colors.black87)),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const SettingsView()),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        'Kategoriler',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        scrollDirection: Axis.horizontal,
                        itemCount: viewModel.categories.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _buildCategoryCard(context, null, 'Tümü', viewModel);
                          }
                          final category = viewModel.categories[index - 1];
                          return _buildCategoryCard(context, category.id, category.name, viewModel);
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      child: Text(
                        'Görevler',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    if (viewModel.isLoading)
                      const Expanded(
                        child: Center(child: CircularProgressIndicator(color: Colors.white)),
                      )
                    else
                      Expanded(
                        child: Builder(builder: (context) {
                          // Seçili kategoriye göre filtreleme yapılır.
                          final filteredTasks = viewModel.selectedCategoryId == null
                              ? viewModel.tasks
                              : viewModel.tasks.where((t) => t.categoryId == viewModel.selectedCategoryId).toList();

                          if (filteredTasks.isEmpty) {
                            return Center(
                                child: Text('Bu kategoride görev bulunmuyor.',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)));
                          }

                          return ListView.builder(
                            itemCount: filteredTasks.length,
                            itemBuilder: (context, index) {
                              final task = filteredTasks[index];
                              return Card(
                                elevation: 2,
                                color: Colors.white.withOpacity(0.2),
                                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                child: ListTile(
                                  title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                                  subtitle: task.description != null && task.description!.isNotEmpty
                                      ? Text(
                                    task.description!,
                                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                                  )
                                      : null,
                                  trailing: Checkbox(
                                    value: task.status == TaskStatus.COMPLETED,
                                    onChanged: (bool? value) {
                                    },
                                    activeColor: Colors.white,
                                    checkColor: Colors.deepPurple,
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (viewModel.categories.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lütfen önce bir kategori oluşturun.')),
                  );
                } else {
                  _showAddTaskDialog(context, viewModel);
                }
              },
              backgroundColor: viewModel.categories.isEmpty ? Colors.grey : Colors.white,
              child: Icon(Icons.add, color: Colors.deepPurple.shade300),
            ),
          );
        },
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          backgroundColor: Colors.deepPurple.shade300.withOpacity(0.9),
          title: const Text('Çıkış Yap', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('Çıkış yapmak istediğinizden emin misiniz?', style: TextStyle(color: Colors.white)),
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
                Navigator.pop(dialogContext);
                logout(context);
              },
              child: const Text('Çıkış Yap'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, int? categoryId, String name, HomeViewModel viewModel) {
    final bool isSelected = viewModel.selectedCategoryId == categoryId;
    return GestureDetector(
      onTap: () => viewModel.selectCategory(categoryId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 130,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [Colors.white, Colors.white.withOpacity(0.9)]
                : [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.deepPurple.shade300 : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? Colors.deepPurple.withOpacity(0.3) : Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isSelected ? Colors.deepPurple.shade700 : Colors.white,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, HomeViewModel viewModel) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    ImportanceLevel selectedImportanceLevel = ImportanceLevel.MEDIUM;
    int? selectedCategoryId = viewModel.selectedCategoryId;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          backgroundColor: Colors.deepPurple.shade300.withOpacity(0.9),
          title: const Text('Yeni Görev Ekle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: titleController,
                  labelText: 'Başlık',
                  icon: Icons.title,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: descriptionController,
                  labelText: 'Açıklama',
                  icon: Icons.description,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<int>(
                  value: selectedCategoryId,
                  items: viewModel.categories.map((CategoryResponse category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(category.name, style: const TextStyle(color: Colors.black)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategoryId = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
                  ),
                  dropdownColor: Colors.deepPurple.shade200,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<ImportanceLevel>(
                  value: selectedImportanceLevel,
                  items: ImportanceLevel.values.map((level) {
                    return DropdownMenuItem<ImportanceLevel>(
                      value: level,
                      child: Text(level.toString().split('.').last, style: const TextStyle(color: Colors.black)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedImportanceLevel = value;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Önem Seviyesi',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
                  ),
                  dropdownColor: Colors.deepPurple.shade200,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            );
          }),
          actions: [
            TextButton(
              child: const Text('İptal', style: TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            SizedBox(
              width: 120,
              child: CustomButton(
                onPressed: () async {
                  final title = titleController.text;
                  final description = descriptionController.text;
                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lütfen bir başlık girin.')),
                    );
                    return;
                  }
                  if (selectedCategoryId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lütfen bir kategori seçin.')),
                    );
                    return;
                  }

                  final success = await viewModel.addTask(title, description, selectedCategoryId!, selectedImportanceLevel);
                  Navigator.of(dialogContext).pop();

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Görev başarıyla eklendi.'), backgroundColor: Colors.green),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Görev eklenirken bir hata oluştu.'), backgroundColor: Colors.red),
                    );
                  }
                },
                text: 'Ekle',
              ),
            )
          ],
        );
      },
    );
  }
}
