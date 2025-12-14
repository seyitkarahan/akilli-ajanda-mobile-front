import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/login_view_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import 'register_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade300, Colors.blue.shade400],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome_mosaic_outlined, size: 80, color: Colors.white.withOpacity(0.9)),
                      const SizedBox(height: 20),
                      const Text(
                        "Akıllı Ajanda",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Tekrar hoş geldin!",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 50),
                      CustomTextField(
                        controller: viewModel.emailController,
                        labelText: "Email",
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: viewModel.passwordController,
                        labelText: "Şifre",
                        obscureText: true,
                        icon: Icons.lock_outline,
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: viewModel.isLoading
                            ? const Center(child: CircularProgressIndicator(color: Colors.white))
                            : CustomButton(onPressed: () => viewModel.login(context), text: "Giriş Yap"),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const RegisterView(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                            ),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: 'Hesabın yok mu? ',
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 15),
                            children: const <TextSpan>[
                              TextSpan(
                                text: 'Kayıt Ol',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
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
