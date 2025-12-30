import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/settings_view_model.dart';
import '../widgets/custom_button.dart';

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
                child: viewModel.isLoading && viewModel.userSettings == null
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
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
      return const Center(child: Text("Ayarlar yüklenemedi.", style: TextStyle(color: Colors.white)));
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSettingsSection(
          context,
          title: 'Görünüm Ayarları',
          children: [
            _buildThemeDropdown(viewModel),
            _buildLanguageDropdown(viewModel),
          ],
        ),
        const SizedBox(height: 20),
        _buildSettingsSection(
          context,
          title: 'Takvim Ayarları',
          children: [
            _buildStartDayOfWeekDropdown(viewModel),
            _buildDateFormatDropdown(viewModel),
            _buildIs24HourFormatSwitch(viewModel),
          ],
        ),
        const SizedBox(height: 20),
        _buildSettingsSection(
          context,
          title: 'Bildirim Ayarları',
          children: [
            _buildEmailNotificationsSwitch(viewModel),
            _buildPushNotificationsSwitch(viewModel),
          ],
        ),
        const SizedBox(height: 20),
        _buildSettingsSection(
          context,
          title: 'Varsayılan Hatırlatıcı Süreleri',
          children: [
            _buildReminderTextField(viewModel.defaultTaskReminderMinutesController, 'Görev Hatırlatıcı (dakika)', Icons.task_alt),
            _buildReminderTextField(viewModel.defaultEventReminderMinutesController, 'Etkinlik Hatırlatıcı (dakika)', Icons.event),
            _buildTimezoneDropdown(viewModel),
          ],
        ),
        const SizedBox(height: 40),
        CustomButton(
          onPressed: () async {
            final success = await viewModel.saveSettings();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? "Ayarlar kaydedildi" : "Ayarlar kaydedilirken bir hata oluştu."),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            }
          },
          text: "Kaydet",
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, {required String title, required List<Widget> children}) {
    return Card(
      color: Colors.white.withOpacity(0.15), // Slightly transparent card background
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...children.map((widget) => Padding( // Add consistent padding to each setting item
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: widget,
            )).toList(),
          ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70), // Add icon here
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.5)), borderRadius: BorderRadius.circular(8.0)),
          focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white), borderRadius: BorderRadius.circular(8.0)),
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        ),
        style: const TextStyle(color: Colors.white),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(color: Colors.white)))).toList(),
        onChanged: onChanged,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70), // Add icon here
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.5)), borderRadius: BorderRadius.circular(8.0)),
          focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white), borderRadius: BorderRadius.circular(8.0)),
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        ),
        dropdownColor: Colors.deepPurple.shade600, // Make dropdown darker
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildSwitchSetting(String title, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      secondary: Icon(icon, color: Colors.white70), // Add icon here
      value: value,
      onChanged: onChanged,
      activeColor: Colors.white,
      activeTrackColor: Colors.green.shade300,
      inactiveThumbColor: Colors.white70,
      inactiveTrackColor: Colors.grey.shade600,
    );
  }
}