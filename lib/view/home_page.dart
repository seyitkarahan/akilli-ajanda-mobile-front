
import 'package:akilli_ajanda_front/model/category_response.dart';
import 'package:akilli_ajanda_front/model/event_request.dart';
import 'package:akilli_ajanda_front/model/event_response.dart';
import 'package:akilli_ajanda_front/model/task_request.dart';
import 'package:akilli_ajanda_front/model/task_response.dart';
import 'package:akilli_ajanda_front/model/task_status.dart';
import 'package:akilli_ajanda_front/service/storage_service.dart';
import 'package:akilli_ajanda_front/view/categories_view.dart';
import 'package:akilli_ajanda_front/view/event_dialog.dart';
import 'package:akilli_ajanda_front/view/events_view.dart';
import 'package:akilli_ajanda_front/view/image_gallery_view.dart';
import 'package:akilli_ajanda_front/view/login_view.dart';
import 'package:akilli_ajanda_front/view/settings_view.dart';
import 'package:akilli_ajanda_front/view/task_dialog.dart';
import 'package:akilli_ajanda_front/view/tasks_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../view_model/home_view_model.dart';
import 'dart:ui';
import 'package:syncfusion_flutter_calendar/calendar.dart';

enum _UpcomingListType { none, tasks, events }

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeViewModel _viewModel;
  late CalendarController _calendarController;
  _UpcomingListType _shownListType = _UpcomingListType.none;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel()..fetchInitialData();
    _calendarController = CalendarController();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  void logout(BuildContext context) async {
    await StorageService().removeToken();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
          (route) => false,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: _buildAppBar(context, viewModel),
            drawer: _buildDrawer(context, viewModel),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade300, Colors.blue.shade400],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: _buildPage(_selectedIndex, viewModel),
              ),
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    color: Colors.black.withOpacity(.1),
                  )
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                  child: GNav(
                    rippleColor: Colors.grey[300]!,
                    hoverColor: Colors.grey[100]!,
                    gap: 8,
                    activeColor: Colors.white,
                    iconSize: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    duration: const Duration(milliseconds: 400),
                    tabBackgroundColor: Colors.deepPurple.shade300,
                    color: Colors.black,
                    tabs: const [
                      GButton(
                        icon: Icons.home,
                        text: 'Ana Sayfa',
                      ),
                      GButton(
                        icon: Icons.task_alt,
                        text: 'Görevler',
                      ),
                      GButton(
                        icon: Icons.event,
                        text: 'Etkinlikler',
                      ),
                      GButton(
                        icon: Icons.settings,
                        text: 'Ayarlar',
                      ),
                    ],
                    selectedIndex: _selectedIndex,
                    onTabChange: _onItemTapped,
                  ),
                ),
              ),
            ),
            floatingActionButton: _buildFab(context, viewModel),
          );
        },
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context, HomeViewModel viewModel) {
    if (_selectedIndex == 0) {
      return AppBar(
        title: const Text('Akıllı Ajanda'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              _calendarController.view == CalendarView.schedule
                  ? Icons.calendar_month_outlined
                  : Icons.view_agenda_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                if (_calendarController.view == CalendarView.schedule) {
                  _calendarController.view = CalendarView.month;
                } else {
                  _calendarController.view = CalendarView.schedule;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutConfirmationDialog(context),
          )
        ],
      );
    } else {
        return AppBar(
        title: Text(['Ana Sayfa', 'Görevler', 'Etkinlikler', 'Ayarlar'][_selectedIndex]),
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white), 
      );
    }
  }

  Widget _buildPage(int index, HomeViewModel viewModel) {
    switch (index) {
      case 0:
        return _buildCalendarPage(viewModel);
      case 1:
        return const TasksView();
      case 2:
        return const EventsView();
      case 3:
        return const SettingsView();
      default:
        return Container();
    }
  }

  Widget _buildCalendarPage(HomeViewModel viewModel) {
    final _AppointmentDataSource dataSource = _AppointmentDataSource(viewModel.tasks, viewModel.events, viewModel.categories);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Text(
              'Takvim',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.6,
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: SfCalendar(
              controller: _calendarController,
              dataSource: dataSource,
              backgroundColor: Colors.transparent,
              headerStyle: const CalendarHeaderStyle(
                textStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                backgroundColor: Colors.transparent,
              ),
              viewHeaderStyle: const ViewHeaderStyle(
                dayTextStyle: TextStyle(color: Colors.black, fontSize: 14),
                dateTextStyle: TextStyle(color: Colors.black, fontSize: 14),
              ),
              monthViewSettings: const MonthViewSettings(
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                showAgenda: true,
                monthCellStyle: MonthCellStyle(
                  textStyle: TextStyle(color: Colors.black),
                  trailingDatesTextStyle: TextStyle(color: Colors.grey),
                  leadingDatesTextStyle: TextStyle(color: Colors.grey),
                  todayTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  todayBackgroundColor: Colors.blue,
                  backgroundColor: Colors.transparent,
                ),
              ),
              scheduleViewSettings: const ScheduleViewSettings(
                appointmentItemHeight: 70,
                monthHeaderSettings: MonthHeaderSettings(
                  height: 100,
                  textAlign: TextAlign.left,
                  backgroundColor: Colors.transparent,
                  monthFormat: 'MMMM, yyyy',
                  monthTextStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.w500),
                ),
                weekHeaderSettings: WeekHeaderSettings(
                  weekTextStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                ),
                dayHeaderSettings: DayHeaderSettings(
                  dayFormat: 'EEEE',
                  width: 70,
                  dayTextStyle: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                      color: Colors.black),
                  dateTextStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                      color: Colors.black),
                ),
              ),
              selectionDecoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.3),
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: const BorderRadius.all(Radius.circular(50)),
                shape: BoxShape.rectangle,
              ),
              todayHighlightColor: Colors.blue,
              onTap: (CalendarTapDetails details) {
                if (details.targetElement == CalendarElement.calendarCell) {
                  if (viewModel.categories.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lütfen önce bir kategori oluşturun.')),
                    );
                  } else {
                    _showAddDialog(context, viewModel, details.date);
                  }
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.task_alt),
                   onPressed: () {
                    setState(() {
                      if (_shownListType == _UpcomingListType.tasks) {
                        _shownListType = _UpcomingListType.none;
                      } else {
                        _shownListType = _UpcomingListType.tasks;
                      }
                    });
                  },
                  label: const Text('Yaklaşan Görevler'),
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)
                   ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.event_available),
                  onPressed: () {
                    setState(() {
                      if (_shownListType == _UpcomingListType.events) {
                        _shownListType = _UpcomingListType.none;
                      } else {
                        _shownListType = _UpcomingListType.events;
                      }
                    });
                  },
                  label: const Text('Yaklaşan Etkinlikler'),
                   style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.deepPurple.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)
                   ),
                ),
              ],
            ),
          ),
           _buildUpcomingList(viewModel),
        ],
      ),
    );
  }

  Widget? _buildFab(BuildContext context, HomeViewModel viewModel) {
    if (_selectedIndex == 0) {
      return SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple.shade300,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.task, color: Colors.white),
            backgroundColor: Colors.blue.shade400,
            label: 'Görev Ekle',
            labelStyle: const TextStyle(fontSize: 16),
            onTap: () {
              if (viewModel.categories.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lütfen önce bir kategori oluşturun.')),
                );
              } else {
                _showAddTaskDialog(context, viewModel, null);
              }
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.event, color: Colors.white),
            backgroundColor: Colors.deepPurple.shade300,
            label: 'Etkinlik Ekle',
            labelStyle: const TextStyle(fontSize: 16),
            onTap: () {
               if (viewModel.categories.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lütfen önce bir kategori oluşturun.')),
                );
              } else {
                _showAddEventDialog(context, viewModel, null);
              }
            },
          ),
        ],
      );
    }
    return null;
  }

  Drawer _buildDrawer(BuildContext context, HomeViewModel viewModel) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        color: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 300,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.deepPurple.shade300, Colors.deepPurple.shade400],
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.menu, color: Colors.white, size: 28),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Menü',
                                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.category, color: Colors.deepPurple.shade600),
                        title: Text('Kategoriler', style: TextStyle(color: Colors.black87)),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CategoriesView()),
                          ).then((_) => viewModel.fetchInitialData());
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.task, color: Colors.deepPurple.shade600),
                        title: Text('Görevler', style: TextStyle(color: Colors.black87)),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TasksView()),
                          ).then((_) => viewModel.fetchInitialData());
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.event, color: Colors.deepPurple.shade600),
                        title: Text('Etkinlikler', style: TextStyle(color: Colors.black87)),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EventsView()),
                          ).then((_) => viewModel.fetchInitialData());
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.photo_album, color: Colors.deepPurple.shade600),
                        title: Text('Resim Galerisi', style: TextStyle(color: Colors.black87)),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ImageGalleryView()),
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(Icons.settings, color: Colors.deepPurple.shade600),
                        title: Text('Ayarlar', style: TextStyle(color: Colors.black87)),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SettingsView()),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingList(HomeViewModel viewModel) {
  if (_shownListType == _UpcomingListType.none) {
    return const SizedBox.shrink();
  }

  final String title;
  final List<Widget> items;
  final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');

  if (_shownListType == _UpcomingListType.tasks) {
    title = 'Yaklaşan Görevler';
    final now = DateTime.now();
    final upcomingTasks = viewModel.tasks.where((task) {
      if (task.startTime == null) return false;
      final difference = task.startTime!.difference(now).inDays;
      return (task.status == TaskStatus.PENDING || task.status == TaskStatus.IN_PROGRESS) && difference >= 0 && difference <= 3;
    }).toList();

    if (upcomingTasks.isEmpty) {
      items = [const ListTile(title: Text('Yaklaşan görev bulunmamaktadır.', style: TextStyle(color: Colors.white)))];
    } else {
      items = upcomingTasks.map((task) {
        final String startTime = formatter.format(task.startTime!);
        final String endTime = task.endTime != null ? formatter.format(task.endTime!) : 'Belirtilmemiş';
        return Card(
          color: Colors.white.withOpacity(0.8),
          child: ListTile(
            title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Başlangıç: $startTime\nBitiş: $endTime', style: const TextStyle(color: Colors.black54)),
            isThreeLine: true,
          ),
        );
      }).toList();
    }
  } else {
    title = 'Yaklaşan Etkinlikler';
    final now = DateTime.now();
    final upcomingEvents = viewModel.events.where((event) {
      if (event.startTime == null) return false;
      final difference = event.startTime!.difference(now).inDays;
      return difference >= 0 && difference <= 3;
    }).toList();

    if (upcomingEvents.isEmpty) {
      items = [const ListTile(title: Text('Yaklaşan etkinlik bulunmamaktadır.', style: TextStyle(color: Colors.white)))];
    } else {
      items = upcomingEvents.map((event) {
        final String startTime = formatter.format(event.startTime!);
        final String endTime = event.endTime != null ? formatter.format(event.endTime!) : 'Belirtilmemiş';
        return Card(
          color: Colors.white.withOpacity(0.8),
          child: ListTile(
            title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Başlangıç: $startTime\nBitiş: $endTime', style: const TextStyle(color: Colors.black54)),
            isThreeLine: true,
          ),
        );
      }).toList();
    }
  }

  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    padding: const EdgeInsets.all(12.0),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.2),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 150,
          ),
          child: ListView(
            shrinkWrap: true,
            children: items,
          ),
        ),
      ],
    ),
  );
}

  void _showAddDialog(BuildContext context, HomeViewModel viewModel, DateTime? selectedDate) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          backgroundColor: Colors.deepPurple.shade300.withOpacity(0.9),
          title: const Text('Ne eklemek istersiniz?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.task, color: Colors.white),
                title: const Text('Görev', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _showAddTaskDialog(context, viewModel, selectedDate);
                },
              ),
              ListTile(
                leading: const Icon(Icons.event, color: Colors.white),
                title: const Text('Etkinlik', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _showAddEventDialog(context, viewModel, selectedDate);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          backgroundColor: Colors.deepPurple.shade300.withOpacity(0.9),
          title: const Text('Çıkış Yap', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('Çıkış yapmak istediğinizden emin misiniz?', style: const TextStyle(color: Colors.white)),
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
                Navigator.pop(dialogContext);
                logout(context);
              },
              child: const Text('Çıkış Yap'),
            ),
          ],
        );
      },
    );
  }

  void _showAddTaskDialog(BuildContext context, HomeViewModel viewModel, DateTime? selectedDate) async {
    final request = await showDialog<TaskRequest>(
      context: context,
      builder: (_) => TaskDialog(selectedDate: selectedDate),
    );

    if (request != null) {
      if (request.categoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen bir kategori seçin.')),
        );
        return;
      }

      final success = await viewModel.addTask(
        request.title,
        request.description ?? '',
        request.categoryId!,
        request.importanceLevel,
        request.startTime,
        request.endTime,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Görev başarıyla eklendi.'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Görev eklenirken bir hata oluştu.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddEventDialog(BuildContext context, HomeViewModel viewModel, DateTime? selectedDate) async {
    final request = await showDialog<EventRequest>(
      context: context,
      builder: (_) => EventDialog(selectedDate: selectedDate),
    );

    if (request != null) {
      final success = await viewModel.addEvent(request);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Etkinlik başarıyla eklendi.'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Etkinlik eklenirken bir hata oluştu.'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<TaskResponse> tasks, List<EventResponse> events, List<CategoryResponse> categories) {
    final List<Color> taskColorPalette = [
      Colors.blue.shade700,
      Colors.red.shade700,
      Colors.orange.shade700,
      Colors.brown.shade700,
      Colors.teal.shade700,
      Colors.deepPurple.shade700,
    ];

    final List<Color> eventColorPalette = [
      Colors.green.shade700,
      Colors.purple.shade700,
      Colors.pink.shade700,
      Colors.amber.shade800,
      Colors.cyan.shade700,
      Colors.indigo.shade700,
    ];

    List<Appointment> appointments = [];

    for (var task in tasks) {
      int categoryIndex = categories.indexWhere((c) => c.id == task.categoryId);
      Color appointmentColor = categoryIndex != -1 ? taskColorPalette[categoryIndex % taskColorPalette.length] : Colors.grey;

      if (task.startTime != null) {
        appointments.add(Appointment(
          startTime: task.startTime!,
          endTime: task.endTime ?? task.startTime!.add(const Duration(hours: 1)),
          subject: 'Görev: ${task.title}',
          notes: task.description ?? '',
          color: appointmentColor,
          isAllDay: false,
        ));
      }
    }

    for (var event in events) {
      int categoryIndex = categories.indexWhere((c) => c.id == event.categoryId);
      Color appointmentColor = categoryIndex != -1 ? eventColorPalette[categoryIndex % eventColorPalette.length] : Colors.grey.shade700;

      if (event.startTime != null) {
        appointments.add(Appointment(
          startTime: event.startTime!,
          endTime: event.endTime ?? event.startTime!.add(const Duration(hours: 1)),
          subject: 'Etkinlik: ${event.title}',
          notes: event.description ?? '',
          color: appointmentColor,
          isAllDay: false,
        ));
      }
    }

    this.appointments = appointments;
  }
}
