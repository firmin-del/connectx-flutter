import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData.light().copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 180, 34, 63),
      primary: const Color.fromARGB(255, 180, 34, 63),
    ),
    scaffoldBackgroundColor: const Color(0xFFFCFCFC),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFCFCFC),
      elevation: 1,
    ),
    textTheme: GoogleFonts.questrialTextTheme(),
  );

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 180, 34, 63),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
  );
}