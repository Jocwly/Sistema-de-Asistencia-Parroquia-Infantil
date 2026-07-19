import 'package:flutter/material.dart';

class LoginStyles {
  // Colores
  static Color get primaryColor => Colors.yellow.shade700;
  static const Color buttonTextColor = Colors.black;
  static const Color errorColor = Colors.redAccent;
  static const Color backgroundColor = Color.fromARGB(255, 255, 255, 255);

  // Espaciados
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: 28,
    vertical: 40,
  );

  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(vertical: 18);

  // Tamaños
  static const double logoSize = 100;
  static const double titleSpacing = 20;
  static const double sectionSpacing = 48;
  static const double fieldSpacing = 16;

  // Bordes
  static const OutlineInputBorder inputBorder = OutlineInputBorder();

  // Icono principal
  static Icon logoIcon() {
    return Icon(Icons.church_outlined, size: logoSize, color: primaryColor);
  }

  // Estilo del botón
  static ButtonStyle loginButtonStyle() {
    return FilledButton.styleFrom(
      backgroundColor: primaryColor,
      padding: buttonPadding,
    );
  }

  // Texto del botón
  static const TextStyle buttonText = TextStyle(
    color: buttonTextColor,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  // Título
  static TextStyle? titleStyle(BuildContext context) {
    return Theme.of(
      context,
    ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold);
  }
}
