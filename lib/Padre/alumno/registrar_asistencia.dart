import 'package:cloud_firestore/cloud_firestore.dart';
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

  final Map<String, String?> _photos = {
    'antes_misa': null,
    'durante_misa': null,
    'al_finalizar': null,
  };

  int get completedPhotos => _photos.values.where((url) => url != null).length;

  Future<void> _takePhoto(String photoKey) async {
    try {
      final image = await CameraService.takePhoto();

      if (image == null) return;

      setState(() => _isUploading = true);

      final imageUrl = await CloudinaryService.uploadImage(image);

      await FirebaseFirestore.instance.collection('asistencias').add({
        'fecha': Timestamp.now(),
        'tipoFoto': photoKey,
        'fotoUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _photos[photoKey] = imageUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fotografía guardada correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir la fotografía: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RegistrarAsistenciaStyles.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: RegistrarAsistenciaStyles.screenPadding,
                    child: Column(
                      children: [
                        _ProgressCard(completedPhotos: completedPhotos),

                        const SizedBox(height: 10),

                        _PhotoCard(
                          emoji: '🌅',
                          title: 'Antes de la Misa',
                          description:
                              'Toma una foto antes de entrar a la iglesia',
                          buttonEnabled: !_isUploading,
                          imageUrl: _photos['antes_misa'],
                          onTap: () => _takePhoto('antes_misa'),
                        ),

                        const SizedBox(height: 10),

                        _PhotoCard(
                          emoji: '⛪',
                          title: 'Durante la Misa',
                          description:
                              'Toma una foto dentro de la iglesia durante la celebración',
                          buttonEnabled:
                              !_isUploading && _photos['antes_misa'] != null,
                          imageUrl: _photos['durante_misa'],
                          onTap: () => _takePhoto('durante_misa'),
                        ),

                        const SizedBox(height: 10),

                        _PhotoCard(
                          emoji: '🙏',
                          title: 'Al Finalizar',
                          description:
                              'Toma una foto al salir después de la misa',
                          buttonEnabled:
                              !_isUploading && _photos['durante_misa'] != null,
                          imageUrl: _photos['al_finalizar'],
                          onTap: () => _takePhoto('al_finalizar'),
                        ),
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

  const _ProgressCard({required this.completedPhotos});

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
                '$completedPhotos/3 fotos',
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
          const Text(
            'jueves, 2 de julio de 2026',
            style: RegistrarAsistenciaStyles.dateText,
          ),
        ],
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final bool buttonEnabled;
  final String? imageUrl;
  final VoidCallback onTap;

  const _PhotoCard({
    required this.emoji,
    required this.title,
    required this.description,
    required this.buttonEnabled,
    required this.imageUrl,
    required this.onTap,
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
              Text(emoji, style: RegistrarAsistenciaStyles.cardEmoji),
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
            height: 90,
            width: double.infinity,
            decoration: RegistrarAsistenciaStyles.photoBoxDecoration,
            clipBehavior: Clip.antiAlias,
            child: imageUrl == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(emoji, style: RegistrarAsistenciaStyles.photoEmoji),
                      const SizedBox(height: 5),
                      Text(
                        title,
                        style: RegistrarAsistenciaStyles.photoBoxText,
                      ),
                    ],
                  )
                : Image.network(imageUrl!, fit: BoxFit.cover),
          ),

          const SizedBox(height: 9),

          SizedBox(
            width: double.infinity,
            height: 35,
            child: ElevatedButton.icon(
              onPressed: buttonEnabled ? onTap : null,
              icon: const Icon(Icons.camera_alt, size: 15),
              label: Text(
                imageUrl == null ? 'Tomar Fotografía' : 'Fotografía Guardada',
              ),
              style: buttonEnabled
                  ? RegistrarAsistenciaStyles.enabledButtonStyle
                  : RegistrarAsistenciaStyles.disabledButtonStyle,
            ),
          ),
        ],
      ),
    );
  }
}
