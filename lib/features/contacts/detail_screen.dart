import 'dart:io';
import '../../shared/widgets/card_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/models/contact.dart' as model;
import '../../core/database/database.dart' hide Contact;
import '../../core/notifications/notification_service.dart';
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
    final ok = await canLaunchUrl(uri) &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't open that link")),
      );
    }
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
      notes: [
        if ((c.notes ?? '').isNotEmpty) Note(c.notes!),
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

  Future<void> _editNotes(model.Contact c) async {
    final text = await _promptText(
      title: 'NOTES',
      hint: 'Anything worth remembering about this contact…',
      buttonLabel: 'Save',
      initialValue: c.notes ?? '',
      maxLines: 6,
    );
    if (text == null || !mounted) return; // sheet dismissed
    await context.read<AppDatabase>().contactsDao.updateNotes(c.id, text);
    await _loadContact();
  }

  Widget _notesCard(model.Contact c) {
    final notes = c.notes ?? '';
    return InkWell(
      onTap: () => _editNotes(c),
      borderRadius: BorderRadius.zero,
      child: _card(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            notes.isEmpty ? 'No notes yet — tap to add.' : notes,
            style: notes.isEmpty
                ? const TextStyle(color: AppTheme.stone)
                : Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddNoteDialog() async {
    final text = await _promptText(
      title: 'ADD NOTE',
      hint: 'Met at the expo, wants a demo…',
      buttonLabel: 'Save note',
      maxLines: 4,
    );
    if (text != null && text.trim().isNotEmpty && mounted) {
      await context.read<AppDatabase>().contactsDao.addNote(widget.id, text.trim());
    }
  }

  Future<String?> _promptText({
    required String title,
    required String buttonLabel,
    String? hint,
    String initialValue = '',
    int maxLines = 3,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppTheme.white,
      builder: (_) => _TextInputSheet(
        title: title,
        buttonLabel: buttonLabel,
        hint: hint,
        initialValue: initialValue,
        maxLines: maxLines,
      ),
    );
  }

  Future<void> _startReminderFlow(model.Contact c) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: c.reminderDate ?? now.add(const Duration(days: 3)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (!mounted) return;

    final when = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime?.hour ?? 9,
      pickedTime?.minute ?? 0,
    );

    final note = await _promptText(
      title: 'REMINDER NOTE',
      hint: 'e.g. Send the proposal',
      buttonLabel: 'Set reminder',
      initialValue: c.reminderNote ?? '',
      maxLines: 2,
    );
    if (note == null || !mounted) return;

    final dao = context.read<AppDatabase>().contactsDao;
    await dao.setReminder(c.id, when, note.isEmpty ? null : note);
    await NotificationService.scheduleReminder(
      id: c.id.hashCode,
      contactName: c.name,
      note: note,
      scheduledDate: when,
      payload: c.id,
    );
    await _loadContact();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reminder set for ${timeago.format(when, allowFromNow: true)}')),
      );
    }
  }

  Future<void> _clearReminder(model.Contact c) async {
    final dao = context.read<AppDatabase>().contactsDao;
    await dao.clearReminder(c.id);
    await NotificationService.cancelReminder(c.id.hashCode);
    await _loadContact();
  }

  Widget _reminderSection(model.Contact c) {
    final due = c.reminderDate;
    if (due == null || c.reminderDone) {
      return OutlinedButton.icon(
        onPressed: () => _startReminderFlow(c),
        icon: const Icon(Icons.alarm_add),
        label: const Text('Set follow-up reminder'),
      );
    }
    final overdue = due.isBefore(DateTime.now());
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: overdue ? AppTheme.error : AppTheme.borderDivider),
      ),
      child: Row(
        children: [
          Icon(Icons.alarm, color: overdue ? AppTheme.error : AppTheme.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  overdue
                      ? 'Overdue · ${timeago.format(due)}'
                      : 'Due ${timeago.format(due, allowFromNow: true)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: overdue ? AppTheme.error : AppTheme.navy,
                  ),
                ),
                if ((c.reminderNote ?? '').isNotEmpty)
                  Text(c.reminderNote!, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => _startReminderFlow(c),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => _clearReminder(c),
          ),
        ],
      ),
    );
  }

  void _shareContact(model.Contact c) {
    final lines = [
      c.name,
      if ((c.designation ?? '').isNotEmpty && (c.company ?? '').isNotEmpty)
        '${c.designation} · ${c.company}'
      else if ((c.company ?? '').isNotEmpty)
        c.company!
      else if ((c.designation ?? '').isNotEmpty)
        c.designation!,
      for (final p in c.phones) p,
      for (final e in c.emails) e,
      if ((c.website ?? '').isNotEmpty) c.website!,
    ];
    SharePlus.instance.share(ShareParams(text: lines.join('\n')));
  }

  String get _initial {
    final n = (_contact?.name ?? '').trim();
    return n.isEmpty ? '?' : n.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (_contact == null) {
      return const Scaffold(
        backgroundColor: AppTheme.slateBg,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final c = _contact!;
    final hasImage = c.imageFrontPath != null && File(c.imageFrontPath!).existsSync();
    final subtitle = [c.designation, c.company]
        .where((e) => e != null && e.isNotEmpty)
        .join('  ·  ');

    return Scaffold(
      backgroundColor: AppTheme.slateBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppTheme.slateBg,
            surfaceTintColor: Colors.transparent,
            foregroundColor: hasImage ? Colors.white : AppTheme.navy,
            expandedHeight: hasImage ? 260 : kToolbarHeight,
            pinned: true,
            stretch: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.canPop() ? context.pop() : context.go('/'),
            ),
            actions: [
              IconButton(
                tooltip: c.isFavorite ? 'Unfavorite' : 'Favorite',
                icon: Icon(c.isFavorite ? Icons.star : Icons.star_border,
                    color: c.isFavorite ? AppTheme.warning : null),
                onPressed: () async {
                  await context.read<AppDatabase>().contactsDao.toggleFavorite(c.id, !c.isFavorite);
                  await _loadContact();
                },
              ),
              IconButton(
                tooltip: 'Share',
                icon: const Icon(Icons.ios_share),
                onPressed: () => _shareContact(c),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(start: 56, bottom: 14, end: 56),
              title: Text(
                c.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  letterSpacing: 1.1,
                  color: hasImage ? Colors.white : AppTheme.navy,
                ),
              ),
              background: hasImage
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        GestureDetector(
                          onTap: () => showCardImageViewer(context,
                              front: c.imageFrontPath!, back: c.imageBackPath),
                          child: Image.file(File(c.imageFrontPath!), fit: BoxFit.cover),
                        ),
                        const IgnorePointer(child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0x99000000), Color(0x00000000), Color(0xCC000000)],
                              stops: [0.0, 0.4, 1.0],
                            ),
                          ),
                        )),
                        const Positioned(
                          right: 12,
                          bottom: 12,
                          child: IgnorePointer(
                            child: Icon(Icons.zoom_out_map, color: Colors.white70, size: 20),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, hasImage ? 20 : 8, 20, 40 + MediaQuery.of(context).padding.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Identity block (no image → show avatar + name; image → just subtitle)
                  if (!hasImage)
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppTheme.blueTint,
                          child: Text(_initial,
                              style: const TextStyle(
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name, style: Theme.of(context).textTheme.titleLarge),
                              if (subtitle.isNotEmpty)
                                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      ],
                    )
                  else if (subtitle.isNotEmpty)
                    Text(subtitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.stone)),

                  const SizedBox(height: 20),
                  _quickActions(c).animate().fadeIn(delay: 80.ms),

                  const SizedBox(height: 28),
                  _sectionHeader("CONTACT INFO"),
                  _contactInfoCard(c),

                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionHeader("NOTES"),
                      TextButton.icon(
                        onPressed: () => _editNotes(c),
                        icon: Icon((c.notes ?? '').isEmpty ? Icons.add : Icons.edit_outlined, size: 18),
                        label: Text((c.notes ?? '').isEmpty ? 'ADD' : 'EDIT'),
                      ),
                    ],
                  ),
                  _notesCard(c),

                  const SizedBox(height: 28),
                  _sectionHeader("FOLLOW-UP"),
                  _reminderSection(c),

                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionHeader("TIMELINE"),
                      TextButton.icon(
                        onPressed: _showAddNoteDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text("ADD"),
                      ),
                    ],
                  ),
                  _notesList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActions(model.Contact c) {
    final actions = <Widget>[
      if (c.phones.isNotEmpty)
        _actionButton(Icons.call, "Call", () => _launchUrl("tel:${c.phones.first}")),
      if (c.phones.isNotEmpty)
        _actionButton(Icons.chat_bubble_outline, "Text", () => _launchUrl("sms:${c.phones.first}")),
      if (c.emails.isNotEmpty)
        _actionButton(Icons.mail_outline, "Email", () => _launchUrl("mailto:${c.emails.first}")),
      _actionButton(Icons.person_add_alt, "Add", _saveToPhoneContacts),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: actions,
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.circle),
              child: Icon(icon, color: AppTheme.white, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.stone, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title,
          style: GoogleFonts.plusJakartaSans(fontSize: 22, color: AppTheme.stone, letterSpacing: 1.4)),
    );
  }

  Widget _contactInfoCard(model.Contact c) {
    final rows = <Widget>[
      for (final p in c.phones)
        _infoTile(Icons.phone_outlined, 'Phone', p, () => _launchUrl('tel:$p'), Icons.call),
      for (final e in c.emails)
        _infoTile(Icons.mail_outline, 'Email', e, () => _launchUrl('mailto:$e'), Icons.north_east),
      if ((c.website ?? '').isNotEmpty)
        _infoTile(Icons.language, 'Website', c.website!, () => _launchUrl(_asUrl(c.website!)), Icons.north_east),
      if ((c.linkedInUrl ?? '').isNotEmpty)
        _infoTile(Icons.link, 'LinkedIn', c.linkedInUrl!, () => _launchUrl(_asUrl(c.linkedInUrl!)), Icons.north_east),
      if ((c.twitterHandle ?? '').isNotEmpty)
        _infoTile(Icons.alternate_email, 'Social', c.twitterHandle!, null, null),
      if ((c.address ?? '').isNotEmpty)
        _infoTile(Icons.location_on_outlined, 'Address', c.address!,
            () => _launchUrl('geo:0,0?q=${Uri.encodeComponent(c.address!)}'), Icons.map_outlined),
      if ((c.exhibitionName ?? '').isNotEmpty)
        _infoTile(Icons.storefront_outlined, 'Captured at', c.exhibitionName!, null, null),
    ];

    if (rows.isEmpty) {
      return _card(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text('No contact details captured', style: TextStyle(color: AppTheme.stone)),
        ),
      );
    }

    return _card(
      Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppTheme.borderDivider),
            rows[i],
          ],
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value, VoidCallback? onTap, IconData? trailing) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.stone, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.stone, letterSpacing: 0.8)),
                  const SizedBox(height: 2),
                  Text(value, style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
            if (trailing != null) Icon(trailing, size: 18, color: AppTheme.primaryBlue),
          ],
        ),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: AppTheme.borderDivider),
      ),
      child: child,
    );
  }

  String _asUrl(String raw) =>
      raw.startsWith('http') ? raw : 'https://$raw';

  Widget _notesList() {
    return StreamBuilder<List<ContactNote>>(
      stream: _notesStream,
      builder: (context, snapshot) {
        final notes = snapshot.data;
        if (notes == null) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
          );
        }
        if (notes.isEmpty) {
          return _card(
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No notes yet — tap ADD to jot something down.',
                  style: TextStyle(color: AppTheme.stone)),
            ),
          );
        }
        return Column(
          children: notes
              .map((note) => Dismissible(
                    key: Key(note.id.toString()),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) =>
                        context.read<AppDatabase>().contactsDao.deleteNote(note.id),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                          color: AppTheme.error, borderRadius: BorderRadius.zero),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.zero,
                        border: Border.all(color: AppTheme.borderDivider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(note.body, style: Theme.of(context).textTheme.bodyLarge),
                          const SizedBox(height: 8),
                          Text(timeago.format(note.createdAt),
                              style: const TextStyle(color: AppTheme.stone, fontSize: 12)),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}

/// A lightweight keyboard-aware text-entry sheet.
///
/// Perf notes: only this small subtree depends on `viewInsets`, so keyboard
/// frames don't rebuild the (heavy) detail screen behind the modal. Focus is
/// requested after the sheet's entrance settles so the slide + keyboard don't
/// animate on top of each other.
class _TextInputSheet extends StatefulWidget {
  const _TextInputSheet({
    required this.title,
    required this.buttonLabel,
    this.hint,
    this.initialValue = '',
    this.maxLines = 3,
  });

  final String title;
  final String buttonLabel;
  final String? hint;
  final String initialValue;
  final int maxLines;

  @override
  State<_TextInputSheet> createState() => _TextInputSheetState();
}

class _TextInputSheetState extends State<_TextInputSheet> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 260), () {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              focusNode: _focus,
              minLines: widget.maxLines >= 3 ? 3 : widget.maxLines,
              maxLines: widget.maxLines,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: widget.hint,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (v) => Navigator.pop(context, v.trim()),
            ),
            const SizedBox(height: 20),
            BeforthButton(
              label: widget.buttonLabel,
              onPressed: () => Navigator.pop(context, _controller.text.trim()),
            ),
          ],
        ),
      ),
    );
  }
}
