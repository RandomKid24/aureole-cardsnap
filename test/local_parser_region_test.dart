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
  group('Phone normalization — no hardcoded region', () {
    test('explicit + country code is always preserved', () {
      for (final region in [null, 'US', 'IN', 'DE']) {
        final parser = LocalParser(region: region);
        final r = parser.parse(makeResult([
          block('Jane Doe', 100, 40, 24),
          block('+44 20 7946 0958', 100, 120, 12),
        ]));
        expect(r.phones.single, '+442079460958');
      }
    });

    test('bare national number uses the device region calling code', () {
      final us = LocalParser(region: 'US').parse(makeResult([
        block('Jane Doe', 100, 40, 24),
        block('(415) 555 2671', 100, 120, 12),
      ]));
      expect(us.phones.single, '+14155552671');

      final de = LocalParser(region: 'DE').parse(makeResult([
        block('Hans Müller', 100, 40, 24),
        block('030 123456', 100, 120, 12),
      ]));
      expect(de.phones.single, '+4930123456'); // trunk 0 dropped
    });

    test('unknown region leaves the number in national format, no guess', () {
      final r = LocalParser(region: null).parse(makeResult([
        block('Jane Doe', 100, 40, 24),
        block('98765 43210', 100, 120, 12),
      ]));
      expect(r.phones.single, '9876543210');
      expect(r.phones.single, isNot(startsWith('+91')));
    });
  });

  group('Address detection — structural, region-agnostic', () {
    test('US-style address is detected without any city list', () {
      final r = LocalParser(region: 'US').parse(makeResult([
        block('Jane Doe', 100, 40, 24),
        block('1600 Amphitheatre Parkway, Springfield, 94043', 100, 130, 10),
      ]));
      expect(r.address, contains('Amphitheatre Parkway'));
    });

    test('UK postcode line is detected', () {
      final r = LocalParser(region: 'GB').parse(makeResult([
        block('John Smith', 100, 40, 24),
        block('221B Baker Street, London NW1 6XE', 100, 130, 10),
      ]));
      expect(r.address, contains('Baker Street'));
    });

    test('a plain company tagline is not treated as an address', () {
      final r = LocalParser(region: 'US').parse(makeResult([
        block('Jane Doe', 100, 40, 24),
        block('Empowering teams to build better software', 100, 130, 10),
      ]));
      expect(r.address, isNull);
    });
  });
}
