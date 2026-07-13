// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_dao.dart';

// ignore_for_file: type=lint
mixin _$ContactsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ContactsTable get contacts => attachedDatabase.contacts;
  $ContactNotesTable get contactNotes => attachedDatabase.contactNotes;
  $ScanDraftsTable get scanDrafts => attachedDatabase.scanDrafts;
  $ParserCorrectionsTable get parserCorrections =>
      attachedDatabase.parserCorrections;
  $ContactFtsTable get contactFts => attachedDatabase.contactFts;
  ContactsDaoManager get managers => ContactsDaoManager(this);
}

class ContactsDaoManager {
  final _$ContactsDaoMixin _db;
  ContactsDaoManager(this._db);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db.attachedDatabase, _db.contacts);
  $$ContactNotesTableTableManager get contactNotes =>
      $$ContactNotesTableTableManager(_db.attachedDatabase, _db.contactNotes);
  $$ScanDraftsTableTableManager get scanDrafts =>
      $$ScanDraftsTableTableManager(_db.attachedDatabase, _db.scanDrafts);
  $$ParserCorrectionsTableTableManager get parserCorrections =>
      $$ParserCorrectionsTableTableManager(
          _db.attachedDatabase, _db.parserCorrections);
  $$ContactFtsTableTableManager get contactFts =>
      $$ContactFtsTableTableManager(_db.attachedDatabase, _db.contactFts);
}
