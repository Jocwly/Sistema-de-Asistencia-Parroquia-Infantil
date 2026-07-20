import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:sapi/Administrador/Calendario.dart';
import 'package:sapi/Administrador/ControlAsistencia.dart';
import 'package:sapi/Administrador/GestionGrupos.dart';
import 'package:sapi/Administrador/Reportes.dart';
import 'package:sapi/services/grupos_service.dart';
import 'package:sapi/styles/InicioAdminStyles.dart';

class InicioAdmin extends StatelessWidget {
  const InicioAdmin({super.key});

  static const routeName = '/InicioAdmin';

  void _cerrarSesion(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/login');
  }

  DateTime? _convertirFecha(dynamic valor) {
    if (valor is Timestamp) {
      return valor.toDate().toLocal();
    }

    if (valor is DateTime) {
      return valor.toLocal();
    }

    if (valor is String) {
      return DateTime.tryParse(valor)?.toLocal();
    }

    return null;
  }

  bool _esHoy(DateTime? fecha) {
    if (fecha == null) return false;

    final hoy = DateTime.now();

    return fecha.year == hoy.year &&
        fecha.month == hoy.month &&
        fecha.day == hoy.day;
  }

  String _obtenerEstado(Map<String, dynamic> data) {
    final fotoAntes = data['fotoAntesUrl']?.toString().trim() ?? '';
    final fotoDurante = data['fotoDuranteUrl']?.toString().trim() ?? '';
    final fotoDespues = data['fotoDespuesUrl']?.toString().trim() ?? '';

    final tieneAntes = fotoAntes.isNotEmpty;
    final tieneDurante = fotoDurante.isNotEmpty;
    final tieneDespues = fotoDespues.isNotEmpty;

    if (tieneAntes && tieneDurante && tieneDespues) {
      return 'Completa';
    }

    if (tieneAntes || tieneDurante || tieneDespues) {
      return 'Parcial';
    }

    return 'Incompleta';
  }

  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return 'Sin fecha';

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

