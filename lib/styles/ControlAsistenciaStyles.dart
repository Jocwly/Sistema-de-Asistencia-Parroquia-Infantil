import 'package:flutter/material.dart';

class ControlAsistenciaStyles {
  ControlAsistenciaStyles._();

  static const Color amarillo = Color(0xFFFFC400);
  static const Color amarilloClaro = Color(0xFFFFF7C2);
  static const Color fondo = Color(0xFFF8F8F8);

  static const Color blanco = Colors.white;
  static const Color negro = Colors.black;
  static const Color negroSuave = Colors.black87;
  static const Color negroClaro = Colors.black54;
  static const Color gris = Colors.grey;
  static const Color error = Colors.redAccent;

  static const Color textoGrupo = Color(0xFF9B8500);
  static const Color textoContador = Color(0xFF857000);
  static const Color iconoEvidencia = Color(0xFFE1B600);
  static const Color etapaInactiva = Color(0xFFD5B000);

  static const Color estadoCompleto = Color(0xFF00AD7C);
  static const Color fondoEstadoCompleto = Color(0xFFD8F7EC);

  static const Color estadoIncompleto = Color.fromARGB(255, 229, 0, 0);
  static const Color fondoEstadoIncompleto = Color(0xFFFFE0E0);

  static const Color estadoParcial = Color(0xFFE5A100);
  static const Color fondoEstadoParcial = Color(0xFFFFF0C7);

  // =========================
  // ESPACIADOS
  // =========================

  static const EdgeInsets filtroPadding = EdgeInsets.fromLTRB(16, 12, 16, 10);

  static const EdgeInsets listaPadding = EdgeInsets.fromLTRB(16, 8, 16, 24);

  static const EdgeInsets tarjetaPadding = EdgeInsets.all(12);

  static const EdgeInsets mensajeErrorPadding = EdgeInsets.all(20);

  static const EdgeInsets campoHorizontalPadding = EdgeInsets.symmetric(
    horizontal: 12,
  );

  static const EdgeInsets buscadorContentPadding = EdgeInsets.symmetric(
    vertical: 12,
  );

  static const EdgeInsets estadoPadding = EdgeInsets.symmetric(
    horizontal: 7,
    vertical: 4,
  );

  // =========================
  // TAMAÑOS
  // =========================

  static const double alturaFiltro = 45;
  static const double radioCampo = 13;
  static const double radioTarjeta = 14;
  static const double radioEstado = 20;
  static const double radioEtapa = 20;
  static const double alturaEtapa = 25;
  static const double radioAvatar = 18;

  // =========================
  // ESTILOS DE TEXTO
  // =========================

  static const TextStyle tituloAppBar = TextStyle(
    color: negro,
    fontWeight: FontWeight.w800,
    fontSize: 22,
  );

  static const TextStyle textoBuscador = TextStyle(
    color: negroSuave,
    fontSize: 13,
  );

  static const TextStyle hintBuscador = TextStyle(color: gris, fontSize: 13);

  static const TextStyle textoDropdown = TextStyle(
    color: negroSuave,
    fontSize: 13,
  );

  static const TextStyle textoError = TextStyle(color: error);

  static const TextStyle textoSinResultados = TextStyle(color: gris);

  static const TextStyle textoContadorRegistros = TextStyle(
    color: textoContador,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle nombreAlumno = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle informacionGrupo = TextStyle(
    fontSize: 10,
    color: textoGrupo,
  );

  static const TextStyle fechaAlumno = TextStyle(
    fontSize: 9,
    color: negroClaro,
  );

  static const TextStyle inicialesAlumno = TextStyle(
    color: blanco,
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle textoEstado = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle textoEtapa = TextStyle(fontSize: 9);


  static InputDecoration buscadorDecoration({
    required bool mostrarBotonLimpiar,
    required VoidCallback onLimpiar,
  }) {
    return InputDecoration(
      hintText: 'Buscar alumno...',
      hintStyle: hintBuscador,
      prefixIcon: const Icon(Icons.search, color: amarillo, size: 20),
      suffixIcon: mostrarBotonLimpiar
          ? IconButton(
              onPressed: onLimpiar,
              icon: const Icon(Icons.close, size: 18),
            )
          : null,
      filled: true,
      fillColor: blanco,
      contentPadding: buscadorContentPadding,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radioCampo),
        borderSide: const BorderSide(color: amarillo),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radioCampo),
        borderSide: const BorderSide(color: amarillo, width: 1.5),
      ),
    );
  }

  static BoxDecoration filtroDecoration = BoxDecoration(
    color: blanco,
    borderRadius: BorderRadius.circular(radioCampo),
    border: Border.all(color: amarillo),
  );

  static BoxDecoration tarjetaDecoration = BoxDecoration(
    color: blanco,
    borderRadius: BorderRadius.circular(radioTarjeta),
    border: Border.all(color: amarillo, width: 1),
  );

  static BoxDecoration estadoDecoration({required bool completa}) {
    return BoxDecoration(
      color: completa ? fondoEstadoCompleto : fondoEstadoParcial,
      borderRadius: BorderRadius.circular(radioEstado),
    );
  }

  static BoxDecoration etapaDecoration({required bool activo}) {
    return BoxDecoration(
      color: activo ? amarillo.withValues(alpha: 0.80) : amarilloClaro,
      borderRadius: BorderRadius.circular(radioEtapa),
    );
  }

  static Color colorEstado(bool completa) {
    return completa ? estadoCompleto : estadoParcial;
  }

  static Color colorTextoFechaFiltro(bool tieneFecha) {
    return tieneFecha ? negroSuave : Colors.grey.shade600;
  }

  static Color colorEtapa(bool activo) {
    return activo ? blanco : etapaInactiva;
  }
}
