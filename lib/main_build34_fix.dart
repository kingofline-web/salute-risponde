// SALUTE RISPONDE BUILD 34 - MULTILINGUA COMPLETA + NUOVO BRAND
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'services/app_storage_service.dart';
import 'services/document_ai_service.dart';
import 'services/language_service.dart';
import 'services/medical_ai_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LanguageService.initialize();
  await NotificationService.instance.initialize();
  runApp(SaluteRispondeApp());
}

class SaluteRispondeApp extends StatelessWidget {
  SaluteRispondeApp({super.key});

  static final navy = Color(0xFF174A43);
  static final primary = Color(0xFF168C7C);
  static final secondary = Color(0xFF40B89F);
  static final cyan = Color(0xFFA8E6D8);
  static final soft = Color(0xFFF5FBF8);
  static final surface = Colors.white;
  static final text = Color(0xFF243B36);
  static final accent = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      secondary: secondary,
      surface: surface,
    );

    return ValueListenableBuilder<String>(
      valueListenable: LanguageService.notifier,
      builder: (context, languageCode, _) {
        return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Salute Risponde',
      locale: LanguageService.locale,
      supportedLocales: LanguageService.supportedLocales,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: soft,
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(
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
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: secondary,
          foregroundColor: Colors.white,
        ),
      ),
      home: HomePage(),
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _openKol() async {
    final uri = Uri.parse('https://www.kol.it');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _activateTester(BuildContext context) async {
    final storage = AppStorageService();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(LanguageService.uiText('Modalità collaudo')),
        content: Text(
          LanguageService.uiText('Attivare la modalità di collaudo interna con risposte illimitate?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(LanguageService.uiText('ANNULLA')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(LanguageService.uiText('ATTIVA TESTER')),
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
      SnackBar(content: Text(LanguageService.uiText('Modalità collaudo attiva: risposte illimitate.'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            Row(
              children: [
                GestureDetector(
                  onLongPress: () => _activateTester(context),
                  child: _BrandWordmark(),
                ),
                Spacer(),
                PopupMenuButton<String>(
                  tooltip: LanguageService.t('language'),
                  icon: Icon(Icons.language_rounded),
                  onSelected: LanguageService.setLanguage,
                  itemBuilder: (context) => LanguageService.options
                      .map(
                        (option) => PopupMenuItem<String>(
                          value: option.code,
                          child: Row(
                            children: [
                              Text(option.flag, style: TextStyle(fontSize: 20)),
                              SizedBox(width: 10),
                              Text(LanguageService.optionName(option)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
                IconButton(
                  tooltip: LanguageService.t('instructions'),
                  onPressed: () => _open(context, InstructionsPage()),
                  icon: Icon(Icons.info_outline_rounded),
                ),
                IconButton.filledTonal(
                  tooltip: LanguageService.t('account'),
                  onPressed: () => _open(context, AccountPage()),
                  icon: Icon(Icons.person_outline_rounded),
                ),
              ],
            ),
            SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [SaluteRispondeApp.navy, SaluteRispondeApp.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1F174A43),
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
                    padding: EdgeInsets.fromLTRB(22, 22, 22, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LanguageService.t('home_hello'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          LanguageService.t('home_help_today'),
                          style: TextStyle(
                            color: Color(0xFFE9FFF7),
                            fontSize: 15.5,
                          ),
                        ),
                        SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () =>
                                _open(context, MedicalChatPage()),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: SaluteRispondeApp.navy,
                              padding: EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                            ),
                            icon: Icon(Icons.chat_bubble_outline_rounded),
                            label: Text(
                              LanguageService.t('ask_question'),
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 168,
                    padding: EdgeInsets.fromLTRB(22, 18, 10, 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1B675D), Color(0xFF40B89F)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LanguageService.t('health_clear'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  height: 1.18,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                LanguageService.t('simple_tools'),
                                style: TextStyle(
                                  color: Color(0xFFE9FFF7),
                                  fontSize: 14,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Image.asset(
                          'assets/branding/saluterisponde_icon_master.png',
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
            SizedBox(height: 24),
            Text(
              LanguageService.t('everything_you_need'),
              style: TextStyle(
                color: SaluteRispondeApp.navy,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.80,
              children: [
                _ServiceCard(
                  icon: Icons.calendar_month_rounded,
                  title: LanguageService.t('agenda_health'),
                  subtitle: LanguageService.t('appointments_visits'),
                  onTap: () => _open(context, AgendaPage()),
                ),
                _ServiceCard(
                  icon: Icons.description_outlined,
                  title: LanguageService.t('tests_reports'),
                  subtitle: LanguageService.t('your_documents'),
                  onTap: () => _open(context, DocumentsPage()),
                ),
                _ServiceCard(
                  icon: Icons.medication_outlined,
                  title: LanguageService.t('medicine_reminders'),
                  subtitle: LanguageService.t('therapies_control'),
                  onTap: () => _open(context, MedicinesPage()),
                ),
                _ServiceCard(
                  icon: Icons.phone_in_talk_rounded,
                  title: LanguageService.t('useful_numbers'),
                  subtitle: LanguageService.t('quick_contacts'),
                  onTap: () => _open(context, UsefulNumbersPage()),
                ),
              ],
            ),
            SizedBox(height: 14),
            _ActionTile(
              icon: Icons.workspace_premium_outlined,
              title: LanguageService.t('plans_title'),
              subtitle: LanguageService.t('choose_plan'),
              onTap: () => _open(context, PlansPage()),
            ),
            SizedBox(height: 18),
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                image: DecorationImage(
                  image: AssetImage('assets/branding/care_reassuring.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Container(
                alignment: Alignment.bottomLeft,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0x00174A43), Color(0xE6174A43)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Text(
                  LanguageService.t('technology_cares'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            _SafetyCard(),
            SizedBox(height: 20),
            Center(
              child: Text(
                '© 2026 SaluteRisponde',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF6B7F87),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 5),
            Center(
              child: InkWell(
                onTap: _openKol,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  child: Text(
                    LanguageService.t('powered_by'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: SaluteRispondeApp.primary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class InstructionsPage extends StatelessWidget {
  InstructionsPage({super.key});

  Widget _section(IconData icon, String title, String body) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Color(0xFFE7F7F6),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: SaluteRispondeApp.primary),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: SaluteRispondeApp.navy,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    body,
                    style: TextStyle(
                      color: SaluteRispondeApp.text,
                      fontSize: 14.5,
                      height: 1.42,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LanguageService.t('instructions'))),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(18, 10, 18, 28),
          children: [
            Text(
              LanguageService.t('instructions_intro'),
              style: TextStyle(
                color: SaluteRispondeApp.text,
                fontSize: 15,
                height: 1.45,
              ),
            ),
            SizedBox(height: 16),
            _section(
              Icons.chat_bubble_outline_rounded,
              LanguageService.t('instructions_chat_title'),
              LanguageService.t('instructions_chat_body'),
            ),
            SizedBox(height: 12),
            _section(
              Icons.description_outlined,
              LanguageService.t('instructions_docs_title'),
              LanguageService.t('instructions_docs_body'),
            ),
            SizedBox(height: 12),
            _section(
              Icons.calendar_month_rounded,
              LanguageService.t('instructions_agenda_title'),
              LanguageService.t('instructions_agenda_body'),
            ),
            SizedBox(height: 12),
            _section(
              Icons.medication_outlined,
              LanguageService.t('instructions_meds_title'),
              LanguageService.t('instructions_meds_body'),
            ),
            SizedBox(height: 12),
            _section(
              Icons.health_and_safety_outlined,
              LanguageService.t('instructions_safety_title'),
              LanguageService.t('instructions_safety_body'),
            ),
          ],
        ),
      ),
    );
  }
}


class _BrandWordmark extends StatelessWidget {
  _BrandWordmark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/branding/saluterisponde_icon_master.png',
          width: 48,
          height: 48,
          fit: BoxFit.contain,
        ),
        SizedBox(width: 9),
        Text(
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

  _ServiceCard({
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
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      SaluteRispondeApp.secondary,
                      SaluteRispondeApp.primary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              Spacer(),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: SaluteRispondeApp.navy,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  height: 1.15,
                ),
              ),
              SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
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

  _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Color(0xFFE7F7F6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: SaluteRispondeApp.primary),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: SaluteRispondeApp.navy,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 17),
        onTap: onTap,
      ),
    );
  }
}

class MedicalChatPage extends StatefulWidget {
  MedicalChatPage({super.key});

  @override
  State<MedicalChatPage> createState() => _MedicalChatPageState();
}

class _MedicalChatPageState extends State<MedicalChatPage> {
  static int _freeLimit = 3;
  static String _freeCountKey = 'salute_risponde_free_answers_used';

  final _service = MedicalAiService();
  final _storage = AppStorageService();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _chatImagePicker = ImagePicker();
  PlatformFile? _chatAttachment;

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      user: false,
      text:
          LanguageService.uiText('Ciao, sono Salute Risponde. Posso aiutarti a capire meglio sintomi, esami e referti. Non sostituisco il medico.'),
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
        duration: Duration(milliseconds: 280),
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
          padding: EdgeInsets.fromLTRB(22, 8, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                size: 42,
                color: SaluteRispondeApp.primary,
              ),
              SizedBox(height: 12),
              Text(
                LanguageService.uiText('Hai utilizzato le 3 risposte gratuite'),
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 8),
              Text(
                LanguageService.uiText('Per continuare a parlare con Salute Risponde scegli il piano PLUS o PRO.'),
                style: TextStyle(fontSize: 16, height: 1.4),
              ),
              SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PlansPage()),
                    );
                  },
                  child: Text(LanguageService.uiText('VEDI PLUS E PRO')),
                ),
              ),
              SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: Text(LanguageService.uiText('NON ORA')),
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
          SnackBar(content: Text(LanguageService.uiText('La foto deve avere una dimensione massima di 10 MB.'))),
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
          SnackBar(content: Text(LanguageService.uiText('L’immagine deve avere una dimensione massima di 10 MB.'))),
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
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.path == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LanguageService.uiText('Non riesco ad accedere al PDF selezionato.'))),
        );
      }
      return;
    }
    if (file.size < 1 || file.size > 10 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LanguageService.uiText('Il PDF deve avere una dimensione massima di 10 MB.'))),
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
          padding: EdgeInsets.fromLTRB(16, 4, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  LanguageService.uiText('Allega alla domanda'),
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                ),
                subtitle: Text(LanguageService.uiText('Foto, immagine dalla galleria oppure PDF.')),
              ),
              ListTile(
                leading: Icon(Icons.photo_camera_outlined),
                title: Text(LanguageService.uiText('Scatta una foto')),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _takeChatPhoto();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_outlined),
                title: Text(LanguageService.uiText('Scegli dalla galleria')),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickChatGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf_outlined),
                title: Text(LanguageService.uiText('Allega un PDF')),
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
        SnackBar(content: Text(LanguageService.uiText('L’allegato non è più disponibile. Selezionalo di nuovo.'))),
      );
      return;
    }

    final message = typedText.isEmpty
        ? LanguageService.uiText('Analizza e spiegami questo allegato sanitario.')
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
          ? LanguageService.uiText('Salute Risponde sta rispondendo…')
          : LanguageService.uiText('Salute Risponde sta analizzando l’allegato…');
    });
    _scrollToBottom();

    Future<void>.delayed(Duration(seconds: 15), () {
      if (mounted && _sending) {
        setState(() {
          _statusMessage = attachment == null
              ? LanguageService.uiText('Salute Risponde sta elaborando la risposta, ancora qualche secondo…')
              : LanguageService.uiText('Analisi dell’allegato in corso, ancora qualche secondo…');
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
        await Future<void>.delayed(Duration(milliseconds: 500));
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
            text: LanguageService.appError(e.runtimeType.toString()),
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
              'assets/branding/saluterisponde_icon_master.png',
              width: 34,
              height: 34,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 10),
            Text(LanguageService.uiText('Fai una domanda')),
          ],
        ),
      ),
      body: Column(
        children: [
          if (tester)
            Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(16, 8, 16, 4),
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Color(0xFFE3F7F2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                LanguageService.uiText('COLLAUDO • risposte illimitate'),
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          if (free)
            Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(16, 8, 16, 4),
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Color(0xFFEAF8F4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _remaining > 0
                    ? LanguageService.freeRemaining(_remaining)
                    : LanguageService.freeLimitReached(),
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          if (free && _remaining == 0)
            Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: SaluteRispondeApp.primary, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LanguageService.uiText('Hai terminato le 3 risposte gratuite'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: SaluteRispondeApp.text,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    LanguageService.uiText('Continua con Salute Risponde scegliendo PLUS o PRO.'),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => PlansPage()),
                            );
                          },
                          child: Text('PLUS'),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => PlansPage()),
                            );
                          },
                          child: Text('PRO'),
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
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                return Align(
                  alignment: m.user ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 330),
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: m.user
                          ? SaluteRispondeApp.primary
                          : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(22),
                        topRight: Radius.circular(22),
                        bottomLeft: Radius.circular(m.user ? 22 : 6),
                        bottomRight: Radius.circular(m.user ? 6 : 22),
                      ),
                      border: m.user
                          ? null
                          : Border.all(color: Color(0xFFE2EEE9)),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x0D174A43),
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
              padding: EdgeInsets.fromLTRB(18, 4, 18, 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _statusMessage ?? LanguageService.uiText('Salute Risponde sta rispondendo…'),
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_chatAttachment != null)
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.fromLTRB(12, 8, 6, 8),
                      decoration: BoxDecoration(
                        color: Color(0xFFEAF8F4),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Color(0xFFD5ECE6)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _chatAttachment!.name.toLowerCase().endsWith('.pdf')
                                ? Icons.picture_as_pdf_outlined
                                : Icons.image_outlined,
                            color: SaluteRispondeApp.primary,
                          ),
                          SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              _chatAttachment!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                          IconButton(
                            tooltip: LanguageService.uiText('Rimuovi allegato'),
                            onPressed: _sending
                                ? null
                                : () => setState(() => _chatAttachment = null),
                            icon: Icon(Icons.close_rounded),
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
                          color: Color(0xFFEAF8F4),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: IconButton(
                          tooltip: LanguageService.uiText('Allega foto o PDF'),
                          color: SaluteRispondeApp.primary,
                          onPressed: _sending || (free && _freeUsed >= _freeLimit)
                              ? null
                              : _chooseChatAttachment,
                          icon: Icon(Icons.attach_file_rounded),
                        ),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          enabled: !(free && _freeUsed >= _freeLimit),
                          minLines: 1,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: free && _freeUsed >= _freeLimit
                                ? LanguageService.uiText('Scegli PLUS o PRO per continuare')
                                : LanguageService.uiText('Scrivi una domanda o allega un esame...'),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
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
  _ChatMessage({required this.user, required this.text});
}

