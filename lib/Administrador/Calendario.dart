import 'package:flutter/material.dart';

class CalendarioAdmin extends StatefulWidget {
  const CalendarioAdmin({super.key});

  static const routeName = '/calendarioAdmin';

  @override
  State<CalendarioAdmin> createState() => _CalendarioAdminState();
}

class _CalendarioAdminState extends State<CalendarioAdmin> {
  DateTime mesActual = DateTime(2026, 7);

  final Map<DateTime, String> misasEspeciales = {
    DateTime(2026, 7, 10): 'Misa de confirmaciones',
  };

  static const Color amarillo = Color(0xFFFFD814);
  static const Color amarilloClaro = Color(0xFFFFF7C7);
  static const Color borde = Color(0xFFFFC400);

  final List<String> nombresMeses = const [
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

  final List<String> diasSemana = const [
    'Lu',
    'Ma',
    'Mi',
    'Ju',
    'Vi',
    'Sa',
    'Do',
  ];

  DateTime _normalizarFecha(DateTime fecha) {
    return DateTime(fecha.year, fecha.month, fecha.day);
  }

  bool _esDomingo(DateTime fecha) {
    return fecha.weekday == DateTime.sunday;
  }

  bool _esMisaEspecial(DateTime fecha) {
    return misasEspeciales.containsKey(_normalizarFecha(fecha));
  }

  void _mesAnterior() {
    setState(() {
      mesActual = DateTime(mesActual.year, mesActual.month - 1);
    });
  }

  void _mesSiguiente() {
    setState(() {
      mesActual = DateTime(mesActual.year, mesActual.month + 1);
    });
  }

  Future<void> _seleccionarDia(DateTime fecha) async {
    final fechaNormalizada = _normalizarFecha(fecha);
    final controlador = TextEditingController(
      text: misasEspeciales[fechaNormalizada] ?? '',
    );

    await showDialog(
      context: context,
      builder: (dialogContext) {
        final yaExiste = misasEspeciales.containsKey(fechaNormalizada);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            yaExiste ? 'Editar misa especial' : 'Agregar misa especial',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${fecha.day}/${fecha.month}/${fecha.year}',
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controlador,
                maxLength: 80,
                decoration: InputDecoration(
                  labelText: 'Nombre de la misa',
                  hintText: 'Ej. Misa de confirmaciones',
                  filled: true,
                  fillColor: const Color(0xFFFFFDF2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: borde, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            if (yaExiste)
              TextButton(
                onPressed: () {
                  setState(() {
                    misasEspeciales.remove(fechaNormalizada);
                  });

                  Navigator.pop(dialogContext);
                },
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: amarillo,
                foregroundColor: Colors.black,
                elevation: 0,
              ),
              onPressed: () {
                final nombre = controlador.text.trim();

                if (nombre.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Escribe el nombre de la misa.'),
                    ),
                  );
                  return;
                }

                setState(() {
                  misasEspeciales[fechaNormalizada] = nombre;
                });

                Navigator.pop(dialogContext);
              },
              child: Text(yaExiste ? 'Guardar' : 'Agregar'),
            ),
          ],
        );
      },
    );
  }

  List<DateTime?> _obtenerDiasCalendario() {
    final primerDia = DateTime(mesActual.year, mesActual.month, 1);
    final ultimoDia = DateTime(mesActual.year, mesActual.month + 1, 0);

    // En Dart: lunes = 1 y domingo = 7.
    final espaciosIniciales = primerDia.weekday - 1;

    final List<DateTime?> dias = List<DateTime?>.filled(
      espaciosIniciales,
      null,
      growable: true,
    );
    for (int dia = 1; dia <= ultimoDia.day; dia++) {
      dias.add(DateTime(mesActual.year, mesActual.month, dia));
    }

    return dias;
  }

  List<MapEntry<DateTime, String>> _misasDelMes() {
    final lista = misasEspeciales.entries.where((misa) {
      return misa.key.year == mesActual.year &&
          misa.key.month == mesActual.month;
    }).toList();

    lista.sort((a, b) => a.key.compareTo(b.key));

    return lista;
  }

  @override
  Widget build(BuildContext context) {
    final dias = _obtenerDiasCalendario();
    final misasDelMes = _misasDelMes();

    return Container(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: amarillo,
          foregroundColor: Colors.black,
          elevation: 0,

          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          title: const Text(
            'Calendario de misas',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _construirLeyenda(),
                const SizedBox(height: 14),
                _construirCalendario(dias),
                const SizedBox(height: 14),
                _construirMisasEspeciales(misasDelMes),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirLeyenda() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: borde),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _elementoLeyenda(
                color: amarillo,
                texto: 'Domingo (automático)',
                relleno: true,
              ),
              _elementoLeyenda(
                color: amarillo,
                texto: 'Misa especial (admin)',
                relleno: false,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Toca cualquier día para agregar o quitar una misa especial. '
            'Los domingos no se pueden desactivar.',
            style: TextStyle(fontSize: 11, color: Color(0xFF9A7B00)),
          ),
        ],
      ),
    );
  }

  Widget _elementoLeyenda({
    required Color color,
    required String texto,
    required bool relleno,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 17,
          height: 17,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: relleno ? color : Colors.white,
            border: Border.all(color: color, width: 1.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          texto,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _construirCalendario(List<DateTime?> dias) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borde),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _botonMes(icono: Icons.chevron_left, onPressed: _mesAnterior),
              Expanded(
                child: Text(
                  '${nombresMeses[mesActual.month - 1]} de ${mesActual.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _botonMes(icono: Icons.chevron_right, onPressed: _mesSiguiente),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: diasSemana.map((dia) {
              final esDomingo = dia == 'Do';

              return Expanded(
                child: Center(
                  child: Text(
                    dia,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: esDomingo
                          ? const Color(0xFFD29E00)
                          : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dias.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              final fecha = dias[index];

              if (fecha == null) {
                return const SizedBox();
              }

              return _construirDia(fecha);
            },
          ),
        ],
      ),
    );
  }

  Widget _botonMes({required IconData icono, required VoidCallback onPressed}) {
    return Material(
      color: amarilloClaro,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icono, color: const Color(0xFFD3A500)),
        ),
      ),
    );
  }

  Widget _construirDia(DateTime fecha) {
    final esDomingo = _esDomingo(fecha);
    final esEspecial = _esMisaEspecial(fecha);

    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: () => _seleccionarDia(fecha),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: esDomingo ? amarillo : Colors.white,
            border: esEspecial && !esDomingo
                ? Border.all(color: borde, width: 1.5)
                : null,
          ),
          child: Text(
            '${fecha.day}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: esDomingo || esEspecial
                  ? FontWeight.bold
                  : FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirMisasEspeciales(
    List<MapEntry<DateTime, String>> misasDelMes,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: borde),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Misas Especiales Programadas',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 6),
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: amarilloClaro,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${misasDelMes.length}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB08A00),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (misasDelMes.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Sin misas especiales programadas',
                  style: TextStyle(fontSize: 12, color: Color(0xFFB08A00)),
                ),
              ),
            )
          else
            ...misasDelMes.map((misa) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBE8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 35,
                      height: 35,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: borde),
                      ),
                      child: Text(
                        '${misa.key.day}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        misa.value,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Editar',
                      onPressed: () => _seleccionarDia(misa.key),
                      icon: const Icon(Icons.edit_outlined, size: 19),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
