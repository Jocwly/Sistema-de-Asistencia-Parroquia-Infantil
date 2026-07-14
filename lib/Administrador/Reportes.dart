import 'dart:typed_data';
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
  String _grupoSeleccionado = 'Todos los grupos';

  final List<String> _grupos = const [
    'Todos los grupos',
    'Grupo A',
    'Grupo B',
    'Grupo C',
  ];

  final List<AlumnoReporte> _alumnos = const [
    AlumnoReporte(
      nombre: 'Ana García López',
      grupo: 'Grupo A',
      porcentaje: 50,
      estado: EstadoAsistencia.completa,
    ),
    AlumnoReporte(
      nombre: 'Ana García López',
      grupo: 'Grupo B',
      porcentaje: 50,
      estado: EstadoAsistencia.completa,
    ),
    AlumnoReporte(
      nombre: 'Alumno',
      grupo: 'Grupo C',
      porcentaje: 50,
      estado: EstadoAsistencia.ausente,
    ),
  ];

  List<AlumnoReporte> get _alumnosFiltrados {
    if (_grupoSeleccionado == 'Todos los grupos') {
      return _alumnos;
    }

    return _alumnos
        .where((alumno) => alumno.grupo == _grupoSeleccionado)
        .toList();
  }

  int get _completas => _alumnosFiltrados
      .where((alumno) => alumno.estado == EstadoAsistencia.completa)
      .length;

  int get _parciales => _alumnosFiltrados
      .where((alumno) => alumno.estado == EstadoAsistencia.parcial)
      .length;

  int get _ausentes => _alumnosFiltrados
      .where((alumno) => alumno.estado == EstadoAsistencia.ausente)
      .length;

  void _generarReporte() {
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _grupoSeleccionado == 'Todos los grupos'
              ? 'Reporte configurado para todos los grupos'
              : 'Reporte configurado para $_grupoSeleccionado',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<Uint8List> _crearPdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    final alumnos = _alumnosFiltrados;

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

            pw.Text(
              'Fecha: 19/07/2026',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),

            pw.SizedBox(height: 8),

            pw.Text(
              'Grupo: $_grupoSeleccionado',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),

            pw.SizedBox(height: 20),

            pw.Row(
              children: [
                pw.Expanded(
                  child: _pdfResumenCard(
                    titulo: 'Total de registros',
                    cantidad: alumnos.length,
                    color: PdfColors.amber100,
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: _pdfResumenCard(
                    titulo: 'Completas',
                    cantidad: _completas,
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
                    titulo: 'Ausentes',
                    cantidad: _ausentes,
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
              headers: const ['Alumno', 'Grupo', 'Estado', 'Porcentaje'],
              data: alumnos.map((alumno) {
                return [
                  alumno.nombre,
                  alumno.grupo,
                  alumno.estado.texto,
                  '${alumno.porcentaje}%',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.amber800,
              ),
              cellStyle: const pw.TextStyle(fontSize: 10),
              cellPadding: const pw.EdgeInsets.all(8),
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
          crearPdf: _crearPdf,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alumnos = _alumnosFiltrados;

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

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: _ResumenCard(
                      cantidad: alumnos.length,
                      titulo: 'Total Registros',
                      backgroundColor: const Color(0xFFFFF5BF),
                      numberColor: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ResumenCard(
                      cantidad: _completas,
                      titulo: 'Completas',
                      backgroundColor: const Color(0xFFC9F4DF),
                      numberColor: const Color(0xFF3514DB),
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
                      cantidad: _ausentes,
                      titulo: 'Ausentes',
                      backgroundColor: const Color(0xFFFFDCDC),
                      numberColor: const Color(0xFFFF2222),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              _buildResumenAlumnos(alumnos),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: alumnos.isEmpty ? null : _abrirVistaPreviaPdf,
                  icon: const Icon(
                    Icons.download_rounded,
                    color: Colors.black,
                    size: 28,
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
          ),
        ),
      ),
    );
  }

  Widget _buildConfiguracion() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFFFC400)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configurar Reporte',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            'Grupo',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: _grupoSeleccionado,
            isExpanded: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 3,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFFFC400)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFFFC400),
                  width: 2,
                ),
              ),
            ),
            items: _grupos.map((grupo) {
              return DropdownMenuItem(
                value: grupo,
                child: Text(grupo, style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
            onChanged: (grupo) {
              if (grupo == null) return;

              setState(() {
                _grupoSeleccionado = grupo;
              });
            },
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _generarReporte,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC800),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Generar Reporte',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenAlumnos(List<AlumnoReporte> alumnos) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(9, 7, 9, 10),
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
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          if (alumnos.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 25),
              child: Center(
                child: Text(
                  'No hay alumnos en este grupo',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...alumnos.map((alumno) => _AlumnoItem(alumno: alumno)),
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
      height: 77,
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
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlumnoItem extends StatelessWidget {
  final AlumnoReporte alumno;

  const _AlumnoItem({required this.alumno});

  String get iniciales {
    final partes = alumno.nombre.trim().split(' ');

    if (partes.length == 1) {
      return partes.first.substring(0, 1).toUpperCase();
    }

    return '${partes.first[0]}${partes[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: const Color(0xFFFFC800),
            child: Text(
              iniciales,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alumno.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  alumno.grupo,
                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                ),
              ],
            ),
          ),
          Text(
            '${alumno.porcentaje}%',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class VistaPreviaReportePdf extends StatelessWidget {
  final String grupo;
  final Future<Uint8List> Function(PdfPageFormat format) crearPdf;

  const VistaPreviaReportePdf({
    super.key,
    required this.grupo,
    required this.crearPdf,
  });

  @override
  Widget build(BuildContext context) {
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
        pdfFileName: 'reporte_${grupo.toLowerCase().replaceAll(' ', '_')}.pdf',
        loadingWidget: const Center(
          child: CircularProgressIndicator(color: Color(0xFFFFC400)),
        ),
      ),
    );
  }
}

enum EstadoAsistencia { completa, parcial, ausente }

extension EstadoAsistenciaExtension on EstadoAsistencia {
  String get texto {
    switch (this) {
      case EstadoAsistencia.completa:
        return 'Completa';
      case EstadoAsistencia.parcial:
        return 'Parcial';
      case EstadoAsistencia.ausente:
        return 'Ausente';
    }
  }
}

class AlumnoReporte {
  final String nombre;
  final String grupo;
  final int porcentaje;
  final EstadoAsistencia estado;

  const AlumnoReporte({
    required this.nombre,
    required this.grupo,
    required this.porcentaje,
    required this.estado,
  });
}
