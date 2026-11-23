import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../../core/models/contact.dart';
import '../../core/database/database.dart' hide Contact;
import '../../core/marketing/marketing_models.dart';
import '../../core/update/update_service.dart';
import '../../core/marketing/marketing_sync_service.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/dot_grid_painter.dart';
import '../../shared/widgets/beforth_button.dart';
import '../../core/utils/csv_utils.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  String _searchQuery = '';
  String _filter = 'All';
  bool _isMultiSelect = false;
  final Set<String> _selectedIds = {};
  List<Contact> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    // Once per launch: offer a newer build from GitHub Releases, if any.
    WidgetsBinding.instance.addPostFrameCallback((_) => UpdateService.checkAndPrompt(context));
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    final dao = context.read<AppDatabase>().contactsDao;
    final results = await dao.searchContacts(_searchQuery);
    if (mounted) {
      setState(() {
        _contacts = results;
        _isLoading = false;
      });
    }
  }

  void _onSearch(String query) async {
    _searchQuery = query;
    _loadContacts();
  }

  static String _initial(String name) {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '?' : trimmed.substring(0, 1).toUpperCase();
  }

  // ─── Current-exhibition selector ───────────────────────────────────

  Widget _exhibitionBanner() {
    final sync = context.watch<MarketingSyncService>();
    if (!sync.isConfigured) return const SizedBox.shrink();
    final active = sync.activeExhibition;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: active == null
          ? Material(
              color: AppTheme.blueTint,
              borderRadius: BorderRadius.zero,
              child: InkWell(
                onTap: _pickExhibition,
                borderRadius: BorderRadius.zero,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.zero,
                    border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.storefront, size: 20, color: AppTheme.primaryBlue),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SET CURRENT EXHIBITION',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    color: AppTheme.primaryBlue)),
                            SizedBox(height: 2),
                            Text('Tag every card you scan here',
                                style: TextStyle(fontSize: 11, color: AppTheme.stone)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppTheme.primaryBlue),
                    ],
                  ),
                ),
              ),
            )
          : Material(
              color: AppTheme.blueTint,
              borderRadius: BorderRadius.zero,
              child: InkWell(
                onTap: _pickExhibition,
                borderRadius: BorderRadius.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.storefront, size: 18, color: AppTheme.primaryBlue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('CAPTURING AT',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: AppTheme.primaryBlue)),
                            Text(active.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.navy)),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => sync.setActiveExhibition(null),
                        borderRadius: BorderRadius.circular(999),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.close, size: 16, color: AppTheme.stone),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _pickExhibition() async {
    final sync = context.read<MarketingSyncService>();
    final picked = await showModalBottomSheet<Object?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppTheme.white,
      builder: (_) => _ExhibitionPickerSheet(sync: sync),
    );
    // The sheet pops `null` on cancel, `false` on "None", or an Exhibition.
    if (picked == false) {
      await sync.setActiveExhibition(null);
    } else if (picked is Exhibition) {
      await sync.setActiveExhibition(picked);
    }
  }

  Future<void> _exportSelected(List<Contact> allContacts) async {
    final selectedContacts = allContacts.where((c) => _selectedIds.contains(c.id)).toList();
    if (selectedContacts.isEmpty) return;

    final csv = CsvUtils.exportCsv(selectedContacts);

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/cardsnap_export.csv';
    final file = File(path);
    await file.writeAsString(csv);

    await SharePlus.instance.share(ShareParams(files: [XFile(path)], subject: 'Exported Contacts'));


    if (mounted) {
      setState(() { _isMultiSelect = false; _selectedIds.clear(); });
    }
  }

  static String _fmtDate(DateTime d) {
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${m[d.month - 1]}';
  }

  /// Scanned card photo; falls back to the initial when there is no image.
  Widget _cardThumb(Contact c) {
    final path = c.imageFrontPath;
    final file = (path != null && path.isNotEmpty) ? File(path) : null;
    final hasImage = file != null && file.existsSync();
    return Container(
      width: 88,
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.blueTint,
        border: Border.all(color: AppTheme.borderDivider),
      ),
      child: hasImage
          ? Image.file(file, fit: BoxFit.cover, cacheWidth: 264,
              errorBuilder: (_, __, ___) => _initialBox(c))
          : _initialBox(c),
    );
  }

  Widget _initialBox(Contact c) => Center(
        child: Text(_initial(c.name),
            style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w800, fontSize: 20)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DotGridBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("CardSnap", style: Theme.of(context).textTheme.displayMedium),
                    IconButton(
                      icon: const Icon(Icons.notifications_none, color: AppTheme.navy),
                      tooltip: 'Reminders',
                      onPressed: () => context.push('/reminders'),
                    ),
                  ],
                ),
              ),
              _exhibitionBanner(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  onChanged: _onSearch,
                  decoration: InputDecoration(
                    hintText: "Search contacts...",
                    prefixIcon: const Icon(Icons.search, color: AppTheme.stone),
                    filled: true,
                    fillColor: AppTheme.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: const BorderSide(color: AppTheme.borderDivider)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: const BorderSide(color: AppTheme.borderDivider)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: ['All', 'Favorites', 'Reminders'].map((f) {
                    final isSelected = _filter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(f.toUpperCase()),
                        selected: isSelected,
                        onSelected: (val) => setState(() { _filter = f; _loadContacts(); }),
                        backgroundColor: AppTheme.white,
                        selectedColor: AppTheme.primaryBlue,
                        checkmarkColor: AppTheme.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999), side: BorderSide(color: isSelected ? AppTheme.primaryBlue : AppTheme.borderDivider)),
                        labelStyle: TextStyle(
                          color: isSelected ? AppTheme.white : AppTheme.stone,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          letterSpacing: 1.0,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (_isMultiSelect)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      Text("${_selectedIds.length} selected", style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      TextButton(onPressed: () => setState(() { _isMultiSelect = false; _selectedIds.clear(); }), child: const Text("Cancel")),
                    ],
                  ),
                ),
              Expanded(
                child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : Builder(
                  builder: (context) {
                    final filtered = _contacts.where((c) {
                      final matchesFilter = _filter == 'All' || 
                                            (_filter == 'Favorites' && c.isFavorite) || 
                                            (_filter == 'Reminders' && c.reminderDate != null && !c.reminderDone);
                      return matchesFilter;
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_add_alt_1, size: 64, color: AppTheme.borderDivider),
                            const SizedBox(height: 16),
                            Text("NO CONTACTS FOUND", style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppTheme.stone)),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final contact = filtered[index];
                        final row = Slidable(
                          key: Key(contact.id),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (_) async {
                                  await context.read<AppDatabase>().contactsDao.deleteContact(contact.id);
                                  _loadContacts();
                                }, 
                                backgroundColor: AppTheme.error, 
                                foregroundColor: Colors.white, 
                                icon: Icons.delete, 
                                label: 'Delete', 
                                borderRadius: BorderRadius.zero
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onLongPress: () => setState(() { _isMultiSelect = true; _selectedIds.add(contact.id); }),
                            onTap: () {
                              if (_isMultiSelect) {
                                setState(() { _selectedIds.contains(contact.id) ? _selectedIds.remove(contact.id) : _selectedIds.add(contact.id); });
                              } else {
                                context.push('/contact/${contact.id}');
                              }
                            },
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              color: _selectedIds.contains(contact.id) ? AppTheme.blueTint : AppTheme.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                                side: BorderSide(color: _selectedIds.contains(contact.id) ? AppTheme.primaryBlue : AppTheme.borderDivider),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    _cardThumb(contact),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(contact.name, style: Theme.of(context).textTheme.titleMedium),
                                          if (contact.company != null || contact.designation != null)
                                            Text([contact.designation, contact.company].where((e) => e != null && e.isNotEmpty).join(' at '), style: Theme.of(context).textTheme.bodyMedium),
                                          if (contact.reminderDate != null && !contact.reminderDone)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 6),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.notifications_active_outlined, size: 14, color: AppTheme.primaryBlue),
                                                  const SizedBox(width: 4),
                                                  Text('Follow up ${_fmtDate(contact.reminderDate!)}',
                                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue)),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (contact.isFavorite) const Icon(Icons.star, color: AppTheme.warning, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                        // Stagger only the first screenful; later rows appear
                        // instantly so scrolling doesn't replay animations.
                        if (index >= 8) return row;
                        return row
                            .animate()
                            .fadeIn(delay: (index * 40).ms)
                            .slideY(begin: 0.08);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _isMultiSelect
        ? FloatingActionButton.extended(
            onPressed: () async {
              _exportSelected(_contacts);
            },
            icon: const Icon(Icons.download),
            label: const Text("EXPORT CSV"),
            backgroundColor: AppTheme.navy,
          )
        : BeforthButton(
            label: "SCAN CARD",
            icon: Icons.document_scanner,
            onPressed: () => context.go('/scan'),
          ),
    );
  }
}

