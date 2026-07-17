import 'package:flutter/material.dart';
import 'package:sapi/styles/CalendarioAdminStyles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarioAdmin extends StatefulWidget {
  const CalendarioAdmin({super.key});

  static const routeName = '/calendarioAdmin';

  @override
  State<CalendarioAdmin> createState() => _CalendarioAdminState();
}

class _CalendarioAdminState extends State<CalendarioAdmin> {
  DateTime mesActual = DateTime(DateTime.now().year, DateTime.now().month);

  final CollectionReference<Map<String, dynamic>> _misasRef = FirebaseFirestore
      .instance
      .collection('misas_especiales');

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

  bool _esFechaAnteriorOActual(DateTime fecha) {
    final hoy = _normalizarFecha(DateTime.now());
    final fechaNormalizada = _normalizarFecha(fecha);

    // Solo se permiten días posteriores a hoy.
    return !fechaNormalizada.isAfter(hoy);
  }

  bool _esDomingo(DateTime fecha) {
    return fecha.weekday == DateTime.sunday;
  }

  bool _esMisaEspecial(DateTime fecha, List<MisaEspecial> misas) {
    final fechaNormalizada = _normalizarFecha(fecha);

    return misas.any((misa) {
      final fechaMisa = _normalizarFecha(misa.fecha);

      return fechaMisa == fechaNormalizada;
    });
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

  Future<void> _seleccionarDia(
    DateTime fechaInicial, {
    MisaEspecial? misaExistente,
  }) async {
    if (misaExistente == null && _esFechaAnteriorOActual(fechaInicial)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Solo puedes registrar misas especiales en fechas futuras.',
          ),
        ),
      );
      return;
    }
    DateTime fechaSeleccionada = _normalizarFecha(
      misaExistente?.fecha ?? fechaInicial,
    );

    final controlador = TextEditingController(
      text: misaExistente?.nombre ?? '',
    );

    bool guardando = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, actualizarDialogo) {
            Future<void> elegirFecha() async {
              final hoy = _normalizarFecha(DateTime.now());
              final manana = hoy.add(const Duration(days: 1));

              final fechaInicialPicker = misaExistente == null
                  ? (fechaSeleccionada.isAfter(hoy)
                        ? fechaSeleccionada
                        : manana)
                  : fechaSeleccionada;

              final nuevaFecha = await showDatePicker(
                context: dialogContext,
                initialDate: fechaInicialPicker,
                firstDate: misaExistente == null ? manana : DateTime(2020),
                lastDate: DateTime(2100),
                helpText: 'Selecciona una fecha futura',
                cancelText: 'Cancelar',
                confirmText: 'Seleccionar',
              );
              if (nuevaFecha != null) {
                actualizarDialogo(() {
                  fechaSeleccionada = _normalizarFecha(nuevaFecha);
                });
              }
            }

            Future<void> guardarMisa() async {
              final nombre = controlador.text.trim();

              if (nombre.isEmpty) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text('Escribe el nombre de la misa.'),
                  ),
                );
                return;
              }
              if (misaExistente == null &&
                  _esFechaAnteriorOActual(fechaSeleccionada)) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'La fecha de la misa debe ser posterior al día de hoy.',
                    ),
                  ),
                );
                return;
              }

              actualizarDialogo(() {
                guardando = true;
              });

              try {
                final datos = <String, dynamic>{
                  'nombre': nombre,
                  'fecha': Timestamp.fromDate(fechaSeleccionada),
                  'actualizadoEn': FieldValue.serverTimestamp(),
                };

                if (misaExistente == null) {
                  datos['creadoEn'] = FieldValue.serverTimestamp();

                  await _misasRef.add(datos);
                } else {
                  await _misasRef.doc(misaExistente.id).update(datos);
                }

                if (!mounted) return;

                Navigator.pop(dialogContext);

                setState(() {
                  mesActual = DateTime(
                    fechaSeleccionada.year,
                    fechaSeleccionada.month,
                  );
                });

                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text(
                      misaExistente == null
                          ? 'Misa especial agregada.'
                          : 'Misa especial actualizada.',
                    ),
                  ),
                );
              } on FirebaseException catch (error) {
                actualizarDialogo(() {
                  guardando = false;
                });

                if (!mounted) return;

                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'No se pudo guardar la misa: ${error.message}',
                    ),
                  ),
                );
              }
            }

            Future<void> eliminarMisa() async {
              if (misaExistente == null) return;

              actualizarDialogo(() {
                guardando = true;
              });

              try {
                await _misasRef.doc(misaExistente.id).delete();

                if (!mounted) return;

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Misa especial eliminada.')),
                );
              } on FirebaseException catch (error) {
                actualizarDialogo(() {
                  guardando = false;
                });

                if (!mounted) return;

                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'No se pudo eliminar la misa: ${error.message}',
                    ),
                  ),
                );
              }
            }

            return AlertDialog(
              shape: CalendarioAdminStyles.dialogShape,
              title: Text(
                misaExistente == null
                    ? 'Agregar misa especial'
                    : 'Editar misa especial',
                style: CalendarioAdminStyles.dialogTitle,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: guardando ? null : elegirFecha,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${fechaSeleccionada.day}/'
                                '${fechaSeleccionada.month}/'
                                '${fechaSeleccionada.year}',
                                style: CalendarioAdminStyles.dialogDate,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controlador,
                      enabled: !guardando,
                      maxLength: 80,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: CalendarioAdminStyles.massInputDecoration(),
                    ),
                  ],
                ),
              ),
              actions: [
                if (misaExistente != null)
                  TextButton(
                    onPressed: guardando ? null : eliminarMisa,
                    child: const Text(
                      'Eliminar',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                TextButton(
                  onPressed: guardando
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: CalendarioAdminStyles.saveButtonStyle,
                  onPressed: guardando ? null : guardarMisa,
                  child: guardando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(misaExistente == null ? 'Agregar' : 'Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    controlador.dispose();
  }

  List<DateTime?> _obtenerDiasCalendario() {
    final primerDia = DateTime(mesActual.year, mesActual.month, 1);

    final ultimoDia = DateTime(mesActual.year, mesActual.month + 1, 0);

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

  List<MisaEspecial> _misasDelMes(List<MisaEspecial> misas) {
    final lista = misas.where((misa) {
      return misa.fecha.year == mesActual.year &&
          misa.fecha.month == mesActual.month;
    }).toList();

    lista.sort((a, b) => a.fecha.compareTo(b.fecha));

    return lista;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CalendarioAdminStyles.backgroundColor,
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: CalendarioAdminStyles.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Calendario de misas',
          style: CalendarioAdminStyles.appBarTitle,
        ),
      ),

      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _misasRef.orderBy('fecha').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No se pudieron cargar las misas.\n'
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final misas =
                snapshot.data?.docs.map(MisaEspecial.fromDocument).toList() ??
                [];

            final dias = _obtenerDiasCalendario();
            final misasDelMes = _misasDelMes(misas);

            return SingleChildScrollView(
              padding: CalendarioAdminStyles.screenPadding,
              child: Column(
                children: [
                  _construirLeyenda(),
                  const SizedBox(height: 14),
                  _construirCalendario(dias, misas),
                  const SizedBox(height: 14),
                  _construirMisasEspeciales(misasDelMes),
                  const SizedBox(height: 90),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _construirCalendario(List<DateTime?> dias, List<MisaEspecial> misas) {
    return Container(
      padding: CalendarioAdminStyles.calendarioPadding,
      decoration: CalendarioAdminStyles.cardDecoration,
      child: Column(
        children: [
          Row(
            children: [
              _botonMes(icono: Icons.chevron_left, onPressed: _mesAnterior),
              Expanded(
                child: Text(
                  '${nombresMeses[mesActual.month - 1]} '
                  'de ${mesActual.year}',
                  textAlign: TextAlign.center,
                  style: CalendarioAdminStyles.monthTitle,
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
                    style: CalendarioAdminStyles.weekDayText(
                      esDomingo: esDomingo,
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

              return _construirDia(fecha, misas);
            },
          ),
        ],
      ),
    );
  }

  Widget _botonMes({required IconData icono, required VoidCallback onPressed}) {
    return Material(
      color: CalendarioAdminStyles.amarilloClaro,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: CalendarioAdminStyles.botonMesSize,
          height: CalendarioAdminStyles.botonMesSize,
          child: Icon(icono, color: CalendarioAdminStyles.iconoMes),
        ),
      ),
    );
  }

  Widget _construirLeyenda() {
    return Container(
      width: double.infinity,
      padding: CalendarioAdminStyles.leyendaPadding,
      decoration: CalendarioAdminStyles.leyendaDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _elementoLeyenda(
                color: CalendarioAdminStyles.amarillo,
                texto: 'Domingo (automático)',
                relleno: true,
              ),
              _elementoLeyenda(
                color: CalendarioAdminStyles.amarillo,
                texto: 'Misa especial (admin)',
                relleno: false,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Toca cualquier día para agregar, editar o eliminar una misa '
            'especial. Los domingos aparecen automáticamente.',
            style: CalendarioAdminStyles.leyendaDescription,
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
          width: CalendarioAdminStyles.indicadorLeyendaSize,
          height: CalendarioAdminStyles.indicadorLeyendaSize,
          decoration: CalendarioAdminStyles.indicadorLeyendaDecoration(
            color: color,
            relleno: relleno,
          ),
        ),
        const SizedBox(width: 6),
        Text(texto, style: CalendarioAdminStyles.leyendaText),
      ],
    );
  }

  Widget _construirDia(DateTime fecha, List<MisaEspecial> misas) {
    final esDomingo = _esDomingo(fecha);
    final esEspecial = _esMisaEspecial(fecha, misas);
    final esFechaPasadaOActual = _esFechaAnteriorOActual(fecha);

    MisaEspecial? misaDelDia;

    for (final misa in misas) {
      if (_normalizarFecha(misa.fecha) == _normalizarFecha(fecha)) {
        misaDelDia = misa;
        break;
      }
    }

    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: esFechaPasadaOActual && misaDelDia == null
          ? null
          : () {
              _seleccionarDia(fecha, misaExistente: misaDelDia);
            },
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: CalendarioAdminStyles.diaSize,
          height: CalendarioAdminStyles.diaSize,
          alignment: Alignment.center,
          decoration: CalendarioAdminStyles.diaDecoration(
            esDomingo: esDomingo,
            esEspecial: esEspecial,
          ),
          child: Text(
            '${fecha.day}',
            style: CalendarioAdminStyles.dayText(
              esDomingo: esDomingo,
              esEspecial: esEspecial,
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirMisasEspeciales(List<MisaEspecial> misasDelMes) {
    return Container(
      width: double.infinity,
      padding: CalendarioAdminStyles.misasPadding,
      decoration: CalendarioAdminStyles.leyendaDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Misas Especiales Programadas',
                style: CalendarioAdminStyles.specialMassTitle,
              ),
              const SizedBox(width: 6),
              Container(
                width: CalendarioAdminStyles.contadorSize,
                height: CalendarioAdminStyles.contadorSize,
                alignment: Alignment.center,
                decoration: CalendarioAdminStyles.contadorDecoration,
                child: Text(
                  '${misasDelMes.length}',
                  style: CalendarioAdminStyles.counterText,
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
                  style: CalendarioAdminStyles.emptyMassText,
                ),
              ),
            )
          else
            ...misasDelMes.map((misa) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: CalendarioAdminStyles.misaItemPadding,
                decoration: CalendarioAdminStyles.misaItemDecoration,
                child: Row(
                  children: [
                    Container(
                      width: CalendarioAdminStyles.numeroMisaSize,
                      height: CalendarioAdminStyles.numeroMisaSize,
                      alignment: Alignment.center,
                      decoration: CalendarioAdminStyles.numeroMisaDecoration(),
                      child: Text(
                        '${misa.fecha.day}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            misa.nombre,
                            style: CalendarioAdminStyles.massNameText,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${misa.fecha.day}/'
                            '${misa.fecha.month}/'
                            '${misa.fecha.year}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Editar',
                      onPressed: () {
                        _seleccionarDia(misa.fecha, misaExistente: misa);
                      },
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
    final timestamp = datos['fecha'] as Timestamp?;

    return MisaEspecial(
      id: documento.id,
      nombre: (datos['nombre'] as String?)?.trim() ?? 'Misa especial',
      fecha: timestamp?.toDate() ?? DateTime.now(),
    );
  }
}
