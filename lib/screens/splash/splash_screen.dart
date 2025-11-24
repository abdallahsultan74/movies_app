import 'dart:async';
import 'package:flutter/material.dart';
import 'package:movie/core/theme/app_assets.dart';
import 'package:movie/screens/onboarding/onboarding_screen.dart';
import '../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = 'splash';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState(){
    super.initState();
    Timer(Duration(seconds: 3),(){
      Navigator.pushReplacementNamed(context, OnboardingScreen.routeName);
    });
  }
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.Black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Image.asset(
                  AppAssets.logo,
                  width: mediaQuery.width * 0.5,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Image.asset(
              AppAssets.routeLogo,
              width: mediaQuery.width * 0.4,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
