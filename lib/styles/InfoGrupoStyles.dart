import 'package:flutter/material.dart';

class GruposStyles {
  static const Color backgroundColor = Colors.white;
  static const Color primaryYellow = Color(0xFFFFD400);
  static const Color softYellow = Color(0xFFFFF7CC);
  static const Color textDark = Color(0xFF111111);
  static const Color textGray = Color(0xFF777777);

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 16,
  );

  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    border: Border.all(color: primaryYellow, width: 1.4),
    borderRadius: BorderRadius.circular(14),
  );

  static BoxDecoration iconCircle = const BoxDecoration(
    color: softYellow,
    shape: BoxShape.circle,
  );

  static TextStyle title = const TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w900,
    color: textDark,
  );

  static TextStyle cardTitle = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w900,
    color: textDark,
  );

  static TextStyle normal = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textGray,
  );

  static TextStyle boldSmall = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: textDark,
  );

  static TextStyle studentName = const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w900,
    color: textDark,
  );

  static TextStyle studentAge = const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textGray,
  );
}