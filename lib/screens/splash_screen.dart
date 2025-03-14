import 'package:flutter/material.dart';
import 'dart:async';
import '../constants/app_texts.dart';
import '../constants/app_colors.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen())
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Icon(Icons.show_chart, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppTexts.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppTexts.appSlogan,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: AppColors.primaryColor),
          ],
        ),
      ),
    );
  }
}