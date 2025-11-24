import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData themeOfApp = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.Black),
    scaffoldBackgroundColor: AppColors.Black,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.Black,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.yellow),
      titleTextStyle: TextStyle(
        color: AppColors.yellow,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),
  );
}