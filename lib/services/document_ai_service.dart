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
      throw DocumentAiException(
        _serviceText('service_document_missing'),
      );
    }

    final size = await file.length();
    if (size < 1 || size > _maxBytes) {
      throw DocumentAiException(
        _serviceText('service_document_10mb'),
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
      throw DocumentAiException(
        _serviceText('service_format'),
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

        throw DocumentAiException(
          _serviceText('service_invalid_explanation'),
        );
      }

      if (decoded is Map && decoded['message'] is String) {
        throw DocumentAiException(decoded['message'].toString());
      }

      throw DocumentAiException(
        'Analisi temporaneamente non disponibile (${response.statusCode}).',
      );
    } on TimeoutException {
      throw DocumentAiException(
        _serviceText('service_timeout_document'),
      );
    } on DocumentAiException {
      rethrow;
    } catch (_) {
      throw DocumentAiException(
        _serviceText('service_connect_document'),
      );
    }
  }

  Future<String> analyzeImage(String imagePath) {
    return analyzeDocument(imagePath);
  }
}

class DocumentAiException implements Exception {
  final String message;

  DocumentAiException(this.message);

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

/* unused in document service */
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
