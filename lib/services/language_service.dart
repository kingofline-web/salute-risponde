import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageOption {
  final String code;
  final String nativeName;
  final String flag;
  final Locale locale;

  const LanguageOption({
    required this.code,
    required this.nativeName,
    required this.flag,
    required this.locale,
  });
}

class LanguageService {
  static const String _prefsKey = 'salute_risponde_language';
  static const String automaticCode = 'auto';

  // Per impostazione predefinita l'app segue la lingua del telefono.
  static final ValueNotifier<String> notifier =
      ValueNotifier<String>(automaticCode);

  static const List<LanguageOption> options = [
    LanguageOption(
      code: automaticCode,
      nativeName: 'Automatico · Telefono',
      flag: '🌐',
      locale: Locale('und'),
    ),
    LanguageOption(
      code: 'it',
      nativeName: 'Italiano',
      flag: '🇮🇹',
      locale: Locale('it', 'IT'),
    ),
    LanguageOption(
      code: 'en',
      nativeName: 'English',
      flag: '🇬🇧',
      locale: Locale('en', 'GB'),
    ),
    LanguageOption(
      code: 'es',
      nativeName: 'Español',
      flag: '🇪🇸',
      locale: Locale('es', 'ES'),
    ),
    LanguageOption(
      code: 'fr',
      nativeName: 'Français',
      flag: '🇫🇷',
      locale: Locale('fr', 'FR'),
    ),
    LanguageOption(
      code: 'de',
      nativeName: 'Deutsch',
      flag: '🇩🇪',
      locale: Locale('de', 'DE'),
    ),
    LanguageOption(
      code: 'pt',
      nativeName: 'Português',
      flag: '🇵🇹',
      locale: Locale('pt', 'PT'),
    ),
  ];

