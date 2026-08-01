import 'package:flutter/material.dart';
import 'theme.dart';
import 'onboarding.dart';
class PrincessAiApp extends StatelessWidget {
  const PrincessAiApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Princess AI',
    theme: buildTheme(),
    home: const OnboardingScreen(),
  );
}
