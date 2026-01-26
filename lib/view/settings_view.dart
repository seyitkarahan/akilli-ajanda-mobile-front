import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/settings_view_model.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel(),
      child: Consumer<SettingsViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: const Text('Ayarlar'),
              elevation: 0,
              backgroundColor: Colors.transparent,
              titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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
                child: viewModel.isLoading && viewModel.userSettings == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(color: Colors.white),
                            const SizedBox(height: 16),
                            Text(
                              'Ayarlar yükleniyor...',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _buildSettingsContent(context, viewModel),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context, SettingsViewModel viewModel) {
    if (viewModel.userSettings == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white.withOpacity(0.7),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              "Ayarlar yüklenemedi.",
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          _buildSettingsSection(
            context,
            icon: Icons.palette_rounded,
            title: 'Görünüm Ayarları',
            gradientColors: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
            children: [
              _buildThemeDropdown(viewModel),
              const SizedBox(height: 12),
              _buildLanguageDropdown(viewModel),
            ],
          ),
          const SizedBox(height: 20),
          _buildSettingsSection(
            context,
            icon: Icons.calendar_today_rounded,
            title: 'Takvim Ayarları',
            gradientColors: [const Color(0xFF10B981), const Color(0xFF34D399)],
            children: [
              _buildStartDayOfWeekDropdown(viewModel),
              const SizedBox(height: 12),
              _buildDateFormatDropdown(viewModel),
              const SizedBox(height: 12),
              _buildIs24HourFormatSwitch(viewModel),
            ],
          ),
          const SizedBox(height: 20),
          _buildSettingsSection(
            context,
            icon: Icons.notifications_active_rounded,
            title: 'Bildirim Ayarları',
            gradientColors: [const Color(0xFFF59E0B), const Color(0xFFFBBF24)],
            children: [
              _buildEmailNotificationsSwitch(viewModel),
              const SizedBox(height: 8),
              _buildPushNotificationsSwitch(viewModel),
            ],
          ),
          const SizedBox(height: 20),
          _buildSettingsSection(
            context,
            icon: Icons.access_time_rounded,
            title: 'Varsayılan Hatırlatıcı Süreleri',
            gradientColors: [const Color(0xFFEC4899), const Color(0xFFF472B6)],
            children: [
              _buildReminderTextField(
                viewModel.defaultTaskReminderMinutesController,
                'Görev Hatırlatıcı (dakika)',
                Icons.task_alt_rounded,
              ),
              const SizedBox(height: 12),
              _buildReminderTextField(
                viewModel.defaultEventReminderMinutesController,
                'Etkinlik Hatırlatıcı (dakika)',
                Icons.event_rounded,
              ),
              const SizedBox(height: 12),
              _buildTimezoneDropdown(viewModel),
            ],
          ),
          const SizedBox(height: 32),
          _buildSaveButton(context, viewModel),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Color> gradientColors,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.15),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
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
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, SettingsViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final success = await viewModel.saveSettings();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        success ? Icons.check_circle : Icons.error,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          success
                              ? "Ayarlar başarıyla kaydedildi"
                              : "Ayarlar kaydedilirken bir hata oluştu.",
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: success ? Colors.green : Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.save_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Ayarları Kaydet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeDropdown(SettingsViewModel viewModel) {
    return _buildDropdownSetting(
      'Tema',
      Icons.palette,
      viewModel.userSettings!.theme,
      ['LIGHT', 'DARK', 'SYSTEM'],
      viewModel.updateTheme,
    );
  }

  Widget _buildLanguageDropdown(SettingsViewModel viewModel) {
    return _buildDropdownSetting(
      'Dil',
      Icons.language,
      viewModel.userSettings!.language,
      ['tr', 'en'],
      viewModel.updateLanguage,
    );
  }

  Widget _buildStartDayOfWeekDropdown(SettingsViewModel viewModel) {
    return _buildDropdownSetting(
      'Haftanın Başlangıcı',
      Icons.calendar_today,
      viewModel.userSettings!.startDayOfWeek,
      ['MONDAY', 'SUNDAY'],
      viewModel.updateStartDayOfWeek,
    );
  }

  Widget _buildDateFormatDropdown(SettingsViewModel viewModel) {
    return _buildDropdownSetting(
      'Tarih Formatı',
      Icons.date_range,
      viewModel.userSettings!.dateFormat,
      ['dd/MM/yyyy', 'MM/dd/yyyy'],
      viewModel.updateDateFormat,
    );
  }

  Widget _buildIs24HourFormatSwitch(SettingsViewModel viewModel) {
    return _buildSwitchSetting(
      '24 Saat Formatı',
      Icons.access_time,
      viewModel.userSettings!.is24HourFormat ?? true,
      viewModel.updateIs24HourFormat,
    );
  }

  Widget _buildEmailNotificationsSwitch(SettingsViewModel viewModel) {
    return _buildSwitchSetting(
      'E-posta Bildirimleri',
      Icons.email,
      viewModel.userSettings!.emailNotificationsEnabled ?? true,
      viewModel.updateEmailNotificationsEnabled,
    );
  }

  Widget _buildPushNotificationsSwitch(SettingsViewModel viewModel) {
    return _buildSwitchSetting(
      'Anlık Bildirimler',
      Icons.notifications_active,
      viewModel.userSettings!.pushNotificationsEnabled ?? true,
      viewModel.updatePushNotificationsEnabled,
    );
  }

  Widget _buildReminderTextField(TextEditingController controller, String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: TextStyle(
          color: Colors.grey.shade900,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6366F1),
              size: 20,
            ),
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        ),
      ),
    );
  }

  Widget _buildTimezoneDropdown(SettingsViewModel viewModel) {
    return _buildDropdownSetting(
      'Saat Dilimi',
      Icons.access_time_filled,
      viewModel.userSettings!.timezone,
      ['Europe/Istanbul', 'Europe/London', 'America/New_York'],
      viewModel.updateTimezone,
    );
  }

  Widget _buildDropdownSetting(String label, IconData icon, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((item) {
          String displayText = item;
          // Türkçe çeviriler
          if (item == 'LIGHT') displayText = 'Açık';
          if (item == 'DARK') displayText = 'Koyu';
          if (item == 'SYSTEM') displayText = 'Sistem';
          if (item == 'tr') displayText = 'Türkçe';
          if (item == 'en') displayText = 'English';
          if (item == 'MONDAY') displayText = 'Pazartesi';
          if (item == 'SUNDAY') displayText = 'Pazar';
          if (item == 'dd/MM/yyyy') displayText = 'GG/AA/YYYY';
          if (item == 'MM/dd/yyyy') displayText = 'AA/GG/YYYY';
          if (item == 'Europe/Istanbul') displayText = 'İstanbul (GMT+3)';
          if (item == 'Europe/London') displayText = 'Londra (GMT+0)';
          if (item == 'America/New_York') displayText = 'New York (GMT-5)';
          
          return DropdownMenuItem(
            value: item,
            child: Text(
              displayText,
              style: TextStyle(
                color: Colors.grey.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade600),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6366F1),
              size: 20,
            ),
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        ),
        dropdownColor: Colors.white,
        style: TextStyle(
          color: Colors.grey.shade900,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildSwitchSetting(String title, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6366F1),
              size: 22,
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade900,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Transform.scale(
            scale: 1.1,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF10B981),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade300,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}