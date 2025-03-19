import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_texts.dart';
import '../../services/auth_service.dart';
import '../../services/database_helper.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  // Veritabanının ilk yüklenmesi için başlatma
  Future<void> _initializeDatabase() async {
    try {
      // Veritabanını önceden yükleyelim
      await _dbHelper.database;
    } on DatabaseException catch (e) {
      debugPrint('Veritabanı başlatılırken hata: $e');
      // Hata durumunda kullanıcıyı bilgilendirmek için state güncelleme
      setState(() {
        _errorMessage = 'Veritabanı başlatılırken hata oluştu. Lütfen tekrar deneyin.';
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final success = await _authService.register(
          _usernameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (!mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hesap başarıyla oluşturuldu! Giriş yapabilirsiniz.'),
              backgroundColor: AppColors.successColor,
            ),
          );
          // Navigate back to login screen
          Navigator.of(context).pop();
        } else {
          // Giriş yapılan kullanıcı adı veya e-posta kontrolü
          final db = await _dbHelper.database;
          final usernameExists = await db.query(
            'users', 
            where: 'username = ?', 
            whereArgs: [_usernameController.text.trim()],
          );
          
          final emailExists = await db.query(
            'users', 
            where: 'email = ?', 
            whereArgs: [_emailController.text.trim()],
          );

          setState(() {
            if (usernameExists.isNotEmpty) {
              _errorMessage = 'Bu kullanıcı adı zaten kullanılıyor.';
            } else if (emailExists.isNotEmpty) {
              _errorMessage = 'Bu e-posta adresi zaten kullanılıyor.';
            } else {
              _errorMessage = 'Hesap oluşturulurken bir hata oluştu. Lütfen tekrar deneyin.';
            }
            _isLoading = false;
          });
        }
      } on Exception catch (e) {
        setState(() {
          _errorMessage = 'Hesap oluşturulurken bir hata oluştu: $e. Lütfen tekrar deneyin.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Register form title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppTexts.createAccount,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Merhaba, uygulamaıyı kullanmak için lütfen hesap oluşturun.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 32),
                // Register form
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
                        controller: _emailController,
                        labelText: AppTexts.email,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppTexts.requiredField;
                          }
                          // Fix invalid regex, removing the extra backslashes
                          if (!RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                          ).hasMatch(value)) {
                            return AppTexts.invalidEmail;
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
                          if (value.length < 6) {
                            return AppTexts.passwordTooShort;
                          }
                          return null;
                        },
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ],
                      const SizedBox(height: 32),
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else
                        CustomButton(text: AppTexts.registerButtonText, onPressed: _register),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppTexts.alreadyHaveAccount,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        AppTexts.loginButtonText,
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
