import 'package:akilli_ajanda_front/model/task_request.dart';
import 'package:akilli_ajanda_front/model/task_response.dart';
import 'package:akilli_ajanda_front/model/task_status.dart';
import 'package:akilli_ajanda_front/view/task_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../view_model/task_view_model.dart';

class TasksView extends StatelessWidget {
  const TasksView({super.key});

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.PENDING:
        return Colors.orange;
      case TaskStatus.IN_PROGRESS:
        return Colors.blue;
      case TaskStatus.COMPLETED:
        return Colors.green;
      case TaskStatus.MISSED:
        return Colors.red;
      case TaskStatus.CANCELLED:
        return Colors.grey;
    }
  }

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
                child: Column(
                  children: [
                    _buildStatusLegend(),
                    Expanded(
                      child: viewModel.tasks.isEmpty
                          ? const Center(
                        child: Text(
                          'Hiç görev yok.',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 16),
                        ),
                      )
                          : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: viewModel.tasks.length,
                        itemBuilder: (context, index) {
                          final task = viewModel.tasks[index];
                          return _buildTaskCard(
                              context, viewModel, task);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () async {
                final request = await showDialog<TaskRequest>(
                  context: context,
                  builder: (_) => const TaskDialog(),
                );
                if (request != null) {
                  viewModel.createTask(request);
                }
              },
              child:
              Icon(Icons.add, color: Colors.deepPurple.shade400),
            ),
          );
        },
      ),
    );
  }

  /// 🧊 Status Legend
  Widget _buildStatusLegend() {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      color: Colors.white.withOpacity(0.15),
      elevation: 0,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 16,
          runSpacing: 8,
          children: TaskStatus.values.map((status) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  status.toString().split('.').last,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 🧊 Task Card
  Widget _buildTaskCard(
      BuildContext context,
      TaskViewModel viewModel,
      TaskResponse task,
      ) {
    final statusColor = _getStatusColor(task.status);

    return Card(
      color: Colors.white.withOpacity(0.15),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showTaskDetailDialog(context, task, statusColor),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (task.description != null &&
                        task.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon:
                const Icon(Icons.more_vert, color: Colors.white70),
                color: Colors.deepPurple.shade600,
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
                    _showDeleteConfirmationDialog(
                        context, viewModel, task);
                  } else if (value == 'change_status') {
                    _showStatusUpdateDialog(
                        context, viewModel, task);
                  }
                },
                itemBuilder: (_) => [
                  _popupItem(Icons.edit_outlined, 'Düzenle', 'edit'),
                  _popupItem(Icons.delete_outline, 'Sil', 'delete'),
                  _popupItem(Icons.change_circle_outlined,
                      'Durum Değiştir', 'change_status'),
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
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  /// 🔍 Task Detail Dialog
  void _showTaskDetailDialog(
      BuildContext context, TaskResponse task, Color statusColor) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: statusColor.withOpacity(0.95),
          title: Text(
            task.title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dialogLabel('Açıklama'),
                _dialogValue(task.description ?? 'Yok'),
                _dialogLabel('Durum'),
                _dialogValue(
                    task.status.toString().split('.').last),
                _dialogLabel('Başlangıç Zamanı'),
                _dialogValue(task.startTime != null
                    ? formatter.format(task.startTime!)
                    : 'Belirtilmemiş'),
                _dialogLabel('Bitiş Zamanı'),
                _dialogValue(task.endTime != null
                    ? formatter.format(task.endTime!)
                    : 'Belirtilmemiş'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child:
              const Text('Kapat', style: TextStyle(color: Colors.white70)),
            ),
          ],
        );
      },
    );
  }

  Widget _dialogLabel(String text) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Text(
      text,
      style:
      TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
    ),
  );

  Widget _dialogValue(String text) =>
      Text(text, style: const TextStyle(color: Colors.white));

  /// 🗑 Delete Dialog
  void _showDeleteConfirmationDialog(
      BuildContext context, TaskViewModel viewModel, TaskResponse task) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Colors.deepPurple.shade300.withOpacity(0.9),
          title: const Text(
            'Görevi Sil',
            style:
            TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            '\'${task.title}\' görevini silmek istediğinizden emin misiniz?',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child:
              const Text('İptal', style: TextStyle(color: Colors.white70)),
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

  /// 🔄 Status Update Dialog
  void _showStatusUpdateDialog(
      BuildContext context, TaskViewModel viewModel, TaskResponse task) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Colors.deepPurple.shade300.withOpacity(0.9),
          title: const Text(
            'Durum Değiştir',
            style:
            TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: TaskStatus.values.map((status) {
              return ListTile(
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(
                  status.toString().split('.').last,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  viewModel.updateTaskStatus(task, status);
                  Navigator.pop(dialogContext);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
