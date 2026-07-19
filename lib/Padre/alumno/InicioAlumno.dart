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
  bool cargandoMisa = true;
  String tituloMisa = 'Consultando próximas misas...';
  String subtituloMisa = '';

  @override
  void initState() {
    super.initState();
    obtenerNombreAlumno();
    _cargarInformacionMisa();
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

  Future<void> _cargarInformacionMisa() async {
    try {
      final ahora = DateTime.now();

      final hoy = DateTime(ahora.year, ahora.month, ahora.day);

      final manana = hoy.add(const Duration(days: 1));

      /*
     * Primero se comprueba si el administrador registró
     * una misa especial para el día de hoy.
     */
      final misasEspecialesDeHoy = await FirebaseFirestore.instance
          .collection('misas_especiales')
          .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(hoy))
          .where('fecha', isLessThan: Timestamp.fromDate(manana))
          .orderBy('fecha')
          .get();

      final hoyEsDomingo = hoy.weekday == DateTime.sunday;
      final hayMisaEspecialHoy = misasEspecialesDeHoy.docs.isNotEmpty;

      /*
     * Puede ocurrir que hoy sea domingo y también exista
     * una misa especial registrada por el administrador.
     */
      if (hoyEsDomingo && hayMisaEspecialHoy) {
        final datos = misasEspecialesDeHoy.docs.first.data();

        final nombreMisa = _obtenerNombreMisa(datos['nombre']);

        if (!mounted) return;

        setState(() {
          cargandoMisa = false;
          tituloMisa = '¡Hoy es domingo y hay misa especial!';
          subtituloMisa =
              'Misa dominical y $nombreMisa. Registra tu asistencia.';
        });

        return;
      }

      /*
     * Si solamente es domingo, se muestra la misa dominical.
     */
      if (hoyEsDomingo) {
        if (!mounted) return;

        setState(() {
          cargandoMisa = false;
          tituloMisa = '¡Hoy es domingo!';
          subtituloMisa = 'Hay misa dominical. Registra tu asistencia de hoy.';
        });

        return;
      }

      /*
     * Si no es domingo, pero existe una misa especial hoy.
     */
      if (hayMisaEspecialHoy) {
        final datos = misasEspecialesDeHoy.docs.first.data();

        final nombreMisa = _obtenerNombreMisa(datos['nombre']);

        if (!mounted) return;

        setState(() {
          cargandoMisa = false;
          tituloMisa = '¡Hoy tienes una misa especial!';
          subtituloMisa = '$nombreMisa. Puedes registrar tu asistencia.';
        });

        return;
      }

      /*
     * Busca la siguiente misa especial después de hoy.
     */
      final proximasMisasEspeciales = await FirebaseFirestore.instance
          .collection('misas_especiales')
          .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(manana))
          .orderBy('fecha')
          .limit(1)
          .get();

      final proximoDomingo = _obtenerProximoDomingo(hoy);

      /*
     * Si no hay ninguna misa especial próxima,
     * se muestra el siguiente domingo.
     */
      if (proximasMisasEspeciales.docs.isEmpty) {
        if (!mounted) return;

        setState(() {
          cargandoMisa = false;
          tituloMisa = 'Próxima misa dominical';
          subtituloMisa = _formatearFechaMisa(proximoDomingo);
        });

        return;
      }

      final documentoMisa = proximasMisasEspeciales.docs.first;
      final datosMisa = documentoMisa.data();

      final fechaFirestore = datosMisa['fecha'];

      if (fechaFirestore is! Timestamp) {
        if (!mounted) return;

        setState(() {
          cargandoMisa = false;
          tituloMisa = 'Próxima misa dominical';
          subtituloMisa = _formatearFechaMisa(proximoDomingo);
        });

        return;
      }

      final fechaMisaEspecialOriginal = fechaFirestore.toDate();

      final fechaMisaEspecial = DateTime(
        fechaMisaEspecialOriginal.year,
        fechaMisaEspecialOriginal.month,
        fechaMisaEspecialOriginal.day,
      );

      final nombreMisa = _obtenerNombreMisa(datosMisa['nombre']);

      /*
     * Si la misa especial y el domingo son el mismo día,
     * se muestran los dos eventos.
     */
      if (_esMismaFecha(fechaMisaEspecial, proximoDomingo)) {
        if (!mounted) return;

        setState(() {
          cargandoMisa = false;
          tituloMisa = 'Próximo domingo con misa especial';
          subtituloMisa =
              '$nombreMisa · ${_formatearFechaMisa(fechaMisaEspecial)}';
        });

        return;
      }

      /*
     * Se muestra el evento que ocurra primero:
     * la misa especial o el próximo domingo.
     */
      if (fechaMisaEspecial.isBefore(proximoDomingo)) {
        if (!mounted) return;

        setState(() {
          cargandoMisa = false;
          tituloMisa = 'Próxima misa especial';
          subtituloMisa =
              '$nombreMisa · ${_formatearFechaMisa(fechaMisaEspecial)}';
        });
      } else {
        if (!mounted) return;

        setState(() {
          cargandoMisa = false;
          tituloMisa = 'Próxima misa dominical';
          subtituloMisa = _formatearFechaMisa(proximoDomingo);
        });
      }
    } catch (error) {
      debugPrint('Error al cargar la información de misas: $error');

      if (!mounted) return;

      final hoy = DateTime.now();
      final proximoDomingo = _obtenerProximoDomingo(hoy);

      setState(() {
        cargandoMisa = false;
        tituloMisa = 'Próxima misa dominical';
        subtituloMisa = _formatearFechaMisa(proximoDomingo);
      });
    }
  }

  DateTime _obtenerProximoDomingo(DateTime fecha) {
    final fechaNormalizada = DateTime(fecha.year, fecha.month, fecha.day);

    int diasFaltantes = (DateTime.sunday - fechaNormalizada.weekday) % 7;

    /*
   * Cuando hoy sea domingo, se toma el domingo siguiente.
   * Aunque este caso normalmente se maneja antes,
   * se deja como protección adicional.
   */
    if (diasFaltantes == 0) {
      diasFaltantes = 7;
    }

    return fechaNormalizada.add(Duration(days: diasFaltantes));
  }

  bool _esMismaFecha(DateTime fecha1, DateTime fecha2) {
    return fecha1.year == fecha2.year &&
        fecha1.month == fecha2.month &&
        fecha1.day == fecha2.day;
  }

  String _obtenerNombreMisa(dynamic nombre) {
    final texto = nombre?.toString().trim() ?? '';

    if (texto.isEmpty) {
      return 'Misa especial';
    }

    return texto;
  }

  String _formatearFechaMisa(DateTime fecha) {
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

    return '${dias[fecha.weekday - 1]} '
        '${fecha.day} de ${meses[fecha.month - 1]}';
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
        child: SingleChildScrollView(
          padding: InicioAlumnoStyles.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
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

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(30),
                          child: CircularProgressIndicator(
                            color: InicioAlumnoStyles.primaryYellow,
                          ),
                        ),
                      );
                    }

                    final asistencias = snapshot.data?.docs.toList() ?? [];

                    asistencias.sort((a, b) {
                      final fechaA = _obtenerFecha(a.data()['fecha']);
                      final fechaB = _obtenerFecha(b.data()['fecha']);

                      return fechaB.compareTo(fechaA);
                    });

                    final completas = asistencias.where((documento) {
                      final datos = documento.data();
                      final estado = datos['estado']
                          ?.toString()
                          .trim()
                          .toLowerCase();

                      if (estado == 'completa' || estado == 'completo') {
                        return true;
                      }

                      final fotos =
                          [
                            datos['fotoAntesUrl'],
                            datos['fotoDuranteUrl'],
                            datos['fotoDespuesUrl'],
                          ].where((foto) {
                            return foto != null &&
                                foto.toString().trim().isNotEmpty;
                          }).length;

                      return fotos == 3;
                    }).length;

                    final ultimasAsistencias = asistencias.take(2).toList();

                    return Column(
                      children: [
                        _estadisticas(
                          totalMisas: asistencias.length,
                          completas: completas,
                        ),

                        const SizedBox(height: 18),

                        // Los botones ahora forman parte del contenido
                        // desplazable de la pantalla.
                        _barraNavegacionInferior(),

                        const SizedBox(height: 18),

                        // El recuadro se muestra debajo de los botones.
                        _ultimasAsistencias(asistencias: ultimasAsistencias),

                        const SizedBox(height: 24),
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
    return Container(
      width: double.infinity,
      padding: InicioAlumnoStyles.cardPadding,
      decoration: InicioAlumnoStyles.sundayCardDecoration,
      child: Row(
        children: [
          const Text('⛪', style: TextStyle(fontSize: 19)),

          const SizedBox(width: 10),

          Expanded(
            child: cargandoMisa
                ? const Row(
                    children: [
                      SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: InicioAlumnoStyles.primaryYellow,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Consultando próximas misas...',
                          style: InicioAlumnoStyles.sundayTitle,
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tituloMisa,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: InicioAlumnoStyles.sundayTitle,
                      ),

                      const SizedBox(height: 2),

                      Text(
                        subtituloMisa,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: InicioAlumnoStyles.sundaySubtitle,
                      ),
                    ],
                  ),
          ),

          const SizedBox(width: 8),

          SizedBox(
            height: 40,
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
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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

  Widget _barraNavegacionInferior() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _BottomNavigationItem(
              icon: Icons.camera_alt_outlined,
              label: 'Registrar Asistencia',
              onTap: _abrirRegistrarAsistencia,
            ),
          ),

          Expanded(
            child: _BottomNavigationItem(
              icon: Icons.history,
              label: 'Historial',
              onTap: _abrirHistorial,
            ),
          ),

          Expanded(
            child: _BottomNavigationItem(
              icon: Icons.calendar_today_outlined,
              label: 'Calendario',
              onTap: _abrirCalendario,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ultimasAsistencias({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> asistencias,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 18),
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
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: InicioAlumnoStyles.primaryYellow,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),

              const SizedBox(height: 6),

              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: InicioAlumnoStyles.bottomNavigationText.copyWith(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
