import 'package:flutter/material.dart';
import 'EvidenciaFotografica.dart';

class ControlAsistencia extends StatefulWidget {
  const ControlAsistencia({super.key});

  static const routeName = '/control-asistencia';

  @override
  State<ControlAsistencia> createState() => _ControlAsistenciaState();
}

class _ControlAsistenciaState extends State<ControlAsistencia> {
  final TextEditingController _buscarController = TextEditingController();

  DateTime? _fechaSeleccionada;
  String _grupoSeleccionado = 'Todos los grupos';

  final List<Map<String, dynamic>> _alumnos = [
    {
      'nombre': 'Ana García López',
      'grupo': 'Grupo A',
      'edad': 12,
      'fecha': 'domingo, 5 de julio de 2026',
      'estado': 'Parcial',
      'antes': true,
      'durante': true,
      'final': false,
      'horaAntes': '09:02',
      'horaDurante': '10:15',
      'horaFinal': null,
    },
    {
      'nombre': 'Ana García López',
      'grupo': 'Grupo A',
      'edad': 5,
      'fecha': 'domingo, 5 de julio de 2026',
      'estado': 'Completa',
      'antes': true,
      'durante': true,
      'final': true,
      'horaAntes': '09:05',
      'horaDurante': '10:12',
      'horaFinal': '11:03',
    },
    {
      'nombre': 'Carlos Mendoza Ruiz',
      'grupo': 'Grupo A',
      'edad': 5,
      'fecha': 'domingo, 5 de julio de 2026',
      'estado': 'Completa',
      'antes': true,
      'durante': true,
      'final': true,
      'horaAntes': '09:04',
      'horaDurante': '10:14',
      'horaFinal': '11:02',
    },
    {
      'nombre': 'Ana García López',
      'grupo': 'Grupo A',
      'edad': 5,
      'fecha': 'domingo, 5 de julio de 2026',
      'estado': 'Completa',
      'antes': true,
      'durante': true,
      'final': true,
      'horaAntes': '09:03',
      'horaDurante': '10:11',
      'horaFinal': '11:01',
    },
    {
      'nombre': 'Carlos Mendoza Ruiz',
      'grupo': 'Grupo A',
      'edad': 5,
      'fecha': 'domingo, 5 de julio de 2026',
      'estado': 'Completa',
      'antes': true,
      'durante': true,
      'final': true,
      'horaAntes': '09:01',
      'horaDurante': '10:10',
      'horaFinal': '11:05',
    },
  ];

  List<Map<String, dynamic>> get _alumnosFiltrados {
    final texto = _buscarController.text.toLowerCase().trim();

    return _alumnos.where((alumno) {
      final coincideNombre = alumno['nombre'].toString().toLowerCase().contains(
        texto,
      );

      final coincideGrupo =
          _grupoSeleccionado == 'Todos los grupos' ||
          alumno['grupo'] == _grupoSeleccionado;

      return coincideNombre && coincideGrupo;
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

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
    }
  }

  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) {
      return 'dd/mm/aaaa';
    }

    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }

  String _obtenerIniciales(String nombre) {
    final partes = nombre.trim().split(' ');

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
                            child: Text(
                              _formatearFecha(_fechaSeleccionada),
                              style: TextStyle(
                                fontSize: 13,
                                color: _fechaSeleccionada == null
                                    ? Colors.grey.shade600
                                    : Colors.black87,
                              ),
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
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _grupoSeleccionado,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.black87,
                              ),
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Todos los grupos',
                                  child: Text('Todos los grupos'),
                                ),
                                DropdownMenuItem(
                                  value: 'Grupo A',
                                  child: Text('Grupo A'),
                                ),
                                DropdownMenuItem(
                                  value: 'Grupo B',
                                  child: Text('Grupo B'),
                                ),
                              ],
                              onChanged: (valor) {
                                if (valor == null) return;

                                setState(() {
                                  _grupoSeleccionado = valor;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _alumnosFiltrados.isEmpty
                  ? const Center(
                      child: Text(
                        'No se encontraron registros',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            '${_alumnosFiltrados.length} registro(s)',
                            style: const TextStyle(
                              color: Color(0xFF857000),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ..._alumnosFiltrados.map(
                          (alumno) => _TarjetaAlumno(
                            alumno: alumno,
                            iniciales: _obtenerIniciales(alumno['nombre']),
                            colorPrincipal: amarillo,
                            colorClaro: amarilloClaro,
                            onVerEvidencia: () => _abrirEvidencia(alumno),
                          ),
                        ),
                      ],
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
    final bool completa = alumno['estado'] == 'Completa';

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
                      alumno['nombre'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${alumno['grupo']} • ${alumno['edad']} años',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9B8500),
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
                  activo: alumno['antes'],
                  color: colorPrincipal,
                  colorClaro: colorClaro,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _EtapaAsistencia(
                  texto: 'Durante',
                  activo: alumno['durante'],
                  color: colorPrincipal,
                  colorClaro: colorClaro,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _EtapaAsistencia(
                  texto: 'Final',
                  activo: alumno['final'],
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
