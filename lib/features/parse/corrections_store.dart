import 'package:drift/drift.dart';

import '../../core/database/database.dart';
import '../../core/models/correction.dart';

part 'corrections_store.g.dart';

@DriftAccessor(tables: [ParserCorrections])
class CorrectionsStore extends DatabaseAccessor<AppDatabase> with _$CorrectionsStoreMixin {
  CorrectionsStore(super.db);

  Future<void> recordCorrection({
    required String contactId,
    required String fieldName,
    required String originalOcr,
    required String originalParsed,
    required String correctedValue,
    required String fieldType,
  }) async {
    await into(parserCorrections).insert(
      ParserCorrectionsCompanion.insert(
        contactId: contactId,
        fieldName: fieldName,
        originalOcr: originalOcr,
        originalParsed: originalParsed,
        correctedValue: correctedValue,
        fieldType: fieldType,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<List<Correction>> getCorrectionsForField(String fieldType) async {
    final rows = await (select(parserCorrections)
      ..where((t) => t.fieldType.equals(fieldType))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
    ).get();
    return rows.map(_toModel).toList();
  }

  Future<String?> getMostCommonCorrection(String originalParsed, String fieldType) async {
    final rows = await customSelect(
      'SELECT corrected_value, COUNT(*) as cnt FROM parser_corrections '
      'WHERE original_parsed = ? AND field_type = ? '
      'GROUP BY corrected_value ORDER BY cnt DESC LIMIT 1',
      variables: [Variable.withString(originalParsed), Variable.withString(fieldType)],
    ).get();
    return rows.isNotEmpty ? rows.first.data['corrected_value'] as String : null;
  }

  Future<Map<String, String>> getCompanyCorrections() => getCorrectionMap('company');

  /// For a field type, returns a map of {parsed value -> most frequent correction}
  /// so the parser can auto-apply fixes the user has already made before.
  Future<Map<String, String>> getCorrectionMap(String fieldType) async {
    final rows = await customSelect(
      '''
      SELECT original_parsed, corrected_value, COUNT(*) AS cnt
      FROM parser_corrections
      WHERE field_type = ? AND original_parsed <> ''
      GROUP BY original_parsed, corrected_value
      ORDER BY cnt DESC
      ''',
      variables: [Variable.withString(fieldType)],
    ).get();

    final map = <String, String>{};
    for (final row in rows) {
      final original = row.data['original_parsed'] as String;
      // First row per original wins (highest count due to ORDER BY).
      map.putIfAbsent(original, () => row.data['corrected_value'] as String);
    }
    return map;
  }

  Correction _toModel(ParserCorrection row) => Correction(
    id: row.id.toString(),
    contactId: row.contactId,
    fieldName: row.fieldName,
    originalOcr: row.originalOcr,
    originalParsed: row.originalParsed,
    correctedValue: row.correctedValue,
    fieldType: row.fieldType,
    createdAt: row.createdAt,
  );
}
