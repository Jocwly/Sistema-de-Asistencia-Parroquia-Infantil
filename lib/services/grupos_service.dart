import 'package:cloud_firestore/cloud_firestore.dart';

class GruposService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> obtenerGrupos() {
    return _db.collection('grupos').orderBy('grupo').snapshots();
  }

  Future<void> agregarGrupo({
    required String grupo,
    required String catequista,
  }) async {
    await _db.collection('grupos').add({
      'grupo': grupo,
      'catequista': catequista,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> obtenerAlumnosPorGrupo(
    String grupo,
  ) {
    return _db
        .collection('usuarios')
        .where('rol', isEqualTo: 'alumno')
        .where('grupo', isEqualTo: grupo)
        .snapshots();
  }
}