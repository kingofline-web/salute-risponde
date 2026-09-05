import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class DocumentAiService {
  static const String _endpoint =
      'https://www.kingofline.it/wp-json/salute-risponde/v1/analyze-document';
  static const Duration _timeout = Duration(seconds: 90);
  static const int _maxBytes = 10 * 1024 * 1024;

  Future<String> analyzeImage(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw const DocumentAiException(
        'La foto selezionata non è più disponibile sul dispositivo.',
      );
    }

    final size = await file.length();
    if (size < 1 || size > _maxBytes) {
      throw const DocumentAiException(
        'La foto deve avere una dimensione massima di 10 MB.',
      );
    }

    final extension = imagePath.toLowerCase().split('.').last;
    if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
      throw const DocumentAiException(
        'Formato non supportato. Usa JPG, PNG oppure WEBP.',
      );
    }

    try {
      final request = http.MultipartRequest('POST', Uri.parse(_endpoint));
      request.headers['Accept'] = 'application/json';
      request.files.add(
        await http.MultipartFile.fromPath('document', imagePath),
      );

      final streamed = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamed);

      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = null;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is Map) {
          final explanation = decoded['explanation'];
          if (explanation is String && explanation.trim().isNotEmpty) {
            return explanation.trim();
          }
        }
        throw const DocumentAiException(
          'Il servizio non ha restituito una spiegazione valida.',
        );
      }

      if (decoded is Map && decoded['message'] is String) {
        throw DocumentAiException(decoded['message'].toString());
      }

      throw DocumentAiException(
        'Analisi temporaneamente non disponibile (${response.statusCode}).',
      );
    } on TimeoutException {
      throw const DocumentAiException(
        'L’analisi sta impiegando troppo tempo. Riprova tra poco.',
      );
    } on DocumentAiException {
      rethrow;
    } catch (_) {
      throw const DocumentAiException(
        'Impossibile collegarsi al servizio di analisi in questo momento.',
      );
    }
  }
}

class DocumentAiException implements Exception {
  final String message;
  const DocumentAiException(this.message);

  @override
  String toString() => message;
}
