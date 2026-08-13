import 'package:flutter/material.dart';

class GenerarReportesStyles {
  GenerarReportesStyles._();


  static const Color backgroundColor = Color(0xFFF8F8F8);
  static const Color cardColor = Colors.white;

  static const Color amarillo = Color(0xFFFFC800);
  static const Color amarilloBorde = Color(0xFFFFC400);
  static const Color amarilloSuave = Color(0xFFFFF5BF);

  static const Color grisTexto = Color(0xFF858585);
  static const Color grisClaro = Color(0xFFF9F9F9);
  static const Color grisBorde = Color(0xFFE5E5E5);

  static const Color verdeSuave = Color(0xFFC9F4DF);
  static const Color verdeTexto = Color(0xFF168A52);

  static const Color naranjaSuave = Color(0xFFFFF1C6);
  static const Color naranjaTexto = Color(0xFFFF5722);

  static const Color rojoSuave = Color(0xFFFFDCDC);
  static const Color rojoTexto = Color(0xFFFF2222);


  static const double radioTarjeta = 15;
  static const double radioCampo = 14;
  static const double radioBoton = 14;

  static const double alturaCampo = 48;
  static const double alturaBoton = 48;


  static const EdgeInsets screenPadding = EdgeInsets.fromLTRB(16, 18, 16, 20);

  static const EdgeInsets configuracionPadding = EdgeInsets.fromLTRB(
    18,
    16,
    18,
    18,
  );

  static const EdgeInsets resumenPadding = EdgeInsets.fromLTRB(12, 12, 12, 14);

  static const EdgeInsets registroPadding = EdgeInsets.all(10);

  

  static const TextStyle appBarTitle = TextStyle(
    color: Colors.black,
    fontSize: 26,
    fontWeight: FontWeight.w800,
  );


  static const TextStyle sectionTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle fieldLabel = TextStyle(
    color: grisTexto,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle fieldText = TextStyle(color: grisTexto, fontSize: 14);

  static const TextStyle buttonText = TextStyle(
    color: Colors.black,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle resumenTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle resumenSubtitle = TextStyle(
    fontSize: 11,
    color: Colors.grey,
  );

  static const TextStyle registroNombre = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle registroInfo = TextStyle(
    fontSize: 11,
    color: Colors.black54,
  );

  

  static BoxDecoration get configuracionDecoration {
    return BoxDecoration(
      color: cardColor,
      border: Border.all(color: amarilloBorde, width: 1.2),
      borderRadius: BorderRadius.circular(radioTarjeta),
    );
  }

  static BoxDecoration get resumenDecoration {
    return BoxDecoration(
      color: cardColor,
      border: Border.all(color: amarilloBorde),
      borderRadius: BorderRadius.circular(radioTarjeta),
    );
  }

  static BoxDecoration get registroDecoration {
    return BoxDecoration(
      color: grisClaro,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: grisBorde),
    );
  }


  static InputDecoration dropdownDecoration() {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radioCampo),
        borderSide: const BorderSide(color: amarilloBorde, width: 1.2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radioCampo),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radioCampo),
        borderSide: const BorderSide(color: amarilloBorde, width: 1.8),
      ),
    );
  }



  static ButtonStyle get generarButtonStyle {
    return ElevatedButton.styleFrom(
      backgroundColor: amarillo,
      disabledBackgroundColor: const Color(0xFFFFE582),
      foregroundColor: Colors.black,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radioBoton),
      ),
    );
  }

  static ButtonStyle get pdfButtonStyle {
    return ElevatedButton.styleFrom(
      backgroundColor: amarillo,
      disabledBackgroundColor: Colors.grey.shade300,
      foregroundColor: Colors.black,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
