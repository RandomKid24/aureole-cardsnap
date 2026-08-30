import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/models/parse_result.dart';
import '../../core/models/contact.dart';
import '../../core/database/database.dart' hide Contact;
import '../../core/marketing/marketing_sync_service.dart';
import '../../core/marketing/marketing_models.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/field_tile.dart';
import '../../shared/widgets/beforth_button.dart';
import '../duplicate/duplicate_detector.dart';
import '../parse/corrections_store.dart';

class ReviewScreen extends StatefulWidget {
  final String draftId;

  const ReviewScreen({super.key, required this.draftId});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  ParseResult? _parseResult;
  String? _imageFrontPath;
  String? _imageBackPath;

  late String _name;
  late String? _company;
  late String? _designation;
  late List<String> _phones;
  late List<String> _emails;
  late String? _website;
  late String? _address;
  late String? _linkedIn;
  late String? _twitter;
  String _notes = '';
  late Map<String, double> _confidence;

  Contact? _duplicateContact;

  // Marketing capture context (scope + exhibition picker).
  MarketingScope? _mScope;
  List<Exhibition> _exhibitions = const [];
  String? _exhibitionsError;
  Exhibition? _selectedExhibition;
  bool _contextLoading = true;
  bool _marketingConfigured = true;

  @override
  void initState() {
    super.initState();
    _loadDraft();
    _loadCaptureContext();
  }

  Future<void> _loadCaptureContext() async {
    final svc = context.read<MarketingSyncService>();
    if (!svc.isConfigured) {
      setState(() {
        _marketingConfigured = false;
        _contextLoading = false;
      });
      return;
    }
    // Default to whatever exhibition the user set on the main screen.
    _selectedExhibition ??= svc.activeExhibition;
    final ctx = await svc.loadCaptureContext();
    if (!mounted) return;
    setState(() {
      _mScope = ctx.scope;
      _exhibitions = ctx.activeExhibitions;
      _exhibitionsError = ctx.exhibitionsError;
      // If the active exhibition is in the fetched list, use that instance so
      // the dropdown shows it selected.
      if (_selectedExhibition != null) {
        _selectedExhibition = _exhibitions.firstWhere(
          (e) => e.id == _selectedExhibition!.id,
          orElse: () => _selectedExhibition!,
        );
      }
      _contextLoading = false;
    });
  }

  Future<void> _loadDraft() async {
    final draft = await context.read<AppDatabase>().contactsDao.getDraft(widget.draftId);
    if (draft == null) {
      if (mounted) context.go('/');
      return;
    }

    setState(() {
      _parseResult = ParseResult.fromJson(jsonDecode(draft.parseResultJson));
      _imageFrontPath = draft.imageFrontPath;
      _imageBackPath = draft.imageBackPath;

      _name = _parseResult!.name ?? '';
      _company = _parseResult!.company;
      _designation = _parseResult!.designation;
      _phones = _parseResult!.phones.isEmpty ? [''] : List.from(_parseResult!.phones);
      _emails = _parseResult!.emails.isEmpty ? [''] : List.from(_parseResult!.emails);
      _website = _parseResult!.website;
      _address = _parseResult!.address;
      _linkedIn = _parseResult!.linkedInUrl;
      _twitter = _parseResult!.twitterHandle;
      _notes = _parseResult!.notes ?? '';
      _confidence = Map.from(_parseResult!.confidence);

    });

    _checkForDuplicates();
  }

  Future<void> _checkForDuplicates() async {
    if (_parseResult == null) return;

    final all = await context.read<AppDatabase>().contactsDao.getAllContacts();

    final duplicate = await compute(DuplicateDetector.findDuplicate, {
      'name': _name,
      'phones': _phones,
      'emails': _emails,
      'company': _company,
      'website': _website,
      'contacts': all,
    });

    if (duplicate != null && mounted) {
      setState(() { _duplicateContact = duplicate; });
    }
  }

  Future<void> _saveContact() async {
    if (_name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Name is required")));
      return;
    }

    if (_duplicateContact != null) {
      _showDuplicateSheet(_duplicateContact!);
    } else {
      await _executeSave();
    }
  }

  List<String> get _cleanPhones =>
      _phones.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  List<String> get _cleanEmails =>
      _emails.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  /// When merging into an existing contact, append the new note rather than
  /// clobbering whatever was already there.
  String? _mergedNotes(String? existing) {
    final add = _notes.trim();
    if (add.isEmpty) return existing;
    if (existing == null || existing.trim().isEmpty) return add;
    return '${existing.trim()}\n$add';
  }

