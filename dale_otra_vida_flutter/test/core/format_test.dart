import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:dale_otra_vida_flutter/core/format.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
    Intl.defaultLocale = 'es';
  });

  group('formatDistance', () {
    test('formats kilometers with one decimal', () {
      expect(formatDistance(0.8), 'a 0,8 km');
    });

    test('formats distances under 1 km as meters', () {
      expect(formatDistance(0.12), 'a 120 m');
    });

    test('formats long distances in kilometers', () {
      expect(formatDistance(120), 'a 120,0 km');
    });
  });

  group('formatCop', () {
    test('formats COP with space after symbol', () {
      expect(formatCop(25000), '\$ 25.000');
    });

    test('formats large amounts with thousand separators', () {
      expect(formatCop(1000000), '\$ 1.000.000');
    });
  });

  group('formatDate', () {
    test('formats date in Spanish as "d mmm y"', () {
      expect(formatDate(DateTime(2026, 10, 24)), '24 oct 2026');
    });

    test(
      'uses local timezone so a UTC 02:00 timestamp shows the previous day in UTC-5',
      () {
        final utc = DateTime.utc(2026, 10, 25, 2, 0);
        expect(formatDate(utc), '24 oct 2026');
      },
    );
  });

  group('conditionLabel', () {
    test('maps item conditions to Spanish labels', () {
      expect(conditionLabel(ItemCondition.asNew), 'Como nuevo');
      expect(conditionLabel(ItemCondition.good), 'Bueno');
      expect(conditionLabel(ItemCondition.used), 'Usado');
    });
  });

  group('initialsFor', () {
    test('returns first two initials for multi-word names', () {
      expect(initialsFor('María Rodríguez'), 'MR');
    });

    test('returns first initial for single-word names', () {
      expect(initialsFor('Pedro'), 'P');
    });

    test('falls back to "?" for empty names', () {
      expect(initialsFor(''), '?');
      expect(initialsFor(null), '?');
    });

    test('trims surrounding whitespace', () {
      expect(initialsFor('  Ana López  '), 'AL');
    });
  });
}
