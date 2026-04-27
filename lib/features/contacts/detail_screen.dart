import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/models/contact.dart' as model;
import '../../core/database/database.dart' hide Contact;
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/beforth_button.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailScreen extends StatefulWidget {
  final String id;

  const DetailScreen({super.key, required this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  model.Contact? _contact;
  late final Stream<List<ContactNote>> _notesStream;

  @override
  void initState() {
    super.initState();
    _loadContact();
    _notesStream = context.read<AppDatabase>().contactsDao.watchNotesForContact(widget.id);
  }

  Future<void> _loadContact() async {
    final contact = await context.read<AppDatabase>().contactsDao.getContactById(widget.id);
    if (mounted) {
      setState(() { _contact = contact; });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _saveToPhoneContacts() async {
    final hasPermission = await FlutterContacts.requestPermission();
    if (!hasPermission) return;

    final c = _contact!;

    final existing = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: false,
    );

    final String normalizedNewPhone = c.phones.isNotEmpty ? c.phones.first.replaceAll(RegExp(r'[\s\-\(\)\+]'), '') : '';
    final String normalizedNewEmail = c.emails.isNotEmpty ? c.emails.first.toLowerCase() : '';

    final dupe = existing.where((systemContact) {
      final phoneMatch = systemContact.phones.any((p) => p.number.replaceAll(RegExp(r'[\s\-\(\)\+]'), '') == normalizedNewPhone);
      final emailMatch = systemContact.emails.any((e) => e.address.toLowerCase() == normalizedNewEmail);
      return phoneMatch || emailMatch;
    }).firstOrNull;

    if (dupe != null) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Duplicate Contact'),
            content: Text('A contact with this phone or email already exists in your phone: ${dupe.displayName}. Merge or save separate?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _executeSaveToPhone(c);
                }, 
                child: const Text('Save Separate')
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _executeMergeToPhone(dupe, c);
                }, 
                child: const Text('Merge')
              ),
            ],
          )
        );
      }
      return;
    }

    await _executeSaveToPhone(c);
  }

  Future<void> _executeSaveToPhone(model.Contact c) async {
    final contact = Contact(
      name: Name(
        first: c.name.split(' ').first,
        last: c.name.split(' ').skip(1).join(' '),
      ),
      phones: [
        Phone(c.phones.isNotEmpty ? c.phones.first : '', label: PhoneLabel.mobile)
      ],
      emails: [
        Email(c.emails.isNotEmpty ? c.emails.first : '', label: EmailLabel.home)
      ],
      organizations: [
        if (c.company != null || c.designation != null)
          Organization(company: c.company ?? '', title: c.designation ?? '')
      ],
    );

    await FlutterContacts.insertContact(contact);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to phone contacts')));
    }
  }

  Future<void> _executeMergeToPhone(Contact existing, model.Contact c) async {
    final fullContact = await FlutterContacts.getContact(existing.id);
    if (fullContact == null) return;

    if (c.phones.isNotEmpty && !fullContact.phones.any((p) => p.number == c.phones.first)) {
      fullContact.phones.add(Phone(c.phones.first, label: PhoneLabel.mobile));
    }
    if (c.emails.isNotEmpty && !fullContact.emails.any((e) => e.address == c.emails.first)) {
      fullContact.emails.add(Email(c.emails.first, label: EmailLabel.home));
    }
    
    await FlutterContacts.updateContact(fullContact);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact merged successfully')));
    }
  }

  void _showAddNoteDialog() {
    final txt = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24, 
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("ADD NOTE", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(controller: txt, maxLines: 3, decoration: const InputDecoration(border: OutlineInputBorder())),
            const SizedBox(height: 24),
            BeforthButton(
              label: "SAVE NOTE",
              onPressed: () async {
                if (txt.text.isNotEmpty) {
                  await context.read<AppDatabase>().contactsDao.addNote(widget.id, txt.text);
                  if (mounted && ctx.mounted) Navigator.pop(ctx);
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_contact == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final c = _contact!;

    return Scaffold(
      backgroundColor: AppTheme.slateBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppTheme.slateBg,
            expandedHeight: 250,
            pinned: true,
            title: Text(c.name, style: Theme.of(context).textTheme.displayMedium),
            actions: [
              IconButton(
                icon: Icon(c.isFavorite ? Icons.star : Icons.star_border, color: c.isFavorite ? AppTheme.warning : AppTheme.navy),
                onPressed: () async { 
                  await context.read<AppDatabase>().contactsDao.toggleFavorite(c.id, !c.isFavorite); 
                  await _loadContact(); 
                },
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {
                  SharePlus.instance.share(ShareParams(text: "Name: ${c.name}\nCompany: ${c.company}\nPhone: ${c.phones.join(', ')}\nEmail: ${c.emails.join(', ')}"));
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: c.imageFrontPath != null
                  ? Image.file(File(c.imageFrontPath!), fit: BoxFit.cover)
                  : Container(color: AppTheme.blueTint),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.designation ?? '', style: Theme.of(context).textTheme.titleLarge),
                  Text(c.company ?? '', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.primaryBlue)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _actionPill(Icons.call, "Call", () => _launchUrl("tel:${c.phones.first}")),
                      _actionPill(Icons.email, "Email", () => _launchUrl("mailto:${c.emails.first}")),
                      _actionPill(Icons.contacts, "Save", _saveToPhoneContacts),
                    ],
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 32),
                  _sectionHeader("CONTACT INFO"),
                  if (c.phones.isNotEmpty) _infoRow(Icons.phone, c.phones.first),
                  if (c.emails.isNotEmpty) _infoRow(Icons.email, c.emails.first),
                  if (c.website != null) _infoRow(Icons.language, c.website!),
                  if (c.linkedInUrl != null) _infoRow(Icons.link, c.linkedInUrl!),
                  if (c.twitterHandle != null && c.twitterHandle!.isNotEmpty) _infoRow(Icons.share, c.twitterHandle!),
                  if (c.address != null) _infoRow(Icons.location_on, c.address!),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionHeader("NOTES"),
                      TextButton.icon(onPressed: _showAddNoteDialog, icon: const Icon(Icons.add), label: const Text("ADD NOTE")),
                    ],
                  ),
                  StreamBuilder<List<ContactNote>>(
                    stream: _notesStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const CircularProgressIndicator();
                      final notes = snapshot.data!;
                      if (notes.isEmpty) return const Text("No notes added yet.", style: TextStyle(color: AppTheme.stone));
                      
                      return Column(
                        children: notes.map((note) => Dismissible(
                          key: Key(note.id.toString()),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) {
                            context.read<AppDatabase>().contactsDao.deleteNote(note.id);
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(color: AppTheme.error, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderDivider)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(note.body, style: Theme.of(context).textTheme.bodyLarge),
                                  const SizedBox(height: 8),
                                  Text(timeago.format(note.createdAt), style: const TextStyle(color: AppTheme.stone, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        )).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionPill(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(radius: 24, backgroundColor: AppTheme.primaryBlue, child: Icon(icon, color: AppTheme.white)),
          const SizedBox(height: 8),
          Text(label.toUpperCase(), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(title, style: GoogleFonts.bebasNeue(fontSize: 24, color: AppTheme.navy, letterSpacing: 1.2)),
    );
  }

  Widget _infoRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.stone, size: 20),
          const SizedBox(width: 16),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
