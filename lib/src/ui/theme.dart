import 'package:flutter/material.dart';

// @see https://www.figma.com/file/lxQKrYKDLRncVbxacqMc1m/Jung-Colors?node-id=0%3A1&mode=dev
class AppColors {
  static const blueJay = Color(0xff4D92F9);
}

final lightTheme = ThemeData.light().copyWith(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: AppColors.blueJay,
  ),
  appBarTheme: ThemeData.light().appBarTheme.copyWith(
        centerTitle: false,
      ),
);

final darkTheme = ThemeData.dark().copyWith(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: AppColors.blueJay,
  ),
  appBarTheme: ThemeData.light().appBarTheme.copyWith(
        centerTitle: false,
      ),
);
