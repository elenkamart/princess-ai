import 'package:flutter/material.dart';

import '../core/theme/princess_theme.dart';

export '../core/theme/princess_theme.dart';

class AppTheme {
  AppTheme._();

  static const Color primary = PrincessColors.ink;
  static const Color background = PrincessColors.canvas;
  static const Color accent = PrincessColors.berry;

  static ThemeData get lightTheme => PrincessTheme.light();
}
