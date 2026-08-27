import 'package:flutter_test/flutter_test.dart';
import 'package:cardsnap/core/models/contact.dart';
import 'package:cardsnap/features/duplicate/duplicate_detector.dart';

Contact contact({
  String name = 'Test',
  List<String> phones = const [],
  List<String> emails = const [],
  String? company,
  String? website,
}) {
  return Contact(
    id: name,
    name: name,
    phones: phones,
    emails: emails,
    company: company,
    website: website,
    confidence: const {},
    parseMode: 'local',
    createdAt: DateTime(2026, 1, 1),
  );
}

Contact? find({
  String name = 'Test',
  List<String> phones = const [],
  List<String> emails = const [],
  String? company,
  String? website,
  required List<Contact> against,
}) {
  return DuplicateDetector.findDuplicate({
    'name': name,
    'phones': phones,
    'emails': emails,
    'company': company,
    'website': website,
    'contacts': against,
  });
}

void main() {
  test('same phone number (different formats) is a duplicate', () {
    final existing = [contact(name: 'Asha Rao', phones: ['+91 98765 43210'])];
    expect(find(name: 'A. Rao', phones: ['098765 43210'], against: existing), isNotNull);
  });

  test('same email is a duplicate', () {
    final existing = [contact(name: 'Bob', emails: ['bob@acme.com'])];
    expect(find(name: 'Robert', emails: ['BOB@acme.com'], against: existing), isNotNull);
  });

  test('two different coworkers at the same company are NOT duplicates', () {
    final existing = [contact(name: 'John Smith', company: 'Acme Corp')];
    expect(find(name: 'Jane Doe', company: 'Acme Corp', against: existing), isNull);
  });

  test('same company alone is NOT a duplicate', () {
    final existing = [contact(name: 'Priya Sharma', company: 'Infosys Ltd')];
    expect(find(name: 'Ravi Kumar', company: 'Infosys Limited', against: existing), isNull);
  });

  test('same name AND same company is a duplicate (re-scan of one person)', () {
    final existing = [contact(name: 'John Smith', company: 'Acme Corp')];
    expect(find(name: 'John Smith', company: 'Acme Corp Pvt Ltd', against: existing), isNotNull);
  });

  test('similar name but nothing else in common is NOT a duplicate', () {
    final existing = [contact(name: 'John Smith', company: 'Acme')];
    expect(find(name: 'Jon Smith', company: 'Globex', against: existing), isNull);
  });
}
