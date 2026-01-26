
import 'dart:ui';
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
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(color: Colors.white),
                            const SizedBox(height: 16),
                            Text(
                              'Bildirimler yükleniyor...',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : viewModel.notifications.isEmpty
                        ? _buildEmptyState(context)
                        : RefreshIndicator(
                            onRefresh: viewModel.fetchAllEventNotifications,
                            color: Colors.white,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: viewModel.notifications.length,
                              itemBuilder: (context, index) {
                                final notification = viewModel.notifications[index];
                                return _buildNotificationCard(context, viewModel, notification);
                              },
                            ),
                          ),
              ),
            ),
            floatingActionButton: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.white.withOpacity(0.9)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                elevation: 0,
                onPressed: () async {
                  final request = await showDialog<EventNotificationRequest>(
                    context: context,
                    builder: (_) => const EventNotificationDialog(),
                  );
                  if (request != null) {
                    viewModel.createEventNotification(request);
                  }
                },
                child: Icon(Icons.add, color: Colors.deepPurple.shade400, size: 28),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              color: Colors.white.withOpacity(0.7),
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Henüz bildirim yok',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni bildirim eklemek için + butonuna tıklayın',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, EventNotificationViewModel viewModel, EventNotificationResponse notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: notification.isSent
                              ? [Colors.green.shade400, Colors.green.shade600]
                              : [Colors.orange.shade400, Colors.orange.shade600],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: (notification.isSent ? Colors.green : Colors.orange).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        notification.isSent ? Icons.check_circle : Icons.schedule,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder(
                            future: ApiService().getEventById(notification.eventId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Row(
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.7)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Yükleniyor...',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                );
                              }
                              if (snapshot.hasError || !snapshot.hasData) {
                                return Row(
                                  children: [
                                    Icon(Icons.error_outline, size: 16, color: Colors.white.withOpacity(0.7)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Etkinlik ID: ${notification.eventId}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return Row(
                                children: [
                                  Icon(
                                    Icons.event,
                                    size: 18,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      snapshot.data!.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                DateFormat('dd/MM/yyyy HH:mm').format(notification.notifyAt),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: (notification.isSent ? Colors.green : Colors.orange).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: (notification.isSent ? Colors.green : Colors.orange).withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  notification.isSent ? Icons.send : Icons.pending,
                                  size: 14,
                                  color: notification.isSent ? Colors.green.shade300 : Colors.orange.shade300,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  notification.isSent ? 'Gönderildi' : 'Bekliyor',
                                  style: TextStyle(
                                    color: notification.isSent ? Colors.green.shade300 : Colors.orange.shade300,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      color: Colors.deepPurple.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _popupItem(IconData icon, String text, String value) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, EventNotificationViewModel viewModel, EventNotificationResponse notification) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          backgroundColor: Colors.deepPurple.shade300.withOpacity(0.95),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Bildirimi Sil',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Bu bildirimi silmek istediğinizden emin misiniz?',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'İptal',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade400, Colors.red.shade600],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  viewModel.deleteEventNotification(notification.id);
                  Navigator.pop(dialogContext);
                },
                child: const Text(
                  'Sil',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
