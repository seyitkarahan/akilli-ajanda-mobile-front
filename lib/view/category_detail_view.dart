import 'package:akilli_ajanda_front/model/category_response.dart';
import 'package:akilli_ajanda_front/model/event_request.dart';
import 'package:akilli_ajanda_front/model/event_response.dart';
import 'package:akilli_ajanda_front/model/task_request.dart';
import 'package:akilli_ajanda_front/model/task_response.dart';
import 'package:akilli_ajanda_front/view/event_dialog.dart';
import 'package:akilli_ajanda_front/view/task_dialog.dart';
import 'package:akilli_ajanda_front/view_model/category_detail_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryDetailView extends StatelessWidget {
  final CategoryResponse category;

  const CategoryDetailView({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategoryDetailViewModel()..fetchTasksAndEvents(category.id),
      child: Consumer<CategoryDetailViewModel>(
        builder: (context, viewModel, child) {
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                elevation: 0,
                backgroundColor: Colors.transparent,
                iconTheme: const IconThemeData(color: Colors.white),
                bottom: const TabBar(
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: [
                    Tab(text: 'Görevler'),
                    Tab(text: 'Etkinlikler'),
                  ],
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
                  child: TabBarView(
                    children: [
                      _buildTasksList(context, viewModel),
                      _buildEventsList(context, viewModel),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTasksList(BuildContext context, CategoryDetailViewModel viewModel) {
    if (viewModel.tasks.isEmpty) {
      return const Center(child: Text('Bu kategoride görev yok.', style: TextStyle(color: Colors.white)));
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
            subtitle: Text(task.description ?? '', style: TextStyle(color: Colors.white.withOpacity(0.9))),
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
                  _showDeleteConfirmationDialog(context, viewModel, task, null);
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
  }

  Widget _buildEventsList(BuildContext context, CategoryDetailViewModel viewModel) {
    if (viewModel.events.isEmpty) {
      return const Center(child: Text('Bu kategoride etkinlik yok.', style: TextStyle(color: Colors.white)));
    }
    return ListView.builder(
      itemCount: viewModel.events.length,
      itemBuilder: (context, index) {
        final event = viewModel.events[index];
        return Card(
          elevation: 4,
          color: Colors.white.withOpacity(0.25),
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: const Icon(Icons.event, color: Colors.white),
            title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
            subtitle: Text(event.description, style: TextStyle(color: Colors.white.withOpacity(0.9))),
             trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  final request = await showDialog<EventRequest>(
                    context: context,
                    builder: (_) => EventDialog(event: event),
                  );
                  if (request != null) {
                    viewModel.updateEvent(event.id, request);
                  }
                } else if (value == 'delete') {
                  _showDeleteConfirmationDialog(context, viewModel, null, event);
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
  }
   void _showDeleteConfirmationDialog(BuildContext context, CategoryDetailViewModel viewModel, TaskResponse? task, EventResponse? event) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          backgroundColor: Colors.deepPurple.shade300.withOpacity(0.9),
          title: Text(task != null ? 'Görevi Sil' : 'Etkinliği Sil', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text('\'${task != null ? task.title : event!.title}\' ${task != null ? 'görevini' : 'etkinliğini'} silmek istediğinizden emin misiniz?', style: const TextStyle(color: Colors.white)),
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
                if (task != null) {
                  viewModel.deleteTask(task.id);
                } else if (event != null) {
                  viewModel.deleteEvent(event.id);
                }
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
