// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'corrections_store.dart';

// ignore_for_file: type=lint
mixin _$CorrectionsStoreMixin on DatabaseAccessor<AppDatabase> {
  $ContactsTable get contacts => attachedDatabase.contacts;
  $ParserCorrectionsTable get parserCorrections =>
      attachedDatabase.parserCorrections;
  CorrectionsStoreManager get managers => CorrectionsStoreManager(this);
}

class CorrectionsStoreManager {
  final _$CorrectionsStoreMixin _db;
  CorrectionsStoreManager(this._db);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db.attachedDatabase, _db.contacts);
  $$ParserCorrectionsTableTableManager get parserCorrections =>
      $$ParserCorrectionsTableTableManager(
          _db.attachedDatabase, _db.parserCorrections);
}
