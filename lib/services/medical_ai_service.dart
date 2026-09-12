import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'language_service.dart';

class MedicalAiService {
  static const String _endpoint =
      'https://www.kingofline.it/wp-json/salute-risponde/v1/chat';
  static const Duration _textTimeout = Duration(seconds: 60);
  static const Duration _attachmentTimeout = Duration(seconds: 90);
  static const int _maxBytes = 10 * 1024 * 1024;

  Future<String> sendMessage({
    required String message,
    List<Map<String, String>> history = const [],
    String? attachmentPath,
    String? attachmentName,
  }) async {
    final clean = message.trim();
    if (clean.isEmpty && attachmentPath == null) {
      throw const MedicalAiException('Scrivi un messaggio oppure allega un file.');
    }

    final payload = <String, dynamic>{
      'message': clean,
      'history': history,
      'language': LanguageService.currentCode,
    };

    if (attachmentPath != null) {
      final file = File(attachmentPath);
      if (!await file.exists()) {
        throw const MedicalAiException(
          'L’allegato non è più disponibile sul dispositivo.',
        );
      }

      final size = await file.length();
      if (size < 1 || size > _maxBytes) {
        throw const MedicalAiException(
          'L’allegato deve avere una dimensione massima di 10 MB.',
        );
      }

      final lowerName = (attachmentName ?? attachmentPath).toLowerCase();
      String mimeType;
      if (lowerName.endsWith('.jpg') || lowerName.endsWith('.jpeg')) {
        mimeType = 'image/jpeg';
      } else if (lowerName.endsWith('.png')) {
        mimeType = 'image/png';
      } else if (lowerName.endsWith('.webp')) {
        mimeType = 'image/webp';
      } else if (lowerName.endsWith('.pdf')) {
        mimeType = 'application/pdf';
      } else {
        throw const MedicalAiException(
          'Formato non supportato. Usa JPG, PNG, WEBP oppure PDF.',
        );
      }

      final bytes = await file.readAsBytes();
      payload['attachment_base64'] = base64Encode(bytes);
      payload['attachment_mime'] = mimeType;
      payload['attachment_name'] = attachmentName ?? file.uri.pathSegments.last;
    }

    try {
      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(
            attachmentPath == null ? _textTimeout : _attachmentTimeout,
          );

      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = null;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is Map) {
          final reply = decoded['reply'] ?? decoded['message'];
          if (reply is String && reply.trim().isNotEmpty) {
            return reply.trim();
          }
        }
        throw const MedicalAiException(
          'Il server ha risposto, ma Salute Risponde non ha ricevuto un testo valido.',
        );
      }

      if (decoded is Map && decoded['message'] is String) {
        throw MedicalAiException(decoded['message'].toString());
      }

      throw MedicalAiException(
        'Servizio Salute Risponde temporaneamente non disponibile (${response.statusCode}).',
      );
    } on TimeoutException {
      throw MedicalAiException(
        attachmentPath == null
            ? 'Salute Risponde sta impiegando più del previsto. Nessuna risposta ricevuta entro 60 secondi: riprova.'
            : 'L’analisi dell’allegato sta impiegando più del previsto. Riprova tra poco.',
      );
    } on MedicalAiException {
      rethrow;
    } catch (e) {
      throw MedicalAiException(
        'Impossibile collegarsi a Salute Risponde in questo momento. Dettaglio: ${e.runtimeType}.',
      );
    }
  }
}

class MedicalAiException implements Exception {
  final String message;
  const MedicalAiException(this.message);

  @override
  String toString() => message;
}
