import 'package:cloud_firestore/cloud_firestore.dart';

class MisaProgramada {
  final bool existe;
  final bool esDomingo;
  final String? misaId;
  final String nombre;

  const MisaProgramada({
    required this.existe,
    required this.esDomingo,
    required this.nombre,
    this.misaId,
  });
}

class MisasService {
  static final CollectionReference<Map<String, dynamic>> _misasRef =
      FirebaseFirestore.instance.collection('misas_especiales');

  /// Verifica si en la fecha indicada existe una misa programada.
  ///
  /// Una misa puede ser:
  /// - Dominical: cualquier domingo.
  /// - Especial: registrada por el administrador en Firestore.
  static Future<MisaProgramada> obtenerMisaProgramada(DateTime fecha) async {
    final dia = DateTime(fecha.year, fecha.month, fecha.day);

    // Todos los domingos tienen misa automáticamente.
    if (dia.weekday == DateTime.sunday) {
      return const MisaProgramada(
        existe: true,
        esDomingo: true,
        nombre: 'Misa dominical',
      );
    }

    final diaSiguiente = dia.add(const Duration(days: 1));

    final resultado = await _misasRef
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(dia))
        .where('fecha', isLessThan: Timestamp.fromDate(diaSiguiente))
        .limit(1)
        .get();

    if (resultado.docs.isEmpty) {
      return const MisaProgramada(existe: false, esDomingo: false, nombre: '');
    }

    final documento = resultado.docs.first;
    final datos = documento.data();

    final nombre = datos['nombre']?.toString().trim();

    return MisaProgramada(
      existe: true,
      esDomingo: false,
      misaId: documento.id,
      nombre: nombre == null || nombre.isEmpty ? 'Misa especial' : nombre,
    );
  }

  static Future<bool> puedeRegistrarAsistenciaHoy() async {
    final misa = await obtenerMisaProgramada(DateTime.now());
    return misa.existe;
  }
}
