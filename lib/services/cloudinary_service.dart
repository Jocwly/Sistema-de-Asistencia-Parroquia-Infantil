import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'gy4dtl7j';
  static const String uploadPreset = 'asistencias';

  static Future<String> uploadImage(File imageFile) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    final Map<String, dynamic> data = jsonDecode(responseBody);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        data['error']?['message'] ?? 'Error al subir imagen a Cloudinary',
      );
    }

    final String? secureUrl = data['secure_url'];

    if (secureUrl == null || secureUrl.isEmpty) {
      throw Exception('Cloudinary no regresó una URL válida');
    }

    return secureUrl;
  }
}
