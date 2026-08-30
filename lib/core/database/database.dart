import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'contacts_dao.dart';

part 'database.g.dart';

class Contacts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get company => text().nullable()();
  TextColumn get designation => text().nullable()();
  TextColumn get phonesJson => text()();
  TextColumn get emailsJson => text()();
  TextColumn get website => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get imageFrontPath => text().nullable()();
  TextColumn get imageBackPath => text().nullable()();
  TextColumn get confidenceJson => text()();
  TextColumn get parseMode => text()();
  /// Free-text notes the user attaches to the card.
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get lastContactedAt => dateTime().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  TextColumn get tagsJson => text().withDefault(const Constant('[]'))();
  TextColumn get reminderNote => text().nullable()();
  DateTimeColumn get reminderDate => dateTime().nullable()();
  BoolColumn get reminderDone => boolean().withDefault(const Constant(false))();
  IntColumn get scanCount => integer().withDefault(const Constant(1))();
  TextColumn get linkedInUrl => text().nullable()();
  TextColumn get twitterHandle => text().nullable()();
  // v3 metadata columns
  TextColumn get aiModelUsed => text().nullable()();
  TextColumn get aiProviderUsed => text().nullable()();
  IntColumn get processingDurationMs => integer().nullable()();
  IntColumn get ocrDurationMs => integer().nullable()();
  IntColumn get parserDurationMs => integer().nullable()();
  RealColumn get imageQualityScore => real().nullable()();
  TextColumn get parserSource => text().withDefault(const Constant('local'))();
  IntColumn get parserVersion => integer().withDefault(const Constant(1))();
  /// `id` of the record created on the Marketing API ("Visiting Card Contact").
  /// Non-null once this contact has been pushed — used to avoid duplicates.
  IntColumn get marketingContactId => integer().nullable()();
  /// Exhibition the card was captured at (picked on the save screen).
  IntColumn get exhibitionId => integer().nullable()();
  TextColumn get exhibitionName => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Durable outbox for pushing contacts to the Marketing API. A row is removed
/// once the POST succeeds; it is kept (status `failed`) for permission/validation
/// errors so the problem can be surfaced in Settings.
class MarketingSyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get contactId => text().nullable()();
  TextColumn get contactName => text().withDefault(const Constant(''))();
  TextColumn get payloadJson => text()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending | failed
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  String get tableName => 'marketing_sync_queue';
}

class ContactNotes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get contactId => text().references(Contacts, #id)();
  TextColumn get body => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  String get tableName => 'contact_notes';
}

class ScanDrafts extends Table {
  TextColumn get id => text()();
  TextColumn get parseResultJson => text()();
  TextColumn get imageFrontPath => text().nullable()();
  TextColumn get imageBackPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ParserCorrections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get contactId => text().references(Contacts, #id)();
  TextColumn get fieldName => text()();
  TextColumn get originalOcr => text()();
  TextColumn get originalParsed => text()();
  TextColumn get correctedValue => text()();
  TextColumn get fieldType => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  String get tableName => 'parser_corrections';
}

// NOTE: `contact_fts` is a raw FTS5 virtual table, not a drift-managed table.
// It must NOT be listed in @DriftDatabase(tables:) — doing so makes
// `m.createAll()` create a plain table that shadows the virtual one and breaks
// the sync triggers. It is created and kept in sync entirely via raw SQL below.

// ─── Raw SQL for the FTS5 search index ──────────────────────────────────────

const _createFtsTable = '''
CREATE VIRTUAL TABLE IF NOT EXISTS contact_fts USING fts5(
  contact_id UNINDEXED,
  name,
  company,
  designation,
  email,
  phone
)
''';

const _dropFtsObjects = '''
DROP TRIGGER IF EXISTS contacts_ai;
DROP TRIGGER IF EXISTS contacts_ad;
DROP TRIGGER IF EXISTS contacts_au;
DROP TABLE IF EXISTS contact_fts;
''';

const _ftsTriggers = [
  '''
  CREATE TRIGGER contacts_ai AFTER INSERT ON contacts BEGIN
    INSERT INTO contact_fts(contact_id, name, company, designation, email, phone)
    VALUES (new.id, new.name, IFNULL(new.company, ''), IFNULL(new.designation, ''),
            new.emails_json, new.phones_json);
  END;
  ''',
  '''
  CREATE TRIGGER contacts_ad AFTER DELETE ON contacts BEGIN
    DELETE FROM contact_fts WHERE contact_id = old.id;
  END;
  ''',
  '''
  CREATE TRIGGER contacts_au AFTER UPDATE ON contacts BEGIN
    DELETE FROM contact_fts WHERE contact_id = old.id;
    INSERT INTO contact_fts(contact_id, name, company, designation, email, phone)
    VALUES (new.id, new.name, IFNULL(new.company, ''), IFNULL(new.designation, ''),
            new.emails_json, new.phones_json);
  END;
  ''',
];

@DriftDatabase(
  tables: [Contacts, ContactNotes, ScanDrafts, ParserCorrections, MarketingSyncQueue],
  daos: [ContactsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// For tests — pass `NativeDatabase.memory()`.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 8;

  Future<void> _setupFts(Migrator m) async {
    for (final stmt in _dropFtsObjects.split(';')) {
      final s = stmt.trim();
      if (s.isNotEmpty) await customStatement(s);
    }
    await customStatement(_createFtsTable);
    for (final t in _ftsTriggers) {
      await customStatement(t);
    }
    await rebuildFtsIndex();
  }

  Future<void> rebuildFtsIndex() async {
    await customStatement('DELETE FROM contact_fts');
    final all = await select(contacts).get();
    await batch((b) {
      for (final c in all) {
        b.customStatement(
          'INSERT INTO contact_fts(contact_id, name, company, designation, email, phone) '
          'VALUES (?, ?, ?, ?, ?, ?)',
          [c.id, c.name, c.company ?? '', c.designation ?? '', c.emailsJson, c.phonesJson],
        );
      }
    });
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _setupFts(m);
        },
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.createTable(contactNotes);
            await migrator.createTable(scanDrafts);
          }
          if (from < 3) {
            await migrator.addColumn(contacts, contacts.aiModelUsed);
            await migrator.addColumn(contacts, contacts.processingDurationMs);
            await migrator.addColumn(contacts, contacts.ocrDurationMs);
            await migrator.addColumn(contacts, contacts.parserDurationMs);
            await migrator.addColumn(contacts, contacts.imageQualityScore);
            await migrator.addColumn(contacts, contacts.parserSource);
            await migrator.addColumn(contacts, contacts.parserVersion);
            await migrator.createTable(parserCorrections);
          }
          if (from < 4) {
            await migrator.addColumn(contacts, contacts.aiProviderUsed);
          }
          if (from < 5) {
            // The old FTS setup created a *plain* `contact_fts` table and sync
            // triggers that referenced non-existent columns (`new.emailsJson`),
            // so every INSERT/UPDATE/DELETE on `contacts` threw. Rebuild it.
            await _setupFts(migrator);
          }
          if (from < 6) {
            await migrator.addColumn(contacts, contacts.notes);
          }
          if (from < 7) {
            await migrator.addColumn(contacts, contacts.marketingContactId);
            await migrator.createTable(marketingSyncQueue);
          }
          if (from < 8) {
            await migrator.addColumn(contacts, contacts.exhibitionId);
            await migrator.addColumn(contacts, contacts.exhibitionName);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'cardsnap.db'));
    return NativeDatabase.createInBackground(file);
  });
}
