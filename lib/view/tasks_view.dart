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
      default:
        return Colors.black;
    }
  }

  Widget _buildStatusLegend(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Wrap(
        spacing: 16.0,
        runSpacing: 8.0,
        children: TaskStatus.values.map((status) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                status.toString().split('.').last,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          );
        }).toList(),
      ),
    );
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
                    _buildStatusLegend(context),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          if (viewModel.tasks.isEmpty) {
                            return const Center(child: Text('Hiç görev yok.', style: TextStyle(color: Colors.white, fontSize: 16)));
                          }
                          return ListView.builder(
                            itemCount: viewModel.tasks.length,
                            itemBuilder: (context, index) {
                              final task = viewModel.tasks[index];
                              final statusColor = _getStatusColor(task.status);
                              return Card(
                                elevation: 4,
                                color: statusColor.withOpacity(0.5),
                                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                child: ListTile(
                                  onTap: () => _showTaskDetailDialog(context, task, statusColor),
                                  leading: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                  ),
                                  title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                                  subtitle: (task.description != null && task.description!.isNotEmpty)
                                      ? Text(task.description!, style: TextStyle(color: Colors.white.withOpacity(0.9)), maxLines: 1, overflow: TextOverflow.ellipsis)
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
                                      } else if (value == 'change_status') {
                                        _showStatusUpdateDialog(context, viewModel, task);
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
                                      const PopupMenuItem(
                                        value: 'change_status',
                                        child: Row(children: [Icon(Icons.change_circle_outlined), SizedBox(width: 8), Text('Durum Değiştir')]),
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
                  ],
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

  void _showTaskDetailDialog(BuildContext context, TaskResponse task, Color statusColor) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
            backgroundColor: statusColor.withOpacity(0.95),
            title: Text(task.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Açıklama:', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                  Text(task.description ?? 'Yok', style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 12),
                  Text('Durum:', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                  Text(task.status.toString().split('.').last, style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 12),
                  Text('Önem Seviyesi:', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                  Text(task.importanceLevel.toString(), style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 12),
                  Text('Başlangıç Zamanı:', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                  Text(task.startTime != null ? formatter.format(task.startTime!) : 'Belirtilmemiş', style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 12),
                  Text('Bitiş Zamanı:', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                  Text(task.endTime != null ? formatter.format(task.endTime!) : 'Belirtilmemiş', style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Kapat', style: TextStyle(color: Colors.white70)),
              ),
            ],
          );
        });
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

  void _showStatusUpdateDialog(BuildContext context, TaskViewModel viewModel, TaskResponse task) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          backgroundColor: Colors.deepPurple.shade300.withOpacity(0.9),
          title: const Text('Durum Değiştir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                title: Text(status.toString().split('.').last, style: const TextStyle(color: Colors.white)),
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
