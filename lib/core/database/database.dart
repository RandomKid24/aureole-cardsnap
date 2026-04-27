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

  @override
  Set<Column> get primaryKey => {id};
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

class ContactFts extends Table {
  TextColumn get contactId => text().named('rowid')();
  TextColumn get name => text()();
  TextColumn get company => text()();
  TextColumn get designation => text()();
  TextColumn get email => text()();
  TextColumn get phone => text()();
}

@DriftDatabase(tables: [Contacts, ContactNotes, ScanDrafts, ContactFts], daos: [ContactsDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  Future<void> rebuildFtsIndex() async {
    await customStatement('DELETE FROM contact_fts');
    final all = await select(contacts).get();
    await transaction(() async {
      for (final c in all) {
        await customStatement(
          'INSERT INTO contact_fts(rowid, name, company, designation, email, phone) VALUES (?, ?, ?, ?, ?, ?)',
          [c.id, c.name, c.company, c.designation, c.emailsJson, c.phonesJson],
        );
      }
    });
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement('''
        CREATE VIRTUAL TABLE IF NOT EXISTS contact_fts
        USING fts5(
          rowid UNINDEXED,
          name,
          company,
          designation,
          email,
          phone,
          content=contacts,
          content_rowid=rowid
        )
      ''');
      
      // Add triggers for FTS sync
      await customStatement('''
        CREATE TRIGGER contacts_ai AFTER INSERT ON contacts BEGIN
          INSERT INTO contact_fts(rowid, name, company, designation, email, phone)
          VALUES (new.rowid, new.name, new.company, new.designation, new.emailsJson, new.phonesJson);
        END;
      ''');
      await customStatement('''
        CREATE TRIGGER contacts_ad AFTER DELETE ON contacts BEGIN
          INSERT INTO contact_fts(contact_fts, rowid, name, company, designation, email, phone)
          VALUES ('delete', old.rowid, old.name, old.company, old.designation, old.emailsJson, old.phonesJson);
        END;
      ''');
      await customStatement('''
        CREATE TRIGGER contacts_au AFTER UPDATE ON contacts BEGIN
          INSERT INTO contact_fts(contact_fts, rowid, name, company, designation, email, phone)
          VALUES ('delete', old.rowid, old.name, old.company, old.designation, old.emailsJson, old.phonesJson);
          INSERT INTO contact_fts(rowid, name, company, designation, email, phone)
          VALUES (new.rowid, new.name, new.company, new.designation, new.emailsJson, new.phonesJson);
        END;
      ''');
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(contactNotes);
        await migrator.createTable(scanDrafts);
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
