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

  const CategoryDetailView({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
      CategoryDetailViewModel()..fetchTasksAndEvents(category.id),
      child: Consumer<CategoryDetailViewModel>(
        builder: (context, viewModel, _) {
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                title: Text(
                  category.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
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
                    colors: [
                      Colors.deepPurple.shade300,
                      Colors.blue.shade400,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: TabBarView(
                    children: [
                      _buildTasksTab(context, viewModel),
                      _buildEventsTab(context, viewModel),
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

  /// ✅ TASKS TAB
  Widget _buildTasksTab(
      BuildContext context, CategoryDetailViewModel viewModel) {
    if (viewModel.tasks.isEmpty) {
      return const Center(
        child: Text(
          'Bu kategoride görev yok.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.tasks.length,
      itemBuilder: (context, index) {
        final task = viewModel.tasks[index];

        return _glassCard(
          child: ListTile(
            leading: const Icon(
              Icons.check_circle_outline,
              color: Colors.white70,
            ),
            title: Text(
              task.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: task.description != null &&
                task.description!.isNotEmpty
                ? Text(
              task.description!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
                : null,
            trailing: _popupMenu(
              onEdit: () async {
                final request = await showDialog<TaskRequest>(
                  context: context,
                  builder: (_) => TaskDialog(task: task),
                );
                if (request != null) {
                  viewModel.updateTask(task.id, request);
                }
              },
              onDelete: () {
                _showDeleteConfirmationDialog(
                  context,
                  viewModel,
                  task: task,
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// ✅ EVENTS TAB
  Widget _buildEventsTab(
      BuildContext context, CategoryDetailViewModel viewModel) {
    if (viewModel.events.isEmpty) {
      return const Center(
        child: Text(
          'Bu kategoride etkinlik yok.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.events.length,
      itemBuilder: (context, index) {
        final event = viewModel.events[index];

        return _glassCard(
          child: ListTile(
            leading: const Icon(Icons.event, color: Colors.white70),
            title: Text(
              event.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              event.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: _popupMenu(
              onEdit: () async {
                final request = await showDialog<EventRequest>(
                  context: context,
                  builder: (_) => EventDialog(event: event),
                );
                if (request != null) {
                  viewModel.updateEvent(event.id, request);
                }
              },
              onDelete: () {
                _showDeleteConfirmationDialog(
                  context,
                  viewModel,
                  event: event,
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// 🧊 GLASS CARD
  Widget _glassCard({required Widget child}) {
    return Card(
      color: Colors.white.withOpacity(0.15),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: child,
    );
  }

  /// ⋮ POPUP MENU
  Widget _popupMenu({
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white70),
      color: Colors.deepPurple.shade600,
      onSelected: (value) {
        if (value == 'edit') {
          onEdit();
        } else if (value == 'delete') {
          onDelete();
        }
      },
      itemBuilder: (_) => [
        _popupItem(Icons.edit_outlined, 'Düzenle', 'edit'),
        _popupItem(Icons.delete_outline, 'Sil', 'delete'),
      ],
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
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  /// 🗑 DELETE CONFIRMATION
  void _showDeleteConfirmationDialog(
      BuildContext context,
      CategoryDetailViewModel viewModel, {
        TaskResponse? task,
        EventResponse? event,
      }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor:
          Colors.deepPurple.shade300.withOpacity(0.95),
          title: Text(
            task != null ? 'Görevi Sil' : 'Etkinliği Sil',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "'${task?.title ?? event!.title}' silmek istediğinizden emin misiniz?",
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'İptal',
                style: TextStyle(color: Colors.white70),
              ),
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
