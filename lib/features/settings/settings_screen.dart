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

import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
  }



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
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['vcf'],
    );
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

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported ${parsed.length} contacts')),
      );
    }
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
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imported ${parsed.length} contacts from CSV')),
        );
      }
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

            _sectionHeader("DATA"),
            Card(
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
            ),
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
