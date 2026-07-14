import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'EvidenciaFotografica.dart';
import 'package:sapi/services/grupos_service.dart';

class ControlAsistencia extends StatefulWidget {
  const ControlAsistencia({super.key});

  static const routeName = '/control-asistencia';

  @override
  State<ControlAsistencia> createState() => _ControlAsistenciaState();
}

class _ControlAsistenciaState extends State<ControlAsistencia> {
  final TextEditingController _buscarController = TextEditingController();
  final GruposService _gruposService = GruposService();

  DateTime? _fechaSeleccionada;
  String _grupoSeleccionado = 'Todos los grupos';

  bool _esLaMismaFecha(DateTime fecha1, DateTime fecha2) {
    return fecha1.year == fecha2.year &&
        fecha1.month == fecha2.month &&
        fecha1.day == fecha2.day;
  }

  DateTime? _convertirFecha(dynamic valor) {
    if (valor is Timestamp) {
      return valor.toDate();
    }

    if (valor is DateTime) {
      return valor;
    }

    if (valor is String) {
      return DateTime.tryParse(valor);
    }

    return null;
  }

  String _formatearFechaCompleta(DateTime? fecha) {
    if (fecha == null) return 'Fecha no disponible';

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

    return '${dias[fecha.weekday - 1]}, '
        '${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}';
  }

  Map<String, dynamic> _convertirDocumento(
    QueryDocumentSnapshot<Map<String, dynamic>> documento,
  ) {
    final data = documento.data();

    final fotoAntes = data['fotoAntesUrl']?.toString() ?? '';
    final fotoDurante = data['fotoDuranteUrl']?.toString() ?? '';
    final fotoDespues = data['fotoDespuesUrl']?.toString() ?? '';

    final antes = fotoAntes.isNotEmpty;
    final durante = fotoDurante.isNotEmpty;
    final finalizo = fotoDespues.isNotEmpty;

    final fecha = _convertirFecha(data['fecha']);

    return {
      'idAsistencia': documento.id,
      'uidAlumno': data['uidAlumno']?.toString() ?? '',
      'nombre': data['nombreAlumno']?.toString().trim().isNotEmpty == true
          ? data['nombreAlumno'].toString()
          : 'Alumno sin nombre',
      'grupo': data['grupo']?.toString() ?? 'Sin grupo',
      'edad': int.tryParse(data['edad']?.toString() ?? '0') ?? 0,
      'correoAlumno': data['correoAlumno']?.toString() ?? '',
      'fechaDateTime': fecha,
      'fecha': _formatearFechaCompleta(fecha),
      'estado': antes && durante && finalizo ? 'Completa' : 'Parcial',
      'antes': antes,
      'durante': durante,
      'final': finalizo,
      'fotoAntesUrl': fotoAntes,
      'fotoDuranteUrl': fotoDurante,
      'fotoDespuesUrl': fotoDespues,
      'horaAntes': data['horaAntes']?.toString(),
      'horaDurante': data['horaDurante']?.toString(),
      'horaFinal': data['horaDespues']?.toString(),
      'horaDespues': data['horaDespues']?.toString(),
    };
  }

  List<Map<String, dynamic>> _filtrarAlumnos(
    List<Map<String, dynamic>> alumnos,
    String grupoSeleccionado,
  ) {
    final texto = _buscarController.text.toLowerCase().trim();

    return alumnos.where((alumno) {
      final nombre = alumno['nombre'].toString().toLowerCase();
      final grupoAlumno = alumno['grupo'].toString().trim();
      final fecha = alumno['fechaDateTime'] as DateTime?;

      final coincideNombre = nombre.contains(texto);

      final coincideGrupo =
          grupoSeleccionado == 'Todos los grupos' ||
          grupoAlumno.toLowerCase() == grupoSeleccionado.toLowerCase();

      final coincideFecha =
          _fechaSeleccionada == null ||
          (fecha != null && _esLaMismaFecha(fecha, _fechaSeleccionada!));

      return coincideNombre && coincideGrupo && coincideFecha;
    }).toList();
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('es', 'MX'),
    );

