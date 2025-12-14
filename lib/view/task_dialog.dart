import 'package:akilli_ajanda_front/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/task_request.dart';
import '../model/task_response.dart';
import '../model/importance_level.dart';
import '../model/task_status.dart';
import '../model/category_response.dart';
import '../service/api_service.dart';
import 'dart:ui';

class TaskDialog extends StatelessWidget {
  final TaskResponse? task;

  const TaskDialog({super.key, this.task});

  @override
  Widget build(BuildContext context) {
    return _TaskDialogContent(task: task);
  }
}

class _TaskDialogContent extends StatefulWidget {
  final TaskResponse? task;

  const _TaskDialogContent({this.task});

  @override
  State<_TaskDialogContent> createState() => _TaskDialogContentState();
}

class _TaskDialogContentState extends State<_TaskDialogContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TaskStatus _status;
  late ImportanceLevel _importanceLevel;
  int? _categoryId;
  List<CategoryResponse> _categories = [];
  late DateTime _startTime;
  late DateTime _endTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _status = widget.task?.status ?? TaskStatus.PENDING;
    _importanceLevel = widget.task?.importanceLevel ?? ImportanceLevel.MEDIUM;
    _categoryId = widget.task?.categoryId;
    _startTime = widget.task?.startTime ?? DateTime.now();
    _endTime = widget.task?.endTime ?? DateTime.now().add(const Duration(hours: 1));
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final categories = await ApiService().getCategories();
    setState(() {
      _categories = categories;
      if (_categoryId == null && _categories.length == 1) {
        _categoryId = _categories.first.id;
      }
    });
  }

  Future<DateTime?> _pickDateTime(BuildContext context, DateTime initialDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade700.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.task == null ? 'Yeni Görev Oluştur' : 'Görevi Düzenle',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(controller: _titleController, labelText: 'Başlık', icon: Icons.title),
                  const SizedBox(height: 16),
                  CustomTextField(controller: _descriptionController, labelText: 'Açıklama', icon: Icons.description),
                  const SizedBox(height: 16),
                  _buildDropdown<TaskStatus>('Durum', _status, TaskStatus.values, (val) => setState(() => _status = val!)),
                  const SizedBox(height: 16),
                  _buildDropdown<ImportanceLevel>('Önem Seviyesi', _importanceLevel, ImportanceLevel.values, (val) => setState(() => _importanceLevel = val!)),
                  const SizedBox(height: 16),
                  if (_categories.isNotEmpty)
                    _buildCategoryDropdown(),
                  const SizedBox(height: 16),
                  _buildDateTimePicker(
                    context,
                    label: 'Başlangıç Zamanı',
                    selectedDate: _startTime,
                    onPressed: () async {
                      final pickedDate = await _pickDateTime(context, _startTime);
                      if (pickedDate != null) {
                        setState(() {
                          _startTime = pickedDate;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDateTimePicker(
                    context,
                    label: 'Bitiş Zamanı',
                    selectedDate: _endTime,
                    onPressed: () async {
                      final pickedDate = await _pickDateTime(context, _endTime);
                      if (pickedDate != null) {
                        setState(() {
                          _endTime = pickedDate;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: const Text('İptal', style: TextStyle(color: Colors.white70)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.deepPurple.shade300,
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            if (_categoryId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Lütfen bir kategori seçin.'), backgroundColor: Colors.red),
                              );
                              return;
                            }
                            final request = TaskRequest(
                              title: _titleController.text,
                              description: _descriptionController.text,
                              status: _status,
                              importanceLevel: _importanceLevel,
                              categoryId: _categoryId,
                              startTime: _startTime,
                              endTime: _endTime,
                            );
                            Navigator.pop(context, request);
                          }
                        },
                        child: const Text('Ekle'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(BuildContext context, {required String label, required DateTime selectedDate, required VoidCallback onPressed}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(selectedDate),
                  style: const TextStyle(color: Colors.white),
                ),
                const Icon(Icons.calendar_today, color: Colors.white),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>(String label, T value, List<T> items, ValueChanged<T?> onChanged) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
      ),
      dropdownColor: Colors.deepPurple.shade200,
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.white,
      items: items.map((item) {
        return DropdownMenuItem<T>(value: item, child: Text(item.toString().split('.').last, style: const TextStyle(color: Colors.white)));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<int>(
      value: _categoryId,
      decoration: InputDecoration(
        labelText: 'Kategori',
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
      ),
      dropdownColor: Colors.deepPurple.shade200,
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.white,
      items: _categories.map((category) {
        return DropdownMenuItem(value: category.id, child: Text(category.name, style: const TextStyle(color: Colors.white)));
      }).toList(),
      onChanged: (value) => setState(() => _categoryId = value),
      validator: (value) => value == null ? 'Lütfen bir kategori seçin' : null,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
