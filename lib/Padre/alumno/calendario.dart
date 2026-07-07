import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Calendario extends StatefulWidget {
  const Calendario({super.key});

  static const routeName = '/calendario';

  @override
  State<Calendario> createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  DateTime selectedMonth = DateTime.now();

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
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<String> _obtenerEstadoMisa(DateTime date) async {
    final doc = await FirebaseFirestore.instance
        .collection('asistencias')
        .doc(_fechaId(date))
        .get();

    if (!doc.exists) return 'Pendiente';

    final data = doc.data()!;

    final fotos = [
      data['fotoAntesUrl'],
      data['fotoDuranteUrl'],
      data['fotoDespuesUrl'],
    ].where((foto) => foto != null && foto.toString().isNotEmpty).length;

    if (fotos == 3) return 'Completa';
    if (fotos > 0) return 'Parcial';
    return 'Pendiente';
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

  @override
  Widget build(BuildContext context) {
    final domingos = _getDomingosDelMes(selectedMonth);

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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
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
                          '${_nombreMes(selectedMonth.month)} De ${selectedMonth.year}',
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

                  ...domingos.map((domingo) {
                    return FutureBuilder<String>(
                      future: _obtenerEstadoMisa(domingo),
                      builder: (context, snapshot) {
                        final estado = snapshot.data ?? 'Pendiente';

                        return _MisaCard(
                          dia: domingo.day,
                          fecha: '${domingo.day} jul',
                          titulo: '${domingo.day} jul',
                          estado: estado,
                        );
                      },
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
      ),
    );
  }

  Widget _botonMes(IconData icon, VoidCallback onTap) {
    return CircleAvatar(
      backgroundColor: Colors.amber.shade100,
      child: IconButton(
        icon: Icon(icon, color: Colors.amber),
        onPressed: onTap,
      ),
    );
  }
}

class _MisaCard extends StatelessWidget {
  final int dia;
  final String fecha;
  final String titulo;
  final String estado;

  const _MisaCard({
    required this.dia,
    required this.fecha,
    required this.titulo,
    required this.estado,
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
            backgroundColor: Colors.amber,
            child: Text(
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
                const Text(
                  'Misa dominical',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
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
