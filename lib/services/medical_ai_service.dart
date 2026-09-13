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
      throw MedicalAiException(_serviceText('service_write_or_attach'));
    }

    final payload = <String, dynamic>{
      'message': clean,
      'history': history,
      'language': LanguageService.currentCode,
    };

    if (attachmentPath != null) {
      final file = File(attachmentPath);
      if (!await file.exists()) {
        throw MedicalAiException(
          _serviceText('service_attachment_missing'),
        );
      }

      final size = await file.length();
      if (size < 1 || size > _maxBytes) {
        throw MedicalAiException(
          _serviceText('service_attachment_10mb'),
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
        throw MedicalAiException(
          _serviceText('service_format'),
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
        throw MedicalAiException(
          _serviceText('service_invalid_reply'),
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
            ? _serviceText('service_timeout_text')
            : _serviceText('service_timeout_attachment'),
      );
    } on MedicalAiException {
      rethrow;
    } catch (e) {
      throw MedicalAiException(
        _serviceConnectError(e.runtimeType.toString()),
      );
    }
  }
}

class MedicalAiException implements Exception {
  final String message;
  MedicalAiException(this.message);

  @override
  String toString() => message;
}


String _serviceText(String key) {
  const texts = <String, Map<String, String>>{
    'service_write_or_attach': {
      'it': 'Scrivi un messaggio oppure allega un file.',
      'en': 'Write a message or attach a file.',
      'es': 'Escribe un mensaje o adjunta un archivo.',
      'fr': 'Écrivez un message ou joignez un fichier.',
      'de': 'Schreibe eine Nachricht oder hänge eine Datei an.',
      'pt': 'Escreva uma mensagem ou anexe um ficheiro.',
    },
    'service_attachment_missing': {
      'it': 'L’allegato non è più disponibile sul dispositivo.',
      'en': 'The attachment is no longer available on the device.',
      'es': 'El archivo adjunto ya no está disponible en el dispositivo.',
      'fr': 'La pièce jointe n’est plus disponible sur l’appareil.',
      'de': 'Der Anhang ist auf dem Gerät nicht mehr verfügbar.',
      'pt': 'O anexo já não está disponível no dispositivo.',
    },
    'service_attachment_10mb': {
      'it': 'L’allegato deve avere una dimensione massima di 10 MB.',
      'en': 'The attachment must be no larger than 10 MB.',
      'es': 'El archivo adjunto no puede superar los 10 MB.',
      'fr': 'La pièce jointe ne doit pas dépasser 10 Mo.',
      'de': 'Der Anhang darf höchstens 10 MB groß sein.',
      'pt': 'O anexo não pode exceder 10 MB.',
    },
    'service_document_missing': {
      'it': 'Il documento selezionato non è più disponibile sul dispositivo.',
      'en': 'The selected document is no longer available on the device.',
      'es': 'El documento seleccionado ya no está disponible en el dispositivo.',
      'fr': 'Le document sélectionné n’est plus disponible sur l’appareil.',
      'de': 'Das ausgewählte Dokument ist auf dem Gerät nicht mehr verfügbar.',
      'pt': 'O documento selecionado já não está disponível no dispositivo.',
    },
    'service_document_10mb': {
      'it': 'Il documento deve avere una dimensione massima di 10 MB.',
      'en': 'The document must be no larger than 10 MB.',
      'es': 'El documento no puede superar los 10 MB.',
      'fr': 'Le document ne doit pas dépasser 10 Mo.',
      'de': 'Das Dokument darf höchstens 10 MB groß sein.',
      'pt': 'O documento não pode exceder 10 MB.',
    },
    'service_format': {
      'it': 'Formato non supportato. Usa JPG, PNG, WEBP oppure PDF.',
      'en': 'Unsupported format. Use JPG, PNG, WEBP or PDF.',
      'es': 'Formato no compatible. Usa JPG, PNG, WEBP o PDF.',
      'fr': 'Format non pris en charge. Utilisez JPG, PNG, WEBP ou PDF.',
      'de': 'Nicht unterstütztes Format. Verwende JPG, PNG, WEBP oder PDF.',
      'pt': 'Formato não suportado. Use JPG, PNG, WEBP ou PDF.',
    },
    'service_invalid_reply': {
      'it': 'Il server ha risposto, ma Salute Risponde non ha ricevuto un testo valido.',
      'en': 'The server replied, but SaluteRisponde did not receive valid text.',
      'es': 'El servidor respondió, pero SaluteRisponde no recibió un texto válido.',
      'fr': 'Le serveur a répondu, mais SaluteRisponde n’a pas reçu de texte valide.',
      'de': 'Der Server hat geantwortet, aber SaluteRisponde hat keinen gültigen Text erhalten.',
      'pt': 'O servidor respondeu, mas a SaluteRisponde não recebeu texto válido.',
    },
    'service_invalid_explanation': {
      'it': 'Il servizio non ha restituito una spiegazione valida.',
      'en': 'The service did not return a valid explanation.',
      'es': 'El servicio no devolvió una explicación válida.',
      'fr': 'Le service n’a pas renvoyé d’explication valide.',
      'de': 'Der Dienst hat keine gültige Erklärung zurückgegeben.',
      'pt': 'O serviço não devolveu uma explicação válida.',
    },
    'service_timeout_text': {
      'it': 'Salute Risponde sta impiegando più del previsto. Nessuna risposta ricevuta entro 60 secondi: riprova.',
      'en': 'SaluteRisponde is taking longer than expected. No answer was received within 60 seconds: try again.',
      'es': 'SaluteRisponde está tardando más de lo previsto. No se recibió respuesta en 60 segundos: inténtalo de nuevo.',
      'fr': 'SaluteRisponde prend plus de temps que prévu. Aucune réponse reçue en 60 secondes : réessayez.',
      'de': 'SaluteRisponde braucht länger als erwartet. Innerhalb von 60 Sekunden kam keine Antwort: versuche es erneut.',
      'pt': 'A SaluteRisponde está a demorar mais do que o previsto. Não houve resposta em 60 segundos: tente novamente.',
    },
    'service_timeout_attachment': {
      'it': 'L’analisi dell’allegato sta impiegando più del previsto. Riprova tra poco.',
      'en': 'The attachment analysis is taking longer than expected. Try again shortly.',
      'es': 'El análisis del archivo adjunto está tardando más de lo previsto. Inténtalo de nuevo en breve.',
      'fr': 'L’analyse de la pièce jointe prend plus de temps que prévu. Réessayez dans un instant.',
      'de': 'Die Analyse des Anhangs dauert länger als erwartet. Versuche es gleich noch einmal.',
      'pt': 'A análise do anexo está a demorar mais do que o previsto. Tente novamente em breve.',
    },
    'service_timeout_document': {
      'it': 'L’analisi sta impiegando troppo tempo. Riprova tra poco.',
      'en': 'The analysis is taking too long. Try again shortly.',
      'es': 'El análisis está tardando demasiado. Inténtalo de nuevo en breve.',
      'fr': 'L’analyse prend trop de temps. Réessayez dans un instant.',
      'de': 'Die Analyse dauert zu lange. Versuche es gleich noch einmal.',
      'pt': 'A análise está a demorar demasiado. Tente novamente em breve.',
    },
    'service_connect_document': {
      'it': 'Impossibile collegarsi al servizio di analisi in questo momento.',
      'en': 'Unable to connect to the analysis service right now.',
      'es': 'No se puede conectar con el servicio de análisis en este momento.',
      'fr': 'Impossible de se connecter au service d’analyse pour le moment.',
      'de': 'Der Analysedienst ist momentan nicht erreichbar.',
      'pt': 'Não foi possível ligar ao serviço de análise neste momento.',
    },
  };
  final byLanguage = texts[key] ?? const <String, String>{};
  return byLanguage[LanguageService.currentCode] ?? byLanguage['it'] ?? key;
}

String _serviceConnectError(String type) {
  switch (LanguageService.currentCode) {
    case 'en': return 'Unable to connect to SaluteRisponde right now. Detail: $type.';
    case 'es': return 'No se puede conectar con SaluteRisponde en este momento. Detalle: $type.';
    case 'fr': return 'Impossible de se connecter à SaluteRisponde pour le moment. Détail : $type.';
    case 'de': return 'SaluteRisponde ist momentan nicht erreichbar. Detail: $type.';
    case 'pt': return 'Não foi possível ligar à SaluteRisponde neste momento. Detalhe: $type.';
    default: return 'Impossibile collegarsi a Salute Risponde in questo momento. Dettaglio: $type.';
  }
}
