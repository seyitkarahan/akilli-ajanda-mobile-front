
import 'package:akilli_ajanda_front/model/task_response.dart';
import 'package:akilli_ajanda_front/model/task_status.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChartData {
  ChartData(this.x, this.y, [this.color]);
  final String x;
  final double y;
  final Color? color;
}

class StatisticsViewModel extends ChangeNotifier {
  final List<TaskResponse> _tasks;

  int _completedTaskCount = 0;
  int _pendingTaskCount = 0;
  int _missedTaskCount = 0;
  int _cancelledTaskCount = 0;
  int _inProgressTaskCount = 0;

  int get completedTaskCount => _completedTaskCount;
  int get pendingTaskCount => _pendingTaskCount;
  int get missedTaskCount => _missedTaskCount;
  int get cancelledTaskCount => _cancelledTaskCount;
  int get inProgressTaskCount => _inProgressTaskCount;


  int get totalTaskCount => _tasks.length;

  double get taskCompletionRate => totalTaskCount > 0 ? _completedTaskCount / totalTaskCount : 0.0;

  String _mostProductiveDay = '-';
  String get mostProductiveDay => _mostProductiveDay;

  StatisticsViewModel(this._tasks) {
    _calculateStatistics();
  }

  List<ChartData> get taskStatusDistribution {
    final Map<TaskStatus, int> statusCounts = {};
    for (var task in _tasks) {
      statusCounts[task.status] = (statusCounts[task.status] ?? 0) + 1;
    }

    return statusCounts.entries.map((entry) {
      return ChartData(entry.key.toString().split('.').last, entry.value.toDouble());
    }).toList();
  }

  void _calculateStatistics() {
    _completedTaskCount = _tasks.where((task) => task.status == TaskStatus.COMPLETED).length;
    _pendingTaskCount = _tasks.where((task) => task.status == TaskStatus.PENDING).length;
    _missedTaskCount = _tasks.where((task) => task.status == TaskStatus.MISSED).length;
    _cancelledTaskCount = _tasks.where((task) => task.status == TaskStatus.CANCELLED).length;
    _inProgressTaskCount = _tasks.where((task) => task.status == TaskStatus.IN_PROGRESS).length;

    if (_completedTaskCount > 0) {
      final Map<int, int> completedTasksPerWeekday = {};
      for (var task in _tasks.where((task) => task.status == TaskStatus.COMPLETED && task.endTime != null)) {
        final weekday = task.endTime!.weekday;
        completedTasksPerWeekday[weekday] = (completedTasksPerWeekday[weekday] ?? 0) + 1;
      }

      if (completedTasksPerWeekday.isNotEmpty) {
        final mostProductiveWeekday = completedTasksPerWeekday.entries.reduce((a, b) => a.value > b.value ? a : b).key;
        // Create a date that corresponds to the most productive weekday to format it.
        // We use a known Monday (Jan 2, 2023) and add the difference.
        final aMonday = DateTime(2023, 1, 2);
        final dateForMostProductiveDay = aMonday.add(Duration(days: mostProductiveWeekday - 1));
        _mostProductiveDay = DateFormat('EEEE', 'tr_TR').format(dateForMostProductiveDay);
      }
    }
    
    notifyListeners();
  }
}
