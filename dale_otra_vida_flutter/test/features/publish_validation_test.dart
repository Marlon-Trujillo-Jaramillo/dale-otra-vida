import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:dale_otra_vida_flutter/features/publish/listing_draft.dart';
import 'package:dale_otra_vida_flutter/features/publish/publish_screen.dart';
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

  test('rejects draft with more than 5 photos', () {
    final draft = validDraft().copyWith(
      photos: const [
        '1.jpg',
        '2.jpg',
        '3.jpg',
        '4.jpg',
        '5.jpg',
        '6.jpg',
      ],
    );
    expect(validateListingDraft(draft), contains('5'));
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

    test('rejects today expiry date', () {
      final draft = validDraft().copyWith(
        category: Category.food,
        expiresAt: DateTime.now(),
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

    test('rejects price above 100000000', () {
      final draft = validDraft().copyWith(
        type: ListingType.sell,
        price: 100000001,
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

    test('rejects today return date', () {
      final draft = validDraft().copyWith(
        type: ListingType.lend,
        returnDate: DateTime.now(),
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

    test('rejects wanted item shorter than 3 characters', () {
      final draft = validDraft().copyWith(
        type: ListingType.exchange,
        wantedInExchange: 'AB',
      );
      expect(validateListingDraft(draft), contains('cambio'));
    });

    test('rejects wanted item longer than 200 characters', () {
      final draft = validDraft().copyWith(
        type: ListingType.exchange,
        wantedInExchange: 'A' * 201,
      );
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

  group('neighborhood', () {
    test('rejects empty neighborhood', () {
      final draft = validDraft().copyWith(neighborhood: '');
      expect(validateListingDraft(draft), contains('barrio'));
    });

    test('rejects neighborhood shorter than 2 characters', () {
      final draft = validDraft().copyWith(neighborhood: 'A');
      expect(validateListingDraft(draft), contains('barrio'));
    });

    test('rejects neighborhood longer than 60 characters', () {
      final draft = validDraft().copyWith(neighborhood: 'A' * 61);
      expect(validateListingDraft(draft), contains('barrio'));
    });
  });

  group('safe meeting point', () {
    test('rejects meeting point longer than 120 characters', () {
      final draft = validDraft().copyWith(safeMeetingPoint: 'A' * 121);
      expect(
        validateListingDraft(draft),
        contains('punto de encuentro'),
      );
    });

    test('accepts empty meeting point', () {
      final draft = validDraft().copyWith(safeMeetingPoint: '');
      expect(validateListingDraft(draft), isNull);
    });
  });

  test('rejects draft without location', () {
    final draft = validDraft().copyWith(latitude: null, longitude: null);
    expect(validateListingDraft(draft), contains('ubicación'));
  });

  group('toListing', () {
    test('drops price when switching from sell to donate', () {
      final draft = validDraft()
          .copyWith(type: ListingType.sell, price: 25000)
          .copyWith(type: ListingType.donate);
      final listing = draft.toListing(ownerId: 1);
      expect(listing.price, isNull);
      expect(listing.type, ListingType.donate);
    });

    test('drops return date when switching from lend to sell', () {
      final draft = validDraft()
          .copyWith(
            type: ListingType.lend,
            returnDate: DateTime.now().add(const Duration(days: 5)),
          )
          .copyWith(type: ListingType.sell);
      final listing = draft.toListing(ownerId: 1);
      expect(listing.returnDate, isNull);
      expect(listing.type, ListingType.sell);
    });

    test('drops wanted in exchange when switching from exchange to donate', () {
      final draft = validDraft()
          .copyWith(
            type: ListingType.exchange,
            wantedInExchange: 'Una planta',
          )
          .copyWith(type: ListingType.donate);
      final listing = draft.toListing(ownerId: 1);
      expect(listing.wantedInExchange, isNull);
      expect(listing.type, ListingType.donate);
    });

    test('drops expiry when switching from food to books', () {
      final draft = validDraft()
          .copyWith(
            category: Category.food,
            expiresAt: DateTime.now().add(const Duration(days: 5)),
          )
          .copyWith(category: Category.books);
      final listing = draft.toListing(ownerId: 1);
      expect(listing.expiresAt, isNull);
      expect(listing.category, Category.books);
    });

    test('keeps conditional fields when type/category match', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final draft = validDraft().copyWith(
        type: ListingType.sell,
        price: 50000,
        category: Category.food,
        expiresAt: tomorrow,
      );
      final listing = draft.toListing(ownerId: 1);
      expect(listing.price, 50000);
      expect(listing.expiresAt, tomorrow);
    });
  });

  group('CopInputFormatter', () {
    final formatter = CopInputFormatter();

    test('formats digits as COP', () {
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '25000'),
      );
      expect(result.text, '25.000');
    });

    test('caps at 9 digits', () {
      final oldValue = TextEditingValue.empty;
      final result = formatter.formatEditUpdate(
        oldValue,
        const TextEditingValue(text: '1234567890'),
      );
      expect(result.text, oldValue.text);
    });

    test('returns empty when no digits remain', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: '25.000'),
        const TextEditingValue(text: ''),
      );
      expect(result.text, '');
    });

    test('does not throw on invalid input', () {
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: 'abc'),
      );
      expect(result.text, '');
    });
  });
}
