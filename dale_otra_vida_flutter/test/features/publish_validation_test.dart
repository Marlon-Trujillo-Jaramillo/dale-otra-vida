import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:dale_otra_vida_flutter/features/publish/listing_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ListingDraft validDraft() => ListingDraft(
    photos: const ['photos/one.jpg'],
    type: ListingType.donate,
    category: Category.books,
    title: 'Libro de Flutter',
    description: 'Un libro en buen estado con varios ejemplos de código.',
    condition: ItemCondition.good,
    neighborhood: 'Laureles',
    latitude: 6.2,
    longitude: -75.5,
  );

  test('valid draft passes validation', () {
    expect(validateListingDraft(validDraft()), isNull);
  });

  test('rejects draft without photos', () {
    final draft = validDraft().copyWith(photos: const []);
    expect(validateListingDraft(draft), contains('foto'));
  });

  test('rejects draft without type', () {
    final draft = validDraft().copyWith(type: null);
    expect(validateListingDraft(draft), contains('qué quieres'));
  });

  test('rejects draft without category', () {
    final draft = validDraft().copyWith(category: null);
    expect(validateListingDraft(draft), contains('categoría'));
  });

  test('rejects title shorter than 3 characters', () {
    final draft = validDraft().copyWith(title: 'Ab');
    expect(validateListingDraft(draft), contains('título'));
  });

  test('rejects title longer than 80 characters', () {
    final draft = validDraft().copyWith(title: 'A' * 81);
    expect(validateListingDraft(draft), contains('título'));
  });

  test('rejects description shorter than 10 characters', () {
    final draft = validDraft().copyWith(description: 'Corta');
    expect(validateListingDraft(draft), contains('descripción'));
  });

  test('rejects description longer than 1000 characters', () {
    final draft = validDraft().copyWith(description: 'A' * 1001);
    expect(validateListingDraft(draft), contains('descripción'));
  });

  test('rejects draft without condition', () {
    final draft = validDraft().copyWith(condition: null);
    expect(validateListingDraft(draft), contains('estado'));
  });

  group('food category', () {
    test('requires expiry date', () {
      final draft = validDraft().copyWith(category: Category.food);
      expect(validateListingDraft(draft), contains('vencimiento'));
    });

    test('rejects past expiry date', () {
      final draft = validDraft().copyWith(
        category: Category.food,
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(validateListingDraft(draft), contains('futura'));
    });

    test('accepts future expiry date', () {
      final draft = validDraft().copyWith(
        category: Category.food,
        expiresAt: DateTime.now().add(const Duration(days: 5)),
      );
      expect(validateListingDraft(draft), isNull);
    });
  });

  group('sell type', () {
    test('requires a price', () {
      final draft = validDraft().copyWith(type: ListingType.sell);
      expect(validateListingDraft(draft), contains('precio'));
    });

    test('rejects non-positive price', () {
      final draft = validDraft().copyWith(
        type: ListingType.sell,
        price: 0,
      );
      expect(validateListingDraft(draft), contains('precio'));
    });

    test('accepts positive price', () {
      final draft = validDraft().copyWith(
        type: ListingType.sell,
        price: 25000,
      );
      expect(validateListingDraft(draft), isNull);
    });
  });

  group('lend type', () {
    test('requires return date', () {
      final draft = validDraft().copyWith(type: ListingType.lend);
      expect(validateListingDraft(draft), contains('devolución'));
    });

    test('rejects past return date', () {
      final draft = validDraft().copyWith(
        type: ListingType.lend,
        returnDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(validateListingDraft(draft), contains('futura'));
    });

    test('accepts future return date', () {
      final draft = validDraft().copyWith(
        type: ListingType.lend,
        returnDate: DateTime.now().add(const Duration(days: 5)),
      );
      expect(validateListingDraft(draft), isNull);
    });
  });

  group('exchange type', () {
    test('requires wanted item', () {
      final draft = validDraft().copyWith(type: ListingType.exchange);
      expect(validateListingDraft(draft), contains('cambio'));
    });

    test('accepts wanted item', () {
      final draft = validDraft().copyWith(
        type: ListingType.exchange,
        wantedInExchange: 'Una planta',
      );
      expect(validateListingDraft(draft), isNull);
    });
  });

  test('rejects empty neighborhood', () {
    final draft = validDraft().copyWith(neighborhood: '');
    expect(validateListingDraft(draft), contains('barrio'));
  });

  test('rejects draft without location', () {
    final draft = validDraft().copyWith(latitude: null, longitude: null);
    expect(validateListingDraft(draft), contains('ubicación'));
  });
}
