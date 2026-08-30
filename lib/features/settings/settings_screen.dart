import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models/contact.dart';
import '../../core/utils/vcard_utils.dart';
import '../../core/utils/csv_utils.dart';
import '../../core/database/database.dart' hide Contact;
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/dot_grid_painter.dart';
import '../../shared/widgets/beforth_button.dart';
import '../../core/auth/auth_service.dart';
import '../../core/marketing/marketing_sync_service.dart';
import '../../core/config/ai_provider_config.dart';
import '../../core/secure_storage/key_storage.dart';
import '../../features/parse/ai_parser.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _keyStorage = KeyStorage();
  AiProviderConfig _config = AiProviderConfig.defaults;
  bool _loaded = false;

  final _apiKeyController = TextEditingController();
  final _modelController = TextEditingController();
  final _customUrlController = TextEditingController();

  bool _showApiKey = false;
  bool _testing = false;
  String? _testResult;
  bool _testOk = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _modelController.dispose();
    _customUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    final config = await _keyStorage.getAiConfig();
    if (!mounted) return;
    setState(() {
      _config = config;
      _apiKeyController.text = config.apiKey;
      // Show the model that will actually be used (default, unless overridden).
      _modelController.text = config.effectiveModel;
      _customUrlController.text = config.customBaseUrl;
      _loaded = true;
    });
  }

  AiProviderConfig get _editedConfig {
    final typed = _modelController.text.trim();
    // Store an override only when it differs from the current provider default.
    final override = typed == AiProviderConfig.defaultModelFor(_config.type) ? '' : typed;
    return _config.copyWith(
      apiKey: _apiKeyController.text.trim(),
      model: override,
      customBaseUrl: _customUrlController.text.trim(),
    );
  }

  bool get _dirty {
    final e = _editedConfig;
    return e.apiKey != _config.apiKey ||
        e.model != _config.model ||
        e.customBaseUrl != _config.customBaseUrl;
  }

  Future<void> _save() async {
    final next = _editedConfig;
    setState(() {
      _config = next;
      _testResult = null;
    });
    await _keyStorage.saveAiConfig(next);
  }

  void _setProvider(AiProviderType? type) {
    if (type == null || type == _config.type) return;
    // A model id is provider-specific: reset to the new provider's default.
    final next = _config.copyWith(type: type, model: '');
    _modelController.text = next.effectiveModel;
    setState(() {
      _config = next;
      _testResult = null;
    });
    _keyStorage.saveAiConfig(next);
  }

  Future<void> _testConnection() async {
    if (_dirty) await _save();
    setState(() {
      _testing = true;
      _testResult = null;
    });
    final error = await AiParser().testConnection(_config);
    if (!mounted) return;
    setState(() {
      _testing = false;
      _testOk = error == null;
      _testResult = error ?? 'Connected — AI parsing is ready.';
    });
  }

  // ─── vCard / CSV import & export ────────────────────────────────────

  Future<void> _exportVCard() async {
    final db = context.read<AppDatabase>();
    final contacts = await db.contactsDao.getAllContacts();
    if (contacts.isEmpty) {
      if (mounted) _toast('No contacts to export');
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
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['vcf']);
    if (result == null) return;
    final content = await File(result.files.single.path!).readAsString();
    final parsed = parseVCardFile(content);
    if (!mounted) return;
    final db = context.read<AppDatabase>();
    for (final data in parsed) {
      await db.contactsDao.insertContact(Contact(
        id: const Uuid().v4(),
        name: data['name'] as String,
        phones: List<String>.from(data['phones'] as List),
        emails: List<String>.from(data['emails'] as List),
        company: data['company'] as String?,
        designation: data['designation'] as String?,
        website: data['website'] as String?,
        address: data['address'] as String?,
        notes: data['notes'] as String?,
        parseMode: 'import',
        confidence: const {},
        createdAt: DateTime.now(),
      ));
    }
    if (mounted) _toast('Imported ${parsed.length} contacts');
  }

  Future<void> _exportCSV() async {
    final db = context.read<AppDatabase>();
    final contacts = await db.contactsDao.getAllContacts();
    if (contacts.isEmpty) {
      if (mounted) _toast('No contacts to export');
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
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
    if (result == null) return;
    try {
      final content = await File(result.files.single.path!).readAsString();
      final parsed = await CsvUtils.importCsv(content);
      if (!mounted) return;
      final db = context.read<AppDatabase>();
      for (final data in parsed) {
        await db.contactsDao.insertContact(Contact(
          id: const Uuid().v4(),
          name: data.name ?? 'Unknown',
          phones: data.phones,
          emails: data.emails,
          company: data.company,
          designation: data.designation,
          website: data.website,
          address: data.address,
          notes: data.notes,
          parseMode: 'import',
          confidence: const {},
          createdAt: DateTime.now(),
        ));
      }
      if (mounted) _toast('Imported ${parsed.length} contacts from CSV');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CSV import failed: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
            'Your scanned contacts stay on this device. You\'ll need to sign in again to use the app.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<AuthService>().logout();
      // The router redirect takes over and shows the login screen.
    }
  }

  Widget _buildAccountSection() {
    final auth = context.watch<AuthService>();
    final session = auth.session;
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppTheme.blueTint,
              child: Icon(Icons.person, color: AppTheme.primaryBlue),
            ),
            title: Text(session?.displayName ?? 'Signed in'),
            subtitle: session?.subtitle != null
                ? Text(session!.subtitle!)
                : (auth.isOffline
                    ? Text('Offline — using saved session',
                        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.warning))
                    : null),
          ),
          if ((session?.roles ?? const []).isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final r in session!.roles)
                      Chip(
                        label: Text(_roleLabel(r), style: const TextStyle(fontSize: 11)),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                  ],
                ),
              ),
            ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.error),
            title: const Text('Sign out', style: TextStyle(color: AppTheme.error)),
            onTap: _confirmLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildMarketingSyncSection() {
    final sync = context.watch<MarketingSyncService>();
    if (!sync.isConfigured) return const SizedBox.shrink();

    final failures = sync.failures;
    final pending = sync.pendingCount;
    if (pending == 0 && failures.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader("MARKETING SYNC"),
        Card(
          child: Column(
            children: [
              if (pending > 0)
                ListTile(
                  leading: const SizedBox(
                      width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
                  title: Text('$pending contact${pending == 1 ? '' : 's'} queued'),
                  subtitle: Text('Sending to Marketing…',
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.stone)),
                ),
              for (final f in failures) ...[
                if (pending > 0 || f != failures.first) const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.error_outline, color: AppTheme.error),
                  title: Text(f.contactName),
                  subtitle: Text(f.error,
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.error)),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    tooltip: 'Discard',
                    onPressed: () => sync.discard(f.queueId),
                  ),
                ),
              ],
              if (failures.isNotEmpty) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.refresh, color: AppTheme.primaryBlue),
                  title: const Text('Retry failed'),
                  onTap: sync.retryFailed,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  String _roleLabel(dynamic role) {
    if (role is String) return role;
    if (role is Map) {
      final v = role['name'] ?? role['role'] ?? role['label'] ?? role['code'];
      if (v is String) return v;
    }
    return 'Role';
  }

  // ─── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SETTINGS")),
      body: DotGridBackground(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _sectionHeader("ACCOUNT"),
            _buildAccountSection(),
            const SizedBox(height: 24),
            _buildMarketingSyncSection(),
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
                  ListTile(
                    title: const Text("Licenses"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showLicensePage(context: context),
                  ),
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
    if (!_loaded) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final defaultModel = AiProviderConfig.defaultModelFor(_config.type);
    final isCustom = _config.type == AiProviderType.custom;
    final modelIsCustomised =
        defaultModel.isNotEmpty && _modelController.text.trim() != defaultModel;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 4, 12, 4),
            title: const Text('Use AI parsing'),
            subtitle: Text(
              _config.enabled
                  ? 'Low-confidence scans get a second pass from your provider.'
                  : 'Off — on-device parsing only.',
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.stone),
            ),
            value: _config.enabled,
            onChanged: (v) {
              setState(() => _config = _config.copyWith(enabled: v));
              _keyStorage.saveAiConfig(_config);
            },
          ),
          if (_config.enabled) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _fieldLabel('PROVIDER'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<AiProviderType>(
                    initialValue: _config.type,
                    isExpanded: true,
                    decoration: _fieldDecoration(),
                    borderRadius: BorderRadius.circular(12),
                    items: const [
                      DropdownMenuItem(value: AiProviderType.openai, child: Text('OpenAI')),
                      DropdownMenuItem(value: AiProviderType.gemini, child: Text('Google Gemini')),
                      DropdownMenuItem(value: AiProviderType.xai, child: Text('xAI (Grok)')),
                      DropdownMenuItem(value: AiProviderType.groq, child: Text('Groq')),
                      DropdownMenuItem(
                          value: AiProviderType.custom, child: Text('Custom (OpenAI-compatible)')),
                    ],
                    onChanged: _setProvider,
                  ),
                  const SizedBox(height: 16),

                  _fieldLabel('API KEY'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: !_showApiKey,
                    autocorrect: false,
                    enableSuggestions: false,
                    style: GoogleFonts.robotoMono(fontSize: 13),
                    onChanged: (_) => setState(() {}),
                    decoration: _fieldDecoration(
                      hint: switch (_config.type) {
                        AiProviderType.gemini => 'AIza…',
                        AiProviderType.groq => 'gsk_…',
                        AiProviderType.xai => 'xai-…',
                        _ => 'sk-…',
                      },
                      suffix: IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(_showApiKey ? Icons.visibility_off : Icons.visibility,
                            size: 20, color: AppTheme.stone),
                        onPressed: () => setState(() => _showApiKey = !_showApiKey),
                      ),
                    ),
                  ),

                  if (isCustom) ...[
                    const SizedBox(height: 16),
                    _fieldLabel('BASE URL'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _customUrlController,
                      autocorrect: false,
                      keyboardType: TextInputType.url,
                      style: GoogleFonts.robotoMono(fontSize: 13),
                      onChanged: (_) => setState(() {}),
                      decoration: _fieldDecoration(hint: 'https://…/v1'),
                    ),
                  ],

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _fieldLabel('MODEL'),
                      const Spacer(),
                      if (modelIsCustomised)
                        InkWell(
                          onTap: () => setState(() => _modelController.text = defaultModel),
                          child: const Padding(
                            padding: EdgeInsets.all(2),
                            child: Text('Reset to default',
                                style: TextStyle(fontSize: 11, color: AppTheme.primaryBlue)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _modelController,
                    autocorrect: false,
                    style: GoogleFonts.robotoMono(fontSize: 13),
                    onChanged: (_) => setState(() {}),
                    decoration: _fieldDecoration(
                      hint: defaultModel.isEmpty ? 'model id' : defaultModel,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Must be a vision-capable model.',
                      style: GoogleFonts.inter(fontSize: 11, color: AppTheme.stone)),

                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: BeforthButton(
                          label: _dirty ? 'Save' : 'Saved',
                          onPressed: _dirty ? _save : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: BeforthButton(
                          label: _testing ? 'Testing' : 'Test',
                          variant: BeforthButtonVariant.ghost,
                          isLoading: _testing,
                          onPressed: _testConnection,
                        ),
                      ),
                    ],
                  ),

                  if (_testResult != null)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (_testOk ? AppTheme.success : AppTheme.error)
                            .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(_testOk ? Icons.check_circle : Icons.error_outline,
                              size: 16,
                              color: _testOk ? AppTheme.success : AppTheme.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_testResult!,
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: _testOk ? AppTheme.success : AppTheme.error)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(
        text,
        style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppTheme.stone),
      );

  InputDecoration _fieldDecoration({String? hint, Widget? suffix}) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.robotoMono(fontSize: 13, color: AppTheme.stone.withValues(alpha: 0.6)),
        filled: true,
        fillColor: AppTheme.slateBg,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.borderDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
        ),
      );

  Widget _buildDataSection() {
    return Card(
      child: Column(
        children: [
          _dataTile(Icons.contact_page_outlined, 'Export all as vCard',
              Icons.ios_share, _exportVCard),
          const Divider(height: 1),
          _dataTile(Icons.contact_mail_outlined, 'Import from vCard (.vcf)',
              Icons.file_download_outlined, _importVCard),
          const Divider(height: 1),
          _dataTile(Icons.table_chart_outlined, 'Export all as CSV',
              Icons.ios_share, _exportCSV),
          const Divider(height: 1),
          _dataTile(Icons.post_add_outlined, 'Import from CSV (.csv)',
              Icons.file_download_outlined, _importCSV),
        ],
      ),
    );
  }

  Widget _dataTile(IconData leading, String title, IconData trailing, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(color: AppTheme.blueTint, shape: BoxShape.circle),
        child: Icon(leading, color: AppTheme.primaryBlue, size: 20),
      ),
      title: Text(title),
      trailing: Icon(trailing, size: 20, color: AppTheme.stone),
      onTap: onTap,
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
      child: Text(title,
          style: GoogleFonts.bebasNeue(fontSize: 20, color: AppTheme.stone, letterSpacing: 1.2)),
    );
  }
}

class _ForgedByBeforth extends StatelessWidget {
  const _ForgedByBeforth();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text("Forged by ",
            style: GoogleFonts.inter(
                fontSize: 14, color: AppTheme.stone, fontWeight: FontWeight.w500)),
        Text(
          "BEFORTH",
          style: GoogleFonts.bebasNeue(
            fontSize: 22,
            height: 1.05,
            letterSpacing: 1.0,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.0
              ..color = AppTheme.stone.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