    return '${fecha.day} ${meses[fecha.month - 1]}';
  }

  String _obtenerNombre(Map<String, dynamic> data) {
    final nombre = data['nombreAlumno']?.toString().trim() ?? '';
    final apellidos = data['apellidosAlumno']?.toString().trim() ?? '';

    final nombreCompleto = '$nombre $apellidos'.trim();

    if (nombreCompleto.isNotEmpty) {
      return nombreCompleto;
    }

    return 'Alumno sin nombre';
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
      return partes.first[0].toUpperCase();
    }

    return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InicioAdminStyles.fondo,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: InicioAdminStyles.paddingPantalla,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _construirEncabezado(context),

              const SizedBox(height: 14),

              _construirContadores(),

              const SizedBox(height: 20),

              _construirMenu(context),

              const SizedBox(height: 20),

              const _AsistenciasRecientes(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirEncabezado(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Bienvenido, Admin!',
            style: InicioAdminStyles.tituloPrincipal,
          ),
        ),
        PopupMenuButton<String>(
          tooltip: 'Opciones',
          onSelected: (value) {
            if (value == 'cerrar_sesion') {
              _cerrarSesion(context);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem<String>(
              value: 'cerrar_sesion',
              child: Row(
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 10),
                  Text('Cerrar sesión'),
                ],
              ),
            ),
          ],
          child: Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFD6D6D6),
            ),
            child: const Icon(
              Icons.account_circle_outlined,
              color: Color(0xFF666666),
              size: 30,
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirContadores() {
    return Row(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('asistencias')
                .snapshots(),
            builder: (context, snapshot) {
              int completasHoy = 0;

              if (snapshot.hasData) {
                for (final documento in snapshot.data!.docs) {
                  final data = documento.data();
                  final fecha = _convertirFecha(data['fecha']);
                  final estado = _obtenerEstado(data);

                  if (_esHoy(fecha) && estado == 'Completa') {
                    completasHoy++;
                  }
                }
              }

              return _ContadorCard(
                icono: Icons.check_circle_outline_rounded,
                numero: completasHoy,
                texto: 'Completas hoy',
                cargando: snapshot.connectionState == ConnectionState.waiting,
              );
            },
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: GruposService().obtenerGrupos(),
            builder: (context, snapshot) {
              final grupos =
                  snapshot.data?.docs
                      .map(
                        (documento) =>
                            documento.data()['grupo']?.toString().trim() ?? '',
                      )
                      .where((grupo) => grupo.isNotEmpty)
                      .map((grupo) => grupo.toUpperCase())
                      .toSet() ??
                  <String>{};

              return _ContadorCard(
                icono: Icons.groups_rounded,
                numero: grupos.length,
                texto: 'Grupos',
                cargando: snapshot.connectionState == ConnectionState.waiting,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _construirMenu(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MenuCard(
                icono: Icons.groups_rounded,
                texto: 'Grupos',
                onTap: () {
                  Navigator.pushNamed(context, GestionGrupos.routeName);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MenuCard(
                icono: Icons.file_copy_outlined,
                texto: 'Asistencias',
                onTap: () {
                  Navigator.pushNamed(context, ControlAsistencia.routeName);
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _MenuCard(
                icono: Icons.calendar_today_outlined,
                texto: 'Calendario',
                onTap: () {
                  Navigator.pushNamed(context, CalendarioAdmin.routeName);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MenuCard(
                icono: Icons.description_outlined,
                texto: 'Reportes',
                onTap: () {
                  Navigator.pushNamed(context, GenerarReportes.routeName);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ContadorCard extends StatelessWidget {
  final IconData icono;
  final int numero;
  final String texto;
  final bool cargando;

  const _ContadorCard({
    required this.icono,
    required this.numero,
    required this.texto,
    required this.cargando,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 17),
      decoration: InicioAdminStyles.contadorDecoration,
      child: Row(
        children: [
          Icon(icono, color: InicioAdminStyles.naranja, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (cargando)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: InicioAdminStyles.naranja,
                    ),
                  )
                else
                  Text(
                    numero.toString(),
                    style: InicioAdminStyles.numeroContador,
                  ),
                const SizedBox(height: 1),
                Text(
                  texto,
                  textAlign: TextAlign.center,
                  style: InicioAdminStyles.textoContador,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icono;
  final IconData? iconoSecundario;
  final String texto;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icono,
    required this.texto,
    required this.onTap,
    this.iconoSecundario,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(13),
            child: Ink(
              height: 90,
              width: 180,
              decoration: InicioAdminStyles.botonDecoration,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icono, size: 45, color: Colors.white),
                  if (iconoSecundario != null)
                    Positioned(
                      right: 38,
                      bottom: 11,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: InicioAdminStyles.amarillo,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(texto, style: InicioAdminStyles.textoBoton),
      ],
    );
  }
}

class _AsistenciasRecientes extends StatelessWidget {
  const _AsistenciasRecientes();

  DateTime? _convertirFecha(dynamic valor) {
    if (valor is Timestamp) {
      return valor.toDate().toLocal();
    }

    if (valor is DateTime) {
      return valor.toLocal();
    }

    if (valor is String) {
      return DateTime.tryParse(valor)?.toLocal();
    }

    return null;
  }

  String _obtenerEstado(Map<String, dynamic> data) {
    final antes = data['fotoAntesUrl']?.toString().trim().isNotEmpty == true;
    final durante =
        data['fotoDuranteUrl']?.toString().trim().isNotEmpty == true;
    final despues =
        data['fotoDespuesUrl']?.toString().trim().isNotEmpty == true;

    if (antes && durante && despues) {
      return 'Completa';
    }

    if (antes || durante || despues) {
      return 'Parcial';
    }

    return 'Incompleta';
  }

  String _obtenerNombre(Map<String, dynamic> data) {
    final nombre = data['nombreAlumno']?.toString().trim() ?? '';
    final apellidos = data['apellidosAlumno']?.toString().trim() ?? '';

    final nombreCompleto = '$nombre $apellidos'.trim();

    return nombreCompleto.isEmpty ? 'Alumno sin nombre' : nombreCompleto;
  }

  String _obtenerIniciales(String nombre) {
    final partes = nombre
        .trim()
        .split(RegExp(r'\s+'))
        .where((parte) => parte.isNotEmpty)
        .toList();

    if (partes.isEmpty) return '?';

    if (partes.length == 1) {
      return partes[0][0].toUpperCase();
    }

    return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
  }

  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return 'Sin fecha';

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

    return '${fecha.day} ${meses[fecha.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(7, 8, 7, 5),
      decoration: InicioAdminStyles.recientesDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              'Asistencias Recientes',
              style: InicioAdminStyles.tituloSeccion,
            ),
          ),

          const SizedBox(height: 5),

          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('asistencias')
                .orderBy('fecha', descending: true)
                .limit(15)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'No se pudieron cargar las asistencias',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: InicioAdminStyles.amarillo,
                  ),
                );
              }

              final documentos = snapshot.data?.docs ?? [];

              if (documentos.isEmpty) {
                return const Center(
                  child: Text(
                    'Todavía no hay asistencias registradas',
                    style: TextStyle(
                      fontSize: 11,
                      color: InicioAdminStyles.textoSecundario,
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: documentos.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  thickness: 0.7,
                  color: Color(0xFFFFE2A3),
                ),
                itemBuilder: (context, index) {
                  final data = documentos[index].data();
                  final nombre = _obtenerNombre(data);

                  final grupo =
                      data['grupo']?.toString().trim().isNotEmpty == true
                      ? data['grupo'].toString().trim()
                      : 'Sin grupo';

                  final fecha = _convertirFecha(data['fecha']);
                  final estado = _obtenerEstado(data);

                  return _AsistenciaRecienteItem(
                    iniciales: _obtenerIniciales(nombre),
                    nombre: nombre,
                    fecha: _formatearFecha(fecha),
                    grupo: grupo,
                    estado: estado,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AsistenciaRecienteItem extends StatelessWidget {
  final String iniciales;
  final String nombre;
  final String fecha;
  final String grupo;
  final String estado;

  const _AsistenciaRecienteItem({
    required this.iniciales,
    required this.nombre,
    required this.fecha,
    required this.grupo,
    required this.estado,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 47,
      child: Row(
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: InicioAdminStyles.naranja,
            child: Text(
              iniciales,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: InicioAdminStyles.nombreAlumno,
                ),
                const SizedBox(height: 2),
                Text(
                  '$fecha · Grupo $grupo',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: InicioAdminStyles.informacionAlumno,
                ),
              ],
            ),
          ),

          const SizedBox(width: 5),

          _EstadoChip(estado: estado),
        ],
      ),
    );
  }
}

class _EstadoChip extends StatelessWidget {
  final String estado;

  const _EstadoChip({required this.estado});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color fondo;
    IconData icono;

    switch (estado) {
      case 'Completa':
        color = InicioAdminStyles.verde;
        fondo = InicioAdminStyles.verdeClaro;
        icono = Icons.check_circle_outline;
        break;

      case 'Parcial':
        color = InicioAdminStyles.naranjaEstado;
        fondo = InicioAdminStyles.naranjaEstadoClaro;
        icono = Icons.access_time_rounded;
        break;

      default:
        color = InicioAdminStyles.rojo;
        fondo = InicioAdminStyles.rojoClaro;
        icono = Icons.cancel_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, color: color, size: 10),
          const SizedBox(width: 3),
          Text(
            estado,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
