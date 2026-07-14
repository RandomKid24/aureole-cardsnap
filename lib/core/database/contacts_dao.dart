import 'dart:convert';
import 'package:drift/drift.dart';
import '../models/contact.dart' as model;
import '../models/parse_result.dart';
import 'database.dart';

part 'contacts_dao.g.dart';

@DriftAccessor(tables: [Contacts, ContactNotes, ScanDrafts, ParserCorrections, ContactFts])
class ContactsDao extends DatabaseAccessor<AppDatabase> with _$ContactsDaoMixin {
  ContactsDao(super.db);

  Stream<List<model.Contact>> watchAllContacts() {
    return (select(contacts)..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
        .map(_mapToModel).watch();
  }

  Future<List<model.Contact>> getAllContacts() async {
    final results = await (select(contacts)..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])).get();
    return results.map(_mapToModel).toList();
  }

  Future<model.Contact?> getContactById(String id) async {
    final result = await (select(contacts)..where((t) => t.id.equals(id))).getSingleOrNull();
    return result != null ? _mapToModel(result) : null;
  }

  Future<int> insertContact(model.Contact contact) {
    return into(contacts).insert(_mapToTable(contact));
  }

  Future<bool> updateContact(model.Contact contact) {
    return update(contacts).replace(_mapToTable(contact));
  }

  Future<int> deleteContact(String id) {
    return (delete(contacts)..where((t) => t.id.equals(id))).go();
  }

  Future<void> toggleFavorite(String id, bool isFavorite) async {
    await (update(contacts)..where((t) => t.id.equals(id))).write(ContactsCompanion(isFavorite: Value(isFavorite)));
  }

  Future<List<model.Contact>> getOverdueReminders() async {
    final now = DateTime.now();
    final results = await (select(contacts)
      ..where((t) => t.reminderDate.isSmallerOrEqualValue(now) & t.reminderDone.equals(false))
      ..orderBy([(t) => OrderingTerm(expression: t.reminderDate)])
    ).get();
    return results.map(_mapToModel).toList();
  }

  Future<void> markReminderDone(String id) async {
    await (update(contacts)..where((t) => t.id.equals(id))).write(const ContactsCompanion(reminderDone: Value(true)));
  }

  // Notes
  Stream<List<ContactNote>> watchNotesForContact(String contactId) =>
      (select(contactNotes)
        ..where((n) => n.contactId.equals(contactId))
        ..orderBy([(n) => OrderingTerm(expression: n.createdAt, mode: OrderingMode.desc)]))
      .watch();

  Future<void> addNote(String contactId, String body) =>
      into(contactNotes).insert(ContactNotesCompanion.insert(
        contactId: contactId,
        body: body,
        createdAt: DateTime.now(),
      ));

  Future<void> deleteNote(int noteId) =>
      (delete(contactNotes)..where((n) => n.id.equals(noteId))).go();

  // Drafts
  Future<void> saveDraft(String id, ParseResult result, String? imageFront, String? imageBack) =>
      into(scanDrafts).insertOnConflictUpdate(ScanDraftsCompanion.insert(
        id: id,
        parseResultJson: jsonEncode(result.toJson()),
        imageFrontPath: Value(imageFront),
        imageBackPath: Value(imageBack),
        createdAt: DateTime.now(),
      ));

  Future<ScanDraft?> getDraft(String id) =>
      (select(scanDrafts)..where((d) => d.id.equals(id))).getSingleOrNull();

  Future<void> cleanOldDrafts(DateTime before) =>
      (delete(scanDrafts)..where((d) => d.createdAt.isSmallerThanValue(before))).go();

  // FTS
  Future<List<model.Contact>> searchContacts(String query) async {
    if (query.trim().isEmpty) return getAllContacts();

    final ftsQuery = '${query.trim()}*';
    final results = await customSelect(
      '''
      SELECT c.* FROM contacts c
      INNER JOIN contact_fts fts ON c.rowid = fts.rowid
      WHERE contact_fts MATCH ?
      ORDER BY rank
      ''',
      variables: [Variable.withString(ftsQuery)],
      readsFrom: {contacts, contactFts},
    ).get();

    return results.map((row) {
      final map = row.data;
      return model.Contact(
        id: map['id'],
        name: map['name'],
        company: map['company'],
        designation: map['designation'],
        phones: List<String>.from(jsonDecode(map['phones_json'] ?? '[]')),
        emails: List<String>.from(jsonDecode(map['emails_json'] ?? '[]')),
        website: map['website'],
        address: map['address'],
        imageFrontPath: map['image_front_path'],
        imageBackPath: map['image_back_path'],
        confidence: Map<String, double>.from(jsonDecode(map['confidence_json'] ?? '{}')),
        parseMode: map['parse_mode'] ?? 'local',
        createdAt: DateTime.fromMillisecondsSinceEpoch((map['created_at'] as int) * 1000),
        updatedAt: map['updated_at'] != null ? DateTime.fromMillisecondsSinceEpoch((map['updated_at'] as int) * 1000) : null,
        lastContactedAt: map['last_contacted_at'] != null ? DateTime.fromMillisecondsSinceEpoch((map['last_contacted_at'] as int) * 1000) : null,
        isFavorite: map['is_favorite'] == 1,
        tags: List<String>.from(jsonDecode(map['tags_json'] ?? '[]')),
        reminderNote: map['reminder_note'],
        reminderDate: map['reminder_date'] != null ? DateTime.fromMillisecondsSinceEpoch((map['reminder_date'] as int) * 1000) : null,
        reminderDone: map['reminder_done'] == 1,
        scanCount: map['scan_count'] ?? 1,
        linkedInUrl: map['linked_in_url'],
        twitterHandle: map['twitter_handle'],
        aiModelUsed: map['ai_model_used'],
        aiProviderUsed: map['ai_provider_used'],
        processingDurationMs: map['processing_duration_ms'],
        ocrDurationMs: map['ocr_duration_ms'],
        parserDurationMs: map['parser_duration_ms'],
        imageQualityScore: map['image_quality_score']?.toDouble(),
        parserSource: map['parser_source'] ?? 'local',
        parserVersion: map['parser_version'] ?? 1,
      );
    }).toList();
  }

  model.Contact _mapToModel(Contact row) {
    return model.Contact(
      id: row.id,
      name: row.name,
      company: row.company,
      designation: row.designation,
      phones: List<String>.from(jsonDecode(row.phonesJson)),
      emails: List<String>.from(jsonDecode(row.emailsJson)),
      website: row.website,
      address: row.address,
      imageFrontPath: row.imageFrontPath,
      imageBackPath: row.imageBackPath,
      confidence: Map<String, double>.from(jsonDecode(row.confidenceJson)),
      parseMode: row.parseMode,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      lastContactedAt: row.lastContactedAt,
      isFavorite: row.isFavorite,
      tags: List<String>.from(jsonDecode(row.tagsJson)),
      reminderNote: row.reminderNote,
      reminderDate: row.reminderDate,
      reminderDone: row.reminderDone,
      scanCount: row.scanCount,
      linkedInUrl: row.linkedInUrl,
      twitterHandle: row.twitterHandle,
      aiModelUsed: row.aiModelUsed,
      aiProviderUsed: row.aiProviderUsed,
      processingDurationMs: row.processingDurationMs,
      ocrDurationMs: row.ocrDurationMs,
      parserDurationMs: row.parserDurationMs,
      imageQualityScore: row.imageQualityScore,
      parserSource: row.parserSource,
      parserVersion: row.parserVersion,
    );
  }

  ContactsCompanion _mapToTable(model.Contact c) {
    return ContactsCompanion(
      id: Value(c.id),
      name: Value(c.name),
      company: Value(c.company),
      designation: Value(c.designation),
      phonesJson: Value(jsonEncode(c.phones)),
      emailsJson: Value(jsonEncode(c.emails)),
      website: Value(c.website),
      address: Value(c.address),
      imageFrontPath: Value(c.imageFrontPath),
      imageBackPath: Value(c.imageBackPath),
      confidenceJson: Value(jsonEncode(c.confidence)),
      parseMode: Value(c.parseMode),
      createdAt: Value(c.createdAt),
      updatedAt: Value(c.updatedAt),
      lastContactedAt: Value(c.lastContactedAt),
      isFavorite: Value(c.isFavorite),
      tagsJson: Value(jsonEncode(c.tags)),
      reminderNote: Value(c.reminderNote),
      reminderDate: Value(c.reminderDate),
      reminderDone: Value(c.reminderDone),
      scanCount: Value(c.scanCount),
      linkedInUrl: Value(c.linkedInUrl),
      twitterHandle: Value(c.twitterHandle),
      aiModelUsed: Value(c.aiModelUsed),
      aiProviderUsed: Value(c.aiProviderUsed),
      processingDurationMs: Value(c.processingDurationMs),
      ocrDurationMs: Value(c.ocrDurationMs),
      parserDurationMs: Value(c.parserDurationMs),
      imageQualityScore: Value(c.imageQualityScore),
      parserSource: Value(c.parserSource),
      parserVersion: Value(c.parserVersion),
    );
  }
}