    if (fecha != null && mounted) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
    }
  }

  String _formatearFechaFiltro(DateTime? fecha) {
    if (fecha == null) {
      return 'dd/mm/aaaa';
    }

    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }

  String _obtenerIniciales(String nombre) {
    final partes = nombre
        .trim()
        .split(RegExp(r'\s+'))
        .where((parte) => parte.isNotEmpty)
        .toList();

    if (partes.isEmpty) return '?';

    if (partes.length == 1) {
      return partes.first.substring(0, 1).toUpperCase();
    }

    return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
  }

  void _abrirEvidencia(Map<String, dynamic> alumno) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EvidenciaFotografica(alumno: alumno)),
    );
  }

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const amarillo = Color(0xFFFFC400);
    const amarilloClaro = Color(0xFFFFF7C2);
    const fondo = Color(0xFFF8F8F8);

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
        ),
        title: const Text(
          'Control de Asistencia',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: amarillo, height: 1, thickness: 1),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Column(
                children: [
                  TextField(
                    controller: _buscarController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Buscar alumno...',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: amarillo,
                        size: 20,
                      ),
                      suffixIcon: _buscarController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _buscarController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close, size: 18),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: const BorderSide(color: amarillo),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: const BorderSide(
                          color: amarillo,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _seleccionarFecha,
                          borderRadius: BorderRadius.circular(13),
                          child: Container(
                            height: 45,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(color: amarillo),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _formatearFechaFiltro(_fechaSeleccionada),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _fechaSeleccionada == null
                                          ? Colors.grey.shade600
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                                if (_fechaSeleccionada != null)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _fechaSeleccionada = null;
                                      });
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      size: 17,
                                      color: Colors.black54,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 45,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(color: amarillo),
                          ),
                          child:
                              StreamBuilder<
                                QuerySnapshot<Map<String, dynamic>>
                              >(
                                stream: _gruposService.obtenerGrupos(),
                                builder: (context, snapshotGrupos) {
                                  if (snapshotGrupos.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: amarillo,
                                        ),
                                      ),
                                    );
                                  }

                                  final gruposFirestore =
                                      snapshotGrupos.data?.docs
                                          .map(
                                            (documento) =>
                                                documento
                                                    .data()['grupo']
                                                    ?.toString()
                                                    .trim() ??
                                                '',
                                          )
                                          .where((grupo) => grupo.isNotEmpty)
                                          .toSet()
                                          .toList() ??
                                      [];

                                  gruposFirestore.sort(
                                    (grupo1, grupo2) =>
                                        grupo1.compareTo(grupo2),
                                  );

                                  final opciones = [
                                    'Todos los grupos',
                                    ...gruposFirestore,
                                  ];

                                  final valorActual =
                                      opciones.contains(_grupoSeleccionado)
                                      ? _grupoSeleccionado
                                      : 'Todos los grupos';

                                  return DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: valorActual,
                                      isExpanded: true,
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.black87,
                                      ),
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 13,
                                      ),
                                      items: opciones.map((grupo) {
                                        return DropdownMenuItem<String>(
                                          value: grupo,
                                          child: Text(
                                            grupo,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (valor) {
                                        if (valor == null) return;

                                        setState(() {
                                          _grupoSeleccionado = valor;
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('asistencias')
                    .orderBy('fecha', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'No se pudieron cargar las asistencias.\n'
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: amarillo),
                    );
                  }

                  final documentos = snapshot.data?.docs ?? [];

                  final alumnos = documentos.map(_convertirDocumento).toList();

                  final alumnosFiltrados = _filtrarAlumnos(
                    alumnos,
                    _grupoSeleccionado,
                  );
                  if (alumnosFiltrados.isEmpty) {
                    return const Center(
                      child: Text(
                        'No se encontraron registros',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '${alumnosFiltrados.length} registro(s)',
                          style: const TextStyle(
                            color: Color(0xFF857000),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ...alumnosFiltrados.map(
                        (alumno) => _TarjetaAlumno(
                          alumno: alumno,
                          iniciales: _obtenerIniciales(
                            alumno['nombre'].toString(),
                          ),
                          colorPrincipal: amarillo,
                          colorClaro: amarilloClaro,
                          onVerEvidencia: () => _abrirEvidencia(alumno),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaAlumno extends StatelessWidget {
  final Map<String, dynamic> alumno;
  final String iniciales;
  final Color colorPrincipal;
  final Color colorClaro;
  final VoidCallback onVerEvidencia;

  const _TarjetaAlumno({
    required this.alumno,
    required this.iniciales,
    required this.colorPrincipal,
    required this.colorClaro,
    required this.onVerEvidencia,
  });

  @override
  Widget build(BuildContext context) {
    final completa = alumno['estado'] == 'Completa';
    final edad = alumno['edad'] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorPrincipal, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: colorPrincipal,
                child: Text(
                  iniciales,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alumno['nombre'].toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      edad > 0
                          ? '${alumno['grupo']} • $edad años'
                          : alumno['grupo'].toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9B8500),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      alumno['fecha'].toString(),
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              _EstadoAsistencia(completa: completa),
              const SizedBox(width: 5),
              Material(
                color: colorClaro,
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: onVerEvidencia,
                  constraints: const BoxConstraints(
                    minHeight: 32,
                    minWidth: 32,
                  ),
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.remove_red_eye_outlined,
                    color: Color(0xFFE1B600),
                    size: 17,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: _EtapaAsistencia(
                  texto: 'Antes',
                  activo: alumno['antes'] == true,
                  color: colorPrincipal,
                  colorClaro: colorClaro,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _EtapaAsistencia(
                  texto: 'Durante',
                  activo: alumno['durante'] == true,
                  color: colorPrincipal,
                  colorClaro: colorClaro,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _EtapaAsistencia(
                  texto: 'Final',
                  activo: alumno['final'] == true,
                  color: colorPrincipal,
                  colorClaro: colorClaro,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EstadoAsistencia extends StatelessWidget {
  final bool completa;

  const _EstadoAsistencia({required this.completa});

  @override
  Widget build(BuildContext context) {
    final color = completa ? const Color(0xFF00AD7C) : const Color(0xFFE5A100);

    final fondo = completa ? const Color(0xFFD8F7EC) : const Color(0xFFFFF0C7);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            completa ? Icons.check_circle_outline : Icons.access_time,
            color: color,
            size: 12,
          ),
          const SizedBox(width: 3),
          Text(
            completa ? 'Completa' : 'Parcial',
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EtapaAsistencia extends StatelessWidget {
  final String texto;
  final bool activo;
  final Color color;
  final Color colorClaro;

  const _EtapaAsistencia({
    required this.texto,
    required this.activo,
    required this.color,
    required this.colorClaro,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: activo ? color.withValues(alpha: 0.80) : colorClaro,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            activo ? Icons.check_circle_outline : Icons.close,
            color: activo ? Colors.white : const Color(0xFFD5B000),
            size: 10,
          ),
          const SizedBox(width: 3),
          Text(
            texto,
            style: TextStyle(
              fontSize: 9,
              color: activo ? Colors.white : const Color(0xFFD5B000),
            ),
          ),
        ],
      ),
    );
  }
}
