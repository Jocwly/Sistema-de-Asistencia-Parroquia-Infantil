import 'package:flutter/material.dart';

class InicioAdminStyles {
  InicioAdminStyles._();

  static const Color fondo = Color(0xFFFDFDFD);
  static const Color blanco = Colors.white;

  static const Color amarillo = Color(0xFFFFBE00);
  static const Color amarilloClaro = Color(0xFFFFF294);
  static const Color amarilloMuyClaro = Color(0xFFFFF8D7);

  static const Color naranja = Color(0xFFFF9500);

  // Un poco más negro
  static const Color textoPrincipal = Color(0xFF080808);

  static const Color textoSecundario = Color(0xFF777777);
  static const Color borde = Color(0xFFFFC107);

  static const Color verde = Color(0xFF30C99A);
  static const Color verdeClaro = Color(0xFFD6F8EC);

  static const Color naranjaEstado = Color(0xFFF5A623);
  static const Color naranjaEstadoClaro = Color(0xFFFFF1C7);

  static const Color rojo = Color(0xFFFF6B6B);
  static const Color rojoClaro = Color(0xFFFFDEDE);

  // Más espacio en la parte superior
  static const EdgeInsets paddingPantalla = EdgeInsets.fromLTRB(16, 30, 16, 16);

  static const TextStyle tituloPrincipal = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w900,
    color: textoPrincipal,
    height: 1.2,
  );

  static const TextStyle numeroContador = TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.w800,
    color: textoPrincipal,
  );

  static const TextStyle textoContador = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: textoPrincipal,
  );

  static const TextStyle textoBoton = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w900,
    color: textoPrincipal,
  );

  static const TextStyle tituloSeccion = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: textoPrincipal,
  );

  static const TextStyle nombreAlumno = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    color: textoPrincipal,
  );

  static const TextStyle informacionAlumno = TextStyle(
    fontSize: 8.5,
    fontWeight: FontWeight.w500,
    color: naranja,
  );

  static BoxDecoration contadorDecoration = BoxDecoration(
    color: amarilloClaro,
    borderRadius: BorderRadius.circular(13),
  );

  static BoxDecoration botonDecoration = BoxDecoration(
    color: amarillo,
    borderRadius: BorderRadius.circular(13),
  );

  static BoxDecoration recientesDecoration = BoxDecoration(
    color: blanco,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: borde, width: 1),
  );
}
