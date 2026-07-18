import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sapi/Login.dart';
import 'package:sapi/Padre/alumno/registrar_asistencia.dart';
import 'package:sapi/styles/inicio_alumno_styles.dart';

class InicioAlumno extends StatefulWidget {
  const InicioAlumno({super.key});

  static const routeName = '/InicioAlumno';

  @override
  State<InicioAlumno> createState() => _InicioAlumnoState();
}

class _InicioAlumnoState extends State<InicioAlumno> {
  String nombreAlumno = '';
  bool cargandoNombre = true;

  @override
  void initState() {
    super.initState();
    obtenerNombreAlumno();
  }

  Future<void> obtenerNombreAlumno() async {
    try {
      final usuario = FirebaseAuth.instance.currentUser;

      if (usuario == null) {
        if (mounted) {
          setState(() {
            cargandoNombre = false;
          });
        }
        return;
      }

      final documento = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario.uid)
          .get();

      if (!mounted) return;

      setState(() {
        nombreAlumno = documento.data()?['nombre']?.toString() ?? 'Alumno';
        cargandoNombre = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        nombreAlumno = 'Alumno';
        cargandoNombre = false;
      });
    }
  }

  Future<void> _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      Login.routeName,
      (route) => false,
    );
  }

  void _abrirRegistrarAsistencia() {
    Navigator.pushNamed(context, RegistrarAsistencia.routeName);
  }

  void _abrirHistorial() {
    Navigator.pushNamed(context, '/mi-historial');
  }

  void _abrirCalendario() {
    Navigator.pushNamed(context, '/calendario');
  }

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: InicioAlumnoStyles.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: InicioAlumnoStyles.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    _bienvenida(),
                    const SizedBox(height: 6),
                    _tarjetaDomingo(),
                    const SizedBox(height: 14),

                    if (usuario != null)
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('asistencias')
                            .where('uidAlumno', isEqualTo: usuario.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return _mensajeError();
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(30),
                                child: CircularProgressIndicator(
                                  color: InicioAlumnoStyles.primaryYellow,
                                ),
                              ),
                            );
                          }

                          final asistencias =
                              snapshot.data?.docs.toList() ?? [];

                          asistencias.sort((a, b) {
                            final fechaA = _obtenerFecha(a.data()['fecha']);
                            final fechaB = _obtenerFecha(b.data()['fecha']);

                            return fechaB.compareTo(fechaA);
                          });

                          final completas = asistencias.where((documento) {
                            final estado = documento
                                .data()['estado']
                                ?.toString()
                                .toLowerCase();

                            return estado == 'completa' || estado == 'completo';
                          }).length;

                          final ultimasAsistencias = asistencias
                              .take(2)
                              .toList();

                          return Column(
                            children: [
                              _estadisticas(
                                totalMisas: asistencias.length,
                                completas: completas,
                              ),
                              const SizedBox(height: 10),
                              _ultimasAsistencias(
                                asistencias: ultimasAsistencias,
                              ),
                            ],
                          );
                        },
                      )
                    else
                      _mensajeSinSesion(),
                  ],
                ),
              ),
            ),

            _barraNavegacionInferior(),
          ],
        ),
      ),
    );
  }

  Widget _bienvenida() {
    final nombre = cargandoNombre || nombreAlumno.trim().isEmpty
        ? 'Alumno'
        : nombreAlumno;

    return Row(
      children: [
        Expanded(
          child: Text(
            'Bienvenido, $nombre!',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: InicioAlumnoStyles.welcomeText,
          ),
        ),
        PopupMenuButton<String>(
          icon: const CircleAvatar(
            radius: 14,
            backgroundColor: Color(0xFFD0D0D0),
            child: Icon(
              Icons.person_outline,
              color: Color(0xFF666666),
              size: 18,
            ),
          ),
          onSelected: (value) {
            if (value == 'cerrar_sesion') {
              _cerrarSesion();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem<String>(
              value: 'cerrar_sesion',
              child: Row(
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text('Cerrar sesión'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _tarjetaDomingo() {
    final hoyEsDomingo = DateTime.now().weekday == DateTime.sunday;

    return Container(
      width: double.infinity,
      padding: InicioAlumnoStyles.cardPadding,
      decoration: InicioAlumnoStyles.sundayCardDecoration,
      child: Row(
        children: [
          const Text('⛪', style: TextStyle(fontSize: 19)),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hoyEsDomingo ? '¡Hoy es domingo!' : 'Próxima misa dominical',
                  style: InicioAlumnoStyles.sundayTitle,
                ),
                const SizedBox(height: 2),
                Text(
                  hoyEsDomingo
                      ? 'Registra tu asistencia de hoy'
                      : 'Consulta las próximas fechas',
                  style: InicioAlumnoStyles.sundaySubtitle,
                ),
              ],
            ),
          ),

          SizedBox(
            height: 26,
            child: ElevatedButton(
              onPressed: _abrirCalendario,
              style: ElevatedButton.styleFrom(
                backgroundColor: InicioAlumnoStyles.primaryYellow,
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Calendario',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _estadisticas({required int totalMisas, required int completas}) {
    return Row(
      children: [
        Expanded(
          child: _StatisticCard(
            icon: Icons.calendar_month_outlined,
            number: totalMisas,
            label: 'Misas',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatisticCard(
            icon: Icons.check_circle_outline,
            number: completas,
            label: 'Completas',
          ),
        ),
      ],
    );
  }

  Widget _ultimasAsistencias({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> asistencias,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(9, 10, 9, 4),
      decoration: InicioAlumnoStyles.recentAttendanceDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Últimas Asistencias',
            style: InicioAlumnoStyles.sectionTitle,
          ),
          const SizedBox(height: 6),

          if (asistencias.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Todavía no tienes asistencias registradas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: InicioAlumnoStyles.textSecondary,
                  ),
                ),
              ),
            )
          else
            ...List.generate(asistencias.length, (index) {
              final datos = asistencias[index].data();

              return Column(
                children: [
                  _AttendanceItem(datos: datos),
                  if (index < asistencias.length - 1)
                    const Divider(
                      height: 12,
                      color: InicioAlumnoStyles.dividerColor,
                    ),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _barraNavegacionInferior() {
    return Container(
      width: double.infinity,
      height: 150,
      color: Colors.white,
      padding: const EdgeInsets.only(left: 22, right: 22, top: 8, bottom: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _BottomNavigationItem(
                  icon: Icons.camera_alt_outlined,
                  label: 'Registrar Asistencia',
                  onTap: _abrirRegistrarAsistencia,
                ),
              ),

              const SizedBox(width: 20),

              Expanded(
                child: _BottomNavigationItem(
                  icon: Icons.history,
                  label: 'Historial de Asistencias',
                  onTap: _abrirHistorial,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: 130,
            child: _BottomNavigationItem(
              icon: Icons.calendar_today_outlined,
              label: 'Calendario de Asistencias',
              onTap: _abrirCalendario,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mensajeError() {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(
        child: Text(
          'No fue posible cargar tus asistencias.',
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _mensajeSinSesion() {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(child: Text('No se encontró una sesión activa.')),
    );
  }

  DateTime _obtenerFecha(dynamic fecha) {
    if (fecha is Timestamp) {
      return fecha.toDate();
    }

    if (fecha is DateTime) {
      return fecha;
    }

    if (fecha is String) {
      return DateTime.tryParse(fecha) ?? DateTime(2000);
    }

    return DateTime(2000);
  }
}

class _StatisticCard extends StatelessWidget {
  final IconData icon;
  final int number;
  final String label;

  const _StatisticCard({
    required this.icon,
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: InicioAlumnoStyles.statisticsCardDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFFFF9D22), size: 25),
              const SizedBox(width: 10),
              Text('$number', style: InicioAlumnoStyles.statisticNumber),
            ],
          ),
          const SizedBox(height: 3),
          Text(label, style: InicioAlumnoStyles.statisticLabel),
        ],
      ),
    );
  }
}

class _AttendanceItem extends StatelessWidget {
  final Map<String, dynamic> datos;

  const _AttendanceItem({required this.datos});

  @override
  Widget build(BuildContext context) {
    final fecha = _obtenerFecha(datos['fecha']);
    final estado =
        datos['estado']?.toString().trim().toLowerCase() ?? 'parcial';

    final esCompleta = estado == 'completa' || estado == 'completo';

    final cantidadFotos = _calcularCantidadFotos(datos);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatearFecha(fecha),
                  style: InicioAlumnoStyles.attendanceDate,
                ),
                const SizedBox(height: 3),
                Text(
                  '$cantidadFotos/3 fotos',
                  style: InicioAlumnoStyles.attendancePhotos,
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: esCompleta
                ? InicioAlumnoStyles.completeStatusDecoration
                : InicioAlumnoStyles.partialStatusDecoration,
            child: Row(
              children: [
                Icon(
                  esCompleta ? Icons.check_circle_outline : Icons.info_outline,
                  size: 9,
                  color: esCompleta
                      ? InicioAlumnoStyles.completeText
                      : InicioAlumnoStyles.partialText,
                ),
                const SizedBox(width: 2),
                Text(
                  esCompleta ? 'Completa' : 'Parcial',
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w600,
                    color: esCompleta
                        ? InicioAlumnoStyles.completeText
                        : InicioAlumnoStyles.partialText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _calcularCantidadFotos(Map<String, dynamic> datos) {
    final posiblesCampos = [
      'fotoAntes',
      'fotoDurante',
      'fotoDespues',
      'fotoAntesUrl',
      'fotoDuranteUrl',
      'fotoDespuesUrl',
      'imagenAntes',
      'imagenDurante',
      'imagenDespues',
    ];

    int cantidad = 0;

    for (final campo in posiblesCampos) {
      final valor = datos[campo];

      if (valor != null && valor.toString().trim().isNotEmpty) {
        cantidad++;
      }
    }

    /*
      Se limita a tres porque una misma fotografía podría existir
      con nombres diferentes de campo.
    */
    if (cantidad > 3) {
      return 3;
    }

    /*
      Si tu documento guarda directamente una cantidad de fotografías,
      se utiliza ese valor.
    */
    final cantidadGuardada = datos['cantidadFotos'];

    if (cantidadGuardada is int) {
      return cantidadGuardada.clamp(0, 3);
    }

    return cantidad;
  }

  DateTime _obtenerFecha(dynamic fecha) {
    if (fecha is Timestamp) {
      return fecha.toDate();
    }

    if (fecha is DateTime) {
      return fecha;
    }

    if (fecha is String) {
      return DateTime.tryParse(fecha) ?? DateTime.now();
    }

    return DateTime.now();
  }

  String _formatearFecha(DateTime fecha) {
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
}

class _BottomNavigationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomNavigationItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: InicioAlumnoStyles.primaryYellow,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),

              const SizedBox(height: 6),

              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: InicioAlumnoStyles.bottomNavigationText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
