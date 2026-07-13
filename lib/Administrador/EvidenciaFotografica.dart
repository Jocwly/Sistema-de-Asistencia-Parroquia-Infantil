import 'package:flutter/material.dart';

class EvidenciaFotografica extends StatelessWidget {
  final Map<String, dynamic> alumno;

  const EvidenciaFotografica({
    super.key,
    required this.alumno,
  });

  static const routeName = '/evidencia-fotografica';

  String _obtenerIniciales(String nombre) {
    final partes = nombre.trim().split(' ');

    if (partes.length == 1) {
      return partes.first.substring(0, 1).toUpperCase();
    }

    return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    const amarillo = Color(0xFFFFC400);
    const fondo = Color(0xFFF8F8F8);

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
          ),
        ),
        title: const Text(
          'Evidencia Fotográfica',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            color: amarillo,
            height: 1,
            thickness: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
        child: Column(
          children: [
            _TarjetaAlumno(
              nombre: alumno['nombre'],
              grupo: alumno['grupo'],
              fecha: alumno['fecha'],
              iniciales: _obtenerIniciales(alumno['nombre']),
              estado: alumno['estado'],
            ),
            const SizedBox(height: 12),
            _TarjetaEvidencia(
              emoji: '🌅',
              titulo: 'Antes de la Misa',
              hora: alumno['horaAntes'],
              tieneFotografia: alumno['antes'] == true,
              fondoFotografia: const Color(0xFFFFF6BC),
            ),
            const SizedBox(height: 12),
            _TarjetaEvidencia(
              emoji: '⛪',
              titulo: 'Durante la Misa',
              hora: alumno['horaDurante'],
              tieneFotografia: alumno['durante'] == true,
              fondoFotografia: const Color(0xFFFFE94D),
            ),
            const SizedBox(height: 12),
            _TarjetaEvidencia(
              emoji: '🙏',
              titulo: 'Al Finalizar',
              hora: alumno['horaFinal'],
              tieneFotografia: alumno['final'] == true,
              fondoFotografia: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaAlumno extends StatelessWidget {
  final String nombre;
  final String grupo;
  final String fecha;
  final String iniciales;
  final String estado;

  const _TarjetaAlumno({
    required this.nombre,
    required this.grupo,
    required this.fecha,
    required this.iniciales,
    required this.estado,
  });

  @override
  Widget build(BuildContext context) {
    const amarillo = Color(0xFFFFC400);
    final completa = estado == 'Completa';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: amarillo,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: amarillo,
            child: Text(
              iniciales,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  grupo,
                  style: const TextStyle(
                    color: Color(0xFF9B8500),
                    fontSize: 10,
                  ),
                ),
                Text(
                  fecha,
                  style: const TextStyle(
                    color: Color(0xFF9B8500),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: completa
                        ? const Color(0xFFD7F7EB)
                        : const Color(0xFFFFF0C7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        completa
                            ? Icons.check_circle_outline
                            : Icons.access_time,
                        color: completa
                            ? const Color(0xFF00AD7C)
                            : const Color(0xFFE5A100),
                        size: 12,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        estado,
                        style: TextStyle(
                          color: completa
                              ? const Color(0xFF00AD7C)
                              : const Color(0xFFE5A100),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaEvidencia extends StatelessWidget {
  final String emoji;
  final String titulo;
  final String? hora;
  final bool tieneFotografia;
  final Color fondoFotografia;

  const _TarjetaEvidencia({
    required this.emoji,
    required this.titulo,
    required this.hora,
    required this.tieneFotografia,
    required this.fondoFotografia,
  });

  @override
  Widget build(BuildContext context) {
    const amarillo = Color(0xFFFFC400);
    const verde = Color(0xFF00AD7C);
    const rojo = Color(0xFFF44336);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 13, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: amarillo,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tieneFotografia
                          ? 'Enviada a las ${hora ?? '--:--'}'
                          : 'No se envió evidencia',
                      style: const TextStyle(
                        color: Color(0xFF9B8500),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                tieneFotografia
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                color: tieneFotografia ? verde : rojo,
                size: 19,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 130,
            decoration: BoxDecoration(
              color: fondoFotografia,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: amarillo,
                width: 1.3,
              ),
            ),
            child: tieneFotografia
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.photo_camera_outlined,
                        color: amarillo,
                        size: 34,
                      ),
                      const SizedBox(height: 9),
                      const Text(
                        'Fotografía registrada',
                        style: TextStyle(
                          color: Color(0xFF6F5D00),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        hora ?? '--:--',
                        style: const TextStyle(
                          color: Color(0xFFA28A00),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: amarillo,
                        size: 31,
                      ),
                      SizedBox(height: 9),
                      Text(
                        'Sin fotografía',
                        style: TextStyle(
                          color: Color(0xFF9B8500),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}