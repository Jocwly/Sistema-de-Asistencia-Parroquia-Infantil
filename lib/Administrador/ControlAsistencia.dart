import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sapi/services/grupos_service.dart';
import 'package:sapi/styles/ControlAsistenciaStyles.dart';

import 'EvidenciaFotografica.dart';

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
    return DateUtils.isSameDay(fecha1, fecha2);
  }

  DateTime? _convertirFecha(dynamic valor) {
    DateTime? fecha;

    if (valor is Timestamp) {
      fecha = valor.toDate();
    } else if (valor is DateTime) {
      fecha = valor;
    } else if (valor is String) {
      // Intenta convertir formatos como 2026-07-16
      fecha = DateTime.tryParse(valor);

      // Intenta convertir formatos como 16/07/2026
      if (fecha == null) {
        final partes = valor.split('/');

        if (partes.length == 3) {
          final dia = int.tryParse(partes[0]);
          final mes = int.tryParse(partes[1]);
          final anio = int.tryParse(partes[2]);

          if (dia != null && mes != null && anio != null) {
            fecha = DateTime(anio, mes, dia);
          }
        }
      }
    }

    if (fecha == null) {
      return null;
    }

    // Convierte a hora local y elimina la hora.
    final fechaLocal = fecha.toLocal();

    return DateTime(fechaLocal.year, fechaLocal.month, fechaLocal.day);
  }

  String _formatearFechaCompleta(DateTime? fecha) {
    if (fecha == null) {
      return 'Fecha no disponible';
    }

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
    final nombre = data['nombreAlumno']?.toString() ?? '';
    final apellidos = data['apellidosAlumno']?.toString() ?? '';

    final nombreCompleto = '$nombre $apellidos'.trim();

    return {
      'idAsistencia': documento.id,
      'uidAlumno': data['uidAlumno']?.toString() ?? '',
      'nombre': nombreCompleto.isNotEmpty
          ? nombreCompleto
          : 'Alumno sin nombre',
      'grupo': data['grupo']?.toString() ?? 'Sin grupo',
      'edad': int.tryParse(data['edad']?.toString() ?? '0') ?? 0,
      'correoAlumno': data['correoAlumno']?.toString() ?? '',
      'fechaDateTime': fecha,
      'fecha': _formatearFechaCompleta(fecha),
      'estado': antes && durante && finalizo
          ? 'Completa'
          : (antes || durante || finalizo)
          ? 'Parcial'
          : 'Incompleta',
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
    final textoBuscado = _buscarController.text.toLowerCase().trim();

    return alumnos.where((alumno) {
      final nombre = alumno['nombre'].toString().toLowerCase();
      final grupoAlumno = alumno['grupo'].toString().trim();
      final fechaAlumno = alumno['fechaDateTime'] as DateTime?;

      final coincideNombre = nombre.contains(textoBuscado);

      final coincideGrupo =
          grupoSeleccionado == 'Todos los grupos' ||
          grupoAlumno.toLowerCase() == grupoSeleccionado.toLowerCase();

      final coincideFecha;

      if (_fechaSeleccionada == null) {
        coincideFecha = true;
      } else if (fechaAlumno == null) {
        coincideFecha = false;
      } else {
        coincideFecha = _esLaMismaFecha(fechaAlumno, _fechaSeleccionada!);
      }

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

    if (fecha == null || !mounted) {
      return;
    }

    setState(() {
      _fechaSeleccionada = DateTime(fecha.year, fecha.month, fecha.day);
    });
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

    if (partes.isEmpty) {
      return '?';
    }

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

  void _limpiarBusqueda() {
    _buscarController.clear();
    setState(() {});
  }

  void _limpiarFecha() {
    setState(() {
      _fechaSeleccionada = null;
    });
  }

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ControlAsistenciaStyles.fondo,
      appBar: _construirAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _construirFiltros(),
            Expanded(child: _construirListaAsistencias()),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _construirAppBar() {
    return AppBar(
      backgroundColor: ControlAsistenciaStyles.blanco,
      surfaceTintColor: ControlAsistenciaStyles.blanco,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: ControlAsistenciaStyles.negroSuave,
        ),
      ),
      title: const Text(
        'Control de Asistencia',
        style: ControlAsistenciaStyles.tituloAppBar,
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(
          color: ControlAsistenciaStyles.amarillo,
          height: 1,
          thickness: 1,
        ),
      ),
    );
  }

  Widget _construirFiltros() {
    return Container(
      color: ControlAsistenciaStyles.blanco,
      padding: ControlAsistenciaStyles.filtroPadding,
      child: Column(
        children: [
          TextField(
            controller: _buscarController,
            onChanged: (_) => setState(() {}),
            style: ControlAsistenciaStyles.textoBuscador,
            decoration: ControlAsistenciaStyles.buscadorDecoration(
              mostrarBotonLimpiar: _buscarController.text.isNotEmpty,
              onLimpiar: _limpiarBusqueda,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _construirFiltroFecha()),
              const SizedBox(width: 8),
              Expanded(child: _construirFiltroGrupo()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirFiltroFecha() {
    return InkWell(
      onTap: _seleccionarFecha,
      borderRadius: BorderRadius.circular(ControlAsistenciaStyles.radioCampo),
      child: Container(
        height: ControlAsistenciaStyles.alturaFiltro,
        padding: ControlAsistenciaStyles.campoHorizontalPadding,
        alignment: Alignment.centerLeft,
        decoration: ControlAsistenciaStyles.filtroDecoration,
        child: Row(
          children: [
            Expanded(
              child: Text(
                _formatearFechaFiltro(_fechaSeleccionada),
                style: ControlAsistenciaStyles.textoDropdown.copyWith(
                  color: ControlAsistenciaStyles.colorTextoFechaFiltro(
                    _fechaSeleccionada != null,
                  ),
                ),
              ),
            ),
            if (_fechaSeleccionada != null)
              GestureDetector(
                onTap: _limpiarFecha,
                child: const Icon(
                  Icons.close,
                  size: 17,
                  color: ControlAsistenciaStyles.negroClaro,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _construirFiltroGrupo() {
    return Container(
      height: ControlAsistenciaStyles.alturaFiltro,
      padding: ControlAsistenciaStyles.campoHorizontalPadding,
      decoration: ControlAsistenciaStyles.filtroDecoration,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _gruposService.obtenerGruposRegistrados(),
        builder: (context, snapshotGrupos) {
          if (snapshotGrupos.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ControlAsistenciaStyles.amarillo,
                ),
              ),
            );
          }

          final gruposFirestore =
              snapshotGrupos.data?.docs
                  .map(
                    (documento) =>
                        documento.data()['grupo']?.toString().trim() ?? '',
                  )
                  .where((grupo) => grupo.isNotEmpty)
                  .toSet()
                  .toList() ??
              [];

          gruposFirestore.sort((grupo1, grupo2) => grupo1.compareTo(grupo2));

          final opciones = ['Todos los grupos', ...gruposFirestore];

          final valorActual = opciones.contains(_grupoSeleccionado)
              ? _grupoSeleccionado
              : 'Todos los grupos';

          return DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: valorActual,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: ControlAsistenciaStyles.negroSuave,
              ),
              style: ControlAsistenciaStyles.textoDropdown,
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
                if (valor == null) {
                  return;
                }

                setState(() {
                  _grupoSeleccionado = valor;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _construirListaAsistencias() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('asistencias')
          .orderBy('fecha', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: ControlAsistenciaStyles.mensajeErrorPadding,
              child: Text(
                'No se pudieron cargar las asistencias.\n'
                '${snapshot.error}',
                textAlign: TextAlign.center,
                style: ControlAsistenciaStyles.textoError,
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: ControlAsistenciaStyles.amarillo,
            ),
          );
        }

        final documentos = snapshot.data?.docs ?? [];

        final alumnos = documentos.map(_convertirDocumento).toList();

        final alumnosFiltrados = _filtrarAlumnos(alumnos, _grupoSeleccionado);

        if (alumnosFiltrados.isEmpty) {
          return const Center(
            child: Text(
              'No se encontraron registros',
              style: ControlAsistenciaStyles.textoSinResultados,
            ),
          );
        }

        return ListView(
          padding: ControlAsistenciaStyles.listaPadding,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${alumnosFiltrados.length} registro(s)',
                style: ControlAsistenciaStyles.textoContadorRegistros,
              ),
            ),
            ...alumnosFiltrados.map(
              (alumno) => _TarjetaAlumno(
                alumno: alumno,
                iniciales: _obtenerIniciales(alumno['nombre'].toString()),
                onVerEvidencia: () => _abrirEvidencia(alumno),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TarjetaAlumno extends StatelessWidget {
  final Map<String, dynamic> alumno;
  final String iniciales;
  final VoidCallback onVerEvidencia;

  const _TarjetaAlumno({
    required this.alumno,
    required this.iniciales,
    required this.onVerEvidencia,
  });

  @override
  Widget build(BuildContext context) {
    final completa = alumno['estado'] == 'Completa';
    final edad = alumno['edad'] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: ControlAsistenciaStyles.tarjetaPadding,
      decoration: ControlAsistenciaStyles.tarjetaDecoration,
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: ControlAsistenciaStyles.radioAvatar,
                backgroundColor: ControlAsistenciaStyles.amarillo,
                child: Text(
                  iniciales,
                  style: ControlAsistenciaStyles.inicialesAlumno,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _construirInformacionAlumno(edad)),
              _EstadoAsistencia(estado: alumno['estado'].toString()),
              const SizedBox(width: 5),
              _construirBotonEvidencia(),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: _EtapaAsistencia(
                  texto: 'Antes',
                  activo: alumno['antes'] == true,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _EtapaAsistencia(
                  texto: 'Durante',
                  activo: alumno['durante'] == true,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _EtapaAsistencia(
                  texto: 'Final',
                  activo: alumno['final'] == true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirInformacionAlumno(int edad) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          alumno['nombre'].toString(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ControlAsistenciaStyles.nombreAlumno,
        ),
        const SizedBox(height: 2),
        Text(
          edad > 0
              ? '${alumno['grupo']} • $edad años'
              : alumno['grupo'].toString(),
          style: ControlAsistenciaStyles.informacionGrupo,
        ),
        const SizedBox(height: 2),
        Text(
          alumno['fecha'].toString(),
          style: ControlAsistenciaStyles.fechaAlumno,
        ),
      ],
    );
  }

  Widget _construirBotonEvidencia() {
    return Material(
      color: ControlAsistenciaStyles.amarilloClaro,
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onVerEvidencia,
        constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
        padding: EdgeInsets.zero,
        icon: const Icon(
          Icons.remove_red_eye_outlined,
          color: ControlAsistenciaStyles.iconoEvidencia,
          size: 17,
        ),
      ),
    );
  }
}

class _EstadoAsistencia extends StatelessWidget {
  final String estado;

  const _EstadoAsistencia({required this.estado});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color fondo;
    IconData icono;

    switch (estado) {
      case 'Completa':
        color = ControlAsistenciaStyles.estadoCompleto;
        fondo = ControlAsistenciaStyles.fondoEstadoCompleto;
        icono = Icons.check_circle_outline;
        break;

      case 'Parcial':
        color = ControlAsistenciaStyles.estadoParcial;
        fondo = ControlAsistenciaStyles.fondoEstadoParcial;
        icono = Icons.access_time;
        break;

      default:
        color = ControlAsistenciaStyles.estadoIncompleto;
        fondo = ControlAsistenciaStyles.fondoEstadoIncompleto;
        icono = Icons.cancel_outlined;
    }

    return Container(
      padding: ControlAsistenciaStyles.estadoPadding,
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icono, color: color, size: 12),
          const SizedBox(width: 3),
          Text(
            estado,
            style: ControlAsistenciaStyles.textoEstado.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _EtapaAsistencia extends StatelessWidget {
  final String texto;
  final bool activo;

  const _EtapaAsistencia({required this.texto, required this.activo});

  @override
  Widget build(BuildContext context) {
    final colorContenido = ControlAsistenciaStyles.colorEtapa(activo);

    return Container(
      height: ControlAsistenciaStyles.alturaEtapa,
      alignment: Alignment.center,
      decoration: ControlAsistenciaStyles.etapaDecoration(activo: activo),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            activo ? Icons.check_circle_outline : Icons.close,
            color: colorContenido,
            size: 10,
          ),
          const SizedBox(width: 3),
          Text(
            texto,
            style: ControlAsistenciaStyles.textoEtapa.copyWith(
              color: colorContenido,
            ),
          ),
        ],
      ),
    );
  }
}
