import 'package:akilli_ajanda_front/view/home_page.dart';
import 'package:flutter/material.dart';
import 'service/storage_service.dart';
import 'view/login_view.dart';

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: StorageService().getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const HomePage();
        } else {
          return const LoginView();
        }
      },
    );
  }
}
