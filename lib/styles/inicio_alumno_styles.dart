import 'package:flutter/material.dart';

class InicioAlumnoStyles {
  // Colores principales
  static const Color backgroundColor = Color.fromARGB(
    255,
    255,
    255,
    255,
  ); //Color(0xFFF9F9F9);
  static const Color primaryYellow = Color(0xFFFFC400);
  static const Color lightYellow = Color(0xFFFFF08A);
  static const Color borderYellow = Color(0xFFFFC400);

  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF666666);

  static const Color completeBackground = Color(0xFFD9F9E8);
  static const Color completeText = Color(0xFF28A76F);

  static const Color partialBackground = Color(0xFFFFF2D6);
  static const Color partialText = Color(0xFFD99A00);

  static const Color dividerColor = Color(0xFFE9E9E9);

  // Espaciados
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 8,
  );

  static const EdgeInsets cardPadding = EdgeInsets.symmetric(
    horizontal: 18,
    vertical: 22,
  );

  // Textos
  static const TextStyle logoText = TextStyle(
    fontSize: 23,
    fontWeight: FontWeight.w900,
    color: textPrimary,
  );

  static const TextStyle welcomeText = TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.w900,
    color: textPrimary,
  );

  static const TextStyle sundayTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: textPrimary,
  );

  static const TextStyle sundaySubtitle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static const TextStyle statisticNumber = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: textPrimary,
  );

  static const TextStyle statisticLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    color: textPrimary,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w900,
    color: textPrimary,
  );

  static const TextStyle attendanceDate = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: textPrimary,
  );

  static const TextStyle attendancePhotos = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static const TextStyle bottomNavigationText = TextStyle(
    fontSize: 8,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  // Decoraciones
  static BoxDecoration get sundayCardDecoration {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: borderYellow, width: 1.2),
    );
  }

  static BoxDecoration get statisticsCardDecoration {
    return BoxDecoration(
      color: lightYellow,
      borderRadius: BorderRadius.circular(12),
    );
  }

  static BoxDecoration get recentAttendanceDecoration {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: borderYellow, width: 1),
    );
  }

  static BoxDecoration get navigationIconDecoration {
    return BoxDecoration(
      color: primaryYellow,
      borderRadius: BorderRadius.circular(8),
    );
  }

  static BoxDecoration get completeStatusDecoration {
    return BoxDecoration(
      color: completeBackground,
      borderRadius: BorderRadius.circular(12),
    );
  }

  static BoxDecoration get partialStatusDecoration {
    return BoxDecoration(
      color: partialBackground,
      borderRadius: BorderRadius.circular(12),
    );
  }
}
