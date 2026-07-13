import 'package:flutter/material.dart';

class CalendarioAdminStyles {
  CalendarioAdminStyles._();

  // Colores principales
  static const Color backgroundColor = Colors.white;
  static const Color amarillo = Color(0xFFFFD814);
  static const Color amarilloClaro = Color(0xFFFFF7C7);
  static const Color borde = Color(0xFFFFC400);
  static const Color textoDorado = Color(0xFFB08A00);
  static const Color textoDomingo = Color(0xFFD29E00);
  static const Color iconoMes = Color(0xFFD3A500);
  static const Color fondoCampo = Color(0xFFFFFDF2);
  static const Color fondoMisa = Color(0xFFFFFBE8);
  static const Color textoInformativo = Color(0xFF9A7B00);

  // Espaciados
  static const EdgeInsets screenPadding = EdgeInsets.all(12);
  static const EdgeInsets leyendaPadding = EdgeInsets.all(12);

  static const EdgeInsets calendarioPadding = EdgeInsets.fromLTRB(
    12,
    12,
    12,
    16,
  );

  static const EdgeInsets misasPadding = EdgeInsets.all(14);
  static const EdgeInsets misaItemPadding = EdgeInsets.all(10);

  // Radios
  static const double cardRadius = 15;
  static const double dialogRadius = 18;
  static const double inputRadius = 14;
  static const double misaItemRadius = 12;

  // Tamaños
  static const double botonMesSize = 38;
  static const double diaSize = 38;
  static const double indicadorLeyendaSize = 17;
  static const double numeroMisaSize = 35;
  static const double contadorSize = 20;

  // Bordes
  static Border cardBorder = Border.all(color: borde);

  static Border misaEspecialBorder = Border.all(color: borde, width: 1.5);

  // Decoraciones
  static BoxDecoration get cardDecoration {
    return BoxDecoration(
      color: backgroundColor,
      border: cardBorder,
      borderRadius: BorderRadius.circular(cardRadius),
    );
  }

  static BoxDecoration get leyendaDecoration {
    return BoxDecoration(
      border: cardBorder,
      borderRadius: BorderRadius.circular(cardRadius),
    );
  }

  static BoxDecoration get misaItemDecoration {
    return BoxDecoration(
      color: fondoMisa,
      borderRadius: BorderRadius.circular(misaItemRadius),
    );
  }

  static BoxDecoration get contadorDecoration {
    return const BoxDecoration(color: amarilloClaro, shape: BoxShape.circle);
  }

  static BoxDecoration numeroMisaDecoration() {
    return BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: borde),
    );
  }

  static BoxDecoration diaDecoration({
    required bool esDomingo,
    required bool esEspecial,
  }) {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: esDomingo ? amarillo : backgroundColor,
      border: esEspecial && !esDomingo ? misaEspecialBorder : null,
    );
  }

  static BoxDecoration indicadorLeyendaDecoration({
    required Color color,
    required bool relleno,
  }) {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: relleno ? color : backgroundColor,
      border: Border.all(color: color, width: 1.5),
    );
  }

  // Estilos de texto
  static const TextStyle appBarTitle = TextStyle(fontWeight: FontWeight.bold);

  static const TextStyle dialogTitle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  static const TextStyle dialogDate = TextStyle(
    color: Colors.black54,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle leyendaText = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle leyendaDescription = TextStyle(
    fontSize: 11,
    color: textoInformativo,
  );

  static const TextStyle monthTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle specialMassTitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle counterText = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: textoDorado,
  );

  static const TextStyle emptyMassText = TextStyle(
    fontSize: 12,
    color: textoDorado,
  );

  static const TextStyle massNameText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static TextStyle weekDayText({required bool esDomingo}) {
    return TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      color: esDomingo ? textoDomingo : Colors.black87,
    );
  }

  static TextStyle dayText({
    required bool esDomingo,
    required bool esEspecial,
  }) {
    return TextStyle(
      fontSize: 12,
      fontWeight: esDomingo || esEspecial ? FontWeight.bold : FontWeight.w500,
      color: Colors.black,
    );
  }

  // Estilos de componentes
  static InputDecoration massInputDecoration() {
    return InputDecoration(
      labelText: 'Nombre de la misa',
      hintText: 'Ej. Misa de confirmaciones',
      filled: true,
      fillColor: fondoCampo,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: const BorderSide(color: borde, width: 2),
      ),
    );
  }

  static ButtonStyle get saveButtonStyle {
    return ElevatedButton.styleFrom(
      backgroundColor: amarillo,
      foregroundColor: Colors.black,
      elevation: 0,
    );
  }

  static RoundedRectangleBorder get dialogShape {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(dialogRadius),
    );
  }
}
