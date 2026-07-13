import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:cardsnap/features/scan/ocr_service.dart';
import 'package:cardsnap/features/parse/local_parser.dart';

OcrBlock block(String text, double left, double top, double fontSize) {
  return OcrBlock(
    text: text,
    rect: Rect.fromLTWH(left, top, text.length * fontSize * 0.6, fontSize),
    fontSize: fontSize,
  );
}

OcrResult makeResult(List<OcrBlock> blocks) {
  return OcrResult(
    blocks: blocks,
    imageWidth: 1000,
    imageHeight: 700,
    rawText: blocks.map((b) => b.text).join(' '),
  );
}

void main() {
  final parser = LocalParser();

  group('Two-pass parser — name and company detection', () {
    test('Scenario 1: ALL-CAPS name + no-suffix company (VIVEK C. ZOPE / Beforth)', () {
      // Name is larger, near top; company is smaller, below name
      final result = parser.parse(makeResult([
        block('VIVEK C. ZOPE', 100, 50, 28),
        block('Beforth', 100, 100, 18),
        block('+91 98765 43210', 100, 160, 12),
        block('vivek@beforth.com', 100, 190, 12),
      ]));

      expect(result.name, 'VIVEK C. ZOPE');
      expect(result.company, 'Beforth');
      expect(result.phones, isNotEmpty);
      expect(result.emails, isNotEmpty);
    });

    test('Scenario 2: Standard layout with company suffix (John Smith / Acme Corp Pvt Ltd)', () {
      final result = parser.parse(makeResult([
        block('John Smith', 100, 50, 24),
        block('Acme Corp Pvt Ltd', 100, 95, 16),
        block('CEO', 100, 130, 14),
        block('john@acme.com', 100, 170, 12),
      ]));

      expect(result.name, 'John Smith');
      expect(result.company, contains('Acme'));
      expect(result.designation, 'CEO');
    });

    test('Scenario 3: Company above name (Beforth / VIVEK C. ZOPE)', () {
      // Company appears first (higher on card), name below
      final result = parser.parse(makeResult([
        block('Beforth', 100, 30, 22),
        block('VIVEK C. ZOPE', 100, 80, 28),
        block('+91 98765 43210', 100, 140, 12),
      ]));

      expect(result.name, 'VIVEK C. ZOPE');
      expect(result.company, 'Beforth');
    });

    test('Scenario 4: Designation sandwiched between name and company (Dr. Priya Sharma / TCS / Senior Consultant)', () {
      final result = parser.parse(makeResult([
        block('Dr. Priya Sharma', 100, 50, 22),
        block('Senior Consultant', 100, 90, 14),
        block('TCS', 100, 130, 18),
        block('priya@tcs.com', 100, 170, 12),
      ]));

      expect(result.name, 'Dr. Priya Sharma');
      expect(result.company, 'TCS');
      expect(result.designation, contains('Consultant'));
    });

    test('Scenario 5: Solo person, no company (Rahul Gupta)', () {
      final result = parser.parse(makeResult([
        block('Rahul Gupta', 100, 60, 24),
        block('rahul@gmail.com', 100, 110, 12),
        block('+91 99887 76655', 100, 140, 12),
      ]));

      expect(result.name, 'Rahul Gupta');
      // Company may be null or the email/phone block — just verify name is correct
      expect(result.name, isNotNull);
      expect(result.emails, isNotEmpty);
    });

    test('Scenario 6: Single-word name is penalized but still picked if best candidate', () {
      // "Beforth" alone with no other name-like candidates
      final result = parser.parse(makeResult([
        block('Beforth', 100, 60, 24),
        block('hello@beforth.com', 100, 110, 12),
      ]));

      // Single word gets low name score but should still be picked if it's the only candidate
      expect(result.name, isNotNull);
    });

    test('Scenario 7: Name scoring proximity — closer to company candidate scores higher', () {
      // Two name-like blocks; the one closer to the company block should win
      final result = parser.parse(makeResult([
        block('Alice Wonder', 100, 200, 20),  // far from company
        block('Bob Builder', 100, 90, 18),     // close to company
        block('Construction Inc', 100, 120, 16),
        block('+1 555 123 4567', 100, 160, 12),
      ]));

      // Bob Builder is closer to "Construction Inc" — should win
      expect(result.name, 'Bob Builder');
      expect(result.company, contains('Construction'));
    });
  });
}
