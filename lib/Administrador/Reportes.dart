import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class GenerarReportes extends StatefulWidget {
  const GenerarReportes({super.key});

  static const routeName = '/GenerarReportes';

  @override
  State<GenerarReportes> createState() => _GenerarReportesState();
}

class _GenerarReportesState extends State<GenerarReportes> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _grupoSeleccionado = 'Todos los grupos';
  DateTime? _fechaSeleccionada;

  List<String> _grupos = ['Todos los grupos'];
  List<RegistroReporte> _registros = [];

  bool _cargandoGrupos = true;
  bool _generandoReporte = false;
  bool _reporteGenerado = false;

  @override
  void initState() {
    super.initState();
    _cargarGrupos();
  }

  Future<void> _cargarGrupos() async {
    const gruposExistentes = [
      '1A',
      '1B',
      '2A',
      '2B',
      '3A',
      '3B',
      '4A',
      '4B',
      '5A',
      '5B',
      '6A',
      '6B',
    ];

    if (!mounted) return;

    setState(() {
      _grupos = ['Todos los grupos', ...gruposExistentes];

      _cargandoGrupos = false;
    });
  }

  Future<void> _generarReporte() async {
    setState(() {
      _generandoReporte = true;
      _reporteGenerado = false;
      _registros = [];
    });

    try {
      final snapshot = await _firestore
          .collection('asistencias')
          .orderBy('fecha', descending: true)
          .get();

      final registros = <RegistroReporte>[];

      for (final documento in snapshot.docs) {
        final data = documento.data();

        final grupo = _leerTexto(data, ['grupo']);
        final fecha = _leerFecha(data['fecha']);

        if (fecha == null) {
          continue;
        }

        final cumpleGrupo =
            _grupoSeleccionado == 'Todos los grupos' ||
            grupo == _grupoSeleccionado;

        final cumpleFecha =
            _fechaSeleccionada == null ||
            _esMismoDia(fecha, _fechaSeleccionada!);

        if (!cumpleGrupo || !cumpleFecha) {
          continue;
        }

        registros.add(
          RegistroReporte(
            id: documento.id,
            uidAlumno: _leerTexto(data, [
              'uidAlumno',
              'alumnoId',
              'uid',
              'idAlumno',
            ]),
            nombre: _obtenerNombreAlumno(data),
            grupo: grupo.isEmpty ? 'Sin grupo' : grupo,
            fecha: fecha,
            estado: _obtenerEstado(data),
          ),
        );
      }

      registros.sort((a, b) => b.fecha.compareTo(a.fecha));

      if (!mounted) return;

      setState(() {
        _registros = registros;
        _generandoReporte = false;
        _reporteGenerado = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            registros.isEmpty
                ? 'No se encontraron asistencias con los filtros seleccionados'
                : 'Reporte generado con ${registros.length} registro(s)',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;

      setState(() {
        _generandoReporte = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.code == 'failed-precondition'
                ? 'Firestore necesita un índice para realizar esta consulta'
                : 'Error de Firebase: ${error.message}',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _generandoReporte = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No fue posible generar el reporte: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _obtenerNombreAlumno(Map<String, dynamic> data) {
    final nombreCompleto = _leerTexto(data, [
      'nombreAlumno',
      'nombreCompleto',
      'nombre',
      'alumno',
    ]);

    if (nombreCompleto.isNotEmpty) {
      return nombreCompleto;
    }

    final nombres = _leerTexto(data, ['nombres']);
    final apellidos = _leerTexto(data, ['apellidos']);

    final nombreConstruido = '$nombres $apellidos'.trim();

    if (nombreConstruido.isNotEmpty) {
      return nombreConstruido;
    }

    return 'Alumno sin nombre';
  }

  EstadoAsistencia _obtenerEstado(Map<String, dynamic> data) {
    final estadoGuardado = _leerTexto(data, [
      'estado',
      'estadoAsistencia',
    ]).toLowerCase();

    final estadoNormalizado = estadoGuardado
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');

    if (estadoNormalizado == 'completo' || estadoNormalizado == 'completa') {
      return EstadoAsistencia.completo;
    }

    if (estadoNormalizado == 'parcial') {
      return EstadoAsistencia.parcial;
    }

    if (estadoNormalizado == 'incompleto' ||
        estadoNormalizado == 'incompleta' ||
        estadoNormalizado == 'ausente') {
      return EstadoAsistencia.incompleto;
    }

    final fotoAntes = _leerFoto(data, [
      'fotoAntesUrl',
      'fotoAntesURL',
      'urlFotoAntes',
      'fotoAntes',
      'imagenAntes',
    ]);

    final fotoDespues = _leerFoto(data, [
      'fotoDespuesUrl',
      'fotoDespuesURL',
      'urlFotoDespues',
      'fotoDespues',
      'imagenDespues',
    ]);

    final tieneFotoAntes = fotoAntes.isNotEmpty;
    final tieneFotoDespues = fotoDespues.isNotEmpty;

    if (tieneFotoAntes && tieneFotoDespues) {
      return EstadoAsistencia.completo;
    }

    if (tieneFotoAntes || tieneFotoDespues) {
      return EstadoAsistencia.parcial;
    }

    return EstadoAsistencia.incompleto;
  }

  String _leerFoto(Map<String, dynamic> data, List<String> posiblesCampos) {
    final valorDirecto = _leerTexto(data, posiblesCampos);

    if (valorDirecto.isNotEmpty) {
      return valorDirecto;
    }

    final fotos = data['fotos'];

    if (fotos is Map) {
      final mapaFotos = Map<String, dynamic>.from(fotos);

      for (final campo in posiblesCampos) {
        final valor = mapaFotos[campo];

        if (valor != null && valor.toString().trim().isNotEmpty) {
          return valor.toString().trim();
        }
      }
    }

    return '';
  }

  String _leerTexto(Map<String, dynamic> data, List<String> posiblesCampos) {
    for (final campo in posiblesCampos) {
      final valor = data[campo];

      if (valor != null && valor.toString().trim().isNotEmpty) {
        return valor.toString().trim();
      }
    }

    return '';
  }

  DateTime? _leerFecha(dynamic valor) {
    if (valor == null) {
      return null;
    }

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

  bool _esMismoDia(DateTime fecha1, DateTime fecha2) {
    return fecha1.year == fecha2.year &&
        fecha1.month == fecha2.month &&
        fecha1.day == fecha2.day;
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year.toString();

    return '$dia/$mes/$anio';
  }

  String get _textoFiltroFecha {
    if (_fechaSeleccionada == null) {
      return 'Todas las fechas';
    }

    return _formatearFecha(_fechaSeleccionada!);
  }

  void _limpiarResultados() {
    setState(() {
      _registros = [];
      _reporteGenerado = false;
    });
  }

  // ---------------------------------------------------------------------------
  // SELECTOR DE FECHA
  // ---------------------------------------------------------------------------

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Seleccionar fecha del reporte',
      cancelText: 'Cancelar',
      confirmText: 'Seleccionar',
      fieldLabelText: 'Fecha',
      fieldHintText: 'DD/MM/AAAA',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFFC400),
              onPrimary: Colors.black,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (fecha == null) {
      return;
    }

    setState(() {
      _fechaSeleccionada = fecha;
      _registros = [];
      _reporteGenerado = false;
    });
  }

  void _quitarFiltroFecha() {
    setState(() {
      _fechaSeleccionada = null;
      _registros = [];
      _reporteGenerado = false;
    });
  }

  int get _completos {
    return _registros
        .where((registro) => registro.estado == EstadoAsistencia.completo)
        .length;
  }

  int get _parciales {
    return _registros
        .where((registro) => registro.estado == EstadoAsistencia.parcial)
        .length;
  }

  int get _incompletos {
    return _registros
        .where((registro) => registro.estado == EstadoAsistencia.incompleto)
        .length;
  }

  Future<Uint8List> _crearPdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(32),
        header: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 12),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.amber, width: 2),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'SAPI',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.amber800,
                  ),
                ),
                pw.Text(
                  'Reporte de asistencias',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
        footer: (context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 15),
            child: pw.Text(
              'Página ${context.pageNumber} de ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          );
        },
        build: (context) {
          return [
            pw.SizedBox(height: 20),

            pw.Text(
              'Resumen general',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),

            pw.SizedBox(height: 8),

            pw.Text(
              'Grupo: $_grupoSeleccionado',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),

            pw.SizedBox(height: 4),

            pw.Text(
              'Fecha del reporte: $_textoFiltroFecha',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),

            pw.SizedBox(height: 4),

            pw.Text(
              'Generado el: ${_formatearFecha(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),

            pw.SizedBox(height: 20),

            pw.Row(
              children: [
                pw.Expanded(
                  child: _pdfResumenCard(
                    titulo: 'Total de registros',
                    cantidad: _registros.length,
                    color: PdfColors.amber100,
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: _pdfResumenCard(
                    titulo: 'Completos',
                    cantidad: _completos,
                    color: PdfColors.green100,
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 10),

            pw.Row(
              children: [
                pw.Expanded(
                  child: _pdfResumenCard(
                    titulo: 'Parciales',
                    cantidad: _parciales,
                    color: PdfColors.orange100,
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: _pdfResumenCard(
                    titulo: 'Incompletos',
                    cantidad: _incompletos,
                    color: PdfColors.red100,
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 25),

            pw.Text(
              'Resumen por alumno',
              style: pw.TextStyle(fontSize: 17, fontWeight: pw.FontWeight.bold),
            ),

            pw.SizedBox(height: 12),

            pw.TableHelper.fromTextArray(
              headers: const ['Alumno', 'Grupo', 'Fecha', 'Estado'],
              data: _registros.map((registro) {
                return [
                  registro.nombre,
                  registro.grupo,
                  _formatearFecha(registro.fecha),
                  registro.estado.texto,
                ];
              }).toList(),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.amber800,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellPadding: const pw.EdgeInsets.all(7),
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
              oddRowDecoration: const pw.BoxDecoration(
                color: PdfColors.grey100,
              ),
            ),

            pw.SizedBox(height: 25),

            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                'Este reporte fue generado automáticamente desde la aplicación SAPI.',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfResumenCard({
    required String titulo,
    required int cantidad,
    required PdfColor color,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            cantidad.toString(),
            style: pw.TextStyle(fontSize: 25, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            titulo,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _abrirVistaPreviaPdf() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VistaPreviaReportePdf(
          grupo: _grupoSeleccionado,
          fecha: _fechaSeleccionada,
          crearPdf: _crearPdf,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
          ),
        ),
        title: const Text(
          'Generar Reportes',
          style: TextStyle(
            color: Colors.black,
            fontSize: 27,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Color(0xFFFFC400)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 28, 18, 24),
          child: Column(
            children: [
              _buildConfiguracion(),

              if (_reporteGenerado) ...[
                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: _ResumenCard(
                        cantidad: _registros.length,
                        titulo: 'Total Registros',
                        backgroundColor: const Color(0xFFFFF5BF),
                        numberColor: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ResumenCard(
                        cantidad: _completos,
                        titulo: 'Completos',
                        backgroundColor: const Color(0xFFC9F4DF),
                        numberColor: const Color(0xFF168A52),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _ResumenCard(
                        cantidad: _parciales,
                        titulo: 'Parciales',
                        backgroundColor: const Color(0xFFFFF1C6),
                        numberColor: const Color(0xFFFF5722),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ResumenCard(
                        cantidad: _incompletos,
                        titulo: 'Incompletos',
                        backgroundColor: const Color(0xFFFFDCDC),
                        numberColor: const Color(0xFFFF2222),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _buildResumenAlumnos(),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _registros.isEmpty ? null : _abrirVistaPreviaPdf,
                    icon: const Icon(
                      Icons.picture_as_pdf_rounded,
                      color: Colors.black,
                      size: 27,
                    ),
                    label: const Text(
                      'Descargar PDF',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC800),
                      disabledBackgroundColor: Colors.grey.shade300,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfiguracion() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFFFC400), width: 1.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configurar Reporte',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 14),

          const Text(
            'Grupo',
            style: TextStyle(
              color: Color(0xFF858585),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            value: _grupoSeleccionado,
            isExpanded: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(
                  color: Color(0xFFFFC400),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(
                  color: Color(0xFFFFC400),
                  width: 2,
                ),
              ),
            ),
            items: _grupos.map((grupo) {
              return DropdownMenuItem<String>(
                value: grupo,
                child: Text(
                  grupo,
                  style: const TextStyle(
                    color: Color(0xFF858585),
                    fontSize: 17,
                  ),
                ),
              );
            }).toList(),
            onChanged: _cargandoGrupos
                ? null
                : (grupo) {
                    if (grupo == null) return;

                    setState(() {
                      _grupoSeleccionado = grupo;
                    });

                    _limpiarResultados();
                  },
          ),

          const SizedBox(height: 14),

          const Text(
            'Fecha',
            style: TextStyle(
              color: Color(0xFF858585),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          InkWell(
            onTap: _seleccionarFecha,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: double.infinity,
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFFC400), width: 1.5),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _fechaSeleccionada == null
                          ? 'DD/MM/AAAA'
                          : _formatearFecha(_fechaSeleccionada!),
                      style: const TextStyle(
                        color: Color(0xFF858585),
                        fontSize: 17,
                      ),
                    ),
                  ),
                  if (_fechaSeleccionada != null)
                    IconButton(
                      tooltip: 'Quitar filtro de fecha',
                      onPressed: _quitarFiltroFecha,
                      icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    )
                  else
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.black87,
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: _generandoReporte ? null : _generarReporte,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC800),
                disabledBackgroundColor: const Color(0xFFFFE582),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: _generandoReporte
                  ? const SizedBox(
                      width: 23,
                      height: 23,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.black,
                      ),
                    )
                  : const Text(
                      'Generar Reporte',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenAlumnos() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFFFC400)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen por Alumno',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 5),

          Text(
            'Grupo: $_grupoSeleccionado · Fecha: $_textoFiltroFecha',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),

          const SizedBox(height: 12),

          if (_registros.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      color: Colors.grey,
                      size: 42,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No hay asistencias con estos filtros',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._registros.map(
              (registro) => _RegistroItem(
                registro: registro,
                fechaFormateada: _formatearFecha(registro.fecha),
              ),
            ),
        ],
      ),
    );
  }
}

class _ResumenCard extends StatelessWidget {
  final int cantidad;
  final String titulo;
  final Color backgroundColor;
  final Color numberColor;

  const _ResumenCard({
    required this.cantidad,
    required this.titulo,
    required this.backgroundColor,
    required this.numberColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            cantidad.toString(),
            style: TextStyle(
              color: numberColor,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RegistroItem extends StatelessWidget {
  final RegistroReporte registro;
  final String fechaFormateada;

  const _RegistroItem({required this.registro, required this.fechaFormateada});

  String get iniciales {
    final partes = registro.nombre
        .trim()
        .split(' ')
        .where((parte) => parte.isNotEmpty)
        .toList();

    if (partes.isEmpty) {
      return 'A';
    }

    if (partes.length == 1) {
      return partes.first.substring(0, 1).toUpperCase();
    }

    return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFFFC800),
            child: Text(
              iniciales,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  registro.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${registro.grupo} · $fechaFormateada',
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          _EstadoChip(estado: registro.estado),
        ],
      ),
    );
  }
}

class _EstadoChip extends StatelessWidget {
  final EstadoAsistencia estado;

  const _EstadoChip({required this.estado});

  Color get backgroundColor {
    switch (estado) {
      case EstadoAsistencia.completo:
        return const Color(0xFFC9F4DF);
      case EstadoAsistencia.parcial:
        return const Color(0xFFFFE6B5);
      case EstadoAsistencia.incompleto:
        return const Color(0xFFFFDCDC);
    }
  }

  Color get textColor {
    switch (estado) {
      case EstadoAsistencia.completo:
        return const Color(0xFF168A52);
      case EstadoAsistencia.parcial:
        return const Color(0xFFD85D00);
      case EstadoAsistencia.incompleto:
        return const Color(0xFFD71920);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado.texto,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class VistaPreviaReportePdf extends StatelessWidget {
  final String grupo;
  final DateTime? fecha;
  final Future<Uint8List> Function(PdfPageFormat format) crearPdf;

  const VistaPreviaReportePdf({
    super.key,
    required this.grupo,
    required this.fecha,
    required this.crearPdf,
  });

  String get nombreFecha {
    if (fecha == null) {
      return 'todas_las_fechas';
    }

    final dia = fecha!.day.toString().padLeft(2, '0');
    final mes = fecha!.month.toString().padLeft(2, '0');
    final anio = fecha!.year.toString();

    return '${dia}_${mes}_$anio';
  }

  @override
  Widget build(BuildContext context) {
    final grupoArchivo = grupo
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('/', '_');

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Vista previa del PDF',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFFFC400)),
        ),
      ),
      body: PdfPreview(
        build: crearPdf,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        allowPrinting: true,
        allowSharing: true,
        pdfFileName: 'reporte_${grupoArchivo}_$nombreFecha.pdf',
        loadingWidget: const Center(
          child: CircularProgressIndicator(color: Color(0xFFFFC400)),
        ),
      ),
    );
  }
}

enum EstadoAsistencia { completo, parcial, incompleto }

extension EstadoAsistenciaExtension on EstadoAsistencia {
  String get texto {
    switch (this) {
      case EstadoAsistencia.completo:
        return 'Completo';
      case EstadoAsistencia.parcial:
        return 'Parcial';
      case EstadoAsistencia.incompleto:
        return 'Incompleto';
    }
  }
}

class RegistroReporte {
  final String id;
  final String uidAlumno;
  final String nombre;
  final String grupo;
  final DateTime fecha;
  final EstadoAsistencia estado;

  const RegistroReporte({
    required this.id,
    required this.uidAlumno,
    required this.nombre,
    required this.grupo,
    required this.fecha,
    required this.estado,
  });
}
