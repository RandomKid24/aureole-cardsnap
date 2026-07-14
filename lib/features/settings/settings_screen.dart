import 'dart:io';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/models/contact.dart';

import '../../core/utils/vcard_utils.dart';
import '../../core/utils/csv_utils.dart';
import '../../core/database/database.dart' hide Contact;
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/dot_grid_painter.dart';
import '../../core/config/ai_provider_config.dart';
import '../../core/secure_storage/key_storage.dart';
import '../../features/parse/ai_parser.dart';

import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _keyStorage = KeyStorage();
  AiProviderConfig _aiConfig = AiProviderConfig.defaults;
  bool _showApiKey = false;
  bool _testingConnection = false;
  String? _testResult;
  bool _testSuccess = false;

  // Editing controllers for text fields
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _modelController = TextEditingController();
  final _visionModelController = TextEditingController();
  final _apiKeyFocus = FocusNode();
  final _baseUrlFocus = FocusNode();
  final _modelFocus = FocusNode();
  final _visionModelFocus = FocusNode();

  String? _validationError;

  @override
  void initState() {
    super.initState();
    _loadAiConfig();
    _apiKeyFocus.addListener(_onApiKeyFocusLost);
    _baseUrlFocus.addListener(_onBaseUrlFocusLost);
    _modelFocus.addListener(_onModelFocusLost);
    _visionModelFocus.addListener(_onVisionModelFocusLost);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    _visionModelController.dispose();
    _apiKeyFocus.removeListener(_onApiKeyFocusLost);
    _baseUrlFocus.removeListener(_onBaseUrlFocusLost);
    _modelFocus.removeListener(_onModelFocusLost);
    _visionModelFocus.removeListener(_onVisionModelFocusLost);
    _apiKeyFocus.dispose();
    _baseUrlFocus.dispose();
    _modelFocus.dispose();
    _visionModelFocus.dispose();
    super.dispose();
  }

  Future<void> _loadAiConfig() async {
    final config = await _keyStorage.getAiConfig();
    if (mounted) {
      setState(() {
        _aiConfig = config;
        _apiKeyController.text = config.apiKey;
        _baseUrlController.text = config.baseUrl;
        _modelController.text = config.model;
        _visionModelController.text = config.visionModel;
      });
    }
  }

  void _onApiKeyFocusLost() => _saveIfValid();
  void _onBaseUrlFocusLost() => _saveIfValid();
  void _onModelFocusLost() => _saveIfValid();
  void _onVisionModelFocusLost() => _saveIfValid();

  bool _validate() {
    if (_aiConfig.enabled) {
      if (_apiKeyController.text.trim().isEmpty) {
        _validationError = 'API key is required when AI is enabled';
        return false;
      }
      if (_modelController.text.trim().isEmpty) {
        _validationError = 'Text model is required when AI is enabled';
        return false;
      }
      final baseUrl = _baseUrlController.text.trim();
      if (baseUrl.isEmpty) {
        _validationError = 'Base URL is required when AI is enabled';
        return false;
      }
      final uri = Uri.tryParse(baseUrl);
      if (uri == null || !uri.isAbsolute || uri.scheme != 'https') {
        _validationError = 'Base URL must be a valid HTTPS URL';
        return false;
      }
    }
    _validationError = null;
    return true;
  }

  Future<void> _saveIfValid() async {
    final config = _aiConfig.copyWith(
      apiKey: _apiKeyController.text.trim(),
      baseUrl: _baseUrlController.text.trim(),
      model: _modelController.text.trim(),
      visionModel: _visionModelController.text.trim(),
    );
    if (_validate()) {
      await _keyStorage.saveAiConfig(config);
      if (mounted) setState(() => _aiConfig = config);
    }
  }

  void _onProviderChanged(AiProviderType? newType) {
    if (newType == null) return;
    final merged = _aiConfig.mergeWithPreset(
      newType,
      currentBaseUrl: _baseUrlController.text.trim(),
      currentModel: _modelController.text.trim(),
      currentVisionModel: _visionModelController.text.trim(),
    );
    setState(() {
      _aiConfig = merged;
      _baseUrlController.text = merged.baseUrl;
      _modelController.text = merged.model;
      _visionModelController.text = merged.visionModel;
    });
    _saveIfValid();
  }

  void _onFormatChanged(ApiFormat? newFormat) {
    if (newFormat == null) return;
    setState(() => _aiConfig = _aiConfig.copyWith(format: newFormat));
    _saveIfValid();
  }

  Future<void> _testConnection() async {
    setState(() {
      _testingConnection = true;
      _testResult = null;
    });

    final config = _aiConfig.copyWith(
      apiKey: _apiKeyController.text.trim(),
      baseUrl: _baseUrlController.text.trim(),
      model: _modelController.text.trim(),
      visionModel: _visionModelController.text.trim(),
    );

    final parser = AiParser();
    final error = await parser.testConnection(config);

    if (mounted) {
      setState(() {
        _testingConnection = false;
        _testResult = error;
        _testSuccess = error == null;
      });
    }
  }

  // ─── vCard/CSV methods (unchanged) ───────────────────────────────

  Future<void> _exportVCard() async {
    final db = context.read<AppDatabase>();
    final contacts = await db.contactsDao.getAllContacts();
    if (contacts.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No contacts to export')));
      return;
    }
    final vcf = contactsToVCardBundle(contacts);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/cardsnap_contacts.vcf');
    await file.writeAsString(vcf);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], subject: 'CardSnap contacts'),
    );
  }

  Future<void> _importVCard() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['vcf']);
    if (result == null) return;
    final content = await File(result.files.single.path!).readAsString();
    final parsed = parseVCardFile(content);
    if (!mounted) return;
    final db = context.read<AppDatabase>();
    for (final data in parsed) {
      final contact = Contact(
        id: const Uuid().v4(),
        name: data['name'] as String,
        phones: List<String>.from(data['phones'] as List),
        emails: List<String>.from(data['emails'] as List),
        company: data['company'] as String?,
        designation: data['designation'] as String?,
        website: data['website'] as String?,
        address: data['address'] as String?,
        parseMode: 'import',
        confidence: {},
        createdAt: DateTime.now(),
        isFavorite: false,
        tags: const [],
        scanCount: 0,
        reminderDone: false,
      );
      await db.contactsDao.insertContact(contact);
    }
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Imported ${parsed.length} contacts')));
  }

  Future<void> _exportCSV() async {
    final db = context.read<AppDatabase>();
    final contacts = await db.contactsDao.getAllContacts();
    if (contacts.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No contacts to export')));
      return;
    }
    final csv = CsvUtils.exportCsv(contacts);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/cardsnap_contacts.csv');
    await file.writeAsString(csv);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], subject: 'CardSnap contacts (CSV)'),
    );
  }

  Future<void> _importCSV() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
    if (result == null) return;
    try {
      final content = await File(result.files.single.path!).readAsString();
      final parsed = await CsvUtils.importCsv(content);
      if (!mounted) return;
      final db = context.read<AppDatabase>();
      for (final data in parsed) {
        final contact = Contact(
          id: const Uuid().v4(),
          name: data.name ?? 'Unknown',
          phones: data.phones,
          emails: data.emails,
          company: data.company,
          designation: data.designation,
          website: data.website,
          address: data.address,
          parseMode: 'import',
          confidence: {},
          createdAt: DateTime.now(),
          isFavorite: false,
          tags: const [],
          scanCount: 0,
          reminderDone: false,
        );
        await db.contactsDao.insertContact(contact);
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Imported ${parsed.length} contacts from CSV')));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CSV Import failed: ${e.toString()}'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SETTINGS")),
      body: DotGridBackground(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _sectionHeader("APPEARANCE"),
            const Card(child: ListTile(title: Text("Theme"), trailing: Text("System"))),
            const SizedBox(height: 24),

            _sectionHeader("AI PARSING"),
            _buildAiSection(),
            const SizedBox(height: 24),

            _sectionHeader("DATA"),
            _buildDataSection(),
            const SizedBox(height: 24),

            _sectionHeader("ABOUT"),
            Card(
              child: Column(
                children: [
                  const ListTile(title: Text("Version"), trailing: Text("1.0.0")),
                  const Divider(height: 1),
                  const ListTile(title: Text("Built with Beforth brand guidelines")),
                  const Divider(height: 1),
                  ListTile(title: const Text("Licenses"), trailing: const Icon(Icons.chevron_right), onTap: () => showLicensePage(context: context)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const _ForgedByBeforth(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildAiSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: const Text('Enable AI Parsing'),
            subtitle: Text(
              _aiConfig.enabled ? 'AI will assist when confidence is low' : 'Using local parser only',
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.stone),
            ),
            value: _aiConfig.enabled,
            onChanged: (val) {
              setState(() => _aiConfig = _aiConfig.copyWith(enabled: val));
              _saveIfValid();
            },
          ),
          const Divider(height: 1),

          // Provider
          ListTile(
            title: const Text('Provider'),
            trailing: DropdownButton<AiProviderType>(
              value: _aiConfig.type,
              items: const [
                DropdownMenuItem(value: AiProviderType.openai, child: Text('OpenAI')),
                DropdownMenuItem(value: AiProviderType.xai, child: Text('xAI (Grok)')),
                DropdownMenuItem(value: AiProviderType.gemini, child: Text('Google Gemini')),
                DropdownMenuItem(value: AiProviderType.custom, child: Text('Custom')),
              ],
              onChanged: _onProviderChanged,
            ),
          ),

          // API Format (visible for Custom provider)
          if (_aiConfig.type == AiProviderType.custom)
            ListTile(
              title: const Text('API Format'),
              trailing: DropdownButton<ApiFormat>(
                value: _aiConfig.format,
                items: const [
                  DropdownMenuItem(value: ApiFormat.openai, child: Text('OpenAI Compatible')),
                  DropdownMenuItem(value: ApiFormat.gemini, child: Text('Gemini')),
                ],
                onChanged: _onFormatChanged,
              ),
            ),

          const Divider(height: 1),

          // API Key
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _apiKeyController,
              focusNode: _apiKeyFocus,
              obscureText: !_showApiKey,
              decoration: InputDecoration(
                labelText: 'API Key',
                hintText: 'sk-...',
                suffixIcon: IconButton(
                  icon: Icon(_showApiKey ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _showApiKey = !_showApiKey),
                ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onEditingComplete: _saveIfValid,
            ),
          ),

          // Base URL
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _baseUrlController,
              focusNode: _baseUrlFocus,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                hintText: 'https://api.openai.com/v1',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onEditingComplete: _saveIfValid,
            ),
          ),

          // Text Model
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _modelController,
              focusNode: _modelFocus,
              decoration: const InputDecoration(
                labelText: 'Text Model',
                hintText: 'gpt-4o-mini',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onEditingComplete: _saveIfValid,
            ),
          ),

          // Vision Model
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _visionModelController,
              focusNode: _visionModelFocus,
              decoration: const InputDecoration(
                labelText: 'Vision Model',
                hintText: 'Leave empty to reuse text model',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onEditingComplete: _saveIfValid,
            ),
          ),

          // Supports Vision
          SwitchListTile(
            title: const Text('Supports Vision'),
            subtitle: Text(
              'Send card image to AI for better accuracy',
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.stone),
            ),
            value: _aiConfig.supportsVision,
            onChanged: (val) {
              setState(() => _aiConfig = _aiConfig.copyWith(supportsVision: val));
              _saveIfValid();
            },
          ),
          const Divider(height: 1),

          // Test Connection
          ListTile(
            leading: _testingConnection
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(
                    _testResult == null ? Icons.wifi_tethering : (_testSuccess ? Icons.check_circle : Icons.error),
                    color: _testResult == null ? AppTheme.stone : (_testSuccess ? Colors.green : AppTheme.error),
                  ),
            title: Text(_testingConnection ? 'Testing...' : 'Test Connection'),
            onTap: _testingConnection ? null : _testConnection,
          ),
          if (_testResult != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Text(
                _testSuccess ? 'Connection successful!' : _testResult!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: _testSuccess ? Colors.green : AppTheme.error,
                ),
              ),
            ),

          // Validation error
          if (_validationError != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Text(
                _validationError!,
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.error),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDataSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: AppTheme.blueTint, shape: BoxShape.circle),
              child: const Icon(Icons.contact_page_outlined, color: AppTheme.primaryBlue, size: 20),
            ),
            title: const Text('Export all as vCard'),
            trailing: const Icon(Icons.ios_share, size: 20, color: AppTheme.stone),
            onTap: _exportVCard,
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppTheme.stone.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.contact_mail_outlined, color: AppTheme.navy, size: 20),
            ),
            title: const Text('Import from vCard (.vcf)'),
            trailing: const Icon(Icons.file_download_outlined, size: 20, color: AppTheme.stone),
            onTap: _importVCard,
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: AppTheme.blueTint, shape: BoxShape.circle),
              child: const Icon(Icons.table_chart_outlined, color: AppTheme.primaryBlue, size: 20),
            ),
            title: const Text('Export all as CSV'),
            trailing: const Icon(Icons.ios_share, size: 20, color: AppTheme.stone),
            onTap: _exportCSV,
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppTheme.stone.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.post_add_outlined, color: AppTheme.navy, size: 20),
            ),
            title: const Text('Import from CSV (.csv)'),
            trailing: const Icon(Icons.file_download_outlined, size: 20, color: AppTheme.stone),
            onTap: _importCSV,
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
      child: Text(title, style: GoogleFonts.bebasNeue(fontSize: 20, color: AppTheme.stone, letterSpacing: 1.2)),
    );
  }
}

class _ForgedByBeforth extends StatefulWidget {
  const _ForgedByBeforth();

  @override
  State<_ForgedByBeforth> createState() => _ForgedByBeforthState();
}

class _ForgedByBeforthState extends State<_ForgedByBeforth> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text("Forged by ", style: GoogleFonts.inter(fontSize: 14, color: AppTheme.stone, fontWeight: FontWeight.w500)),
            Text(
              "BEFORTH",
              style: GoogleFonts.bebasNeue(
                fontSize: 22,
                height: 1.05,
                letterSpacing: 1.0,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 1.0
                  ..color = _isHovered ? const Color(0xFFE8C14A) : AppTheme.stone.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
