
import 'dart:ui';
import 'package:akilli_ajanda_front/model/event_notification_request.dart';
import 'package:akilli_ajanda_front/model/event_response.dart';
import 'package:akilli_ajanda_front/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventNotificationDialog extends StatefulWidget {
  final EventNotificationRequest? notification;

  const EventNotificationDialog({super.key, this.notification});

  @override
  State<EventNotificationDialog> createState() => _EventNotificationDialogState();
}

class _EventNotificationDialogState extends State<EventNotificationDialog> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _notifyAt;
  int? _eventId;
  List<EventResponse> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _notifyAt = widget.notification?.notifyAt ?? DateTime.now();
    _eventId = widget.notification?.eventId;
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final events = await ApiService().getEvents();
      if (mounted) {
        setState(() {
          _events = events;
          if (_eventId == null && _events.isNotEmpty) {
            _eventId = _events.first.id;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Etkinlikler yüklenemedi: $e')),
        );
      }
    }
  }

  Future<DateTime?> _pickDateTime(BuildContext context, DateTime initialDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple,
            ),
          ),
          child: child!,
        );
      },
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.notification == null ? 'Yeni Bildirim Oluştur' : 'Bildirimi Düzenle',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 24),
                        if (_events.isNotEmpty)
                          _buildEventDropdown(),
                        const SizedBox(height: 16),
                        _buildDateTimePicker(
                          context,
                          label: 'Bildirim Zamanı',
                          selectedDate: _notifyAt,
                          onPressed: () async {
                            final pickedDate = await _pickDateTime(context, _notifyAt);
                            if (pickedDate != null) {
                              setState(() {
                                _notifyAt = pickedDate;
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
                                  if (_eventId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Lütfen bir etkinlik seçin.'), backgroundColor: Colors.red),
                                    );
                                    return;
                                  }
                                  final request = EventNotificationRequest(
                                    notifyAt: _notifyAt,
                                    eventId: _eventId!,
                                  );
                                  Navigator.pop(context, request);
                                }
                              },
                              child: const Text('Kaydet'),
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

  Widget _buildEventDropdown() {
    return DropdownButtonFormField<int>(
      value: _eventId,
      decoration: InputDecoration(
        labelText: 'Etkinlik',
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
        prefixIcon: const Icon(Icons.event, color: Colors.white70),
      ),
      dropdownColor: Colors.deepPurple.shade200,
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.white,
      items: _events.map((event) {
        return DropdownMenuItem(value: event.id, child: Text(event.title, style: const TextStyle(color: Colors.white)));
      }).toList(),
      onChanged: (value) => setState(() => _eventId = value),
      validator: (value) => value == null ? 'Lütfen bir etkinlik seçin' : null,
    );
  }
}
