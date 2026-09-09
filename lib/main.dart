// SALUTE RISPONDE RC1.3.0 - BASE UNIFICATA
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'services/app_storage_service.dart';
import 'services/document_ai_service.dart';
import 'services/medical_ai_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  runApp(const SaluteRispondeApp());
}

class SaluteRispondeApp extends StatelessWidget {
  const SaluteRispondeApp({super.key});

  static const navy = Color(0xFF0D2B45);
  static const primary = Color(0xFF0E4D5A);
  static const secondary = Color(0xFF00B4A6);
  static const cyan = Color(0xFF6EF6F5);
  static const soft = Color(0xFFF3F8FA);
  static const surface = Colors.white;
  static const text = Color(0xFF17313B);

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      secondary: secondary,
      surface: surface,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Salute Risponde',
      locale: const Locale('it', 'IT'),
      supportedLocales: const [Locale('it', 'IT')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: soft,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: soft,
          foregroundColor: navy,
          elevation: 0,
          centerTitle: false,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: navy,
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(22)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            borderSide: BorderSide(color: Color(0xFFD8E7EC)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            borderSide: BorderSide(color: Color(0xFFD8E7EC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            borderSide: BorderSide(color: secondary, width: 1.6),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: secondary,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _activateTester(BuildContext context) async {
    final storage = AppStorageService();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Modalità collaudo'),
        content: const Text(
          'Attivare la modalità di collaudo interna con risposte illimitate?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ANNULLA'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('ATTIVA TESTER'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await storage.setSelectedPlan('TESTER');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('salute_risponde_free_answers_used', 0);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Modalità collaudo attiva: risposte illimitate.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            Row(
              children: [
                GestureDetector(
                  onLongPress: () => _activateTester(context),
                  child: const _BrandWordmark(),
                ),
                const Spacer(),
                IconButton.filledTonal(
                  tooltip: 'Account',
                  onPressed: () => _open(context, const AccountPage()),
                  icon: const Icon(Icons.person_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [SaluteRispondeApp.navy, SaluteRispondeApp.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F0D2B45),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ciao 👋',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Come posso aiutarti oggi?',
                          style: TextStyle(
                            color: Color(0xFFD8F7F5),
                            fontSize: 15.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () =>
                                _open(context, const MedicalChatPage()),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: SaluteRispondeApp.navy,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                            ),
                            icon: const Icon(Icons.chat_bubble_outline_rounded),
                            label: const Text(
                              'Fai una domanda',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 168,
                    padding: const EdgeInsets.fromLTRB(22, 18, 10, 18),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF123D59), Color(0xFF0B746F)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'La salute, spiegata con chiarezza.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  height: 1.18,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Informazioni semplici e strumenti utili, sempre con te.',
                                style: TextStyle(
                                  color: Color(0xFFD8F7F5),
                                  fontSize: 14,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Image.asset(
                          'assets/branding/salute_risponde_icon.png',
                          width: 118,
                          height: 118,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tutto quello di cui hai bisogno',
              style: TextStyle(
                color: SaluteRispondeApp.navy,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.80,
              children: [
                _ServiceCard(
                  icon: Icons.calendar_month_rounded,
                  title: 'Agenda Salute',
                  subtitle: 'Appuntamenti e visite',
                  onTap: () => _open(context, const AgendaPage()),
                ),
                _ServiceCard(
                  icon: Icons.description_outlined,
                  title: 'Esami e Referti',
                  subtitle: 'I tuoi documenti',
                  onTap: () => _open(context, const DocumentsPage()),
                ),
                _ServiceCard(
                  icon: Icons.medication_outlined,
                  title: 'Promemoria Farmaci',
                  subtitle: 'Terapie sotto controllo',
                  onTap: () => _open(context, const MedicinesPage()),
                ),
                _ServiceCard(
                  icon: Icons.phone_in_talk_rounded,
                  title: 'Numeri Utili',
                  subtitle: 'Contatti rapidi',
                  onTap: () => _open(context, const UsefulNumbersPage()),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _ActionTile(
              icon: Icons.workspace_premium_outlined,
              title: 'Piani FREE, PLUS e PRO',
              subtitle: 'Scegli il piano più adatto',
              onTap: () => _open(context, const PlansPage()),
            ),
            const SizedBox(height: 18),
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                image: const DecorationImage(
                  image: AssetImage('assets/branding/care_reassuring.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Container(
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0x00102E46), Color(0xE6102E46)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const Text(
                  'Tecnologia che si prende cura di te.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _SafetyCard(),
          ],
        ),
      ),
    );
  }
}

class _BrandWordmark extends StatelessWidget {
  const _BrandWordmark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/branding/salute_risponde_icon.png',
          width: 48,
          height: 48,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 9),
        const Text(
          'Salute\nRisponde',
          style: TextStyle(
            color: SaluteRispondeApp.navy,
            fontSize: 20,
            height: 0.98,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      SaluteRispondeApp.secondary,
                      SaluteRispondeApp.primary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: SaluteRispondeApp.navy,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF6B7F87),
                  fontSize: 12.5,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFE7F7F6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: SaluteRispondeApp.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: SaluteRispondeApp.navy,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 17),
        onTap: onTap,
      ),
    );
  }
}

class MedicalChatPage extends StatefulWidget {
  const MedicalChatPage({super.key});

  @override
  State<MedicalChatPage> createState() => _MedicalChatPageState();
}

class _MedicalChatPageState extends State<MedicalChatPage> {
  static const int _freeLimit = 3;
  static const String _freeCountKey = 'salute_risponde_free_answers_used';

  final _service = MedicalAiService();
  final _storage = AppStorageService();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _chatImagePicker = ImagePicker();
  PlatformFile? _chatAttachment;

  final List<_ChatMessage> _messages = const [
    _ChatMessage(
      user: false,
      text:
          'Ciao, sono Salute Risponde. Posso aiutarti a capire meglio sintomi, esami e referti. Non sostituisco il medico.',
    ),
  ].toList();

  bool _sending = false;
  String? _statusMessage;
  int _freeUsed = 0;
  String _plan = 'FREE';

  @override
  void initState() {
    super.initState();
    _loadPlanAndLimit();
  }

  Future<void> _loadPlanAndLimit() async {
    final prefs = await SharedPreferences.getInstance();
    final plan = await _storage.getSelectedPlan();
    if (!mounted) return;
    setState(() {
      _plan = plan;
      _freeUsed = prefs.getInt(_freeCountKey) ?? 0;
    });
  }

  int get _remaining => (_freeLimit - _freeUsed).clamp(0, _freeLimit);

  String _cleanAiText(String text) {
    return text
        .replaceAll('**', '')
        .replaceAll('__', '')
        .replaceAll(RegExp(r'^\s*[-•]\s+', multiLine: true), '• ');
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _showUpgrade() async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                size: 42,
                color: SaluteRispondeApp.primary,
              ),
              const SizedBox(height: 12),
              const Text(
                'Hai utilizzato le 3 risposte gratuite',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Per continuare a parlare con Salute Risponde scegli il piano PLUS o PRO.',
                style: TextStyle(fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PlansPage()),
                    );
                  },
                  child: const Text('VEDI PLUS E PRO'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text('NON ORA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _takeChatPhoto() async {
    final photo = await _chatImagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
      maxWidth: 2400,
    );
    if (photo == null) return;

    final size = await photo.length();
    if (size < 1 || size > 10 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La foto deve avere una dimensione massima di 10 MB.')),
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _chatAttachment = PlatformFile(
        name: photo.name,
        path: photo.path,
        size: size,
      );
    });
  }

  Future<void> _pickChatGallery() async {
    final image = await _chatImagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
      maxWidth: 2600,
    );
    if (image == null) return;

    final size = await image.length();
    if (size < 1 || size > 10 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('L’immagine deve avere una dimensione massima di 10 MB.')),
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _chatAttachment = PlatformFile(
        name: image.name,
        path: image.path,
        size: size,
      );
    });
  }

  Future<void> _pickChatPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.path == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Non riesco ad accedere al PDF selezionato.')),
        );
      }
      return;
    }
    if (file.size < 1 || file.size > 10 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Il PDF deve avere una dimensione massima di 10 MB.')),
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() => _chatAttachment = file);
  }

