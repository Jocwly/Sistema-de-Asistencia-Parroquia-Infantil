import 'dart:io';

import 'package:image_picker/image_picker.dart';

class CameraService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image == null) return null;

      return File(image.path);
    } catch (e) {
      throw Exception('Error al abrir la cámara: $e');
    }
  }
}
