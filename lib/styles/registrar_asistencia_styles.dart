import 'package:flutter/material.dart';

class RegistrarAsistenciaStyles {
  static const Color primaryColor = Color(0xFFFFD000);
  static const Color backgroundColor = Color.fromARGB(255, 255, 255, 255);
  static const Color headerColor = Colors.white;
  static const Color borderColor = Color(0xFFFFCC00);
  static const Color lightYellow = Color(0xFFFFF6C7);
  static const Color progressBackground = Color(0xFFFFF4B8);
  static const Color textColor = Color(0xFF111111);
  static const Color secondaryTextColor = Color(0xFF6C6C3A);

  static const EdgeInsets screenPadding = EdgeInsets.fromLTRB(10, 6, 10, 12);

  static const EdgeInsets progressPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 10,
  );

  static const EdgeInsets photoCardPadding = EdgeInsets.fromLTRB(
    12,
    10,
    12,
    10,
  );

  static BoxDecoration get cardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(13),
    border: Border.all(color: borderColor, width: 1.4),
  );

  static BoxDecoration get backButtonDecoration => BoxDecoration(
    color: Colors.white,
    border: Border.all(color: Colors.blue, width: 2),
  );

  static BoxDecoration get photoBoxDecoration => BoxDecoration(
    color: backgroundColor,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Color(0xFFFFE58A), width: 1),
  );

  static const TextStyle headerTitle = TextStyle(
    fontSize: 23,
    fontWeight: FontWeight.w900,
    color: textColor,
  );

  static const TextStyle progressTitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: textColor,
  );

  static const TextStyle progressCounter = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w900,
    color: primaryColor,
  );

  static const TextStyle dateText = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w500,
    color: secondaryTextColor,
  );

  static const TextStyle cardEmoji = TextStyle(fontSize: 17);

  static const TextStyle photoTitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w900,
    color: textColor,
  );

  static const TextStyle photoDescription = TextStyle(
    fontSize: 8.5,
    fontWeight: FontWeight.w500,
    color: secondaryTextColor,
  );

  static const TextStyle photoEmoji = TextStyle(fontSize: 22);

  static const TextStyle photoBoxText = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    color: secondaryTextColor,
  );

  static ButtonStyle get enabledButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.black,
    disabledBackgroundColor: lightYellow,
    disabledForegroundColor: secondaryTextColor,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
  );

  static ButtonStyle get disabledButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: lightYellow,
    foregroundColor: secondaryTextColor,
    disabledBackgroundColor: lightYellow,
    disabledForegroundColor: secondaryTextColor,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
  );
}
