import 'package:akilli_ajanda_front/model/category_response.dart';
import 'package:akilli_ajanda_front/model/event_request.dart';
import 'package:akilli_ajanda_front/model/event_response.dart';
import 'package:akilli_ajanda_front/model/task_request.dart';
import 'package:akilli_ajanda_front/model/task_response.dart';
import 'package:akilli_ajanda_front/model/task_status.dart';
import 'package:akilli_ajanda_front/view/event_dialog.dart';
import 'package:akilli_ajanda_front/view/task_dialog.dart';
import 'package:akilli_ajanda_front/view_model/category_detail_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CategoryDetailView extends StatelessWidget {
  final CategoryResponse category;

  const CategoryDetailView({
    super.key,
    required this.category,
  });

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.PENDING:
        return const Color(0xFFF59E0B);
      case TaskStatus.IN_PROGRESS:
        return const Color(0xFF3B82F6);
      case TaskStatus.COMPLETED:
        return const Color(0xFF10B981);
      case TaskStatus.MISSED:
        return const Color(0xFFEF4444);
      case TaskStatus.CANCELLED:
        return const Color(0xFF6B7280);
    }
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.PENDING:
        return 'Bekliyor';
      case TaskStatus.IN_PROGRESS:
        return 'Devam Ediyor';
      case TaskStatus.COMPLETED:
        return 'Tamamlandı';
      case TaskStatus.MISSED:
        return 'Kaçırıldı';
      case TaskStatus.CANCELLED:
        return 'İptal Edildi';
    }
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.PENDING:
        return Icons.pending_actions_rounded;
      case TaskStatus.IN_PROGRESS:
        return Icons.hourglass_top_rounded;
      case TaskStatus.COMPLETED:
        return Icons.check_circle_rounded;
      case TaskStatus.MISSED:
        return Icons.error_outline_rounded;
      case TaskStatus.CANCELLED:
        return Icons.cancel_rounded;
    }
  }

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
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.category_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                elevation: 0,
                backgroundColor: Colors.transparent,
                iconTheme: const IconThemeData(color: Colors.white),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TabBar(
                      indicator: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withOpacity(0.7),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                      tabs: const [
                        Tab(
                          icon: Icon(Icons.task_alt_rounded, size: 20),
                          text: 'Görevler',
                        ),
                        Tab(
                          icon: Icon(Icons.event_rounded, size: 20),
                          text: 'Etkinlikler',
                        ),
                      ],
                    ),
                  ),
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

  Widget _buildTasksTab(
      BuildContext context, CategoryDetailViewModel viewModel) {
    if (viewModel.tasks.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.task_alt_rounded,
        message: 'Bu kategoride görev yok',
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.fetchTasksAndEvents(category.id),
      color: const Color(0xFF6366F1),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: viewModel.tasks.length,
        itemBuilder: (context, index) {
          final task = viewModel.tasks[index];
          return _buildTaskCard(context, viewModel, task);
        },
      ),
    );
  }

  Widget _buildTaskCard(
      BuildContext context, CategoryDetailViewModel viewModel, TaskResponse task) {
    final statusColor = _getStatusColor(task.status);
    final statusText = _getStatusText(task.status);
    final statusIcon = _getStatusIcon(task.status);
    final formatter = DateFormat('dd MMM', 'tr_TR');
    final timeFormatter = DateFormat('HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showTaskDetailDialog(context, task, statusColor),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 70,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      statusColor,
                                      statusColor.withOpacity(0.7),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: statusColor.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  statusIcon,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: const TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              if (task.description != null &&
                                  task.description!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  task.description!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                children: [
                                  if (task.startTime != null)
                                    _buildInfoChip(
                                      Icons.access_time_rounded,
                                      task.endTime != null
                                          ? '${formatter.format(task.startTime!)} - ${timeFormatter.format(task.startTime!)}'
                                          : '${formatter.format(task.startTime!)} ${timeFormatter.format(task.startTime!)}',
                                      Colors.blue.shade400,
                                    ),
                                  if (task.endTime != null && task.startTime != null)
                                    _buildInfoChip(
                                      Icons.flag_rounded,
                                      '${formatter.format(task.endTime!)} ${timeFormatter.format(task.endTime!)}',
                                      Colors.orange.shade400,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: Colors.grey.shade400,
                            size: 22,
                          ),
                          color: Colors.white,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
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
                                context,
                                viewModel,
                                task: task,
                              );
                            }
                          },
                          itemBuilder: (_) => [
                            _popupItem(Icons.edit_rounded, 'Düzenle', 'edit', Colors.blue),
                            _popupItem(Icons.delete_rounded, 'Sil', 'delete', Colors.red),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    statusColor,
                    statusColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsTab(
      BuildContext context, CategoryDetailViewModel viewModel) {
    if (viewModel.events.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.event_busy_outlined,
        message: 'Bu kategoride etkinlik yok',
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.fetchTasksAndEvents(category.id),
      color: const Color(0xFF6366F1),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: viewModel.events.length,
        itemBuilder: (context, index) {
          final event = viewModel.events[index];
          return _buildEventCard(context, viewModel, event);
        },
      ),
    );
  }

  Widget _buildEventCard(
      BuildContext context, CategoryDetailViewModel viewModel, EventResponse event) {
    final formatter = DateFormat('dd MMM', 'tr_TR');
    final timeFormatter = DateFormat('HH:mm');
    final now = DateTime.now();
    final isUpcoming = event.startTime.isAfter(now);
    final isPast = event.endTime.isBefore(now);
    final isOngoing = !isUpcoming && !isPast;

    final Color primaryColor;
    final Color accentColor;
    final String statusText;

    if (isUpcoming) {
      primaryColor = const Color(0xFF6366F1);
      accentColor = const Color(0xFF818CF8);
      statusText = 'Yaklaşan';
    } else if (isOngoing) {
      primaryColor = const Color(0xFF10B981);
      accentColor = const Color(0xFF34D399);
      statusText = 'Devam Ediyor';
    } else {
      primaryColor = const Color(0xFF6B7280);
      accentColor = const Color(0xFF9CA3AF);
      statusText = 'Geçmiş';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showEventDetailDialog(context, event, primaryColor),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 70,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [primaryColor, accentColor],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      formatter.format(event.startTime).split(' ')[0],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        height: 1.2,
                                      ),
                                    ),
                                    Text(
                                      formatter.format(event.startTime).split(' ')[1],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  timeFormatter.format(event.startTime),
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      event.title,
                                      style: const TextStyle(
                                        color: Color(0xFF1F2937),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      statusText,
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (event.description.isNotEmpty) ...[
                                Text(
                                  event.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              Wrap(
                                spacing: 16,
                                runSpacing: 8,
                                children: [
                                  if (event.location.isNotEmpty)
                                    _buildInfoChip(
                                      Icons.location_on_rounded,
                                      event.location,
                                      Colors.red.shade400,
                                    ),
                                  _buildInfoChip(
                                    Icons.access_time_rounded,
                                    '${timeFormatter.format(event.startTime)} - ${timeFormatter.format(event.endTime)}',
                                    Colors.blue.shade400,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: Colors.grey.shade400,
                            size: 22,
                          ),
                          color: Colors.white,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
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
                              _showDeleteConfirmationDialog(
                                context,
                                viewModel,
                                event: event,
                              );
                            }
                          },
                          itemBuilder: (_) => [
                            _popupItem(Icons.edit_rounded, 'Düzenle', 'edit', Colors.blue),
                            _popupItem(Icons.delete_rounded, 'Sil', 'delete', Colors.red),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, accentColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 14,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, {required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white.withOpacity(0.9),
              size: 72,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            message,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _popupItem(
      IconData icon, String text, String value, Color color) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showTaskDetailDialog(BuildContext context, TaskResponse task, Color statusColor) {
    final DateFormat dateFormatter = DateFormat('dd MMMM yyyy', 'tr_TR');
    final DateFormat timeFormatter = DateFormat('HH:mm');
    final statusText = _getStatusText(task.status);
    final statusIcon = _getStatusIcon(task.status);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [statusColor, statusColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          statusIcon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          task.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.description != null && task.description!.isNotEmpty) ...[
                          _buildModernDetailRow(
                            Icons.description_rounded,
                            'Açıklama',
                            task.description!,
                            Colors.purple,
                          ),
                          const SizedBox(height: 20),
                        ],
                        _buildModernDetailRow(
                          statusIcon,
                          'Durum',
                          statusText,
                          statusColor,
                        ),
                        if (task.startTime != null) ...[
                          const SizedBox(height: 20),
                          _buildModernDetailRow(
                            Icons.play_circle_rounded,
                            'Başlangıç',
                            '${dateFormatter.format(task.startTime!)} ${timeFormatter.format(task.startTime!)}',
                            Colors.blue,
                          ),
                        ],
                        if (task.endTime != null) ...[
                          const SizedBox(height: 20),
                          _buildModernDetailRow(
                            Icons.flag_rounded,
                            'Bitiş',
                            '${dateFormatter.format(task.endTime!)} ${timeFormatter.format(task.endTime!)}',
                            Colors.orange,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEventDetailDialog(BuildContext context, EventResponse event, Color primaryColor) {
    final DateFormat dateFormatter = DateFormat('dd MMMM yyyy', 'tr_TR');
    final DateFormat timeFormatter = DateFormat('HH:mm');
    final now = DateTime.now();
    final isUpcoming = event.startTime.isAfter(now);
    final isPast = event.endTime.isBefore(now);
    final isOngoing = !isUpcoming && !isPast;

    showDialog(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColor.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isUpcoming
                                ? Icons.event_available
                                : isPast
                                    ? Icons.event_busy
                                    : Icons.event,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            event.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                          onPressed: () => Navigator.pop(dialogContext),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (event.description.isNotEmpty) ...[
                            _buildModernDetailRow(
                              Icons.description_rounded,
                              'Açıklama',
                              event.description,
                              Colors.purple,
                            ),
                            const SizedBox(height: 20),
                          ],
                          _buildModernDetailRow(
                            Icons.location_on_rounded,
                            'Konum',
                            event.location.isNotEmpty ? event.location : 'Belirtilmemiş',
                            Colors.red,
                          ),
                          const SizedBox(height: 20),
                          _buildModernDetailRow(
                            Icons.play_circle_rounded,
                            'Başlangıç',
                            '${dateFormatter.format(event.startTime)} ${timeFormatter.format(event.startTime)}',
                            Colors.blue,
                          ),
                          const SizedBox(height: 20),
                          _buildModernDetailRow(
                            Icons.stop_circle_rounded,
                            'Bitiş',
                            '${dateFormatter.format(event.endTime)} ${timeFormatter.format(event.endTime)}',
                            Colors.orange,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildModernDetailRow(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.grey.shade900,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context,
      CategoryDetailViewModel viewModel, {
        TaskResponse? task,
        EventResponse? event,
      }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_rounded,
                      color: Colors.red,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    task != null ? 'Görevi Sil' : 'Etkinliği Sil',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "'${task?.title ?? event!.title}' silmek istediğinizden emin misiniz?",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            'İptal',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              if (task != null) {
                                viewModel.deleteTask(task.id);
                              } else if (event != null) {
                                viewModel.deleteEvent(event.id);
                              }
                              Navigator.pop(dialogContext);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Sil',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
