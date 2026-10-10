import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'typing/view/typing_screen.dart';

void main() {
  runApp(const FastFingersApp());
}

class FastFingersApp extends StatelessWidget {
  const FastFingersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fast Fingers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
        extensions: const [AppColors.dark],
      ),
      home: const TypingScreen(),
    );
  }
}
