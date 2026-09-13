import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStorageService {
  static const _appointmentsKey = 'salute_risponde_appointments';
  static const _medicinesKey = 'salute_risponde_medicines';
  static const _documentsKey = 'salute_risponde_documents';
  static const _leafletsKey = 'salute_risponde_leaflets';
  static const _selectedPlanKey = 'salute_risponde_selected_plan';

  Future<List<Map<String, dynamic>>> loadAppointments() async {
    return _loadList(_appointmentsKey);
  }

  Future<void> saveAppointments(List<Map<String, dynamic>> data) async {
    await _saveList(_appointmentsKey, data);
  }

  Future<List<Map<String, dynamic>>> loadMedicines() async {
    return _loadList(_medicinesKey);
  }

  Future<void> saveMedicines(List<Map<String, dynamic>> data) async {
    await _saveList(_medicinesKey, data);
  }

  Future<List<Map<String, dynamic>>> loadDocuments() async {
    return _loadList(_documentsKey);
  }

  Future<void> saveDocuments(List<Map<String, dynamic>> data) async {
    await _saveList(_documentsKey, data);
  }

  Future<List<Map<String, dynamic>>> loadLeaflets() async {
    return _loadList(_leafletsKey);
  }

  Future<void> saveLeaflets(List<Map<String, dynamic>> data) async {
    await _saveList(_leafletsKey, data);
  }

  Future<void> saveLeafletEntry({
    required String medicine,
    required String url,
  }) async {
    final items = await loadLeaflets();
    final normalized = medicine.trim().toLowerCase();

    items.removeWhere(
      (item) => (item['medicine']?.toString().trim().toLowerCase() ?? '') == normalized,
    );

    items.insert(0, {
      'medicine': medicine.trim(),
      'url': url,
      'date': DateTime.now().toIso8601String(),
    });

    await saveLeaflets(items);
  }

  Future<String> getSelectedPlan() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedPlanKey) ?? 'FREE';
  }

  Future<void> setSelectedPlan(String plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedPlanKey, plan);
  }

  Future<String> archiveFile(String sourcePath, String originalName) async {
    final directory = await getApplicationDocumentsDirectory();
    final docsDirectory = Directory('${directory.path}/medical_documents');
    if (!await docsDirectory.exists()) {
      await docsDirectory.create(recursive: true);
    }

    final safeName = originalName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$safeName';
    final destination = File('${docsDirectory.path}/$fileName');
    await File(sourcePath).copy(destination.path);
    return destination.path;
  }

  Future<void> deleteArchivedFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<List<Map<String, dynamic>>> _loadList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> _saveList(String key, List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }
}
