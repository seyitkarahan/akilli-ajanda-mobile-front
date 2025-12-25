import 'package:akilli_ajanda_front/model/event_request.dart';
import 'package:akilli_ajanda_front/model/event_response.dart';
import 'package:akilli_ajanda_front/view/event_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/event_view_model.dart';

class EventsView extends StatelessWidget {
  const EventsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EventViewModel()..fetchEvents(),
      child: Consumer<EventViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: const Text('Etkinlikler'),
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
                child: Builder(
                  builder: (context) {
                    if (viewModel.events.isEmpty) {
                      return const Center(child: Text('Hiç etkinlik yok.', style: TextStyle(color: Colors.white, fontSize: 16)));
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
                                  _showDeleteConfirmationDialog(context, viewModel, event);
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
                  },
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final request = await showDialog<EventRequest>(
                  context: context,
                  builder: (_) => const EventDialog(),
                );
                if (request != null) {
                  viewModel.createEvent(request);
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

  void _showDeleteConfirmationDialog(BuildContext context, EventViewModel viewModel, EventResponse event) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          backgroundColor: Colors.deepPurple.shade300.withOpacity(0.9),
          title: const Text('Etkinliği Sil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text('\'${event.title}\' etkinliğini silmek istediğinizden emin misiniz?', style: const TextStyle(color: Colors.white)),
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
                viewModel.deleteEvent(event.id);
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
