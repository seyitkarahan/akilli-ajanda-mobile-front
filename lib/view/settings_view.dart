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
                    : _buildSettingsForm(context, viewModel),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsForm(BuildContext context, SettingsViewModel viewModel) {
    if (viewModel.userSettings == null) {
      return const Center(child: Text("Ayarlar yüklenemedi.", style: TextStyle(color: Colors.white)));
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionTitle('Görünüm Ayarları'),
        _buildThemeDropdown(viewModel),
        _buildLanguageDropdown(viewModel),
        const SizedBox(height: 20),
        _buildSectionTitle('Takvim Ayarları'),
        _buildStartDayOfWeekDropdown(viewModel),
        _buildDateFormatDropdown(viewModel),
        _buildIs24HourFormatSwitch(viewModel),
        const SizedBox(height: 20),
        _buildSectionTitle('Bildirim Ayarları'),
        _buildEmailNotificationsSwitch(viewModel),
        _buildPushNotificationsSwitch(viewModel),
        const SizedBox(height: 20),
        _buildSectionTitle('Varsayılan Hatırlatıcı Süreleri'),
        _buildReminderTextField(viewModel.defaultTaskReminderMinutesController, 'Görev Hatırlatıcı (dakika)'),
        const SizedBox(height: 10),
        _buildReminderTextField(viewModel.defaultEventReminderMinutesController, 'Etkinlik Hatırlatıcı (dakika)'),
        const SizedBox(height: 10),
        _buildTimezoneDropdown(viewModel),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildThemeDropdown(SettingsViewModel viewModel) {
    return _buildDropdown('Tema', viewModel.userSettings!.theme, ['LIGHT', 'DARK', 'SYSTEM'], viewModel.updateTheme);
  }

  Widget _buildLanguageDropdown(SettingsViewModel viewModel) {
    return _buildDropdown('Dil', viewModel.userSettings!.language, ['tr', 'en'], viewModel.updateLanguage);
  }

  Widget _buildStartDayOfWeekDropdown(SettingsViewModel viewModel) {
    return _buildDropdown('Haftanın Başlangıcı', viewModel.userSettings!.startDayOfWeek, ['MONDAY', 'SUNDAY'], viewModel.updateStartDayOfWeek);
  }

  Widget _buildDateFormatDropdown(SettingsViewModel viewModel) {
    return _buildDropdown('Tarih Formatı', viewModel.userSettings!.dateFormat, ['dd/MM/yyyy', 'MM/dd/yyyy'], viewModel.updateDateFormat);
  }

  Widget _buildIs24HourFormatSwitch(SettingsViewModel viewModel) {
    return _buildSwitch('24 Saat Formatı', viewModel.userSettings!.is24HourFormat ?? true, viewModel.updateIs24HourFormat);
  }

  Widget _buildEmailNotificationsSwitch(SettingsViewModel viewModel) {
    return _buildSwitch('E-posta Bildirimleri', viewModel.userSettings!.emailNotificationsEnabled ?? true, viewModel.updateEmailNotificationsEnabled);
  }

  Widget _buildPushNotificationsSwitch(SettingsViewModel viewModel) {
    return _buildSwitch('Anlık Bildirimler', viewModel.userSettings!.pushNotificationsEnabled ?? true, viewModel.updatePushNotificationsEnabled);
  }

  Widget _buildReminderTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.5))),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
  
  Widget _buildTimezoneDropdown(SettingsViewModel viewModel) {
    return _buildDropdown('Saat Dilimi', viewModel.userSettings!.timezone, ['Europe/Istanbul', 'Europe/London', 'America/New_York'], viewModel.updateTimezone);
  }

  Widget _buildDropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.5))),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
      dropdownColor: Colors.deepPurple.shade400,
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildSwitch(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.white,
      activeTrackColor: Colors.green.shade300,
      inactiveThumbColor: Colors.white70,
      inactiveTrackColor: Colors.grey.shade600,
    );
  }
}