  Future<void> _chooseChatAttachment() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Allega alla domanda',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                ),
                subtitle: Text('Foto, immagine dalla galleria oppure PDF.'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Scatta una foto'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _takeChatPhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Scegli dalla galleria'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickChatGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text('Allega un PDF'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickChatPdf();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _send() async {
    final typedText = _controller.text.trim();
    final attachment = _chatAttachment;

    if ((typedText.isEmpty && attachment == null) || _sending) return;

    if (_plan == 'FREE' && _freeUsed >= _freeLimit) {
      await _showUpgrade();
      return;
    }

    if (attachment != null && attachment.path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('L’allegato non è più disponibile. Selezionalo di nuovo.')),
      );
      return;
    }

    final message = typedText.isEmpty
        ? 'Analizza e spiegami questo allegato sanitario.'
        : typedText;

    final history = _messages
        .map((m) => {
              'role': m.user ? 'user' : 'assistant',
              'content': m.text,
            })
        .toList();

    final visibleMessage = attachment == null
        ? message
        : '$message\n📎 ${attachment.name}';

    setState(() {
      _messages.add(_ChatMessage(user: true, text: visibleMessage));
      _controller.clear();
      _chatAttachment = null;
      _sending = true;
      _statusMessage = attachment == null
          ? 'Salute Risponde sta rispondendo…'
          : 'Salute Risponde sta analizzando l’allegato…';
    });
    _scrollToBottom();

    Future<void>.delayed(const Duration(seconds: 15), () {
      if (mounted && _sending) {
        setState(() {
          _statusMessage = attachment == null
              ? 'Salute Risponde sta elaborando la risposta, ancora qualche secondo…'
              : 'Analisi dell’allegato in corso, ancora qualche secondo…';
        });
        _scrollToBottom();
      }
    });

    try {
      final reply = await _service.sendMessage(
        message: message,
        history: history,
        attachmentPath: attachment?.path,
        attachmentName: attachment?.name,
      );

      final cleanedReply = _cleanAiText(reply);

      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(user: false, text: cleanedReply),
        );
      });
      _scrollToBottom();

      // Scala il FREE solo dopo una risposta AI valida realmente mostrata.
      if (_plan == 'FREE') {
        final prefs = await SharedPreferences.getInstance();
        final newCount = (_freeUsed + 1).clamp(0, _freeLimit);
        await prefs.setInt(_freeCountKey, newCount);
        if (mounted) {
          setState(() => _freeUsed = newCount);
        } else {
          _freeUsed = newCount;
        }
      }

      if (_plan == 'FREE' && _freeUsed >= _freeLimit) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (mounted) await _showUpgrade();
      }
    } on MedicalAiException catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(user: false, text: _cleanAiText(e.message)),
        );
        _statusMessage = null;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            user: false,
            text: 'Errore app Salute Risponde: ${e.runtimeType}. Riprova.',
          ),
        );
        _statusMessage = null;
      });
      _scrollToBottom();
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
          _statusMessage = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final free = _plan == 'FREE';
    final tester = _plan == 'TESTER';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/branding/salute_risponde_icon.png',
              width: 34,
              height: 34,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 10),
            const Text('Fai una domanda'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (tester)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F7F2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'COLLAUDO • risposte illimitate',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          if (free)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5F8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _remaining > 0
                    ? 'Piano FREE • $_remaining ${_remaining == 1 ? 'risposta rimasta' : 'risposte rimaste'}'
                    : 'Piano FREE • limite gratuito raggiunto',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          if (free && _remaining == 0)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: SaluteRispondeApp.primary, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hai terminato le 3 risposte gratuite',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: SaluteRispondeApp.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Continua con Salute Risponde scegliendo PLUS o PRO.',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const PlansPage()),
                            );
                          },
                          child: const Text('PLUS'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const PlansPage()),
                            );
                          },
                          child: const Text('PRO'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                return Align(
                  alignment: m.user ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 330),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: m.user
                          ? SaluteRispondeApp.primary
                          : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(22),
                        topRight: const Radius.circular(22),
                        bottomLeft: Radius.circular(m.user ? 22 : 6),
                        bottomRight: Radius.circular(m.user ? 6 : 22),
                      ),
                      border: m.user
                          ? null
                          : Border.all(color: const Color(0xFFE2EDF0)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D0D2B45),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      m.text,
                      style: TextStyle(
                        color: m.user ? Colors.white : SaluteRispondeApp.text,
                        height: 1.35,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_sending)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 6),
              child: Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _statusMessage ?? 'Salute Risponde sta rispondendo…',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_chatAttachment != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5F8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFD3E7EC)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _chatAttachment!.name.toLowerCase().endsWith('.pdf')
                                ? Icons.picture_as_pdf_outlined
                                : Icons.image_outlined,
                            color: SaluteRispondeApp.primary,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              _chatAttachment!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Rimuovi allegato',
                            onPressed: _sending
                                ? null
                                : () => setState(() => _chatAttachment = null),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5F8),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: IconButton(
                          tooltip: 'Allega foto o PDF',
                          color: SaluteRispondeApp.primary,
                          onPressed: _sending || (free && _freeUsed >= _freeLimit)
                              ? null
                              : _chooseChatAttachment,
                          icon: const Icon(Icons.attach_file_rounded),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          enabled: !(free && _freeUsed >= _freeLimit),
                          minLines: 1,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: free && _freeUsed >= _freeLimit
                                ? 'Scegli PLUS o PRO per continuare'
                                : 'Scrivi una domanda o allega un esame...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              SaluteRispondeApp.secondary,
                              SaluteRispondeApp.primary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: IconButton(
                          color: Colors.white,
                          onPressed: _sending
                              ? null
                              : (free && _freeUsed >= _freeLimit)
                                  ? _showUpgrade
                                  : _send,
                          icon: Icon(
                            free && _freeUsed >= _freeLimit
                                ? Icons.workspace_premium
                                : Icons.send_rounded,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final bool user;
  final String text;
  const _ChatMessage({required this.user, required this.text});
}

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  final _storage = AppStorageService();
  final _documentAi = DocumentAiService();
  final _imagePicker = ImagePicker();
  List<Map<String, dynamic>> _documents = [];
  PlatformFile? _pending;
  int? _selectedIndex;
  int? _openingIndex;
  bool _analyzing = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final data = await _storage.loadDocuments();
    if (mounted) setState(() => _documents = data);
  }

  Future<void> _choose() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
    );
    if (result == null || result.files.isEmpty) return;
    setState(() => _pending = result.files.first);
  }

  Future<void> _takePhoto() async {
    final photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 88,
      maxWidth: 2200,
    );
    if (photo == null) return;

    final length = await photo.length();
    setState(() {
      _pending = PlatformFile(
        name: photo.name,
        path: photo.path,
        size: length,
      );
    });
  }

  Future<void> _chooseSource() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Aggiungi un documento',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                ),
                subtitle: Text('Fotografa il documento oppure scegli un file già salvato.'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Scatta una foto'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder_open_outlined),
                title: const Text('Scegli dalla galleria o dai file'),
                subtitle: const Text('PDF, JPG, PNG o WEBP'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _choose();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _savePending() async {
    final file = _pending;
    if (file == null || file.path == null) {
      _snack('Seleziona prima un documento.');
      return;
    }

    try {
      final archivedPath = await _storage.archiveFile(file.path!, file.name);
      _documents.add({
        'name': file.name,
        'path': archivedPath,
        'date': DateTime.now().toIso8601String(),
      });
      await _storage.saveDocuments(_documents);
      if (!mounted) return;
      setState(() {
        _pending = null;
        _selectedIndex = _documents.length - 1;
      });
      _snack('Documento salvato nel tuo archivio.');
    } catch (_) {
      _snack('Non è stato possibile salvare il documento.');
    }
  }

  Future<void> _openDocument(int index) async {
    if (_openingIndex != null) return;

    final item = _documents[index];
    final path = item['path']?.toString() ?? '';
    final name = item['name']?.toString() ?? 'Documento';

    if (path.isEmpty || !await File(path).exists()) {
      _snack('Il file non è più disponibile sul dispositivo.');
      return;
    }

    setState(() {
      _selectedIndex = index;
      _openingIndex = index;
    });

    try {
      final ext = path.toLowerCase().split('.').last;

      if (['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _ImagePreviewPage(
              filePath: path,
              title: name,
            ),
          ),
        );
      } else {
        final result = await OpenFilex.open(path);
        if (result.type != ResultType.done && mounted) {
          _snack('Non riesco ad aprire questo PDF con le app disponibili.');
        }
      }
    } catch (_) {
      if (mounted) {
        _snack('Errore durante l’apertura del documento.');
      }
    } finally {
      if (mounted) {
        setState(() => _openingIndex = null);
      }
    }
  }

  Future<void> _delete(int index) async {
    final item = _documents[index];
    await _storage.deleteArchivedFile(item['path']?.toString() ?? '');
    _documents.removeAt(index);
    if (_selectedIndex == index) {
      _selectedIndex = null;
    } else if (_selectedIndex != null && _selectedIndex! > index) {
      _selectedIndex = _selectedIndex! - 1;
    }
    await _storage.saveDocuments(_documents);
    if (mounted) setState(() {});
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _analyzeSelected() async {
    if (_selectedIndex == null) {
      _snack('Seleziona prima un documento.');
      return;
    }

    final item = _documents[_selectedIndex!];
    final path = item['path']?.toString() ?? '';
    final extension = path.toLowerCase().split('.').last;

    if (path.isEmpty || !await File(path).exists()) {
      _snack('Il file non è più disponibile sul dispositivo.');
      return;
    }

    if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
      _snack('Per ora l’analisi è disponibile per foto e immagini. Fotografa le pagine del PDF.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Analizzare il documento?'),
        content: const Text(
          'La foto verrà inviata in modo sicuro al servizio di analisi per leggerla e spiegarla. Evita di inviare documenti di altre persone senza il loro consenso.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ANNULLA'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('ANALIZZA'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _analyzing = true);
    try {
      final explanation = await _documentAi.analyzeImage(path);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _DocumentAnalysisPage(
            documentName: item['name']?.toString() ?? 'Documento',
            explanation: explanation,
          ),
        ),
      );
    } on DocumentAiException catch (e) {
      if (mounted) _snack(e.message);
    } catch (_) {
      if (mounted) _snack('Non è stato possibile analizzare il documento.');
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Esami e referti')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton.icon(
            onPressed: _chooseSource,
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('Fotografa o scegli un documento'),
          ),
          if (_pending != null) ...[
            const SizedBox(height: 14),
            Card(
              child: ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(_pending!.name),
                subtitle: const Text('Pronto per essere salvato'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _savePending,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Salva nel mio archivio'),
              ),
            ),
          ],
          const SizedBox(height: 20),
          const Text(
            'I miei documenti',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          if (_documents.isEmpty)
            const Text('Nessun documento salvato.')
          else
            ...List.generate(_documents.length, (i) {
              final item = _documents[i];
              final selected = _selectedIndex == i;
              return Card(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: selected ? SaluteRispondeApp.primary : Colors.transparent,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  onTap: () => setState(() => _selectedIndex = i),
                  leading: Icon(
                    selected ? Icons.check_circle : Icons.folder_copy_outlined,
                    color: SaluteRispondeApp.primary,
                  ),
                  title: Text(item['name']?.toString() ?? 'Documento'),
                  subtitle: Text(
                    selected
                        ? 'Selezionato • usa Apri per visualizzarlo'
                        : 'Tocca per selezionare • usa Apri per visualizzarlo',
                  ),
                  trailing: Wrap(
                    spacing: 0,
                    children: [
                      IconButton(
                        tooltip: 'Apri',
                        onPressed: _openingIndex == null ? () => _openDocument(i) : null,
                        icon: _openingIndex == i
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.open_in_new),
                      ),
                      IconButton(
                        tooltip: 'Elimina',
                        onPressed: () => _delete(i),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _selectedIndex == null || _analyzing ? null : _analyzeSelected,
            icon: _analyzing
                ? const SizedBox(
                    width: 19,
                    height: 19,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(_analyzing ? 'Analisi in corso…' : 'Analizza e spiegami'),
          ),
        ],
      ),
    );
  }
}

class _DocumentAnalysisPage extends StatelessWidget {
  final String documentName;
  final String explanation;

  const _DocumentAnalysisPage({
    required this.documentName,
    required this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spiegazione del documento')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            documentName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: SelectableText(
                explanation.replaceAll('**', ''),
                style: const TextStyle(fontSize: 16, height: 1.48),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Questa spiegazione è informativa e non sostituisce il medico che ha richiesto o firmato il documento.',
            style: TextStyle(color: Colors.black54, height: 1.4),
          ),
        ],
      ),
    );
  }
}


