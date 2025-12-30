
import 'package:akilli_ajanda_front/model/event_notification_request.dart';
import 'package:akilli_ajanda_front/model/event_notification_response.dart';
import 'package:akilli_ajanda_front/service/api_service.dart';
import 'package:akilli_ajanda_front/view/event_notification_dialog.dart';
import 'package:akilli_ajanda_front/view_model/event_notification_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EventNotificationPage extends StatelessWidget {
  const EventNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EventNotificationViewModel()..fetchAllEventNotifications(),
      child: Consumer<EventNotificationViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: const Text('Etkinlik Bildirimleri'),
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
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : viewModel.notifications.isEmpty
                        ? const Center(
                            child: Text(
                              'Hiç bildirim yok.',
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: viewModel.notifications.length,
                            itemBuilder: (context, index) {
                              final notification = viewModel.notifications[index];
                              return _buildNotificationCard(context, viewModel, notification);
                            },
                          ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () async {
                final request = await showDialog<EventNotificationRequest>(
                  context: context,
                  builder: (_) => const EventNotificationDialog(),
                );
                if (request != null) {
                  viewModel.createEventNotification(request);
                }
              },
              child: Icon(Icons.add, color: Colors.deepPurple.shade400),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, EventNotificationViewModel viewModel, EventNotificationResponse notification) {
    return Card(
      color: Colors.white.withOpacity(0.15),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.notifications_active, color: Colors.white70, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder(
                    future: ApiService().getEventById(notification.eventId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Etkinlik adı yükleniyor...', style: TextStyle(color: Colors.white));
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return Text('Etkinlik ID: ${notification.eventId}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16));
                      }
                      return Text(snapshot.data!.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16));
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bildirim Zamanı: ${DateFormat('dd/MM/yyyy HH:mm').format(notification.notifyAt)}',
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  ),
                  Text(
                    'Durum: ${notification.isSent ? 'Gönderildi' : 'Bekliyor'}',
                    style: TextStyle(color: notification.isSent ? Colors.green.shade300 : Colors.orange.shade300),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white70),
              color: Colors.deepPurple.shade600,
              onSelected: (value) async {
                if (value == 'edit') {
                  final request = await showDialog<EventNotificationRequest>(
                    context: context,
                    builder: (_) => EventNotificationDialog(
                      notification: EventNotificationRequest(
                        notifyAt: notification.notifyAt,
                        eventId: notification.eventId,
                      ),
                    ),
                  );
                  if (request != null) {
                    viewModel.updateEventNotification(notification.id, request);
                  }
                } else if (value == 'delete') {
                  _showDeleteConfirmationDialog(context, viewModel, notification);
                }
              },
              itemBuilder: (_) => [
                _popupItem(Icons.edit_outlined, 'Düzenle', 'edit'),
                _popupItem(Icons.delete_outline, 'Sil', 'delete'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _popupItem(IconData icon, String text, String value) {
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

  void _showDeleteConfirmationDialog(BuildContext context, EventNotificationViewModel viewModel, EventNotificationResponse notification) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          backgroundColor: Colors.deepPurple.shade300.withOpacity(0.9),
          title: const Text('Bildirimi Sil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('Bu bildirimi silmek istediğinizden emin misiniz?', style: TextStyle(color: Colors.white)),
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
                viewModel.deleteEventNotification(notification.id);
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
