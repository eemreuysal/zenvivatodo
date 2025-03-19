import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_texts.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../dashboard/dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Login function with AuthService
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Try to login with entered credentials
        final user = await _authService.login(
            _usernameController.text.trim(), 
            _passwordController.text.trim(),
            ); // Virgül eklendi

        if (!mounted) return;

        if (user != null) {
          // Navigate to dashboard if login successful
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => DashboardScreen(userId: user.id!),
            ),
          );
        } else {
          // Show error if login failed
          setState(() {
            _errorMessage =
                'Kullanıcı adı veya şifre hatalı. Lütfen tekrar deneyin.';
            _isLoading = false;
          });
        }
      } on Exception { // Burayı 'catch (e)' yerine sadece 'catch' olarak düzelttik
        if (!mounted) return;

        // Show error if exception occurs
        setState(() {
          _errorMessage =
              'Giriş yapılırken bir hata oluştu. Lütfen tekrar deneyin.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Logo and app name
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.show_chart,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppTexts.appName,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                // Login form title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppTexts.login,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Uygulamayı kullanmak için lütfen giriş yapın.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 32),
                // Login form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _usernameController,
                        labelText: AppTexts.username,
                        prefixIcon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppTexts.requiredField;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _passwordController,
                        labelText: AppTexts.password,
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppTexts.requiredField;
                          }
                          return null;
                        },
                      ),
                      if (_errorMessage != null) ...[ 
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      if (_isLoading) const CircularProgressIndicator() else CustomButton(
                              text: AppTexts.loginButtonText,
                              onPressed: _login,
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppTexts.dontHaveAccount,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to register screen
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        AppTexts.registerButtonText,
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
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
  }
}