class _ImagePreviewPage extends StatelessWidget {
  final String filePath;
  final String title;

  const _ImagePreviewPage({
    required this.filePath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5,
          child: Image.file(
            File(filePath),
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Impossibile visualizzare questa immagine.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  final _storage = AppStorageService();
  List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _storage.loadAppointments();
    if (mounted) setState(() => _appointments = data);
  }

  Future<void> _add() async {
    final result = await Navigator.push<_AppointmentDraft>(
      context,
      MaterialPageRoute(builder: (_) => const AppointmentEditorPage()),
    );
    if (result == null) return;

    final id = DateTime.now().millisecondsSinceEpoch.remainder(2000000000);
    _appointments.add({
      'id': id,
      'title': result.title,
      'date': result.dateTime.toIso8601String(),
    });
    await _storage.saveAppointments(_appointments);
    await NotificationService.instance.scheduleAppointmentReminder(
      id: id,
      title: result.title,
      appointment: result.dateTime,
    );
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Appuntamento salvato.')),
    );
  }

  Future<void> _delete(int index) async {
    final id = (_appointments[index]['id'] as num?)?.toInt();
    if (id != null) await NotificationService.instance.cancel(id);
    _appointments.removeAt(index);
    await _storage.saveAppointments(_appointments);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agenda Salute')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: const Text('Nuova visita'),
      ),
      body: _appointments.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Text(
                  'Nessun appuntamento.\nPremi “Nuova visita” per inserirne uno.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _appointments.length,
              itemBuilder: (_, i) {
                final item = _appointments[i];
                final dt = DateTime.tryParse(item['date']?.toString() ?? '');
                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.event_available,
                      color: SaluteRispondeApp.primary,
                    ),
                    title: Text(item['title']?.toString() ?? 'Visita'),
                    subtitle: Text(dt == null ? '' : _formatDateTime(dt)),
                    trailing: IconButton(
                      onPressed: () => _delete(i),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class AppointmentEditorPage extends StatefulWidget {
  const AppointmentEditorPage({super.key});

  @override
  State<AppointmentEditorPage> createState() => _AppointmentEditorPageState();
}

class _AppointmentEditorPageState extends State<AppointmentEditorPage> {
  final _title = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _save() {
    final title = _title.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci il tipo di visita o lo specialista.')),
      );
      return;
    }
    Navigator.pop(
      context,
      _AppointmentDraft(
        title,
        DateTime(
          _date.year,
          _date.month,
          _date.day,
          _time.hour,
          _time.minute,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuova visita')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          TextField(
            controller: _title,
            decoration: const InputDecoration(
              labelText: 'Visita / specialista',
              hintText: 'Es. Dentista',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text('${_date.day}/${_date.month}/${_date.year}'),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 3650)),
                initialDate: _date,
              );
              if (picked != null) setState(() => _date = picked);
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: Text(_time.format(context)),
            onTap: () async {
              final picked = await showTimePicker(context: context, initialTime: _time);
              if (picked != null) setState(() => _time = picked);
            },
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Salva appuntamento'),
          ),
        ],
      ),
    );
  }
}