  Future<void> _executeSave() async {
    final dao = context.read<AppDatabase>().contactsDao;

    final contact = Contact(
      id: const Uuid().v4(),
      name: _name,
      company: _company,
      designation: _designation,
      phones: _cleanPhones,
      emails: _cleanEmails,
      website: _website,
      address: _address,
      linkedInUrl: _linkedIn,
      twitterHandle: _twitter,
      imageFrontPath: _imageFrontPath,
      imageBackPath: _imageBackPath,
      confidence: _confidence,
      parseMode: _parseResult!.parseMode,
      notes: _notes.trim().isEmpty ? null : _notes.trim(),
      exhibitionId: _selectedExhibition?.id,
      exhibitionName: _selectedExhibition?.name,
      createdAt: DateTime.now(),
    );

    try {
      await dao.insertContact(contact);
    } catch (e, s) {
      debugPrint('ReviewScreen: insertContact failed: $e\n$s');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save contact: $e')),
        );
      }
      return;
    }

    // Contact is saved — the rest is best-effort and must not surface as a save
    // failure.
    try {
      await _recordCorrections(contact.id);
    } catch (e, s) {
      debugPrint('ReviewScreen: recordCorrections failed (contact still saved): $e\n$s');
    }
    if (mounted) {
      unawaited(context.read<MarketingSyncService>().enqueue(contact));
    }

    if (mounted) {
      // Reset to the list, then open the new contact so the back button works.
      context.go('/');
      context.push('/contact/${contact.id}');
    }
  }

  Future<void> _recordCorrections(String contactId) async {
    if (_parseResult == null) return;
    final store = CorrectionsStore(context.read<AppDatabase>());
    final ocrText = _parseResult!.ocrText ?? '';

    final fields = <String, Map<String, String?>>{
      'name': {'original': _parseResult!.name, 'edited': _name},
      'company': {'original': _parseResult!.company, 'edited': _company},
      'designation': {'original': _parseResult!.designation, 'edited': _designation},
      'website': {'original': _parseResult!.website, 'edited': _website},
      'address': {'original': _parseResult!.address, 'edited': _address},
      'linkedInUrl': {'original': _parseResult!.linkedInUrl, 'edited': _linkedIn},
      'twitterHandle': {'original': _parseResult!.twitterHandle, 'edited': _twitter},
    };

    for (final entry in fields.entries) {
      final original = entry.value['original'];
      final edited = entry.value['edited'];
      if (edited != null && edited.isNotEmpty && edited != original) {
        await store.recordCorrection(
          contactId: contactId,
          fieldName: entry.key,
          originalOcr: ocrText,
          originalParsed: original ?? '',
          correctedValue: edited,
          fieldType: entry.key,
        );
      }
    }

    // Phones and emails are lists — compare joined strings
    final origPhones = _parseResult!.phones.join(', ');
    final editPhones = _cleanPhones.join(', ');
    if (editPhones.isNotEmpty && editPhones != origPhones) {
      await store.recordCorrection(
        contactId: contactId,
        fieldName: 'phones',
        originalOcr: ocrText,
        originalParsed: origPhones,
        correctedValue: editPhones,
        fieldType: 'phones',
      );
    }

    final origEmails = _parseResult!.emails.join(', ');
    final editEmails = _cleanEmails.join(', ');
    if (editEmails.isNotEmpty && editEmails != origEmails) {
      await store.recordCorrection(
        contactId: contactId,
        fieldName: 'emails',
        originalOcr: ocrText,
        originalParsed: origEmails,
        correctedValue: editEmails,
        fieldType: 'emails',
      );
    }
  }

  Future<void> _mergeContact(Contact existing) async {
    final merged = existing.copyWith(
      phones: {...existing.phones, ..._cleanPhones}.toList(),
      emails: {...existing.emails, ..._cleanEmails}.toList(),
      company: _company ?? existing.company,
      designation: _designation ?? existing.designation,
      website: _website ?? existing.website,
      address: _address ?? existing.address,
      notes: _mergedNotes(existing.notes),
      exhibitionId: _selectedExhibition?.id ?? existing.exhibitionId,
      exhibitionName: _selectedExhibition?.name ?? existing.exhibitionName,
      updatedAt: DateTime.now(),
      scanCount: existing.scanCount + 1,
    );
    await context.read<AppDatabase>().contactsDao.updateContact(merged);
    if (mounted) {
      // Only pushes if this contact hasn't already gone to Marketing.
      unawaited(context.read<MarketingSyncService>().enqueue(merged));
      context.go('/');
      context.push('/contact/${existing.id}');
    }
  }

  void _showDuplicateSheet(Contact duplicate) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Possible duplicate', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('This looks similar to ${duplicate.name}. What would you like to do?', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: BeforthButton(
                  label: "Save separately",
                  variant: BeforthButtonVariant.ghost,
                  onPressed: () { Navigator.pop(context); _executeSave(); },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BeforthButton(
                  label: "Merge",
                  onPressed: () { Navigator.pop(context); _mergeContact(duplicate); },
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  String _getParserLabel() {
    final mode = _parseResult?.parseMode ?? 'local';
    switch (mode) {
      case 'ai':
        return 'AI-assisted';
      case 'import':
        return 'Imported';
      default:
        return 'Local';
    }
  }

  double _getAverageConfidence() {
    if (_confidence.isEmpty) return 0.0;
    return _confidence.values.reduce((a, b) => a + b) / _confidence.length;
  }

  bool _hasUnsavedChanges() {
    if (_parseResult == null) return false;
    final p = _parseResult!;
    return _name != (p.name ?? '') ||
        _company != p.company ||
        _designation != p.designation ||
        _cleanPhones.join(',') != p.phones.join(',') ||
        _cleanEmails.join(',') != p.emails.join(',') ||
        _website != p.website ||
        _address != p.address ||
        _linkedIn != p.linkedInUrl ||
        _twitter != p.twitterHandle;
  }

  Future<bool> _showDiscardDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Discard changes?"),
        content: const Text("You have unsaved changes. Are you sure you want to go back?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text("Discard"),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _handleBack() async {
    if (_hasUnsavedChanges()) {
      final discard = await _showDiscardDialog();
      if (!mounted) return;
      if (discard) context.go('/');
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_parseResult == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _handleBack,
          ),
          title: const Text("REVIEW DETAILS"),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_duplicateContact != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppTheme.blueTint,
                    border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppTheme.primaryBlue),
                      const SizedBox(width: 12),
                      Expanded(child: Text("Duplicate detected: ${_duplicateContact!.name}", style: const TextStyle(color: AppTheme.navy))),
                    ],
                  ),
                ).animate().fadeIn(),
              FieldTile(label: "Name", initialValue: _name, confidence: _confidence['name'] ?? 0.0, onChanged: (v) => _name = v).animate().fadeIn().slideX(begin: -0.04),
              FieldTile(label: "Company", initialValue: _company ?? '', confidence: _confidence['company'] ?? 0.0, onChanged: (v) => _company = v).animate().fadeIn().slideX(begin: -0.04),
              FieldTile(label: "Designation", initialValue: _designation ?? '', confidence: _confidence['designation'] ?? 0.0, onChanged: (v) => _designation = v).animate().fadeIn().slideX(begin: -0.04),
              ..._buildMultiField("Phone", _phones, _confidence['phones'] ?? 0.0, TextInputType.phone),
              ..._buildMultiField("Email", _emails, _confidence['emails'] ?? 0.0, TextInputType.emailAddress),
              FieldTile(label: "Website", initialValue: _website ?? '', confidence: _confidence['website'] ?? 0.0, onChanged: (v) => _website = v, keyboardType: TextInputType.url).animate().fadeIn().slideX(begin: -0.04),
              FieldTile(label: "LinkedIn", initialValue: _linkedIn ?? '', confidence: _confidence['linkedInUrl'] ?? 0.0, onChanged: (v) => _linkedIn = v).animate().fadeIn().slideX(begin: -0.04),
              FieldTile(label: "Social Media", initialValue: _twitter ?? '', confidence: _confidence['twitterHandle'] ?? 0.0, onChanged: (v) => _twitter = v).animate().fadeIn().slideX(begin: -0.04),
              FieldTile(label: "Address", initialValue: _address ?? '', confidence: _confidence['address'] ?? 0.0, onChanged: (v) => _address = v, maxLines: 3).animate().fadeIn().slideX(begin: -0.04),
              FieldTile(label: "Notes", initialValue: _notes, confidence: 0.0, onChanged: (v) => _notes = v, maxLines: 3).animate().fadeIn().slideX(begin: -0.04),
              const SizedBox(height: 16),
              _buildExhibitionSection(),
              const SizedBox(height: 24),
              // Scan info section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.slateBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _infoChip('Parser', _getParserLabel()),
                    _infoChip('Confidence', '${(_getAverageConfidence() * 100).round()}%'),
                    if (_parseResult!.metadata?.processingDurationMs != null)
                      _infoChip('Time', '${_parseResult!.metadata!.processingDurationMs}ms'),
                  ],
                ),
              ),
              if ((_parseResult!.metadata?.aiError ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.warning.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.auto_awesome, size: 16, color: AppTheme.warning),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'AI parsing was skipped: ${_parseResult!.metadata!.aiError}. '
                          'Showing on-device result.',
                          style: const TextStyle(fontSize: 12, color: AppTheme.navy),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              // Raw OCR text (expandable)
              if (_parseResult!.ocrText != null && _parseResult!.ocrText!.isNotEmpty)
                ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                  childrenPadding: const EdgeInsets.all(12),
                  title: const Text("OCR Text", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.stone, letterSpacing: 1.0)),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.slateBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        _parseResult!.ocrText!,
                        style: const TextStyle(fontSize: 12, height: 1.5, fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 100),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: BeforthButton(
              label: "Save Contact",
              onPressed: _saveContact,
            ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.3, curve: Curves.easeOut),
          ),
        ),
      ),
    );
  }

  Widget _buildExhibitionSection() {
    // Marketing base URL not set → this whole feature is off.
    if (!_marketingConfigured) return const SizedBox.shrink();

    const labelStyle = TextStyle(
        fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.stone, letterSpacing: 1.0);

    if (_contextLoading) {
      return Row(
        children: [
          const Text("EXHIBITION", style: labelStyle),
          const SizedBox(width: 10),
          const SizedBox(
              width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_mScope != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Wrap(
              spacing: 6,
              children: [
                if (_mScope!.domainId != null)
                  _contextChip('Domain ${_mScope!.domainId}'),
                if (_mScope!.regionId != null)
                  _contextChip('Region ${_mScope!.regionId}'),
                if ((_mScope!.role ?? '').isNotEmpty)
                  _contextChip(_mScope!.role!.replaceAll('_', ' ')),
              ],
            ),
          ),
        Row(
          children: [
            const Text("EXHIBITION", style: labelStyle),
            const Spacer(),
            if (!_contextLoading)
              InkWell(
                onTap: () {
                  setState(() => _contextLoading = true);
                  _loadCaptureContext();
                },
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.refresh, size: 16, color: AppTheme.stone),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        if (_exhibitionsError != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.warning.withValues(alpha: 0.4)),
            ),
            child: Text(_exhibitionsError!,
                style: const TextStyle(fontSize: 12, color: AppTheme.navy)),
          )
        else if (_mScope == null && _exhibitions.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.slateBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Couldn't reach the Marketing API — exhibition list unavailable. "
              "The contact still saves and syncs later.",
              style: TextStyle(fontSize: 12, color: AppTheme.stone),
            ),
          )
        else
          Builder(builder: (context) {
            // Include the pre-selected exhibition even if the freshly fetched
            // list doesn't contain it (stale cache / different domain).
            final options = [
              ..._exhibitions,
              if (_selectedExhibition != null &&
                  !_exhibitions.any((e) => e.id == _selectedExhibition!.id))
                _selectedExhibition!,
            ];
            return DropdownButtonFormField<Exhibition?>(
              initialValue: _selectedExhibition,
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.white,
                hintText: options.isEmpty ? 'No active exhibitions' : 'Not at an exhibition',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.borderDivider),
                ),
              ),
              items: [
                const DropdownMenuItem<Exhibition?>(value: null, child: Text('None')),
                for (final e in options)
                  DropdownMenuItem<Exhibition?>(
                    value: e,
                    child: Text(e.label, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: options.isEmpty
                  ? null
                  : (e) => setState(() => _selectedExhibition = e),
            );
          }),
      ],
    ).animate().fadeIn();
  }

  Widget _contextChip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.blueTint,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(text,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue)),
      );

  /// Renders one editable tile per list entry plus an "add" affordance, so a
  /// card with two phone numbers keeps both instead of collapsing to the first.
  List<Widget> _buildMultiField(
    String label,
    List<String> values,
    double confidence,
    TextInputType keyboardType,
  ) {
    return [
      for (int i = 0; i < values.length; i++)
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: FieldTile(
                key: ValueKey('$label-$i-${values.length}'),
                label: i == 0 ? label : '$label ${i + 1}',
                initialValue: values[i],
                confidence: i == 0 ? confidence : 0.0,
                keyboardType: keyboardType,
                onChanged: (v) => values[i] = v,
              ),
            ),
            if (values.length > 1)
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: AppTheme.stone),
                onPressed: () => setState(() => values.removeAt(i)),
              ),
          ],
        ).animate().fadeIn().slideX(begin: -0.04),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => setState(() => values.add('')),
          icon: const Icon(Icons.add, size: 18),
          label: Text('Add ${label.toLowerCase()}'),
        ),
      ),
    ];
  }

  Widget _infoChip(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.stone, letterSpacing: 1.0)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.navy)),
      ],
    );
  }
}
