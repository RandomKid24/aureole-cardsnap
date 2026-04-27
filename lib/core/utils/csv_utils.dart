import 'package:csv/csv.dart';
import '../models/parse_result.dart';

class CsvUtils {
  static Future<List<ParseResult>> importCsv(String csvContent) async {
    final rows = CsvToListConverter().convert(csvContent);
    if (rows.isEmpty) throw const FormatException('Empty file');

    final headers = rows.first.map((h) => h.toString().toLowerCase().trim()).toList();
    const required = ['name', 'email', 'phone'];
    final missing = required.where((h) => !headers.contains(h)).toList();

    if (missing.isNotEmpty) {
      throw FormatException('CSV is missing required columns: ${missing.join(', ')}. '
          'Expected headers: name, email, phone, company, designation, address.');
    }

    return rows.skip(1).map((row) {
      String? cell(String col) {
        final i = headers.indexOf(col);
        return (i >= 0 && i < row.length) ? row[i]?.toString() : null;
      }

      final phones = cell('phone')?.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() ?? [];
      final emails = cell('email')?.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() ?? [];

      return ParseResult(
        name: cell('name'),
        company: cell('company'),
        designation: cell('designation'),
        phones: phones,
        emails: emails,
        address: cell('address'),
        parseMode: 'import',
        confidence: {},
      );
    }).toList();
  }

  static String exportCsv(List<dynamic> contacts) {
    List<List<dynamic>> rows = [
      ["name", "company", "designation", "phone", "email", "address", "website"]
    ];
    for (var c in contacts) {
      rows.add([
        c.name,
        c.company ?? '',
        c.designation ?? '',
        (c.phones as List).join(', '),
        (c.emails as List).join(', '),
        c.address ?? '',
        c.website ?? '',
      ]);
    }
    return ListToCsvConverter().convert(rows);
  }
}
