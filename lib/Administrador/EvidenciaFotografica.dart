import 'package:flutter/material.dart';

class EvidenciaFotografica extends StatelessWidget {
  final Map<String, dynamic> alumno;

  const EvidenciaFotografica({super.key, required this.alumno});

  static const routeName = '/evidencia-fotografica';

  String _texto(dynamic valor, {String valorPredeterminado = ''}) {
    final texto = valor?.toString().trim() ?? '';
    return texto.isEmpty ? valorPredeterminado : texto;
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

  bool _tieneImagen(String? url) {
    return url != null && url.trim().isNotEmpty;
  }

  void _mostrarImagenCompleta(
    BuildContext context, {
    required String url,
    required String titulo,
  }) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.all(12),
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              InteractiveViewer(
                minScale: 0.8,
                maxScale: 5,
                child: Center(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progreso) {
                      if (progreso == null) return child;

                      return const SizedBox(
                        height: 350,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFFC400),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) {
                      return const SizedBox(
                        height: 350,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.broken_image_outlined,
                                color: Colors.white70,
                                size: 48,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'No se pudo cargar la fotografía',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 12,
                right: 48,
                child: Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    shadows: [Shadow(color: Colors.black, blurRadius: 5)],
                  ),
                ),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const amarillo = Color(0xFFFFC400);
    const fondo = Color(0xFFF8F8F8);

    final nombre = _texto(
      alumno['nombre'],
      valorPredeterminado: 'Alumno sin nombre',
    );
    final grupo = _texto(alumno['grupo'], valorPredeterminado: 'Sin grupo');
    final fecha = _texto(
      alumno['fecha'],
      valorPredeterminado: 'Fecha no disponible',
    );
    final estado = _texto(alumno['estado'], valorPredeterminado: 'Parcial');

    final fotoAntes = _texto(alumno['fotoAntesUrl']);
    final fotoDurante = _texto(alumno['fotoDuranteUrl']);
    final fotoFinal = _texto(alumno['fotoDespuesUrl']);

    final horaAntes = _texto(alumno['horaAntes'], valorPredeterminado: '--:--');
    final horaDurante = _texto(
      alumno['horaDurante'],
      valorPredeterminado: '--:--',
    );
    final horaFinal = _texto(
      alumno['horaFinal'] ?? alumno['horaDespues'],
      valorPredeterminado: '--:--',
    );

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
          'Evidencia Fotográfica',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
          child: Column(
            children: [
              _TarjetaAlumno(
                nombre: nombre,
                grupo: grupo,
                fecha: fecha,
                iniciales: _obtenerIniciales(nombre),
                estado: estado,
              ),
              const SizedBox(height: 12),
              _TarjetaEvidencia(
                icono: Icons.wb_sunny_outlined,
                titulo: 'Antes de la Misa',
                hora: horaAntes,
                imageUrl: fotoAntes,
                fondoFotografia: const Color(0xFFFFF6BC),
                onVerImagen: _tieneImagen(fotoAntes)
                    ? () => _mostrarImagenCompleta(
                        context,
                        url: fotoAntes,
                        titulo: 'Antes de la Misa',
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              _TarjetaEvidencia(
                icono: Icons.church_outlined,
                titulo: 'Durante la Misa',
                hora: horaDurante,
                imageUrl: fotoDurante,
                fondoFotografia: const Color(0xFFFFE94D),
                onVerImagen: _tieneImagen(fotoDurante)
                    ? () => _mostrarImagenCompleta(
                        context,
                        url: fotoDurante,
                        titulo: 'Durante la Misa',
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              _TarjetaEvidencia(
                icono: Icons.volunteer_activism_outlined,
                titulo: 'Al Finalizar',
                hora: horaFinal,
                imageUrl: fotoFinal,
                fondoFotografia: Colors.white,
                onVerImagen: _tieneImagen(fotoFinal)
                    ? () => _mostrarImagenCompleta(
                        context,
                        url: fotoFinal,
                        titulo: 'Al Finalizar',
                      )
                    : null,
              ),
            ],
          ),
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
        border: Border.all(color: amarillo),
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
                  'Grupo $grupo',
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
  final IconData icono;
  final String titulo;
  final String hora;
  final String imageUrl;
  final Color fondoFotografia;
  final VoidCallback? onVerImagen;

  const _TarjetaEvidencia({
    required this.icono,
    required this.titulo,
    required this.hora,
    required this.imageUrl,
    required this.fondoFotografia,
    required this.onVerImagen,
  });

  bool get tieneFotografia => imageUrl.trim().isNotEmpty;

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
        border: Border.all(color: amarillo),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icono, color: const Color(0xFF7A6700), size: 21),
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
                          ? 'Enviada a las $hora'
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
          GestureDetector(
            onTap: onVerImagen,
            child: Container(
              width: double.infinity,
              height: 190,
              decoration: BoxDecoration(
                color: fondoFotografia,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: amarillo, width: 1.3),
              ),
              clipBehavior: Clip.antiAlias,
              child: tieneFotografia
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;

                            return const Center(
                              child: CircularProgressIndicator(color: amarillo),
                            );
                          },
                          errorBuilder: (_, __, ___) {
                            return const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image_outlined,
                                  color: Color(0xFF9B8500),
                                  size: 34,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'No se pudo cargar la fotografía',
                                  style: TextStyle(
                                    color: Color(0xFF9B8500),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.zoom_in,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Ver foto',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported_outlined,
                          color: amarillo,
                          size: 34,
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
          ),
        ],
      ),
    );
  }
}
