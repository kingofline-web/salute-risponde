import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class DocumentAiService {
  static const String _endpoint =
      'https://www.kingofline.it/wp-json/salute-risponde/v1/analyze-document';

  static const Duration _timeout = Duration(seconds: 120);
  static const int _maxBytes = 10 * 1024 * 1024;

  Future<String> analyzeDocument(String filePath) async {
    final file = File(filePath);

    if (!await file.exists()) {
      throw const DocumentAiException(
        'Il documento selezionato non è più disponibile sul dispositivo.',
      );
    }

    final size = await file.length();
    if (size < 1 || size > _maxBytes) {
      throw const DocumentAiException(
        'Il documento deve avere una dimensione massima di 10 MB.',
      );
    }

    final extension = filePath.toLowerCase().split('.').last;

    if (!['jpg', 'jpeg', 'png', 'webp', 'pdf'].contains(extension)) {
      throw const DocumentAiException(
        'Formato non supportato. Usa JPG, PNG, WEBP oppure PDF.',
      );
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(_endpoint),
      );

      request.headers['Accept'] = 'application/json';

      request.files.add(
        await http.MultipartFile.fromPath(
          'document',
          filePath,
          filename: file.uri.pathSegments.isNotEmpty
              ? file.uri.pathSegments.last
              : 'documento.$extension',
        ),
      );

      final streamedResponse =
          await request.send().timeout(_timeout);

      final response =
          await http.Response.fromStream(streamedResponse).timeout(_timeout);

      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = null;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is Map) {
          final explanation = decoded['explanation'];

          if (explanation is String &&
              explanation.trim().isNotEmpty) {
            return explanation.trim();
          }
        }

        throw const DocumentAiException(
          'Il servizio non ha restituito una spiegazione valida.',
        );
      }

      if (decoded is Map && decoded['message'] is String) {
        throw DocumentAiException(
          decoded['message'].toString(),
        );
      }

      throw DocumentAiException(
        'Analisi temporaneamente non disponibile '
        '(${response.statusCode}).',
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

  // Manteniamo questo metodo per compatibilità con il codice RC 1.3.
  Future<String> analyzeImage(String imagePath) {
    return analyzeDocument(imagePath);
  }
}

class DocumentAiException implements Exception {
  final String message;

  const DocumentAiException(this.message);

  @override
  String toString() => message;
}
