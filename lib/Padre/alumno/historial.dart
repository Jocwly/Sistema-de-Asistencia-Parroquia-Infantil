import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MiHistorial extends StatelessWidget {
  const MiHistorial({super.key});

  static const routeName = '/mi-historial';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mi Historial',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 26,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('asistencias')
            .where(
              'uidAlumno',
              isEqualTo: FirebaseAuth.instance.currentUser!.uid,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Aún no hay asistencias registradas'),
            );
          }

          final asistencias = snapshot.data!.docs.where((documento) {
            final data = documento.data() as Map<String, dynamic>;

            if (data['fecha'] == null || data['fecha'] is! Timestamp) {
              return false;
            }

            final fecha = (data['fecha'] as Timestamp).toDate();

            // Mostrar únicamente domingos
            return fecha.weekday == DateTime.sunday;
          }).toList();

          asistencias.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;

            final fechaA = (dataA['fecha'] as Timestamp).toDate();
            final fechaB = (dataB['fecha'] as Timestamp).toDate();

            return fechaB.compareTo(fechaA);
          });

          if (asistencias.isEmpty) {
            return const Center(
              child: Text('No hay misas dominicales registradas'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: asistencias.length,
            itemBuilder: (context, index) {
              final data = asistencias[index].data() as Map<String, dynamic>;

              final DateTime fecha = (data['fecha'] as Timestamp).toDate();

              final String grupo = data['grupo']?.toString() ?? 'Sin grupo';

              final String? fotoAntes = data['fotoAntesUrl']?.toString();

              final String? fotoDurante = data['fotoDuranteUrl']?.toString();

              final String? fotoFinal = data['fotoDespuesUrl']?.toString();

              final bool tieneAntes = fotoAntes != null && fotoAntes.isNotEmpty;

              final bool tieneDurante =
                  fotoDurante != null && fotoDurante.isNotEmpty;

              final bool tieneFinal = fotoFinal != null && fotoFinal.isNotEmpty;

              final bool completa = tieneAntes && tieneDurante && tieneFinal;

              return _HistorialCard(
                fecha: fecha,
                grupo: grupo,
                completa: completa,
                antes: tieneAntes,
                durante: tieneDurante,
                finalMisa: tieneFinal,
                horaAntes: data['horaAntes']?.toString() ?? '',
                horaDurante: data['horaDurante']?.toString() ?? '',
                horaFinal: data['horaDespues']?.toString() ?? '',
              );
            },
          );
        },
      ),
    );
  }
}

class _HistorialCard extends StatelessWidget {
  final DateTime fecha;
  final String grupo;
  final bool completa;
  final bool antes;
  final bool durante;
  final bool finalMisa;
  final String horaAntes;
  final String horaDurante;
  final String horaFinal;

  const _HistorialCard({
    required this.fecha,
    required this.grupo,
    required this.completa,
    required this.antes,
    required this.durante,
    required this.finalMisa,
    required this.horaAntes,
    required this.horaDurante,
    required this.horaFinal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffFFD600)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatearFecha(fecha),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
              _EstadoBadge(completa: completa),
            ],
          ),

          const SizedBox(height: 2),

          Text(
            grupo,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _FotoStatusCard(activo: antes, hora: horaAntes, titulo: 'Antes'),
              _FotoStatusCard(
                activo: durante,
                hora: horaDurante,
                titulo: 'Durante',
              ),
              _FotoStatusCard(
                activo: finalMisa,
                hora: horaFinal,
                titulo: 'Final',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    const dias = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo',
    ];

    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    return '${dias[fecha.weekday - 1]}, ${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}';
  }
}

class _EstadoBadge extends StatelessWidget {
  final bool completa;

  const _EstadoBadge({required this.completa});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: completa ? const Color(0xffD6F8E6) : const Color(0xffFFF1C7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            completa ? Icons.check_circle_outline : Icons.info_outline,
            size: 13,
            color: completa ? const Color(0xff00A86B) : const Color(0xffE6A500),
          ),
          const SizedBox(width: 3),
          Text(
            completa ? 'Completa' : 'Parcial',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: completa
                  ? const Color(0xff00A86B)
                  : const Color(0xffE6A500),
            ),
          ),
        ],
      ),
    );
  }
}

class _FotoStatusCard extends StatelessWidget {
  final bool activo;
  final String hora;
  final String titulo;

  const _FotoStatusCard({
    required this.activo,
    required this.hora,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 58,
      decoration: BoxDecoration(
        color: activo ? const Color(0xffFFE600) : const Color(0xffFFF8C4),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            activo ? Icons.check_circle_outline : Icons.cancel_outlined,
            size: 15,
            color: const Color(0xffF4B400),
          ),
          const SizedBox(height: 2),
          Text(
            hora.isEmpty ? '--:--' : hora,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xffE6A500),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            titulo,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
