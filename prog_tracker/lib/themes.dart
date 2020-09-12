import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const MaterialColor globalColors =
    MaterialColor(0xFFFF0000, const <int, Color>{});

ThemeData globalDarkTheme() {
  return ThemeData.dark().copyWith(
    textTheme: GoogleFonts.robotoMonoTextTheme(),
    accentColor: Colors.orange,
    primaryColor: Colors.black,
  );
}
