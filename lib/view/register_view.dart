import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/register_view_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: Consumer<RegisterViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.deepPurple.shade300],
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
                      Icon(Icons.person_add_alt_1_outlined, size: 80, color: Colors.white.withOpacity(0.9)),
                      const SizedBox(height: 20),
                      const Text(
                        "Hesap Oluştur",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Ajandanı oluşturmaya başla!",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 50),
                      CustomTextField(
                        controller: viewModel.nameController,
                        labelText: "İsim",
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 20),
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
                            : CustomButton(onPressed: () => viewModel.register(context), text: "Kayıt Ol"),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: RichText(
                          text: TextSpan(
                            text: 'Zaten bir hesabın var mı? ',
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 15),
                            children: const <TextSpan>[
                              TextSpan(
                                text: 'Giriş Yap',
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
