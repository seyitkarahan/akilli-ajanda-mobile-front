
import 'package:akilli_ajanda_front/model/category_response.dart';
import 'package:akilli_ajanda_front/model/event_request.dart';
import 'package:akilli_ajanda_front/model/event_response.dart';
import 'package:akilli_ajanda_front/model/task_request.dart';
import 'package:akilli_ajanda_front/model/task_response.dart';
import 'package:akilli_ajanda_front/model/task_status.dart';
import 'package:akilli_ajanda_front/service/storage_service.dart';
import 'package:akilli_ajanda_front/view/categories_view.dart';
import 'package:akilli_ajanda_front/view/event_dialog.dart';
import 'package:akilli_ajanda_front/view/event_notification_page.dart';
import 'package:akilli_ajanda_front/view/events_view.dart';
import 'package:akilli_ajanda_front/view/image_gallery_view.dart';
import 'package:akilli_ajanda_front/view/login_view.dart';
import 'package:akilli_ajanda_front/view/map_view.dart';
import 'package:akilli_ajanda_front/view/settings_view.dart';
import 'package:akilli_ajanda_front/view/statistics_view.dart';
import 'package:akilli_ajanda_front/view/chatbot_bottom_sheet.dart';
import 'package:akilli_ajanda_front/view/task_dialog.dart';
import 'package:akilli_ajanda_front/view/task_notification_page.dart';
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

class _BusySlot {
  final DateTime startTime;
  final DateTime endTime;

