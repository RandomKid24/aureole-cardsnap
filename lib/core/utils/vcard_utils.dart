import 'package:collection/collection.dart';
import '../models/contact.dart';

String contactToVCard(Contact contact) {
  final lines = [
    'BEGIN:VCARD',
    'VERSION:3.0',
    'FN:${contact.name}',
    'N:${contact.name.split(' ').last};${contact.name.split(' ').first};;;',
    if (contact.company != null || contact.designation != null)
      'ORG:${contact.company ?? ''};${contact.designation ?? ''}',
    if (contact.designation != null) 'TITLE:${contact.designation}',
    ...contact.phones.map((p) => 'TEL;TYPE=WORK,VOICE:$p'),
    ...contact.emails.map((e) => 'EMAIL;TYPE=WORK:$e'),
    if (contact.website != null) 'URL:${contact.website}',
    if (contact.address != null) 'ADR;TYPE=WORK:;;${contact.address};;;;',
    if (contact.linkedInUrl != null) 'X-SOCIALPROFILE;type=linkedin:${contact.linkedInUrl}',
    if ((contact.notes ?? '').isNotEmpty)
      'NOTE:${contact.notes!.replaceAll('\n', '\\n')}',
    'REV:${DateTime.now().toUtc().toIso8601String()}',
    'END:VCARD',
  ];
  return lines.join('\r\n');
}

String contactsToVCardBundle(List<Contact> contacts) =>
    contacts.map(contactToVCard).join('\r\n\r\n');

List<Map<String, dynamic>> parseVCardFile(String vcfContent) {
  final cards = vcfContent.split(RegExp(r'END:VCARD', caseSensitive: false));
  return cards
      .where((c) => c.trim().isNotEmpty)
      .map((card) {
        final lines = card.split(RegExp(r'\r\n|\n|\r'));
        String? getField(String key) {
          final line = lines.firstWhereOrNull(
            (l) => l.toUpperCase().startsWith(key.toUpperCase()),
          );
          return line?.split(':').skip(1).join(':').trim();
        }

        List<String> getMultiField(String key) => lines
            .where((l) => l.toUpperCase().startsWith(key.toUpperCase()))
            .map((l) => l.split(':').skip(1).join(':').trim())
            .where((v) => v.isNotEmpty)
            .toList();

        return {
          'name': getField('FN') ?? '',
          'phones': getMultiField('TEL'),
          'emails': getMultiField('EMAIL'),
          'website': getField('URL'),
          'address': getField('ADR'),
          'company': getField('ORG')?.split(';').first,
          'designation': getField('TITLE'),
          'notes': getField('NOTE')?.replaceAll('\\n', '\n'),
        };
      })
      .where((c) => (c['name'] as String).isNotEmpty)
      .toList();
}
