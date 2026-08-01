import 'package:flutter/material.dart';
const ink = Color(0xFF171717);
const gold = Color(0xFFC8A96A);
const beige = Color(0xFFEFE7DD);
ThemeData buildTheme() => ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFFFAF8F6),
  colorScheme: ColorScheme.fromSeed(seedColor: gold),
  filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
    backgroundColor: ink, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(54),
  )),
  cardTheme: const CardThemeData(color: Colors.white, elevation: 0),
  inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
);