/// Bottom sheet for choosing the "currently at" exhibition. Pops an [Exhibition],
/// `false` for "not at an exhibition", or `null` on cancel.
class _ExhibitionPickerSheet extends StatefulWidget {
  const _ExhibitionPickerSheet({required this.sync});
  final MarketingSyncService sync;

  @override
  State<_ExhibitionPickerSheet> createState() => _ExhibitionPickerSheetState();
}

class _ExhibitionPickerSheetState extends State<_ExhibitionPickerSheet> {
  bool _loading = true;
  List<Exhibition> _list = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool force = false}) async {
    setState(() => _loading = true);
    final ctx = await widget.sync.loadCaptureContext(forceRefresh: force);
    if (!mounted) return;
    setState(() {
      _list = ctx.activeExhibitions;
      _error = ctx.exhibitionsError;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeId = widget.sync.activeExhibition?.id;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('EXHIBITION', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: _loading ? null : () => _load(force: true),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              if (_error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.zero,
                    border: Border.all(color: AppTheme.warning.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          size: 18, color: AppTheme.warning),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_error!,
                            style: const TextStyle(fontSize: 12, color: AppTheme.navy)),
                      ),
                    ],
                  ),
                ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.block, color: AppTheme.stone),
                title: const Text('Not at an exhibition'),
                trailing: activeId == null
                    ? const Icon(Icons.check, color: AppTheme.primaryBlue)
                    : null,
                onTap: () => Navigator.pop(context, false),
              ),
              if (_list.isEmpty && _error == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('No active exhibitions right now',
                      style: TextStyle(color: AppTheme.stone)),
                ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final e in _list)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading:
                            const Icon(Icons.storefront_outlined, color: AppTheme.primaryBlue),
                        title: Text(e.name),
                        subtitle: e.subtitle.isEmpty ? null : Text(e.subtitle),
                        trailing: activeId == e.id
                            ? const Icon(Icons.check, color: AppTheme.primaryBlue)
                            : null,
                        onTap: () => Navigator.pop(context, e),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text('API: ${widget.sync.baseUrl}',
                  style: const TextStyle(fontSize: 10, color: AppTheme.stone)),
            ],
          ],
        ),
      ),
    );
  }
}