class DocumentsPage extends StatefulWidget {
  DocumentsPage({super.key});

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
          padding: EdgeInsets.fromLTRB(18, 4, 18, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  LanguageService.uiText('Aggiungi un documento'),
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                ),
                subtitle: Text(LanguageService.uiText('Fotografa il documento oppure scegli un file già salvato.')),
              ),
              ListTile(
                leading: Icon(Icons.photo_camera_outlined),
                title: Text(LanguageService.uiText('Scatta una foto')),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: Icon(Icons.folder_open_outlined),
                title: Text(LanguageService.uiText('Scegli dalla galleria o dai file')),
                subtitle: Text(LanguageService.uiText('PDF, JPG, PNG o WEBP')),
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
      _snack(LanguageService.uiText('Seleziona prima un documento.'));
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
      _snack(LanguageService.uiText('Documento salvato nel tuo archivio.'));
    } catch (_) {
      _snack(LanguageService.uiText('Non è stato possibile salvare il documento.'));
    }
  }

  Future<void> _openDocument(int index) async {
    if (_openingIndex != null) return;

    final item = _documents[index];
    final path = item['path']?.toString() ?? '';
    final name = item['name']?.toString() ?? LanguageService.uiText('Documento');

    if (path.isEmpty || !await File(path).exists()) {
      _snack(LanguageService.uiText('Il file non è più disponibile sul dispositivo.'));
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
          _snack(LanguageService.uiText('Non riesco ad aprire questo PDF con le app disponibili.'));
        }
      }
    } catch (_) {
      if (mounted) {
        _snack(LanguageService.uiText('Errore durante l’apertura del documento.'));
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
      _snack(LanguageService.uiText('Seleziona prima un documento.'));
      return;
    }

    final item = _documents[_selectedIndex!];
    final path = item['path']?.toString() ?? '';

    if (path.isEmpty || !await File(path).exists()) {
      _snack(LanguageService.uiText('Il file non è più disponibile sul dispositivo.'));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(LanguageService.uiText('Analizzare il documento?')),
        content: Text(
          LanguageService.uiText('Il documento verrà inviato in modo sicuro al servizio di analisi per leggerlo e spiegarlo. Evita di inviare documenti di altre persone senza il loro consenso.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(LanguageService.uiText('ANNULLA')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(LanguageService.uiText('ANALIZZA')),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _analyzing = true);
    try {
      final explanation = await _documentAi.analyzeDocument(path);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _DocumentAnalysisPage(
            documentName: item['name']?.toString() ?? LanguageService.uiText('Documento'),
            explanation: explanation,
          ),
        ),
      );
    } on DocumentAiException catch (e) {
      if (mounted) _snack(e.message);
    } catch (_) {
      if (mounted) _snack(LanguageService.uiText('Non è stato possibile analizzare il documento.'));
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LanguageService.uiText('Esami e referti'))),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          FilledButton.icon(
            onPressed: _chooseSource,
            icon: Icon(Icons.add_a_photo_outlined),
            label: Text(LanguageService.uiText('Fotografa o scegli un documento')),
          ),
          if (_pending != null) ...[
            SizedBox(height: 14),
            Card(
              child: ListTile(
                leading: Icon(Icons.description_outlined),
                title: Text(_pending!.name),
                subtitle: Text(LanguageService.uiText('Pronto per essere salvato')),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _savePending,
                icon: Icon(Icons.save_outlined),
                label: Text(LanguageService.uiText('Salva nel mio archivio')),
              ),
            ),
          ],
          SizedBox(height: 20),
          Text(
            LanguageService.uiText('I miei documenti'),
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 8),
          if (_documents.isEmpty)
            Text(LanguageService.uiText('Nessun documento salvato.'))
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
                  title: Text(item['name']?.toString() ?? LanguageService.uiText('Documento')),
                  subtitle: Text(
                    selected
                        ? LanguageService.uiText('Selezionato • usa Apri per visualizzarlo')
                        : LanguageService.uiText('Tocca per selezionare • usa Apri per visualizzarlo'),
                  ),
                  trailing: Wrap(
                    spacing: 0,
                    children: [
                      IconButton(
                        tooltip: LanguageService.uiText('Apri'),
                        onPressed: _openingIndex == null ? () => _openDocument(i) : null,
                        icon: _openingIndex == i
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(Icons.open_in_new),
                      ),
                      IconButton(
                        tooltip: LanguageService.uiText('Elimina'),
                        onPressed: () => _delete(i),
                        icon: Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              );
            }),
          SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _selectedIndex == null || _analyzing ? null : _analyzeSelected,
            icon: _analyzing
                ? SizedBox(
                    width: 19,
                    height: 19,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.auto_awesome),
            label: Text(_analyzing ? LanguageService.uiText('Analisi in corso…') : LanguageService.uiText('Analizza e spiegami')),
          ),
        ],
      ),
    );
  }
}

