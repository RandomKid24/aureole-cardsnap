import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/models/parse_result.dart';
import '../../core/models/contact.dart';
import '../../core/database/database.dart' hide Contact;
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/field_tile.dart';
import '../../shared/widgets/beforth_button.dart';

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
  late Map<String, double> _confidence;

  Contact? _duplicateContact;

  @override
  void initState() {
    super.initState();
    _loadDraft();
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
      _phones = List.from(_parseResult!.phones);
      _emails = List.from(_parseResult!.emails);
      _website = _parseResult!.website;
      _address = _parseResult!.address;
      _linkedIn = _parseResult!.linkedInUrl;
      _twitter = _parseResult!.twitterHandle;
      _confidence = Map.from(_parseResult!.confidence);
    });

    _checkForDuplicates();
  }

  static int _levenshtein(String a, String b) {
    final m = a.length, n = b.length;
    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));
    for (int i = 0; i <= m; i++) { dp[i][0] = i; }
    for (int j = 0; j <= n; j++) { dp[0][j] = j; }
    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        dp[i][j] = a[i-1] == b[j-1]
            ? dp[i-1][j-1]
            : 1 + [dp[i-1][j], dp[i][j-1], dp[i-1][j-1]].reduce(min);
      }
    }
    return dp[m][n];
  }

  static String _normalizePhone(String phone) =>
      phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '')
           .replaceAll(RegExp(r'^91'), '')
           .replaceAll(RegExp(r'^0'), '');

  static final _titlePattern = RegExp(
    r'^(Dr\.?|Mr\.?|Mrs\.?|Ms\.?|Prof\.?|Eng\.?)\s+',
    caseSensitive: false,
  );
  static final _suffixPattern = RegExp(
    r'\s+(Jr\.?|Sr\.?|II|III|IV|PhD|MD|MBA)$',
    caseSensitive: false,
  );

  static String _normalizeName(String name) => name
      .replaceAll(_titlePattern, '')
      .replaceAll(_suffixPattern, '')
      .trim()
      .toLowerCase();

  Future<void> _checkForDuplicates() async {
    if (_parseResult == null) return;
    
    final all = await context.read<AppDatabase>().contactsDao.getAllContacts();
    
    final duplicate = await compute(_findDuplicateIsolate, {
      'name': _name,
      'phones': _phones,
      'emails': _emails,
      'contacts': all,
    });

    if (duplicate != null && mounted) {
      setState(() { _duplicateContact = duplicate; });
    }
  }

  static Contact? _findDuplicateIsolate(Map<String, dynamic> args) {
    final String name = args['name'];
    final List<String> phones = args['phones'];
    final List<String> emails = args['emails'];
    final List<Contact> contacts = args['contacts'];

    for (final c in contacts) {
      final existingPhones = c.phones.map(_normalizePhone).toSet();
      final newPhones = phones.map(_normalizePhone).toSet();
      if (existingPhones.intersection(newPhones).isNotEmpty) return c;

      final existingEmails = c.emails.map((e) => e.toLowerCase()).toSet();
      final newEmails = emails.map((e) => e.toLowerCase()).toSet();
      if (existingEmails.intersection(newEmails).isNotEmpty) return c;

      if (name.isNotEmpty) {
        final dist = _levenshtein(_normalizeName(name), _normalizeName(c.name));
        if (dist <= 2) return c;
      }
    }
    return null;
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

  Future<void> _executeSave() async {
    final dao = context.read<AppDatabase>().contactsDao;

    final contact = Contact(
      id: const Uuid().v4(),
      name: _name,
      company: _company,
      designation: _designation,
      phones: _phones,
      emails: _emails,
      website: _website,
      address: _address,
      linkedInUrl: _linkedIn,
      twitterHandle: _twitter,
      imageFrontPath: _imageFrontPath,
      imageBackPath: _imageBackPath,
      confidence: _confidence,
      parseMode: _parseResult!.parseMode,
      createdAt: DateTime.now(),
    );

    try {
      await dao.insertContact(contact);
      if (mounted) context.go('/contact/${contact.id}');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to save contact")));
    }
  }

  Future<void> _mergeContact(Contact existing) async {
    final merged = existing.copyWith(
      phones: {...existing.phones, ..._phones}.toList(),
      emails: {...existing.emails, ..._emails}.toList(),
      company: _company ?? existing.company,
      designation: _designation ?? existing.designation,
      website: _website ?? existing.website,
      address: _address ?? existing.address,
      updatedAt: DateTime.now(),
      scanCount: existing.scanCount + 1,
    );
    await context.read<AppDatabase>().contactsDao.updateContact(merged);
    if (mounted) context.go('/contact/${existing.id}');
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

  @override
  Widget build(BuildContext context) {
    if (_parseResult == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
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
            FieldTile(label: "Phone", initialValue: _phones.isNotEmpty ? _phones.first : '', confidence: _confidence['phones'] ?? 0.0, onChanged: (v) => _phones = [v], keyboardType: TextInputType.phone).animate().fadeIn().slideX(begin: -0.04),
            FieldTile(label: "Email", initialValue: _emails.isNotEmpty ? _emails.first : '', confidence: _confidence['emails'] ?? 0.0, onChanged: (v) => _emails = [v], keyboardType: TextInputType.emailAddress).animate().fadeIn().slideX(begin: -0.04),
            FieldTile(label: "Website", initialValue: _website ?? '', confidence: _confidence['website'] ?? 0.0, onChanged: (v) => _website = v, keyboardType: TextInputType.url).animate().fadeIn().slideX(begin: -0.04),
            FieldTile(label: "LinkedIn", initialValue: _linkedIn ?? '', confidence: _confidence['linkedInUrl'] ?? 0.0, onChanged: (v) => _linkedIn = v).animate().fadeIn().slideX(begin: -0.04),
            FieldTile(label: "Social Media", initialValue: _twitter ?? '', confidence: _confidence['twitterHandle'] ?? 0.0, onChanged: (v) => _twitter = v).animate().fadeIn().slideX(begin: -0.04),
            FieldTile(label: "Address", initialValue: _address ?? '', confidence: _confidence['address'] ?? 0.0, onChanged: (v) => _address = v, maxLines: 3).animate().fadeIn().slideX(begin: -0.04),
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
          ).animate().scaleXY(end: 1.05).then().scaleXY(end: 1.0),
        ),
      ),
    );
  }
}
