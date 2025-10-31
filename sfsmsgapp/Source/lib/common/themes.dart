import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

// commons properties
const xPrimaryColor = Color(0xFF5e72e4);
const xBackgroundColor = Color(0xFFFFFFFF);
const xBackgroundColorDark = Color(0xFF242526);
const xTextColor = Color(0xFF111111);
const xTextColorDark = Color(0xFFD1D1D1);
const xTextLinkColor = Color(0xFF5e72e4);
const xButtonPrimaryColor = Color(0xFF5e72e4);

// app theme
ThemeData appTheme({bool isDark = false, BuildContext? context}) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: xPrimaryColor,
      brightness: isDark ? Brightness.dark : Brightness.light,
    ),
    fontFamily: context?.locale == const Locale('ar', 'SA') ? "Tajawal" : "Poppins",
    scaffoldBackgroundColor: isDark ? xBackgroundColorDark : xBackgroundColor,
    textTheme: textTheme(isDark: isDark, context: context),
    appBarTheme: appBarTheme(isDark: isDark, context: context),
    inputDecorationTheme: inputDecorationTheme(isDark: isDark, context: context),
    textButtonTheme: textButtonTheme(isDark: isDark, context: context),
    elevatedButtonTheme: elevatedButtonTheme(isDark: isDark, context: context),
    outlinedButtonTheme: outlinedButtonTheme(isDark: isDark, context: context),
    progressIndicatorTheme: progressIndicatorTheme(isDark: isDark, context: context),
  );
}

// app bar theme
AppBarTheme appBarTheme({bool isDark = false, BuildContext? context}) {
  return AppBarTheme().copyWith(
    color: isDark ? xBackgroundColorDark : xBackgroundColor,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontFamily: context?.locale == const Locale('ar', 'SA') ? "Tajawal" : "Quicksand",
      fontSize: 24,
      color: isDark ? xTextColorDark : xTextColor,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(
      color: isDark ? xTextColorDark : xTextColor,
      size: 24,
    ),
  );
}

// text theme
TextTheme textTheme({bool isDark = false, BuildContext? context}) {
  return TextTheme().copyWith(
    bodyLarge: TextStyle(
      color: isDark ? xTextColorDark : xTextColor,
    ),
    bodyMedium: TextStyle(
      color: isDark ? xTextColorDark : xTextColor,
    ),
    bodySmall: TextStyle(
      color: isDark ? xTextColorDark : xTextColor,
    ),
    titleSmall: TextStyle(
      color: isDark ? xTextColorDark : xTextColor,
    ),
    titleMedium: TextStyle(
      color: isDark ? xTextColorDark : xTextColor,
    ),
    titleLarge: TextStyle(
      color: isDark ? xTextColorDark : xTextColor,
      fontWeight: FontWeight.bold,
    ),
  );
}

// input decoration theme
InputDecorationTheme inputDecorationTheme({bool isDark = false, BuildContext? context}) {
  var outlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(
      color: Color(0xFFB0B0B0),
    ),
    gapPadding: 10,
  );

  var outlineInputErrorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(
      color: Color(0xFFB91E1E),
    ),
    gapPadding: 10,
  );

  return InputDecorationTheme(
    floatingLabelBehavior: FloatingLabelBehavior.never,
    contentPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
    hintStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.normal,
    ),
    labelStyle: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.normal,
    ),
    focusColor: xTextLinkColor,
    enabledBorder: outlineInputBorder,
    focusedBorder: outlineInputBorder,
    errorBorder: outlineInputErrorBorder,
    focusedErrorBorder: outlineInputErrorBorder,
  );
}

// text button theme
TextButtonThemeData textButtonTheme({bool isDark = false, BuildContext? context}) {
  return TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: xTextLinkColor,
      textStyle: TextStyle(
        fontFamily: context?.locale == const Locale('ar', 'SA') ? "Tajawal" : "Quicksand",
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

// elevated button theme
ElevatedButtonThemeData elevatedButtonTheme({bool isDark = false, BuildContext? context}) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: xButtonPrimaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      textStyle: TextStyle(
        fontFamily: context?.locale == const Locale('ar', 'SA') ? "Tajawal" : "Quicksand",
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

// outlined button theme
OutlinedButtonThemeData outlinedButtonTheme({bool isDark = false, BuildContext? context}) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: (isDark) ? xTextColorDark : xTextColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
      textStyle: TextStyle(
        fontFamily: context?.locale == const Locale('ar', 'SA') ? "Tajawal" : "Quicksand",
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

// progress indicator theme
ProgressIndicatorThemeData progressIndicatorTheme({bool isDark = false, BuildContext? context}) {
  return ProgressIndicatorThemeData(
    color: xPrimaryColor,
  );
}
