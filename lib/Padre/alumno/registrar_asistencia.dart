import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sapi/services/camera_service.dart';
import 'package:sapi/services/cloudinary_service.dart';
import 'package:sapi/styles/registrar_asistencia_styles.dart';

class RegistrarAsistencia extends StatefulWidget {
  const RegistrarAsistencia({super.key});

  static const routeName = '/registrar-asistencia';

  @override
  State<RegistrarAsistencia> createState() => _RegistrarAsistenciaState();
}

class _RegistrarAsistenciaState extends State<RegistrarAsistencia> {
  bool _isUploading = false;
  String? _photoSending;

  // Indica si todavía se está consultando Firestore.
  bool _verificandoDiaMisa = true;

  // Indica si hoy es domingo o hay una misa especial.
  bool _esDiaDeMisa = false;

  // Mensaje que se mostrará en la pantalla.
  String _mensajeDiaMisa = '';

  String nombreAlumno = '';
  String grupoAlumno = '';

  final Map<String, String?> _photos = {
    'antes_misa': null,
    'durante_misa': null,
    'al_finalizar': null,
  };

  final Map<String, bool> _sentPhotos = {
    'antes_misa': false,
    'durante_misa': false,
    'al_finalizar': false,
  };

  int get completedPhotos {
    return _sentPhotos.values.where((enviada) => enviada).length;
  }

  @override
  void initState() {
    super.initState();

    _obtenerDatosAlumno();
    _verificarDiaDeMisa();
  }

