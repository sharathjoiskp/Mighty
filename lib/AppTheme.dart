import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mightystore/utils/colors.dart';
import 'package:mightystore/main.dart';
import 'package:nb_utils/nb_utils.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: backgroundColor,
    primaryColor: primaryColor,
    accentColor: colorAccent,
    errorColor: Colors.red,
    hoverColor: Colors.grey,
    fontFamily: GoogleFonts.poppins().fontFamily,
    appBarTheme: AppBarTheme(
      color: primaryColor,
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    cardColor: backgroundColor,
    colorScheme: ColorScheme.light(
        primary: primaryColor!,
        onPrimary: colorAccent!,
        surface: Colors.white,
        secondary: colorAccent!,
        background: itemBackgroundColor),
    cardTheme: CardTheme(
      color: Colors.white,
    ),
    iconTheme: IconThemeData(
      color: textPrimaryColour,
    ),
    textTheme: TextTheme(
      headline4: TextStyle(
        color: Color(0xFFF6F8FB),
      ),
      bodyText1: TextStyle(
        color: primaryColor,
      ),
      subtitle1: TextStyle(
        color: textSecondaryColour,
      ),
      subtitle2: TextStyle(
        color: textPrimaryColour,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: Color(0xFF131d25),
    errorColor: Color(0xFFCF6676),
    appBarTheme: AppBarTheme(
      color: primaryColor,
      iconTheme: IconThemeData(
        color: Color(0xFF1D2939),
      ),
    ),
    cardColor: Color(0xFF1D2939),
    primaryColor: primaryColor,
    accentColor: white,
    hoverColor: Colors.black,
    fontFamily:  GoogleFonts.poppins().fontFamily,
    colorScheme: ColorScheme.light(
        background: Color(0xFF1D2939),
        primary: Color(0xFF131d25),
        onPrimary: Color(0xFF1D2939),
        surface: Color(0xFF1D2939),
        onSecondary: Colors.white),
    cardTheme: CardTheme(
      color: Color(0xFF1D2939),
    ),
    iconTheme: IconThemeData(
      color: Colors.white70,
    ),
    textTheme: TextTheme(
      headline4: TextStyle(
        color: Color(0xFF1D2939),
      ),
      bodyText1: TextStyle(
        color: Colors.white70,
      ),
      subtitle1: TextStyle(
        color: Colors.white70,
      ),
      subtitle2: TextStyle(
        color: Colors.white54,
      ),
    ),
  );
}