  static const Map<String, Map<String, String>> _strings = {
    'it': {
      'language': 'Lingua',
      'instructions': 'Istruzioni',
      'account': 'Account',
      'home_hello': 'Ciao 👋',
      'home_help_today': 'Come posso aiutarti oggi?',
      'ask_question': 'Fai una domanda',
      'health_clear': 'La salute, spiegata con chiarezza.',
      'simple_tools': 'Informazioni semplici e strumenti utili, sempre con te.',
      'everything_you_need': 'Tutto quello di cui hai bisogno',
      'agenda_health': 'Agenda Salute',
      'appointments_visits': 'Appuntamenti e visite',
      'tests_reports': 'Esami e Referti',
      'your_documents': 'I tuoi documenti',
      'medicine_reminders': 'Promemoria Farmaci',
      'therapies_control': 'Terapie sotto controllo',
      'useful_numbers': 'Numeri Utili',
      'quick_contacts': 'Contatti rapidi',
      'plans_title': 'Piani FREE, PLUS e PRO',
      'choose_plan': 'Scegli il piano più adatto',
      'technology_cares': 'Tecnologia che si prende cura di te.',
      'powered_by': 'Powered by KING OF LINE & Kai',
      'instructions_intro':
          'SaluteRisponde ti aiuta a orientarti tra domande sulla salute, documenti sanitari, appuntamenti e promemoria. È uno strumento informativo e non sostituisce il medico.',
      'instructions_chat_title': 'Fai una domanda',
      'instructions_chat_body':
          'Apri la chat e scrivi la tua domanda. Puoi anche allegare una foto o un PDF di un documento sanitario. Le risposte sono informative.',
      'instructions_docs_title': 'Esami e referti',
      'instructions_docs_body':
          'Fotografa oppure scegli un documento già presente sul telefono, salvalo nel tuo archivio e usa “Analizza e spiegami” per ottenere una spiegazione semplice.',
      'instructions_agenda_title': 'Agenda Salute',
      'instructions_agenda_body':
          'Salva visite e appuntamenti con data e ora per tenere sotto controllo gli impegni sanitari.',
      'instructions_meds_title': 'Promemoria Farmaci',
      'instructions_meds_body':
          'Inserisci farmaci o integratori e imposta l’orario del promemoria. Puoi modificare o cancellare ogni voce.',
      'instructions_safety_title': 'Sicurezza',
      'instructions_safety_body':
          'SaluteRisponde non formula diagnosi definitive e non sostituisce un professionista sanitario. In caso di emergenza usa i numeri di soccorso.',
    },
    'en': {
      'language': 'Language',
      'instructions': 'Instructions',
      'account': 'Account',
      'home_hello': 'Hello 👋',
      'home_help_today': 'How can I help you today?',
      'ask_question': 'Ask a question',
      'health_clear': 'Health, explained clearly.',
      'simple_tools': 'Simple information and useful tools, always with you.',
      'everything_you_need': 'Everything you need',
      'agenda_health': 'Health Agenda',
      'appointments_visits': 'Appointments and visits',
      'tests_reports': 'Tests and Reports',
      'your_documents': 'Your documents',
      'medicine_reminders': 'Medicine Reminders',
      'therapies_control': 'Keep treatments under control',
      'useful_numbers': 'Useful Numbers',
      'quick_contacts': 'Quick contacts',
      'plans_title': 'FREE, PLUS and PRO plans',
      'choose_plan': 'Choose the plan that suits you',
      'technology_cares': 'Technology that takes care of you.',
      'powered_by': 'Powered by KING OF LINE & Kai',
      'instructions_intro':
          'SaluteRisponde helps you navigate health questions, medical documents, appointments and reminders. It is an informational tool and does not replace a doctor.',
      'instructions_chat_title': 'Ask a question',
      'instructions_chat_body':
          'Open the chat and type your question. You can also attach a photo or PDF of a medical document. Answers are for information only.',
      'instructions_docs_title': 'Tests and reports',
      'instructions_docs_body':
          'Take a photo or choose a document already on your phone, save it in your archive and use “Analyze and explain” to get a simple explanation.',
      'instructions_agenda_title': 'Health Agenda',
      'instructions_agenda_body':
          'Save medical visits and appointments with date and time to keep your health commitments organized.',
      'instructions_meds_title': 'Medicine Reminders',
      'instructions_meds_body':
          'Add medicines or supplements and set a reminder time. You can edit or delete each item.',
      'instructions_safety_title': 'Safety',
      'instructions_safety_body':
          'SaluteRisponde does not provide definitive diagnoses and does not replace a healthcare professional. In an emergency, use the emergency numbers.',
    },
    'es': {
      'language': 'Idioma',
      'instructions': 'Instrucciones',
      'account': 'Cuenta',
      'home_hello': 'Hola 👋',
      'home_help_today': '¿Cómo puedo ayudarte hoy?',
      'ask_question': 'Haz una pregunta',
      'health_clear': 'La salud, explicada con claridad.',
      'simple_tools': 'Información sencilla y herramientas útiles, siempre contigo.',
      'everything_you_need': 'Todo lo que necesitas',
      'agenda_health': 'Agenda de Salud',
      'appointments_visits': 'Citas y visitas',
      'tests_reports': 'Pruebas e Informes',
      'your_documents': 'Tus documentos',
      'medicine_reminders': 'Recordatorios de Medicación',
      'therapies_control': 'Tratamientos bajo control',
      'useful_numbers': 'Números Útiles',
      'quick_contacts': 'Contactos rápidos',
      'plans_title': 'Planes FREE, PLUS y PRO',
      'choose_plan': 'Elige el plan más adecuado',
      'technology_cares': 'Tecnología que cuida de ti.',
      'powered_by': 'Powered by KING OF LINE & Kai',
      'instructions_intro':
          'SaluteRisponde te ayuda con preguntas de salud, documentos médicos, citas y recordatorios. Es una herramienta informativa y no sustituye al médico.',
      'instructions_chat_title': 'Haz una pregunta',
      'instructions_chat_body':
          'Abre el chat y escribe tu pregunta. También puedes adjuntar una foto o un PDF de un documento médico. Las respuestas son informativas.',
      'instructions_docs_title': 'Pruebas e informes',
      'instructions_docs_body':
          'Haz una foto o elige un documento guardado en el teléfono, guárdalo en tu archivo y usa “Analizar y explicar” para recibir una explicación sencilla.',
      'instructions_agenda_title': 'Agenda de Salud',
      'instructions_agenda_body':
          'Guarda visitas y citas con fecha y hora para organizar tus compromisos sanitarios.',
      'instructions_meds_title': 'Recordatorios de medicación',
      'instructions_meds_body':
          'Añade medicamentos o suplementos y establece una hora de recordatorio. Puedes modificar o eliminar cada elemento.',
      'instructions_safety_title': 'Seguridad',
      'instructions_safety_body':
          'SaluteRisponde no realiza diagnósticos definitivos ni sustituye a un profesional sanitario. En una emergencia utiliza los números de emergencia.',
    },
    'fr': {
      'language': 'Langue',
      'instructions': 'Instructions',
      'account': 'Compte',
      'home_hello': 'Bonjour 👋',
      'home_help_today': 'Comment puis-je vous aider aujourd’hui ?',
      'ask_question': 'Poser une question',
      'health_clear': 'La santé, expliquée clairement.',
      'simple_tools': 'Des informations simples et des outils utiles, toujours avec vous.',
      'everything_you_need': 'Tout ce dont vous avez besoin',
      'agenda_health': 'Agenda Santé',
      'appointments_visits': 'Rendez-vous et consultations',
      'tests_reports': 'Examens et Comptes rendus',
      'your_documents': 'Vos documents',
      'medicine_reminders': 'Rappels Médicaments',
      'therapies_control': 'Traitements sous contrôle',
      'useful_numbers': 'Numéros Utiles',
      'quick_contacts': 'Contacts rapides',
      'plans_title': 'Formules FREE, PLUS et PRO',
      'choose_plan': 'Choisissez la formule adaptée',
      'technology_cares': 'Une technologie qui prend soin de vous.',
      'powered_by': 'Powered by KING OF LINE & Kai',
      'instructions_intro':
          'SaluteRisponde vous aide à vous orienter dans vos questions de santé, documents médicaux, rendez-vous et rappels. Cet outil est informatif et ne remplace pas un médecin.',
      'instructions_chat_title': 'Poser une question',
      'instructions_chat_body':
          'Ouvrez le chat et saisissez votre question. Vous pouvez aussi joindre une photo ou un PDF d’un document médical. Les réponses sont informatives.',
      'instructions_docs_title': 'Examens et comptes rendus',
      'instructions_docs_body':
          'Prenez une photo ou choisissez un document déjà présent sur le téléphone, enregistrez-le dans vos archives puis utilisez “Analyser et expliquer”.',
      'instructions_agenda_title': 'Agenda Santé',
      'instructions_agenda_body':
          'Enregistrez vos consultations et rendez-vous avec leur date et leur heure pour mieux organiser votre suivi.',
      'instructions_meds_title': 'Rappels Médicaments',
      'instructions_meds_body':
          'Ajoutez des médicaments ou compléments et définissez une heure de rappel. Chaque élément peut être modifié ou supprimé.',
      'instructions_safety_title': 'Sécurité',
      'instructions_safety_body':
          'SaluteRisponde ne fournit pas de diagnostic définitif et ne remplace pas un professionnel de santé. En cas d’urgence, utilisez les numéros d’urgence.',
    },
    'de': {
      'language': 'Sprache',
      'instructions': 'Anleitung',
      'account': 'Konto',
      'home_hello': 'Hallo 👋',
      'home_help_today': 'Wie kann ich dir heute helfen?',
      'ask_question': 'Frage stellen',
      'health_clear': 'Gesundheit, klar erklärt.',
      'simple_tools': 'Einfache Informationen und nützliche Werkzeuge, immer dabei.',
      'everything_you_need': 'Alles, was du brauchst',
      'agenda_health': 'Gesundheitskalender',
      'appointments_visits': 'Termine und Untersuchungen',
      'tests_reports': 'Befunde und Berichte',
      'your_documents': 'Deine Dokumente',
      'medicine_reminders': 'Medikamentenerinnerungen',
      'therapies_control': 'Therapien im Blick',
      'useful_numbers': 'Wichtige Nummern',
      'quick_contacts': 'Schnellkontakte',
      'plans_title': 'FREE-, PLUS- und PRO-Pläne',
      'choose_plan': 'Wähle den passenden Plan',
      'technology_cares': 'Technologie, die sich um dich kümmert.',
      'powered_by': 'Powered by KING OF LINE & Kai',
      'instructions_intro':
          'SaluteRisponde hilft bei Gesundheitsfragen, medizinischen Dokumenten, Terminen und Erinnerungen. Die App dient der Information und ersetzt keinen Arzt.',
      'instructions_chat_title': 'Frage stellen',
      'instructions_chat_body':
          'Öffne den Chat und gib deine Frage ein. Du kannst auch ein Foto oder PDF eines medizinischen Dokuments anhängen. Die Antworten dienen der Information.',
      'instructions_docs_title': 'Befunde und Berichte',
      'instructions_docs_body':
          'Fotografiere ein Dokument oder wähle eine Datei auf dem Telefon, speichere sie im Archiv und nutze „Analysieren und erklären“ für eine einfache Erklärung.',
      'instructions_agenda_title': 'Gesundheitskalender',
      'instructions_agenda_body':
          'Speichere Arzttermine und Untersuchungen mit Datum und Uhrzeit, damit du deine Gesundheitsplanung im Blick behältst.',
      'instructions_meds_title': 'Medikamentenerinnerungen',
      'instructions_meds_body':
          'Füge Medikamente oder Nahrungsergänzungsmittel hinzu und lege eine Erinnerungszeit fest. Jeder Eintrag kann geändert oder gelöscht werden.',
      'instructions_safety_title': 'Sicherheit',
      'instructions_safety_body':
          'SaluteRisponde stellt keine endgültigen Diagnosen und ersetzt kein medizinisches Fachpersonal. Im Notfall nutze die Notrufnummern.',
    },
    'pt': {
      'language': 'Idioma',
      'instructions': 'Instruções',
      'account': 'Conta',
      'home_hello': 'Olá 👋',
      'home_help_today': 'Como posso ajudar hoje?',
      'ask_question': 'Fazer uma pergunta',
      'health_clear': 'Saúde, explicada com clareza.',
      'simple_tools': 'Informação simples e ferramentas úteis, sempre consigo.',
      'everything_you_need': 'Tudo o que precisa',
      'agenda_health': 'Agenda de Saúde',
      'appointments_visits': 'Consultas e compromissos',
      'tests_reports': 'Exames e Relatórios',
      'your_documents': 'Os seus documentos',
      'medicine_reminders': 'Lembretes de Medicação',
      'therapies_control': 'Tratamentos sob controlo',
      'useful_numbers': 'Números Úteis',
      'quick_contacts': 'Contactos rápidos',
      'plans_title': 'Planos FREE, PLUS e PRO',
      'choose_plan': 'Escolha o plano mais adequado',
      'technology_cares': 'Tecnologia que cuida de si.',
      'powered_by': 'Powered by KING OF LINE & Kai',
      'instructions_intro':
          'SaluteRisponde ajuda com questões de saúde, documentos médicos, consultas e lembretes. É uma ferramenta informativa e não substitui um médico.',
      'instructions_chat_title': 'Fazer uma pergunta',
      'instructions_chat_body':
          'Abra o chat e escreva a sua pergunta. Também pode anexar uma foto ou PDF de um documento médico. As respostas são informativas.',
      'instructions_docs_title': 'Exames e relatórios',
      'instructions_docs_body':
          'Tire uma fotografia ou escolha um documento no telefone, guarde-o no arquivo e use “Analisar e explicar” para obter uma explicação simples.',
      'instructions_agenda_title': 'Agenda de Saúde',
      'instructions_agenda_body':
          'Guarde consultas e compromissos com data e hora para manter a sua organização de saúde.',
      'instructions_meds_title': 'Lembretes de medicação',
      'instructions_meds_body':
          'Adicione medicamentos ou suplementos e defina uma hora para o lembrete. Pode editar ou eliminar cada item.',
      'instructions_safety_title': 'Segurança',
      'instructions_safety_body':
          'SaluteRisponde não fornece diagnósticos definitivos e não substitui um profissional de saúde. Em caso de emergência, utilize os números de emergência.',
    },
  };

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);

    if (saved != null && options.any((option) => option.code == saved)) {
      notifier.value = saved;
    } else {
      notifier.value = automaticCode;
      await prefs.setString(_prefsKey, automaticCode);
    }
  }

  static Future<void> setLanguage(String code) async {
    if (!options.any((option) => option.code == code)) return;
    notifier.value = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, code);
  }

  static String _deviceLanguageCode() {
    final code =
        ui.PlatformDispatcher.instance.locale.languageCode.toLowerCase();
    const supported = {'it', 'en', 'es', 'fr', 'de', 'pt'};
    return supported.contains(code) ? code : 'it';
  }

  static String get selectedCode => notifier.value;

  // Codice effettivo: in Automatico segue il telefono.
  static String get currentCode =>
      notifier.value == automaticCode ? _deviceLanguageCode() : notifier.value;

  static Locale get locale {
    final effectiveCode = currentCode;
    return options
        .where((option) => option.code != automaticCode)
        .firstWhere(
          (option) => option.code == effectiveCode,
          orElse: () => options.firstWhere((option) => option.code == 'it'),
        )
        .locale;
  }

  static List<Locale> get supportedLocales => options
      .where((option) => option.code != automaticCode)
      .map((option) => option.locale)
      .toList(growable: false);

  static String t(String key) {
    final selected = _strings[currentCode] ?? _strings['it']!;
    return selected[key] ?? _strings['it']![key] ?? key;
  }
}