class _DocumentAnalysisPage extends StatelessWidget {
  final String documentName;
  final String explanation;

  _DocumentAnalysisPage({
    required this.documentName,
    required this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LanguageService.uiText('Spiegazione del documento'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(18),
        children: [
          Text(
            documentName,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 12),
          Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: SelectableText(
                explanation.replaceAll('**', ''),
                style: TextStyle(fontSize: 16, height: 1.48),
              ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            LanguageService.uiText('Questa spiegazione è informativa e non sostituisce il medico che ha richiesto o firmato il documento.'),
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

  _ImagePreviewPage({
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
            errorBuilder: (_, __, ___) => Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                LanguageService.uiText('Impossibile visualizzare questa immagine.'),
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
  AgendaPage({super.key});

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
      MaterialPageRoute(builder: (_) => AppointmentEditorPage()),
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
      SnackBar(content: Text(LanguageService.uiText('Appuntamento salvato.'))),
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
      appBar: AppBar(title: Text(LanguageService.uiText('Agenda Salute'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: Icon(Icons.add),
        label: Text(LanguageService.uiText('Nuova visita')),
      ),
      body: _appointments.isEmpty
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Text(
                  LanguageService.uiText('Nessun appuntamento.\nPremi “Nuova visita” per inserirne uno.'),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _appointments.length,
              itemBuilder: (_, i) {
                final item = _appointments[i];
                final dt = DateTime.tryParse(item['date']?.toString() ?? '');
                return Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.event_available,
                      color: SaluteRispondeApp.primary,
                    ),
                    title: Text(item['title']?.toString() ?? LanguageService.uiText('Visita')),
                    subtitle: Text(dt == null ? '' : _formatDateTime(dt)),
                    trailing: IconButton(
                      onPressed: () => _delete(i),
                      icon: Icon(Icons.delete_outline),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class AppointmentEditorPage extends StatefulWidget {
  AppointmentEditorPage({super.key});

  @override
  State<AppointmentEditorPage> createState() => _AppointmentEditorPageState();
}

class _AppointmentEditorPageState extends State<AppointmentEditorPage> {
  final _title = TextEditingController();
  DateTime _date = DateTime.now().add(Duration(days: 1));
  TimeOfDay _time = TimeOfDay(hour: 10, minute: 0);

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _save() {
    final title = _title.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LanguageService.uiText('Inserisci il tipo di visita o lo specialista.'))),
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
      appBar: AppBar(title: Text(LanguageService.uiText('Nuova visita'))),
      body: ListView(
        padding: EdgeInsets.all(18),
        children: [
          TextField(
            controller: _title,
            decoration: InputDecoration(
              labelText: LanguageService.uiText('Visita / specialista'),
              hintText: LanguageService.uiText('Es. Dentista'),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 14),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('${_date.day}/${_date.month}/${_date.year}'),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 3650)),
                initialDate: _date,
              );
              if (picked != null) setState(() => _date = picked);
            },
          ),
          ListTile(
            leading: Icon(Icons.schedule),
            title: Text(_time.format(context)),
            onTap: () async {
              final picked = await showTimePicker(context: context, initialTime: _time);
              if (picked != null) setState(() => _time = picked);
            },
          ),
          SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _save,
            icon: Icon(Icons.save),
            label: Text(LanguageService.uiText('Salva appuntamento')),
          ),
        ],
      ),
    );
  }
}

class _AppointmentDraft {
  final String title;
  final DateTime dateTime;
  _AppointmentDraft(this.title, this.dateTime);
}

class MedicinesPage extends StatefulWidget {
  MedicinesPage({super.key});

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
      MaterialPageRoute(builder: (_) => MedicineEditorPage()),
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
      appBar: AppBar(title: Text(LanguageService.uiText('Promemoria farmaci'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: Icon(Icons.add),
        label: Text(LanguageService.uiText('Aggiungi')),
      ),
      body: _medicines.isEmpty
          ? Center(child: Text(LanguageService.uiText('Nessun promemoria farmaco impostato.')))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _medicines.length,
              itemBuilder: (_, i) {
                final m = _medicines[i];
                final hour = (m['hour'] as num?)?.toInt() ?? 0;
                final minute = (m['minute'] as num?)?.toInt() ?? 0;
                return Card(
                  child: ListTile(
                    onTap: () => _edit(i),
                    leading: Icon(
                      Icons.medication,
                      color: SaluteRispondeApp.primary,
                    ),
                    title: Text(m['name']?.toString() ?? LanguageService.uiText('Farmaco')),
                    subtitle: Text(
                      LanguageService.everyDayAt(
                        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
                      ),
                    ),
                    trailing: Wrap(
                      spacing: 0,
                      children: [
                        IconButton(
                          tooltip: LanguageService.uiText('Modifica'),
                          onPressed: () => _edit(i),
                          icon: Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: LanguageService.uiText('Elimina'),
                          onPressed: () => _delete(i),
                          icon: Icon(Icons.delete_outline),
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
  MedicineEditorPage({super.key, this.initial});

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
        SnackBar(content: Text(LanguageService.uiText('Inserisci il nome del farmaco.'))),
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
        title: Text(editing ? LanguageService.uiText('Modifica promemoria') : LanguageService.uiText('Nuovo promemoria')),
      ),
      body: ListView(
        padding: EdgeInsets.all(18),
        children: [
          TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: LanguageService.uiText('Farmaco / integratore'),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 12),
          ListTile(
            leading: Icon(Icons.schedule),
            title: Text(_time.format(context)),
            onTap: () async {
              final picked = await showTimePicker(context: context, initialTime: _time);
              if (picked != null) setState(() => _time = picked);
            },
          ),
          SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _save,
            icon: Icon(Icons.notifications_active),
            label: Text(
              editing ? LanguageService.uiText('Salva modifiche') : LanguageService.uiText('Salva e attiva promemoria'),
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
  _MedicineDraft(this.name, this.hour, this.minute);
}

class UsefulNumbersPage extends StatefulWidget {
  UsefulNumbersPage({super.key});

  @override
  State<UsefulNumbersPage> createState() => _UsefulNumbersPageState();
}

class _UsefulNumbersPageState extends State<UsefulNumbersPage> {
  static const String _contactsKey = 'salute_risponde_personal_health_contacts';
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
        SnackBar(content: Text(LanguageService.uiText('Impossibile aprire il telefono.'))),
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
        title: Text(index == null ? LanguageService.uiText('Aggiungi contatto sanitario') : LanguageService.uiText('Modifica contatto')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: InputDecoration(labelText: LanguageService.uiText('Nome'))),
              TextField(
                controller: role,
                decoration: InputDecoration(
                  labelText: LanguageService.uiText('Ruolo / specialità'),
                  hintText: LanguageService.uiText('Es. Medico di base, Cardiologo'),
                ),
              ),
              TextField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: LanguageService.uiText('Telefono')),
              ),
              TextField(
                controller: note,
                decoration: InputDecoration(labelText: LanguageService.uiText('Nota (facoltativa)')),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(LanguageService.uiText('ANNULLA')),
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
            child: Text(LanguageService.uiText('SALVA')),
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
    final numbers = [
      (LanguageService.uiText('Numero unico emergenze'), '112'),
      (LanguageService.uiText('Emergenza sanitaria'), '118'),
      (LanguageService.uiText('Polizia di Stato'), '113'),
      (LanguageService.uiText('Vigili del Fuoco'), '115'),
      (LanguageService.uiText('Guardia di Finanza'), '117'),
      (LanguageService.uiText('Telefono Azzurro'), '19696'),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(LanguageService.uiText('Numeri utili'))),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text(
            LanguageService.uiText('Numeri nazionali'),
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 8),
          ...numbers.map(
            (item) => Card(
              child: ListTile(
                leading: Icon(Icons.phone_in_talk, color: SaluteRispondeApp.primary),
                title: Text(item.$1),
                subtitle: Text(item.$2),
                trailing: Icon(Icons.phone),
                onTap: () => _call(item.$2),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            LanguageService.uiText('I miei contatti sanitari'),
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 8),
          if (_contacts.isEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                LanguageService.uiText('Aggiungi il tuo medico, uno specialista, una farmacia o un altro contatto di fiducia.'),
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
                  leading: Icon(
                    Icons.medical_services_outlined,
                    color: SaluteRispondeApp.primary,
                  ),
                  title: Text(c['name'] ?? LanguageService.uiText('Contatto')),
                  subtitle: Text(subtitleParts.join(' • ')),
                  onTap: () => _call(c['phone'] ?? ''),
                  trailing: Wrap(
                    spacing: 0,
                    children: [
                      IconButton(
                        tooltip: LanguageService.uiText('Modifica'),
                        onPressed: () => _editContact(index: i),
                        icon: Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: LanguageService.uiText('Elimina'),
                        onPressed: () => _deleteContact(i),
                        icon: Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              );
            }),
          SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _editContact(),
              icon: Icon(Icons.person_add_alt_1),
              label: Text(LanguageService.uiText('Aggiungi contatto')),
            ),
          ),
          SizedBox(height: 18),
          Text(
            LanguageService.uiText('I numeri territoriali verranno inseriti dopo verifica ufficiale per area geografica.'),
            style: TextStyle(fontSize: 12.5, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class PlansPage extends StatefulWidget {
  PlansPage({super.key});

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
        title: Text(LanguageService.planDialogTitle(plan)),
        content: Text(
          LanguageService.uiText('Il piano sarà attivabile tramite Google Play nella versione di pubblicazione.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LanguageService.uiText('Piani Salute Risponde'))),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _PlanCard(
            title: 'FREE',
            price: LanguageService.uiText('Gratis'),
            features: [
              LanguageService.uiText('3 risposte gratuite'),
              LanguageService.uiText('1 esame o referto'),
              LanguageService.uiText('Avvisi di sicurezza sempre disponibili'),
            ],
            selected: selected == 'FREE',
            button: LanguageService.uiText('PIANO ATTUALE'),
            onTap: () => _choose('FREE'),
          ),
          _PlanCard(
            title: 'PLUS',
            price: LanguageService.uiText('Prezzo da definire / mese'),
            features: [
              LanguageService.uiText('Più consultazioni'),
              LanguageService.uiText('Più documenti'),
              LanguageService.uiText('Cronologia'),
              LanguageService.uiText('Agenda Salute'),
            ],
            selected: selected == 'PLUS',
            button: LanguageService.uiText('SCEGLI PLUS'),
            onTap: () => _choose('PLUS'),
          ),
          _PlanCard(
            title: 'PRO',
            price: LanguageService.uiText('Prezzo da definire / mese'),
            features: [
              LanguageService.uiText('Analisi avanzata documenti'),
              LanguageService.uiText('Riepilogo per il medico'),
              LanguageService.uiText('Preparazione visita'),
              LanguageService.uiText('Funzioni avanzate'),
            ],
            selected: selected == 'PRO',
            button: LanguageService.uiText('SCEGLI PRO'),
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

  _PlanCard({
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
      margin: EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                Spacer(),
                if (selected) Chip(label: Text(LanguageService.uiText('ATTIVO'))),
              ],
            ),
            Text(
              price,
              style: TextStyle(
                color: SaluteRispondeApp.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 12),
            ...features.map(
              (f) => Padding(
                padding: EdgeInsets.only(bottom: 7),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, size: 19),
                    SizedBox(width: 8),
                    Expanded(child: Text(f)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
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
  AccountPage({super.key});

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
                    SnackBar(
                      content: Text(LanguageService.uiText('Modalità TESTER disattivata. Piano FREE ripristinato.')),
                    ),
                  );
                }
              }
            },
            child: Text(LanguageService.uiText('Account Salute Risponde')),
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: LanguageService.uiText('ACCEDI')),
              Tab(text: LanguageService.uiText('ISCRIVITI')),
            ],
          ),
        ),
        body: TabBarView(
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
  _AccountForm({required this.register});

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
      padding: EdgeInsets.all(20),
      children: [
        SizedBox(height: 12),
        TextField(
          controller: email,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: LanguageService.uiText('Email'),
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 12),
        TextField(
          controller: password,
          obscureText: true,
          decoration: InputDecoration(
            labelText: LanguageService.uiText('Password'),
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16),
        FilledButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.register
                      ? LanguageService.uiText('Registrazione non ancora attiva.')
                      : LanguageService.uiText('Accesso non ancora attivo.'),
                ),
              ),
            );
          },
          child: Text(widget.register ? LanguageService.uiText('ISCRIVITI') : LanguageService.uiText('ACCEDI')),
        ),
      ],
    );
  }
}

class _SafetyCard extends StatelessWidget {
  _SafetyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEAF9F4), Color(0xFFDDF5EC)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.health_and_safety_outlined,
            color: SaluteRispondeApp.accent,
            size: 28,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              LanguageService.uiText('Sicuro. Affidabile. Umano.\nSalute Risponde offre informazioni e orientamento sanitario e non sostituisce il medico. In caso di emergenza contatta i servizi sanitari.'),
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
  final locale = LanguageService.locale.toLanguageTag();
  return DateFormat.yMd(locale).add_Hm().format(dt);
}