class _AppointmentDraft {
  final String title;
  final DateTime dateTime;
  const _AppointmentDraft(this.title, this.dateTime);
}

class MedicinesPage extends StatefulWidget {
  const MedicinesPage({super.key});

  @override
  State<MedicinesPage> createState() => _MedicinesPageState();
}

class _MedicinesPageState extends State<MedicinesPage> {
  final _storage = AppStorageService();
  List<Map<String, dynamic>> _medicines = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _storage.loadMedicines();
    if (mounted) setState(() => _medicines = data);
  }

  Future<void> _add() async {
    final result = await Navigator.push<_MedicineDraft>(
      context,
      MaterialPageRoute(builder: (_) => const MedicineEditorPage()),
    );
    if (result == null) return;

    final id = DateTime.now().millisecondsSinceEpoch.remainder(2000000000);
    _medicines.add({
      'id': id,
      'name': result.name,
      'hour': result.hour,
      'minute': result.minute,
    });
    await _storage.saveMedicines(_medicines);
    await NotificationService.instance.scheduleDailyMedicine(
      id: id,
      medicine: result.name,
      hour: result.hour,
      minute: result.minute,
    );
    if (mounted) setState(() {});
  }

  Future<void> _edit(int index) async {
    final m = _medicines[index];
    final id = (m['id'] as num?)?.toInt();
    final initial = _MedicineDraft(
      m['name']?.toString() ?? '',
      (m['hour'] as num?)?.toInt() ?? 8,
      (m['minute'] as num?)?.toInt() ?? 0,
    );

    final result = await Navigator.push<_MedicineDraft>(
      context,
      MaterialPageRoute(
        builder: (_) => MedicineEditorPage(initial: initial),
      ),
    );
    if (result == null) return;

    if (id != null) await NotificationService.instance.cancel(id);

    _medicines[index] = {
      'id': id ?? DateTime.now().millisecondsSinceEpoch.remainder(2000000000),
      'name': result.name,
      'hour': result.hour,
      'minute': result.minute,
    };

    await _storage.saveMedicines(_medicines);

    final newId = (_medicines[index]['id'] as num).toInt();
    await NotificationService.instance.scheduleDailyMedicine(
      id: newId,
      medicine: result.name,
      hour: result.hour,
      minute: result.minute,
    );

    if (mounted) setState(() {});
  }

  Future<void> _delete(int index) async {
    final id = (_medicines[index]['id'] as num?)?.toInt();
    if (id != null) await NotificationService.instance.cancel(id);
    _medicines.removeAt(index);
    await _storage.saveMedicines(_medicines);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Promemoria farmaci')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: const Text('Aggiungi'),
      ),
      body: _medicines.isEmpty
          ? const Center(child: Text('Nessun promemoria farmaco impostato.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _medicines.length,
              itemBuilder: (_, i) {
                final m = _medicines[i];
                final hour = (m['hour'] as num?)?.toInt() ?? 0;
                final minute = (m['minute'] as num?)?.toInt() ?? 0;
                return Card(
                  child: ListTile(
                    onTap: () => _edit(i),
                    leading: const Icon(
                      Icons.medication,
                      color: SaluteRispondeApp.primary,
                    ),
                    title: Text(m['name']?.toString() ?? 'Farmaco'),
                    subtitle: Text(
                      'Ogni giorno alle ${hour.toString().padLeft(2, '0')}:'
                      '${minute.toString().padLeft(2, '0')}',
                    ),
                    trailing: Wrap(
                      spacing: 0,
                      children: [
                        IconButton(
                          tooltip: 'Modifica',
                          onPressed: () => _edit(i),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: 'Elimina',
                          onPressed: () => _delete(i),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class MedicineEditorPage extends StatefulWidget {
  final _MedicineDraft? initial;
  const MedicineEditorPage({super.key, this.initial});

  @override
  State<MedicineEditorPage> createState() => _MedicineEditorPageState();
}

class _MedicineEditorPageState extends State<MedicineEditorPage> {
  late final TextEditingController _name;
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial?.name ?? '');
    _time = TimeOfDay(
      hour: widget.initial?.hour ?? 8,
      minute: widget.initial?.minute ?? 0,
    );
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci il nome del farmaco.')),
      );
      return;
    }
    Navigator.pop(
      context,
      _MedicineDraft(name, _time.hour, _time.minute),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initial != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Modifica promemoria' : 'Nuovo promemoria'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Farmaco / integratore',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: Text(_time.format(context)),
            onTap: () async {
              final picked = await showTimePicker(context: context, initialTime: _time);
              if (picked != null) setState(() => _time = picked);
            },
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.notifications_active),
            label: Text(
              editing ? 'Salva modifiche' : 'Salva e attiva promemoria',
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicineDraft {
  final String name;
  final int hour;
  final int minute;
  const _MedicineDraft(this.name, this.hour, this.minute);
}

class UsefulNumbersPage extends StatefulWidget {
  const UsefulNumbersPage({super.key});

  @override
  State<UsefulNumbersPage> createState() => _UsefulNumbersPageState();
}

class _UsefulNumbersPageState extends State<UsefulNumbersPage> {
  static const _contactsKey = 'salute_risponde_personal_health_contacts';
  List<Map<String, String>> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_contactsKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        _contacts = decoded
            .whereType<Map>()
            .map((e) => {
                  'name': e['name']?.toString() ?? '',
                  'role': e['role']?.toString() ?? '',
                  'phone': e['phone']?.toString() ?? '',
                  'note': e['note']?.toString() ?? '',
                })
            .toList();
      }
    } catch (_) {}
    if (mounted) setState(() {});
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_contactsKey, jsonEncode(_contacts));
  }

  Future<void> _call(String number) async {
    final uri = Uri(scheme: 'tel', path: number.replaceAll(' ', ''));
    if (!await launchUrl(uri) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossibile aprire il telefono.')),
      );
    }
  }

  Future<void> _editContact({int? index}) async {
    final existing = index == null ? null : _contacts[index];
    final name = TextEditingController(text: existing?['name'] ?? '');
    final role = TextEditingController(text: existing?['role'] ?? '');
    final phone = TextEditingController(text: existing?['phone'] ?? '');
    final note = TextEditingController(text: existing?['note'] ?? '');

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(index == null ? 'Aggiungi contatto sanitario' : 'Modifica contatto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome')),
              TextField(
                controller: role,
                decoration: const InputDecoration(
                  labelText: 'Ruolo / specialità',
                  hintText: 'Es. Medico di base, Cardiologo',
                ),
              ),
              TextField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Telefono'),
              ),
              TextField(
                controller: note,
                decoration: const InputDecoration(labelText: 'Nota (facoltativa)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('ANNULLA'),
          ),
          FilledButton(
            onPressed: () {
              if (name.text.trim().isEmpty || phone.text.trim().isEmpty) return;
              Navigator.pop(dialogContext, {
                'name': name.text.trim(),
                'role': role.text.trim(),
                'phone': phone.text.trim(),
                'note': note.text.trim(),
              });
            },
            child: const Text('SALVA'),
          ),
        ],
      ),
    );

    name.dispose();
    role.dispose();
    phone.dispose();
    note.dispose();

    if (result == null) return;
    if (index == null) {
      _contacts.add(result);
    } else {
      _contacts[index] = result;
    }
    await _saveContacts();
    if (mounted) setState(() {});
  }

  Future<void> _deleteContact(int index) async {
    _contacts.removeAt(index);
    await _saveContacts();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const numbers = [
      ('Numero unico emergenze', '112'),
      ('Emergenza sanitaria', '118'),
      ('Polizia di Stato', '113'),
      ('Vigili del Fuoco', '115'),
      ('Guardia di Finanza', '117'),
      ('Telefono Azzurro', '19696'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Numeri utili')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          const Text(
            'Numeri nazionali',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          ...numbers.map(
            (item) => Card(
              child: ListTile(
                leading: const Icon(Icons.phone_in_talk, color: SaluteRispondeApp.primary),
                title: Text(item.$1),
                subtitle: Text(item.$2),
                trailing: const Icon(Icons.phone),
                onTap: () => _call(item.$2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'I miei contatti sanitari',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          if (_contacts.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Aggiungi il tuo medico, uno specialista, una farmacia o un altro contatto di fiducia.',
              ),
            )
          else
            ...List.generate(_contacts.length, (i) {
              final c = _contacts[i];
              final role = c['role']?.trim() ?? '';
              final note = c['note']?.trim() ?? '';
              final subtitleParts = <String>[
                if (role.isNotEmpty) role,
                c['phone'] ?? '',
                if (note.isNotEmpty) note,
              ];
              return Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.medical_services_outlined,
                    color: SaluteRispondeApp.primary,
                  ),
                  title: Text(c['name'] ?? 'Contatto'),
                  subtitle: Text(subtitleParts.join(' • ')),
                  onTap: () => _call(c['phone'] ?? ''),
                  trailing: Wrap(
                    spacing: 0,
                    children: [
                      IconButton(
                        tooltip: 'Modifica',
                        onPressed: () => _editContact(index: i),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Elimina',
                        onPressed: () => _deleteContact(i),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _editContact(),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Aggiungi contatto'),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'I numeri territoriali verranno inseriti dopo verifica ufficiale per area geografica.',
            style: TextStyle(fontSize: 12.5, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  final _storage = AppStorageService();
  String selected = 'FREE';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    selected = await _storage.getSelectedPlan();
    if (mounted) setState(() {});
  }

  Future<void> _choose(String plan) async {
    if (plan == 'FREE') {
      await _storage.setSelectedPlan(plan);
      if (mounted) setState(() => selected = plan);
      return;
    }

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Piano $plan'),
        content: const Text(
          'Il piano sarà attivabile tramite Google Play nella versione di pubblicazione.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Piani Salute Risponde')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PlanCard(
            title: 'FREE',
            price: 'Gratis',
            features: const [
              '3 risposte gratuite',
              '1 esame o referto',
              'Avvisi di sicurezza sempre disponibili',
            ],
            selected: selected == 'FREE',
            button: 'PIANO ATTUALE',
            onTap: () => _choose('FREE'),
          ),
          _PlanCard(
            title: 'PLUS',
            price: 'Prezzo da definire / mese',
            features: const [
              'Più consultazioni',
              'Più documenti',
              'Cronologia',
              'Agenda Salute',
            ],
            selected: selected == 'PLUS',
            button: 'SCEGLI PLUS',
            onTap: () => _choose('PLUS'),
          ),
          _PlanCard(
            title: 'PRO',
            price: 'Prezzo da definire / mese',
            features: const [
              'Analisi avanzata documenti',
              'Riepilogo per il medico',
              'Preparazione visita',
              'Funzioni avanzate',
            ],
            selected: selected == 'PRO',
            button: 'SCEGLI PRO',
            onTap: () => _choose('PRO'),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final List<String> features;
  final bool selected;
  final String button;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.features,
    required this.selected,
    required this.button,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                if (selected) const Chip(label: Text('ATTIVO')),
              ],
            ),
            Text(
              price,
              style: const TextStyle(
                color: SaluteRispondeApp.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            ...features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 19),
                    const SizedBox(width: 8),
                    Expanded(child: Text(f)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onTap,
                child: Text(button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onLongPress: () async {
              final storage = AppStorageService();
              final current = await storage.getSelectedPlan();
              if (current == 'TESTER') {
                await storage.setSelectedPlan('FREE');
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('salute_risponde_free_answers_used', 0);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Modalità TESTER disattivata. Piano FREE ripristinato.'),
                    ),
                  );
                }
              }
            },
            child: const Text('Account Salute Risponde'),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'ACCEDI'),
              Tab(text: 'ISCRIVITI'),
            ],
          ),
        ),
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            _AccountForm(register: false),
            _AccountForm(register: true),
          ],
        ),
      ),
    );
  }
}

class _AccountForm extends StatefulWidget {
  final bool register;
  const _AccountForm({required this.register});

  @override
  State<_AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<_AccountForm> {
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 12),
        TextField(
          controller: email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: password,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.register
                      ? 'Registrazione non ancora attiva.'
                      : 'Accesso non ancora attivo.',
                ),
              ),
            );
          },
          child: Text(widget.register ? 'ISCRIVITI' : 'ACCEDI'),
        ),
      ],
    );
  }
}

class _SafetyCard extends StatelessWidget {
  const _SafetyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEAF8FA), Color(0xFFDDF6F3)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: SaluteRispondeApp.secondary,
            size: 28,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sicuro. Affidabile. Umano.\nSalute Risponde offre informazioni e orientamento sanitario e non sostituisce il medico. In caso di emergenza contatta i servizi sanitari.',
              style: TextStyle(
                color: SaluteRispondeApp.navy,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDateTime(DateTime dt) {
  return '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/${dt.year} · '
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';
}
