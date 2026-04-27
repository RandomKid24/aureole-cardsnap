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
                    Text("CARDSNAP", style: Theme.of(context).textTheme.displayMedium),
                  ],
                ),
              ),
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
                        return Slidable(
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
                                borderRadius: BorderRadius.circular(16)
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
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: _selectedIds.contains(contact.id) ? AppTheme.primaryBlue : AppTheme.borderDivider),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                      child: Text(contact.name.substring(0, 1).toUpperCase(), style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 18)),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(contact.name, style: Theme.of(context).textTheme.titleMedium),
                                          if (contact.company != null || contact.designation != null)
                                            Text([contact.designation, contact.company].where((e) => e != null && e.isNotEmpty).join(' at '), style: Theme.of(context).textTheme.bodyMedium),
                                        ],
                                      ),
                                    ),
                                    if (contact.isFavorite) const Icon(Icons.star, color: AppTheme.warning, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: (index * 40).ms).slideY(begin: 0.08);
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
            onPressed: () => context.push('/scan'),
          ),
    );
  }
}