  Future<void> _obtenerDatosAlumno() async {
    try {
      final usuario = FirebaseAuth.instance.currentUser;

      if (usuario == null) return;

      final documento = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario.uid)
          .get();

      if (!documento.exists) return;

      final data = documento.data();

      if (data == null || !mounted) return;

      setState(() {
        nombreAlumno = data['nombre']?.toString() ?? '';
        grupoAlumno = data['grupo']?.toString() ?? '';
      });
    } catch (e) {
      debugPrint('Error al obtener datos del alumno: $e');
    }
  }

  String _fechaId(DateTime fecha) {
    return '${fecha.year}-'
        '${fecha.month.toString().padLeft(2, '0')}-'
        '${fecha.day.toString().padLeft(2, '0')}';
  }

  String _documentoAsistenciaId(String uid, DateTime fecha) {
    return '${uid}_${_fechaId(fecha)}';
  }

  /// Comprueba si el alumno puede registrar asistencia hoy.
  ///
  /// Se permite cuando:
  /// 1. Hoy es domingo.
  /// 2. Hay un documento en misasEspeciales con la fecha de hoy.
  Future<void> _verificarDiaDeMisa() async {
    if (mounted) {
      setState(() {
        _verificandoDiaMisa = true;
      });
    }

    try {
      final ahora = DateTime.now();
      final hoy = DateTime(ahora.year, ahora.month, ahora.day);

      /*
       * Si hoy es domingo, se permite registrar asistencia
       * sin consultar misasEspeciales.
       */
      if (ahora.weekday == DateTime.sunday) {
        if (!mounted) return;

        setState(() {
          _esDiaDeMisa = true;
          _verificandoDiaMisa = false;
          _mensajeDiaMisa = 'Hoy es domingo. Puedes registrar tu asistencia.';
        });

        await _cargarEvidenciasDeHoy();
        return;
      }

      /*
       * Si no es domingo, busca una misa especial con fecha de hoy.
       *
       * Se consulta desde las 00:00 de hoy hasta antes de las
       * 00:00 del día siguiente.
       */
      final inicioDelDia = hoy;
      final inicioDiaSiguiente = hoy.add(const Duration(days: 1));

      final resultado = await FirebaseFirestore.instance
          .collection('misasEspeciales')
          .where(
            'fecha',
            isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDelDia),
          )
          .where('fecha', isLessThan: Timestamp.fromDate(inicioDiaSiguiente))
          .limit(1)
          .get();

      final existeMisaEspecial = resultado.docs.isNotEmpty;

      if (!mounted) return;

      setState(() {
        _esDiaDeMisa = existeMisaEspecial;
        _verificandoDiaMisa = false;

        _mensajeDiaMisa = existeMisaEspecial
            ? 'Hoy hay una misa especial. Puedes registrar tu asistencia.'
            : 'Hoy no hay misa programada. No puedes registrar asistencia.';
      });

      if (existeMisaEspecial) {
        await _cargarEvidenciasDeHoy();
      }
    } catch (e) {
      debugPrint('Error al verificar el día de misa: $e');

      if (!mounted) return;

      setState(() {
        _esDiaDeMisa = false;
        _verificandoDiaMisa = false;
        _mensajeDiaMisa =
            'No se pudo verificar si hoy hay misa. Inténtalo nuevamente.';
      });
    }
  }

  Future<void> _cargarEvidenciasDeHoy() async {
    try {
      final usuario = FirebaseAuth.instance.currentUser;

      if (usuario == null) return;

      final ahora = DateTime.now();

      final documentoId = _documentoAsistenciaId(usuario.uid, ahora);

      final documento = await FirebaseFirestore.instance
          .collection('asistencias')
          .doc(documentoId)
          .get();

      if (!documento.exists) return;

      final data = documento.data();

      if (data == null || !mounted) return;

      final fotoAntes = data['fotoAntesUrl']?.toString();
      final fotoDurante = data['fotoDuranteUrl']?.toString();
      final fotoDespues = data['fotoDespuesUrl']?.toString();

      setState(() {
        _photos['antes_misa'] = fotoAntes;
        _photos['durante_misa'] = fotoDurante;
        _photos['al_finalizar'] = fotoDespues;

        _sentPhotos['antes_misa'] = fotoAntes != null && fotoAntes.isNotEmpty;

        _sentPhotos['durante_misa'] =
            fotoDurante != null && fotoDurante.isNotEmpty;

        _sentPhotos['al_finalizar'] =
            fotoDespues != null && fotoDespues.isNotEmpty;
      });
    } catch (e) {
      debugPrint('Error al cargar evidencias: $e');
    }
  }

  Future<void> _takePhoto(String photoKey) async {
    /*
     * Protección adicional.
     *
     * Aunque los botones estén bloqueados, este método
     * tampoco permite abrir la cámara si no hay misa.
     */
    if (_verificandoDiaMisa) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Se está verificando si hoy hay misa.')),
      );

      return;
    }

    if (!_esDiaDeMisa) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No puedes tomar evidencias porque hoy no hay misa programada.',
          ),
        ),
      );

      return;
    }

    try {
      final image = await CameraService.takePhoto();

      if (image == null) return;

      if (!mounted) return;

      setState(() {
        _isUploading = true;
      });

      final imageUrl = await CloudinaryService.uploadImage(image);

      if (!mounted) return;

      setState(() {
        _photos[photoKey] = imageUrl;
        _sentPhotos[photoKey] = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Fotografía tomada. Ahora presiona "Enviar evidencia".',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir la fotografía: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _sendPhoto(String photoKey) async {
    /*
     * Se vuelve a revisar Firestore antes de guardar.
     *
     * Esto evita enviar una asistencia inválida aunque
     * el método se ejecutara directamente.
     */
    final puedeEnviar = await _confirmarDiaDeMisaAntesDeEnviar();

    if (!puedeEnviar) return;

    final usuario = FirebaseAuth.instance.currentUser;
    final imageUrl = _photos[photoKey];

    if (usuario == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró un usuario autenticado.')),
      );

      return;
    }

    if (imageUrl == null || imageUrl.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero debes tomar una fotografía.')),
      );

      return;
    }

    try {
      if (!mounted) return;

      setState(() {
        _photoSending = photoKey;
      });

      final ahora = DateTime.now();

      final documentoId = _documentoAsistenciaId(usuario.uid, ahora);

      final String campoFoto;
      final String campoHora;

      switch (photoKey) {
        case 'antes_misa':
          campoFoto = 'fotoAntesUrl';
          campoHora = 'horaAntes';
          break;

        case 'durante_misa':
          campoFoto = 'fotoDuranteUrl';
          campoHora = 'horaDurante';
          break;

        case 'al_finalizar':
          campoFoto = 'fotoDespuesUrl';
          campoHora = 'horaDespues';
          break;

        default:
          throw Exception('Tipo de fotografía no válido.');
      }

      final hora =
          '${ahora.hour.toString().padLeft(2, '0')}:'
          '${ahora.minute.toString().padLeft(2, '0')}';

      await FirebaseFirestore.instance
          .collection('asistencias')
          .doc(documentoId)
          .set({
            'uidAlumno': usuario.uid,
            'nombreAlumno': nombreAlumno,
            'grupo': grupoAlumno,
            'correoAlumno': usuario.email ?? '',
            'fecha': Timestamp.fromDate(
              DateTime(ahora.year, ahora.month, ahora.day),
            ),
            campoFoto: imageUrl,
            campoHora: hora,
            'actualizadoEn': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (!mounted) return;

      setState(() {
        _sentPhotos[photoKey] = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evidencia enviada correctamente.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar la evidencia: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _photoSending = null;
        });
      }
    }
  }

  /// Realiza una segunda comprobación justo antes de escribir
  /// la evidencia en la colección asistencias.
  Future<bool> _confirmarDiaDeMisaAntesDeEnviar() async {
    try {
      final ahora = DateTime.now();

      if (ahora.weekday == DateTime.sunday) {
        return true;
      }

      final inicioDelDia = DateTime(ahora.year, ahora.month, ahora.day);

      final inicioDiaSiguiente = inicioDelDia.add(const Duration(days: 1));

      final resultado = await FirebaseFirestore.instance
          .collection('misasEspeciales')
          .where(
            'fecha',
            isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDelDia),
          )
          .where('fecha', isLessThan: Timestamp.fromDate(inicioDiaSiguiente))
          .limit(1)
          .get();

      if (resultado.docs.isNotEmpty) {
        return true;
      }

      if (!mounted) return false;

      setState(() {
        _esDiaDeMisa = false;
        _mensajeDiaMisa =
            'Hoy no hay misa programada. No puedes registrar asistencia.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No puedes enviar asistencia porque hoy no hay misa programada.',
          ),
        ),
      );

      return false;
    } catch (e) {
      debugPrint('Error al confirmar el día de misa: $e');

      if (!mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo comprobar la misa. Inténtalo nuevamente.'),
        ),
      );

      return false;
    }
  }

  String _formatearFecha(DateTime fecha) {
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
        '${fecha.day} de '
        '${meses[fecha.month - 1]} de '
        '${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bool antesEnviada = _sentPhotos['antes_misa'] ?? false;

    final bool duranteEnviada = _sentPhotos['durante_misa'] ?? false;

    /*
     * Esta variable será false:
     * - mientras se consulta Firestore;
     * - cuando hoy no sea día de misa;
     * - mientras se sube una fotografía.
     */
    final bool registroDisponible =
        !_verificandoDiaMisa && _esDiaDeMisa && !_isUploading;

    return Scaffold(
      backgroundColor: RegistrarAsistenciaStyles.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),

            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: RegistrarAsistenciaStyles.screenPadding,
                    child: Column(
                      children: [
                        _ProgressCard(
                          completedPhotos: completedPhotos,
                          fecha: _formatearFecha(DateTime.now()),
                        ),

                        const SizedBox(height: 10),

                        _DiaMisaCard(
                          verificando: _verificandoDiaMisa,
                          esDiaDeMisa: _esDiaDeMisa,
                          mensaje: _mensajeDiaMisa,
                          onReintentar: _verificarDiaDeMisa,
                        ),

                        const SizedBox(height: 10),

                        _PhotoCard(
                          icon: const Icon(
                            Icons.church,
                            size: 25,
                            color: Colors.black87,
                          ),
                          title: 'Antes de la Misa',
                          description:
                              'Toma una foto antes de entrar a la iglesia',
                          buttonEnabled: registroDisponible,
                          imageUrl: _photos['antes_misa'],
                          sent: _sentPhotos['antes_misa'] ?? false,
                          isSending: _photoSending == 'antes_misa',
                          onTakePhoto: () {
                            _takePhoto('antes_misa');
                          },
                          onSend: () {
                            _sendPhoto('antes_misa');
                          },
                        ),

                        const SizedBox(height: 10),

                        _PhotoCard(
                          icon: const Icon(
                            Icons.access_time,
                            size: 25,
                            color: Colors.black87,
                          ),
                          title: 'Durante la Misa',
                          description:
                              'Toma una foto dentro de la iglesia durante la celebración',
                          buttonEnabled: registroDisponible && antesEnviada,
                          imageUrl: _photos['durante_misa'],
                          sent: _sentPhotos['durante_misa'] ?? false,
                          isSending: _photoSending == 'durante_misa',
                          onTakePhoto: () {
                            _takePhoto('durante_misa');
                          },
                          onSend: () {
                            _sendPhoto('durante_misa');
                          },
                        ),

                        const SizedBox(height: 10),

                        _PhotoCard(
                          icon: const Icon(
                            Icons.church,
                            size: 25,
                            color: Colors.black87,
                          ),
                          title: 'Al Finalizar',
                          description:
                              'Toma una foto al salir después de la misa',
                          buttonEnabled: registroDisponible && duranteEnviada,
                          imageUrl: _photos['al_finalizar'],
                          sent: _sentPhotos['al_finalizar'] ?? false,
                          isSending: _photoSending == 'al_finalizar',
                          onTakePhoto: () {
                            _takePhoto('al_finalizar');
                          },
                          onSend: () {
                            _sendPhoto('al_finalizar');
                          },
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  if (_isUploading)
                    Container(
                      color: Colors.black.withOpacity(0.15),
                      child: const Center(child: CircularProgressIndicator()),
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      color: RegistrarAsistenciaStyles.headerColor,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 31,
              height: 35,
              decoration: RegistrarAsistenciaStyles.backButtonDecoration,
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.blue,
                size: 22,
              ),
            ),
          ),

          const SizedBox(width: 4),

          const Text(
            'Registrar Asistencia',
            style: RegistrarAsistenciaStyles.headerTitle,
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int completedPhotos;
  final String fecha;

  const _ProgressCard({required this.completedPhotos, required this.fecha});

  @override
  Widget build(BuildContext context) {
    final double progress = completedPhotos / 3;

    return Container(
      width: double.infinity,
      padding: RegistrarAsistenciaStyles.progressPadding,
      decoration: RegistrarAsistenciaStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Progreso de hoy',
                  style: RegistrarAsistenciaStyles.progressTitle,
                ),
              ),

              Text(
                '$completedPhotos/3 fotos enviadas',
                style: RegistrarAsistenciaStyles.progressCounter,
              ),
            ],
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: progress,
              backgroundColor: RegistrarAsistenciaStyles.progressBackground,
              valueColor: const AlwaysStoppedAnimation<Color>(
                RegistrarAsistenciaStyles.primaryColor,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(fecha, style: RegistrarAsistenciaStyles.dateText),
        ],
      ),
    );
  }
}

