import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_texts.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Simulate a loading time
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Navigate to login screen directly for now
    // Dart 3.7+ wildcard değişken kullanımı
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    // Material 3 renklerini kullanalım
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        // Gradient arkaplan
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorScheme.primaryContainer, colorScheme.surface],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo container - modern tasarım
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      // Opacity 0.2 için Alpha değeri 51'dir (255 * 0.2 = 51)
                      color: Colors.black.withAlpha(51),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Center(child: Icon(Icons.show_chart, size: 60, color: Colors.white)),
              ),

              const SizedBox(height: 24),

              // Uygulama adı
              Text(
                AppTexts.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Slogan
              Text(
                AppTexts.appSlogan,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
              ),

              const SizedBox(height: 48),

              // Animasyonlu yükleme göstergesi
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 2),
                builder: (_, value, _) {
                  // Gereksiz çoklu alt çizgi kullanımı düzeltildi
                  return CircularProgressIndicator(
                    value: value,
                    color: colorScheme.primary,
                    strokeWidth: 4,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
