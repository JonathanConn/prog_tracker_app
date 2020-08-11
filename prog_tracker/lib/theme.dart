import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


final ThemeData baseData = ThemeData.dark();
final TextTheme baseText = GoogleFonts.robotoTextTheme();

ThemeData basicTextTheme() {
  TextTheme basicText(TextTheme textBase) {
    return textBase.copyWith(
      headline1: textBase.headline1.copyWith(
        fontFamily: 'arial',
        fontSize: 20.0,
        color: Colors.orange
      ),
      bodyText1: textBase.bodyText1.copyWith(
        fontSize: 8,
        color: Colors.cyan
      )
    );
  }
  
  return baseData.copyWith(
    textTheme: basicText(baseText),
    primaryColor: Colors.cyan,
  );

}