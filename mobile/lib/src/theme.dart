import 'package:flutter/material.dart';

import '../core/theme/princess_theme.dart';

export '../core/theme/princess_theme.dart';

// Short names kept for the existing src/ screens.
const ink = PrincessColors.ink;
const gold = PrincessColors.berry;
const cream = PrincessColors.canvas;
const rose = PrincessColors.berryTint;
const border = PrincessColors.border;

ThemeData buildTheme() => PrincessTheme.light();
