import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Calendario extends StatefulWidget {
  const Calendario({super.key});

  static const routeName = '/calendario';

  @override
  State<Calendario> createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  DateTime selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  final CollectionReference<Map<String, dynamic>> _misasEspecialesRef =
      FirebaseFirestore.instance.collection('misas_especiales');

  List<DateTime> _getDomingosDelMes(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    final domingos = <DateTime>[];

    for (int i = 0; i < lastDay.day; i++) {
      final date = firstDay.add(Duration(days: i));

      if (date.weekday == DateTime.sunday) {
        domingos.add(date);
      }
    }

    return domingos;
  }

  String _fechaId(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<String> _obtenerEstadoMisa(DateTime date) async {
    final doc = await FirebaseFirestore.instance
        .collection('asistencias')
        .doc(_fechaId(date))
        .get();

    if (!doc.exists) {
      return 'Pendiente';
    }

    final data = doc.data()!;

    final fotos =
        [
          data['fotoAntesUrl'],
          data['fotoDuranteUrl'],
          data['fotoDespuesUrl'],
        ].where((foto) {
          return foto != null && foto.toString().trim().isNotEmpty;
        }).length;

    if (fotos == 3) {
      return 'Completa';
    }

    if (fotos > 0) {
      return 'Parcial';
    }

    return 'Pendiente';
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _obtenerMisasEspecialesDelMes() {
    final inicioMes = DateTime(selectedMonth.year, selectedMonth.month, 1);

    final inicioMesSiguiente = DateTime(
      selectedMonth.year,
      selectedMonth.month + 1,
      1,
    );

    return _misasEspecialesRef
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioMes))
        .where('fecha', isLessThan: Timestamp.fromDate(inicioMesSiguiente))
        .orderBy('fecha')
        .snapshots();
  }

  List<EventoMisa> _crearEventosDelMes(List<MisaEspecial> misasEspeciales) {
    final domingos = _getDomingosDelMes(selectedMonth);

    final eventos = <EventoMisa>[];

    // Agrega los domingos automáticamente.
    for (final domingo in domingos) {
      eventos.add(
        EventoMisa(
          fecha: domingo,
          titulo: '${domingo.day} ${_nombreMesCorto(domingo.month)}',
          descripcion: 'Misa dominical',
          esEspecial: false,
        ),
      );
    }

    // Agrega las misas especiales registradas por el administrador.
    for (final misa in misasEspeciales) {
      eventos.add(
        EventoMisa(
          fecha: misa.fecha,
          titulo: misa.nombre,
          descripcion: '${misa.fecha.day} ${_nombreMesCorto(misa.fecha.month)}',
          esEspecial: true,
        ),
      );
    }

    // Ordena todo por fecha.
    eventos.sort((a, b) {
      final comparacionFecha = a.fecha.compareTo(b.fecha);

      if (comparacionFecha != 0) {
        return comparacionFecha;
      }
      if (a.esEspecial == b.esEspecial) {
        return 0;
      }

      return a.esEspecial ? 1 : -1;
    });

    return eventos;
  }

  void _mesAnterior() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
    });
  }

  void _mesSiguiente() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
    });
  }

  String _nombreMes(int month) {
    const meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    return meses[month - 1];
  }

  String _nombreMesCorto(int month) {
    const meses = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];

    return meses[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Calendario',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        key: ValueKey('${selectedMonth.year}-${selectedMonth.month}'),
        stream: _obtenerMisasEspecialesDelMes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudieron cargar las misas especiales.\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final misasEspeciales =
              snapshot.data?.docs.map((doc) {
                return MisaEspecial.fromDocument(doc);
              }).toList() ??
              [];

          final eventos = _crearEventosDelMes(misasEspeciales);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.amber),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _botonMes(Icons.chevron_left, _mesAnterior),
                            Expanded(
                              child: Text(
                                '${_nombreMes(selectedMonth.month)} '
                                'de ${selectedMonth.year}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            _botonMes(Icons.chevron_right, _mesSiguiente),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: eventos.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No hay misas programadas para este mes.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: eventos.length,
                                  itemBuilder: (context, index) {
                                    final evento = eventos[index];

                                    return FutureBuilder<String>(
                                      key: ValueKey(
                                        '${_fechaId(evento.fecha)}-'
                                        '${evento.esEspecial}-'
                                        '${evento.titulo}',
                                      ),
                                      future: _obtenerEstadoMisa(evento.fecha),
                                      builder: (context, estadoSnapshot) {
                                        final estado =
                                            estadoSnapshot.data ?? 'Pendiente';

                                        return _MisaCard(
                                          dia: evento.fecha.day,
                                          titulo: evento.titulo,
                                          subtitulo: evento.descripcion,
                                          estado: estado,
                                          esEspecial: evento.esEspecial,
                                        );
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.amber),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, color: Colors.amber, size: 14),
                      SizedBox(width: 6),
                      Text('Domingo', style: TextStyle(fontSize: 11)),
                      SizedBox(width: 20),
                      Icon(Icons.star, color: Colors.amber, size: 14),
                      SizedBox(width: 6),
                      Text('Misa especial', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _botonMes(IconData icon, VoidCallback onTap) {
    return CircleAvatar(
      backgroundColor: Colors.amber.shade100,
      child: IconButton(
        icon: Icon(icon, color: Colors.amber.shade800),
        onPressed: onTap,
      ),
    );
  }
}

class _MisaCard extends StatelessWidget {
  final int dia;
  final String titulo;
  final String subtitulo;
  final String estado;
  final bool esEspecial;

  const _MisaCard({
    required this.dia,
    required this.titulo,
    required this.subtitulo,
    required this.estado,
    required this.esEspecial,
  });

  @override
  Widget build(BuildContext context) {
    final bool completa = estado == 'Completa';
    final bool parcial = estado == 'Parcial';

    Color estadoColor = Colors.grey;
    Color estadoBg = Colors.transparent;
    IconData? estadoIcon;

    if (completa) {
      estadoColor = Colors.teal;
      estadoBg = Colors.teal.shade50;
      estadoIcon = Icons.check_circle_outline;
    } else if (parcial) {
      estadoColor = Colors.orange;
      estadoBg = Colors.orange.shade50;
      estadoIcon = Icons.access_time;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: esEspecial ? Colors.white : Colors.amber,
            child: esEspecial
                ? const Icon(Icons.star, color: Colors.amber, size: 22)
                : Text(
                    '$dia',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  esEspecial ? '$subtitulo · Misa especial' : subtitulo,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: estadoBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                if (estadoIcon != null) ...[
                  Icon(estadoIcon, size: 12, color: estadoColor),
                  const SizedBox(width: 3),
                ],
                Text(
                  estado,
                  style: TextStyle(
                    color: estadoColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EventoMisa {
  final DateTime fecha;
  final String titulo;
  final String descripcion;
  final bool esEspecial;

  const EventoMisa({
    required this.fecha,
    required this.titulo,
    required this.descripcion,
    required this.esEspecial,
  });
}

class MisaEspecial {
  final String id;
  final String nombre;
  final DateTime fecha;

  const MisaEspecial({
    required this.id,
    required this.nombre,
    required this.fecha,
  });

  factory MisaEspecial.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> documento,
  ) {
    final datos = documento.data();
    final fechaFirestore = datos['fecha'];

    DateTime fecha;

    if (fechaFirestore is Timestamp) {
      fecha = fechaFirestore.toDate();
    } else {
      fecha = DateTime.now();
    }

    return MisaEspecial(
      id: documento.id,
      nombre: (datos['nombre'] as String?)?.trim().isNotEmpty == true
          ? (datos['nombre'] as String).trim()
          : 'Misa especial',
      fecha: fecha,
    );
  }
}
