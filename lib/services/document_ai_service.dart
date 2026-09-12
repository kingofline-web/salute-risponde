import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'language_service.dart';

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

    final lowerPath = filePath.toLowerCase();
    String mimeType;

    if (lowerPath.endsWith('.jpg') || lowerPath.endsWith('.jpeg')) {
      mimeType = 'image/jpeg';
    } else if (lowerPath.endsWith('.png')) {
      mimeType = 'image/png';
    } else if (lowerPath.endsWith('.webp')) {
      mimeType = 'image/webp';
    } else if (lowerPath.endsWith('.pdf')) {
      mimeType = 'application/pdf';
    } else {
      throw const DocumentAiException(
        'Formato non supportato. Usa JPG, PNG, WEBP oppure PDF.',
      );
    }

    final bytes = await file.readAsBytes();
    final filename = file.uri.pathSegments.isNotEmpty
        ? file.uri.pathSegments.last
        : (mimeType == 'application/pdf' ? 'documento.pdf' : 'documento.jpg');

    try {
      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'document_base64': base64Encode(bytes),
              'mime_type': mimeType,
              'filename': filename,
              'language': LanguageService.currentCode,
            }),
          )
          .timeout(_timeout);

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