class _DiaMisaCard extends StatelessWidget {
  final bool verificando;
  final bool esDiaDeMisa;
  final String mensaje;
  final VoidCallback onReintentar;

  const _DiaMisaCard({
    required this.verificando,
    required this.esDiaDeMisa,
    required this.mensaje,
    required this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = verificando
        ? Colors.blue.shade50
        : esDiaDeMisa
        ? Colors.green.shade50
        : Colors.red.shade50;

    final Color foregroundColor = verificando
        ? Colors.blue.shade700
        : esDiaDeMisa
        ? Colors.green.shade700
        : Colors.red.shade700;

    final IconData icon = verificando
        ? Icons.access_time
        : esDiaDeMisa
        ? Icons.check_circle
        : Icons.event_busy;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: foregroundColor.withOpacity(0.30)),
      ),
      child: Row(
        children: [
          if (verificando)
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: foregroundColor,
              ),
            )
          else
            Icon(icon, color: foregroundColor),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              verificando ? 'Verificando si hoy hay misa...' : mensaje,
              style: TextStyle(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),

          if (!verificando && !esDiaDeMisa)
            IconButton(
              onPressed: onReintentar,
              tooltip: 'Volver a verificar',
              icon: Icon(Icons.refresh, color: foregroundColor),
            ),
        ],
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final String description;
  final bool buttonEnabled;
  final String? imageUrl;
  final bool sent;
  final bool isSending;
  final VoidCallback onTakePhoto;
  final VoidCallback onSend;

  const _PhotoCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonEnabled,
    required this.imageUrl,
    required this.sent,
    required this.isSending,
    required this.onTakePhoto,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: RegistrarAsistenciaStyles.photoCardPadding,
      decoration: RegistrarAsistenciaStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon,

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: RegistrarAsistenciaStyles.photoTitle),

                    Text(
                      description,
                      style: RegistrarAsistenciaStyles.photoDescription,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            height: 120,
            width: double.infinity,
            decoration: RegistrarAsistenciaStyles.photoBoxDecoration,
            clipBehavior: Clip.antiAlias,
            child: imageUrl == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      icon,

                      const SizedBox(height: 5),

                      Text(
                        title,
                        style: RegistrarAsistenciaStyles.photoBoxText,
                      ),
                    ],
                  )
                : Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 35,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 9),

          SizedBox(
            width: double.infinity,
            height: 35,
            child: ElevatedButton.icon(
              onPressed: buttonEnabled && !sent && !isSending
                  ? onTakePhoto
                  : null,
              icon: const Icon(Icons.camera_alt, size: 15),
              label: Text(
                imageUrl == null
                    ? 'Tomar Fotografía'
                    : sent
                    ? 'Fotografía Enviada'
                    : 'Volver a Tomar',
              ),
              style: buttonEnabled && !sent && !isSending
                  ? RegistrarAsistenciaStyles.enabledButtonStyle
                  : RegistrarAsistenciaStyles.disabledButtonStyle,
            ),
          ),

          if (imageUrl != null) ...[
            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              height: 35,
              child: ElevatedButton.icon(
                /*
                 * También se utiliza buttonEnabled para
                 * impedir enviar cuando no sea día de misa.
                 */
                onPressed: !buttonEnabled || sent || isSending ? null : onSend,
                icon: isSending
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(sent ? Icons.check_circle : Icons.send, size: 15),
                label: Text(
                  isSending
                      ? 'Enviando...'
                      : sent
                      ? 'Evidencia Enviada'
                      : 'Enviar Evidencia',
                ),
                style: !buttonEnabled || sent || isSending
                    ? RegistrarAsistenciaStyles.disabledButtonStyle
                    : RegistrarAsistenciaStyles.enabledButtonStyle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
