import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/settings_view_model.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  void _showDeleteConfirmation(BuildContext context, SettingsViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          backgroundColor: Colors.deepPurple.shade300.withOpacity(0.9),
          title: const Text('Ayarları Sil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('Ayarlarınızı silmek istediğinizden emin misiniz?', style: TextStyle(color: Colors.white70)),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal', style: TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sil'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final success = await viewModel.deleteSettings();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Ayarlar başarıyla silindi.' : 'Ayarlar silinirken bir hata oluştu.'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

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
                child: viewModel.isLoading && viewModel.notificationController.text.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: viewModel.notificationController,
                              labelText: "Bildirim Tercihi",
                              icon: Icons.notifications_none,
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              controller: viewModel.timezoneController,
                              labelText: "Saat Dilimi",
                              icon: Icons.access_time,
                            ),
                            const SizedBox(height: 40),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
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
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: CustomButton(
                                    onPressed: () => _showDeleteConfirmation(context, viewModel),
                                    text: "Sil",
                                    color: Colors.red.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
