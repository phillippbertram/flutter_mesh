import 'package:flutter/material.dart';

// TODO: Use ThemeExtensions
// https://medium.com/@alexandersnotes/flutter-custom-theme-with-themeextension-792034106abc

class AppTheme with ChangeNotifier {
  var _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  set themeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  static final light = ThemeData.light().copyWith(extensions: [
    _lightAppColors,
  ]);

  static final _lightAppColors = AppColorsExtension(
    primary: AppColorPalette.blueJay,
    accent: AppColorPalette.midsummer,
    error: AppColorPalette.carissma,
  );

  static final dark = ThemeData.dark().copyWith(extensions: [
    _darkAppColors,
  ]);

  static final _darkAppColors = AppColorsExtension(
    primary: AppColorPalette.carissma,
    accent: AppColorPalette.midsummer,
    error: AppColorPalette.blueJay,
  );
}

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  AppColorsExtension({
    required this.primary,
    required this.accent,
    required this.error,
  });

  final AppColor primary;
  final AppColor accent;
  final AppColor error;

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    AppColor? primary,
    AppColor? accent,
    AppColor? error,
  }) {
    Color.lerp(Colors.red, Colors.black, 0.5);
    return AppColorsExtension(
      primary: primary ?? this.primary,
      accent: accent ?? this.accent,
      error: error ?? this.error,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
      covariant ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) {
      return this;
    }

    return AppColorsExtension(
      primary: AppColor.lerp(primary, other.primary, t),
      accent: AppColor.lerp(accent, other.accent, t),
      error: AppColor.lerp(error, other.error, t),
    );
  }
}

extension AppThemeExtension on ThemeData {
  /// Usage example: Theme.of(context).appColors;
  AppColorsExtension get appColors =>
      extension<AppColorsExtension>() ?? AppTheme._lightAppColors;
}

extension ThemeGetter on BuildContext {
  /// Usage example: `context.theme`
  ThemeData get theme => Theme.of(this);
}

// @see https://www.figma.com/file/lxQKrYKDLRncVbxacqMc1m/Jung-Colors?node-id=0%3A1&mode=dev
abstract class AppColorPalette {
  static const blueJay = _BlueJayColors();
  static const carissma = _CarissmaColors();
  static const midsummer = AppColor(
    shade200: Color(0xFFFEF8EB),
    shade300: Color(0xFFFDEECE),
    shade400: Color(0xFFFCE4B1),
    shade500: Color(0xFFF9D076),
    shade600: Color(0xFFF7BB3B),
    shade700: Color(0xFFEBA40A),
    shade800: Color(0xFFB07B07),
    shade900: Color(0xFF765205),
  );
}

// TODO: extend ColorSwatch<int>?
class AppColor {
  const AppColor({
    required this.shade200,
    required this.shade300,
    required this.shade400,
    required this.shade500,
    required this.shade600,
    required this.shade700,
    required this.shade800,
    required this.shade900,
  });

  final Color shade200;
  final Color shade300;
  final Color shade400;
  final Color shade500;
  final Color shade600;
  final Color shade700;
  final Color shade800;
  final Color shade900;

  Color get defaultColor => shade500;

  static AppColor lerp(AppColor a, AppColor b, double t) {
    return AppColor(
      shade200: Color.lerp(a.shade200, b.shade200, t)!,
      shade300: Color.lerp(a.shade300, b.shade300, t)!,
      shade400: Color.lerp(a.shade400, b.shade400, t)!,
      shade500: Color.lerp(a.shade500, b.shade500, t)!,
      shade600: Color.lerp(a.shade600, b.shade600, t)!,
      shade700: Color.lerp(a.shade700, b.shade700, t)!,
      shade800: Color.lerp(a.shade800, b.shade800, t)!,
      shade900: Color.lerp(a.shade900, b.shade900, t)!,
    );
  }
}

class _BlueJayColors extends AppColor {
  const _BlueJayColors()
      : super(
          shade200: const Color(0xFFE1EDFE),
          shade300: const Color(0xFFC4DBFD),
          shade400: const Color(0xFF88B6FB),
          shade500: const Color(0xFF4D92F9),
          shade600: const Color(0xFF126EF8),
          shade700: const Color(0xFF0653C6),
          shade800: const Color(0xFF032E6D),
          shade900: const Color(0xFF021531),
        );
}

class _CarissmaColors extends AppColor {
  const _CarissmaColors()
      : super(
          shade200: const Color(0xFFFCEDF1),
          shade300: const Color(0xFFF9DCE3),
          shade400: const Color(0xFFF4B9C8),
          shade500: const Color(0xFFEB849E),
          shade600: const Color(0xFFE25074),
          shade700: const Color(0xFFD3224F),
          shade800: const Color(0xFF9E1A3B),
          shade900: const Color(0xFF691127),
        );
}

final lightTheme = ThemeData.light().copyWith(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: AppColorPalette.blueJay.defaultColor,
  ),
  appBarTheme: ThemeData.light().appBarTheme.copyWith(
        centerTitle: false,
      ),
);

final darkTheme = ThemeData.dark().copyWith(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: AppColorPalette.blueJay.defaultColor,
  ),
  appBarTheme: ThemeData.light().appBarTheme.copyWith(
        centerTitle: false,
      ),
);
