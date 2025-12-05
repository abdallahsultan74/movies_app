import 'package:flutter/material.dart';
import 'package:movie/screens/auth/login_screen.dart';
import 'package:movie/screens/auth/register_screen.dart';
import 'package:movie/screens/auth/reset_password_screen.dart';
import 'package:movie/screens/home/home_screen.dart';
import 'package:movie/screens/home/update_profile_tab.dart';
import 'package:movie/screens/onboarding/onboarding_screen.dart';
import 'package:movie/screens/splash/splash_screen.dart';

import 'core/theme/app_theme.dart';

void main() {
  runApp(const MovieApp());
}

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeOfApp,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        OnboardingScreen.routeName: (_) => OnboardingScreen(),
        LoginScreen.routeName: (_) => LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        ResetPasswordScreen.routeName: (_) => const ResetPasswordScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        UpdateProfileTab.routeName: (_) => const UpdateProfileTab(),
      },
    );
  }
}

      theme: AppTheme.themeOfApp,

      initialRoute: SplashScreen.routeName,

      routes: {

        SplashScreen.routeName: (context) => const SplashScreen(),

        OnboardingScreen.routeName: (_) => OnboardingScreen(),
        LoginScreen.routeName: (_) => LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        ResetPasswordScreen.routeName: (_) => const ResetPasswordScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
      },

    );

  }

}