  _BusySlot({required this.startTime, required this.endTime});
}

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
  bool _showSmartSuggestions = false;

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
    if (!mounted) return;
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
            body: Stack(
              children: [
                Container(
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
                if (_selectedIndex == 0) _buildChatbotButton(context, viewModel),
              ],
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GNav(
                      rippleColor: Colors.grey.shade300,
                      hoverColor: Colors.grey.shade100,
                      gap: 8,
                      activeColor: Colors.white,
                      iconSize: 22,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      duration: const Duration(milliseconds: 400),
                      tabBackgroundColor: const Color(0xFF6366F1),
                      color: Colors.grey.shade700,
                      curve: Curves.easeInOut,
                      tabs: const [
                        GButton(
                          icon: Icons.home_rounded,
                          text: 'Ana Sayfa',
                        ),
                        GButton(
                          icon: Icons.task_alt_rounded,
                          text: 'Görevler',
                        ),
                        GButton(
                          icon: Icons.event_rounded,
                          text: 'Etkinlikler',
                        ),
                        GButton(
                          icon: Icons.settings_rounded,
                          text: 'Ayarlar',
                        ),
                      ],
                      selectedIndex: _selectedIndex,
                      onTabChange: _onItemTapped,
                    ),
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Akıllı Ajanda',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: -0.5,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _showSmartSuggestions
                  ? Colors.white.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                _showSmartSuggestions
                    ? Icons.lightbulb_rounded
                    : Icons.lightbulb_outline_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _showSmartSuggestions = !_showSmartSuggestions;
                });
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                _calendarController.view == CalendarView.schedule
                    ? Icons.calendar_month_rounded
                    : Icons.view_agenda_rounded,
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
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              onPressed: () => _showLogoutConfirmationDialog(context),
            ),
          ),
        ],
      );
    } else {
      return AppBar(
        title: Text(
          ['Ana Sayfa', 'Görevler', 'Etkinlikler', 'Ayarlar'][_selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
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

  List<Map<String, DateTime>> _findFreeTimeSlots(List<TaskResponse> tasks, List<EventResponse> events) {
    final busySlots = <_BusySlot>[];
    for (var task in tasks) {
      if (task.startTime != null && task.endTime != null) {
        busySlots.add(_BusySlot(startTime: task.startTime!, endTime: task.endTime!));
      }
    }
    for (var event in events) {
        busySlots.add(_BusySlot(startTime: event.startTime, endTime: event.endTime));
    }

    busySlots.sort((a, b) => a.startTime.compareTo(b.startTime));

    final freeSlots = <Map<String, DateTime>>[];
    final now = DateTime.now();
    DateTime searchStart = now;
    final DateTime searchEnd = DateTime(now.year, now.month, now.day).add(const Duration(days: 2));

    for (final slot in busySlots) {
      if (slot.endTime.isBefore(searchStart)) continue;
      if (slot.startTime.isAfter(searchStart)) {
        final gapDuration = slot.startTime.difference(searchStart);
        if (gapDuration.inMinutes >= 60) {
          freeSlots.add({'start': searchStart, 'end': slot.startTime});
        }
      }
      if(slot.endTime.isAfter(searchStart)) {
          searchStart = slot.endTime;
      }
    }

    if (searchStart.isBefore(searchEnd)) {
        final gapDuration = searchEnd.difference(searchStart);
         if (gapDuration.inMinutes >= 60) {
            freeSlots.add({'start': searchStart, 'end': searchEnd});
         }
    }

    return freeSlots;
  }

  Widget _buildSmartSuggestions(HomeViewModel viewModel) {
    final freeSlots = _findFreeTimeSlots(viewModel.tasks, viewModel.events);

    if (freeSlots.isEmpty) {
      return const SizedBox.shrink();
    }

    final timeFormat = (viewModel.userSettings?.is24HourFormat ?? true) ? 'HH:mm' : 'hh:mm a';
    final dateFormat = DateFormat('E, d MMM $timeFormat', 'tr_TR');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Akıllı Öneriler',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.92),
              itemCount: freeSlots.length,
              itemBuilder: (context, index) {
                final slot = freeSlots[index];
                final startTime = slot['start']!;
                final endTime = slot['end']!;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        // Gradient background
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6366F1),
                                const Color(0xFF8B5CF6),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.schedule_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'Boş Zamanınız Var!',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 14,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            dateFormat.format(startTime),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white.withOpacity(0.95),
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.flag_rounded,
                                          size: 14,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            dateFormat.format(endTime),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white.withOpacity(0.95),
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => _showAddTaskDialog(context, viewModel, startTime),
                                          borderRadius: BorderRadius.circular(12),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.add_task_rounded,
                                                  size: 16,
                                                  color: const Color(0xFF6366F1),
                                                ),
                                                const SizedBox(width: 6),
                                                Flexible(
                                                  child: Text(
                                                    'Görev',
                                                    style: TextStyle(
                                                      color: const Color(0xFF6366F1),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => _showAddEventDialog(context, viewModel, startTime),
                                          borderRadius: BorderRadius.circular(12),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.event_available_rounded,
                                                  size: 16,
                                                  color: const Color(0xFF6366F1),
                                                ),
                                                const SizedBox(width: 6),
                                                Flexible(
                                                  child: Text(
                                                    'Etkinlik',
                                                    style: TextStyle(
                                                      color: const Color(0xFF6366F1),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
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
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarPage(HomeViewModel viewModel) {
    final _AppointmentDataSource dataSource = _AppointmentDataSource(viewModel.tasks, viewModel.events, viewModel.categories);
    return RefreshIndicator(
      onRefresh: viewModel.fetchInitialData,
      color: const Color(0xFF6366F1),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_showSmartSuggestions) _buildSmartSuggestions(viewModel),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Takvim',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.6,
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.grey.shade50,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SfCalendar(
                    controller: _calendarController,
                    dataSource: dataSource,
                    firstDayOfWeek: viewModel.userSettings?.startDayOfWeek == 'SUNDAY' ? 7 : 1,
                    backgroundColor: Colors.transparent,
                    todayTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    todayHighlightColor: const Color(0xFF6366F1),
                    headerStyle: const CalendarHeaderStyle(
                      textStyle: TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    viewHeaderStyle: ViewHeaderStyle(
                      dayTextStyle: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                      dateTextStyle: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: Colors.grey.shade50,
                    ),
                    monthViewSettings: MonthViewSettings(
                      appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                      showAgenda: true,
                      agendaViewHeight: 150,
                      agendaStyle: AgendaStyle(
                        backgroundColor: Colors.transparent,
                        appointmentTextStyle: const TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        dateTextStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      monthCellStyle: MonthCellStyle(
                        textStyle: const TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        trailingDatesTextStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        leadingDatesTextStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        todayBackgroundColor: const Color(0xFF6366F1),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    scheduleViewSettings: ScheduleViewSettings(
                      appointmentItemHeight: 75,
                      monthHeaderSettings: MonthHeaderSettings(
                        height: 110,
                        textAlign: TextAlign.left,
                        backgroundColor: Colors.transparent,
                        monthFormat: 'MMMM yyyy',
                        monthTextStyle: const TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      weekHeaderSettings: WeekHeaderSettings(
                        weekTextStyle: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        backgroundColor: Colors.grey.shade50,
                      ),
                      dayHeaderSettings: DayHeaderSettings(
                        dayFormat: 'EEEE',
                        width: 75,
                        dayTextStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                          letterSpacing: 0.5,
                        ),
                        dateTextStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    selectionDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6366F1).withOpacity(0.2),
                          const Color(0xFF8B5CF6).withOpacity(0.2),
                        ],
                      ),
                      border: Border.all(
                        color: const Color(0xFF6366F1),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      shape: BoxShape.rectangle,
                    ),
                    onTap: (CalendarTapDetails details) {
                      if (details.targetElement == CalendarElement.calendarCell) {
                        if (viewModel.categories.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.white),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text('Lütfen önce bir kategori oluşturun.'),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.orange,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        } else {
                          _showAddDialog(context, viewModel, details.date);
                        }
                      }
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF3B82F6),
                            const Color(0xFF2563EB),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (_shownListType == _UpcomingListType.tasks) {
                                _shownListType = _UpcomingListType.none;
                              } else {
                                _shownListType = _UpcomingListType.tasks;
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _shownListType == _UpcomingListType.tasks
                                      ? Icons.task_alt_rounded
                                      : Icons.task_alt_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Yaklaşan Görevler',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6366F1),
                            const Color(0xFF4F46E5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (_shownListType == _UpcomingListType.events) {
                                _shownListType = _UpcomingListType.none;
                              } else {
                                _shownListType = _UpcomingListType.events;
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _shownListType == _UpcomingListType.events
                                      ? Icons.event_rounded
                                      : Icons.event_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Yaklaşan Etkinlikler',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildUpcomingList(viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildChatbotButton(BuildContext context, HomeViewModel viewModel) {
    return Positioned(
      right: 16,
      bottom: 100,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(28),
        color: Colors.white,
        child: InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => ChatbotBottomSheet(
                onDataChanged: () => viewModel.fetchInitialData(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(28),
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Icon(Icons.chat_rounded, color: Color(0xFF6366F1), size: 28),
          ),
        ),
      ),
    );
  }

  Widget? _buildFab(BuildContext context, HomeViewModel viewModel) {
    if (_selectedIndex == 0) {
      return SpeedDial(
        icon: Icons.add_rounded,
        activeIcon: Icons.close_rounded,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF6366F1),
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        elevation: 8,
        spacing: 12,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.task_alt_rounded, color: Colors.white),
            backgroundColor: const Color(0xFF3B82F6),
            label: 'Görev Ekle',
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            labelBackgroundColor: const Color(0xFF3B82F6),
            onTap: () {
              if (viewModel.categories.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.white),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text('Lütfen önce bir kategori oluşturun.'),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              } else {
                _showAddTaskDialog(context, viewModel, null);
              }
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.event_rounded, color: Colors.white),
            backgroundColor: const Color(0xFF6366F1),
            label: 'Etkinlik Ekle',
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            labelBackgroundColor: const Color(0xFF6366F1),
            onTap: () {
              if (viewModel.categories.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.white),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text('Lütfen önce bir kategori oluşturun.'),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 320,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.menu_rounded, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Menü',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          children: [
                            _buildDrawerItem(
                              context,
                              icon: Icons.category_rounded,
                              title: 'Kategoriler',
                              color: const Color(0xFF6366F1),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const CategoriesView()),
                                ).then((_) => viewModel.fetchInitialData());
                              },
                            ),
                            _buildDrawerItem(
                              context,
                              icon: Icons.task_alt_rounded,
                              title: 'Görevler',
                              color: const Color(0xFF3B82F6),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const TasksView()),
                                ).then((_) => viewModel.fetchInitialData());
                              },
                            ),
                            _buildDrawerItem(
                              context,
                              icon: Icons.event_rounded,
                              title: 'Etkinlikler',
                              color: const Color(0xFF8B5CF6),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const EventsView()),
                                ).then((_) => viewModel.fetchInitialData());
                              },
                            ),
                            _buildDrawerItem(
                              context,
                              icon: Icons.notifications_active_rounded,
                              title: 'Etkinlik Bildirimleri',
                              color: const Color(0xFFF59E0B),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const EventNotificationPage()),
                                );
                              },
                            ),
                            _buildDrawerItem(
                              context,
                              icon: Icons.edit_notifications_rounded,
                              title: 'Görev Bildirimleri',
                              color: const Color(0xFFEC4899),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const TaskNotificationPage()),
                                );
                              },
                            ),
                            _buildDrawerItem(
                              context,
                              icon: Icons.map_rounded,
                              title: 'Etkinlik Haritası',
                              color: const Color(0xFF10B981),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => MapView(viewModel: viewModel)),
                                );
                              },
                            ),
                            _buildDrawerItem(
                              context,
                              icon: Icons.photo_library_rounded,
                              title: 'Resim Galerisi',
                              color: const Color(0xFF14B8A6),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ImageGalleryView()),
                                );
                              },
                            ),
                            _buildDrawerItem(
                              context,
                              icon: Icons.pie_chart_rounded,
                              title: 'İstatistikler',
                              color: const Color(0xFFEF4444),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChangeNotifierProvider.value(
                                      value: viewModel,
                                      child: const StatisticsView(),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 32, indent: 20, endIndent: 20),
                            _buildDrawerItem(
                              context,
                              icon: Icons.settings_rounded,
                              title: 'Ayarlar',
                              color: const Color(0xFF6B7280),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SettingsView()),
                                ).then((_) => viewModel.fetchInitialData());
                              },
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade900,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildUpcomingList(HomeViewModel viewModel) {
    if (_shownListType == _UpcomingListType.none) {
      return const SizedBox.shrink();
    }

    final String title;
    final List<Widget> items;
    final Color primaryColor;
    final IconData titleIcon;
    final String timeFormat = (viewModel.userSettings?.is24HourFormat ?? true) ? 'HH:mm' : 'hh:mm a';
    final DateFormat formatter = DateFormat(('${viewModel.userSettings?.dateFormat ?? 'dd/MM/yyyy'}') + (' $timeFormat'));

    if (_shownListType == _UpcomingListType.tasks) {
      title = 'Yaklaşan Görevler';
      primaryColor = const Color(0xFF3B82F6);
      titleIcon = Icons.task_alt_rounded;
      final now = DateTime.now();
      final upcomingTasks = viewModel.tasks.where((task) {
        if (task.startTime == null) return false;
        final difference = task.startTime!.difference(now).inDays;
        return (task.status == TaskStatus.PENDING || task.status == TaskStatus.IN_PROGRESS) && difference >= 0 && difference <= 3;
      }).toList();

      if (upcomingTasks.isEmpty) {
        items = [
          Container(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                'Yaklaşan görev bulunmamaktadır.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ];
      } else {
        items = upcomingTasks.map((task) {
          final String startTime = formatter.format(task.startTime!);
          final String endTime = task.endTime != null ? formatter.format(task.endTime!) : 'Belirtilmemiş';
          final difference = task.startTime!.difference(DateTime.now());
          final bool showCountdown = !difference.isNegative && difference.inHours < 24;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.task_alt_rounded,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              title: Text(
                task.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1F2937),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'Başlangıç: $startTime',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.flag_rounded, size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'Bitiş: $endTime',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                    if (showCountdown) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer_rounded, size: 12, color: Colors.red.shade600),
                            const SizedBox(width: 4),
                            Text(
                              'Kalan: ${difference.inHours} sa ${difference.inMinutes.remainder(60)} dk',
                              style: TextStyle(
                                color: Colors.red.shade600,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList();
      }
    } else {
      title = 'Yaklaşan Etkinlikler';
      primaryColor = const Color(0xFF6366F1);
      titleIcon = Icons.event_rounded;
      final now = DateTime.now();
      final upcomingEvents = viewModel.events.where((event) {
        final difference = event.startTime.difference(now).inDays;
        return difference >= 0 && difference <= 3;
      }).toList();

      if (upcomingEvents.isEmpty) {
        items = [
          Container(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                'Yaklaşan etkinlik bulunmamaktadır.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ];
      } else {
        items = upcomingEvents.map((event) {
          final String startTime = formatter.format(event.startTime);
          final String endTime = formatter.format(event.endTime);
          final difference = event.startTime.difference(DateTime.now());
          final bool showCountdown = !difference.isNegative && difference.inHours < 24;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.event_rounded,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              title: Text(
                event.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1F2937),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'Başlangıç: $startTime',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.flag_rounded, size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'Bitiş: $endTime',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                    if (showCountdown) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer_rounded, size: 12, color: Colors.red.shade600),
                            const SizedBox(width: 4),
                            Text(
                              'Kalan: ${difference.inHours} sa ${difference.inMinutes.remainder(60)} dk',
                              style: TextStyle(
                                color: Colors.red.shade600,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList();
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      padding: const EdgeInsets.all(20.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  titleIcon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 200,
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
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Ne eklemek istersiniz?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.task_alt_rounded, color: Colors.white, size: 24),
                      ),
                      title: const Text(
                        'Görev',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Color(0xFF3B82F6)),
                      onTap: () {
                        Navigator.pop(dialogContext);
                        _showAddTaskDialog(context, viewModel, selectedDate);
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.event_rounded, color: Colors.white, size: 24),
                      ),
                      title: const Text(
                        'Etkinlik',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Color(0xFF6366F1)),
                      onTap: () {
                        Navigator.pop(dialogContext);
                        _showAddEventDialog(context, viewModel, selectedDate);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
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
                      Icons.logout_rounded,
                      color: Colors.red,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Çıkış Yap',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Çıkış yapmak istediğinizden emin misiniz?',
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              logout(context);
                            },
                            child: const Text(
                              'Çıkış Yap',
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

  void _showAddTaskDialog(BuildContext context, HomeViewModel viewModel, DateTime? selectedDate) async {
    final request = await showDialog<TaskRequest>(
      context: context,
      builder: (_) => TaskDialog(selectedDate: selectedDate),
    );

    if (request != null) {
      if (!mounted) return;
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
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Görev başarıyla eklendi.')),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Görev eklenirken bir hata oluştu.')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
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
      if (!mounted) return;
      final success = await viewModel.addEvent(request);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Etkinlik başarıyla eklendi.')),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Etkinlik eklenirken bir hata oluştu.')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
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

        appointments.add(Appointment(
          startTime: event.startTime,
          endTime: event.endTime,
          subject: 'Etkinlik: ${event.title}',
          notes: event.description,
          color: appointmentColor,
          isAllDay: false,
        ));
    }

    this.appointments = appointments;
  }
}
