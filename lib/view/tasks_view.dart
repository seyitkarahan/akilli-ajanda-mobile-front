import 'package:akilli_ajanda_front/model/task_request.dart';
import 'package:akilli_ajanda_front/model/task_response.dart';
import 'package:akilli_ajanda_front/view/task_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/task_view_model.dart';

class TasksView extends StatelessWidget {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskViewModel()..fetchTasks(),
      child: Consumer<TaskViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: const Text('Görevler'),
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
                    if (viewModel.tasks.isEmpty) {
                      return const Center(child: Text('Hiç görev yok.', style: TextStyle(color: Colors.white, fontSize: 16)));
                    }
                    return ListView.builder(
                      itemCount: viewModel.tasks.length,
                      itemBuilder: (context, index) {
                        final task = viewModel.tasks[index];
                        return Card(
                          elevation: 4,
                          color: Colors.white.withOpacity(0.25),
                          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: ListTile(
                            leading: const Icon(Icons.check_circle_outline, color: Colors.white),
                            title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                            subtitle: (task.description != null && task.description!.isNotEmpty)
                                ? Text(task.description!, style: TextStyle(color: Colors.white.withOpacity(0.9)))
                                : null,
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  final request = await showDialog<TaskRequest>(
                                    context: context,
                                    builder: (_) => TaskDialog(task: task),
                                  );
                                  if (request != null) {
                                    viewModel.updateTask(task.id, request);
                                  }
                                } else if (value == 'delete') {
                                  _showDeleteConfirmationDialog(context, viewModel, task);
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
                    );
                  },
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final request = await showDialog<TaskRequest>(
                  context: context,
                  builder: (_) => const TaskDialog(),
                );
                if (request != null) {
                  viewModel.createTask(request);
                }
              },
              backgroundColor: Colors.white,
              child: Icon(Icons.add, color: Colors.deepPurple.shade300),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, TaskViewModel viewModel, TaskResponse task) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          backgroundColor: Colors.deepPurple.shade300.withOpacity(0.9),
          title: const Text('Görevi Sil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text('\'${task.title}\' görevini silmek istediğinizden emin misiniz?', style: const TextStyle(color: Colors.white)),
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
                viewModel.deleteTask(task.id);
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
