import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';

class _Sentinel {
  const _Sentinel();
}

const _sentinel = _Sentinel();

class ListingDraft {
  ListingDraft({
    this.photos = const [],
    this.type,
    this.category,
    this.title = '',
    this.description = '',
    this.condition,
    this.expiresAt,
    this.price,
    this.returnDate,
    this.wantedInExchange = '',
    this.neighborhood = '',
    this.safeMeetingPoint = '',
    this.latitude,
    this.longitude,
  });

  final List<String> photos;
  final ListingType? type;
  final Category? category;
  final String title;
  final String description;
  final ItemCondition? condition;
  final DateTime? expiresAt;
  final int? price;
  final DateTime? returnDate;
  final String wantedInExchange;
  final String neighborhood;
  final String safeMeetingPoint;
  final double? latitude;
  final double? longitude;

  ListingDraft copyWith({
    List<String>? photos,
    Object? type = _sentinel,
    Object? category = _sentinel,
    String? title,
    String? description,
    Object? condition = _sentinel,
    Object? expiresAt = _sentinel,
    Object? price = _sentinel,
    Object? returnDate = _sentinel,
    String? wantedInExchange,
    String? neighborhood,
    String? safeMeetingPoint,
    Object? latitude = _sentinel,
    Object? longitude = _sentinel,
  }) {
    return ListingDraft(
      photos: photos ?? this.photos,
      type: type == _sentinel ? this.type : type as ListingType?,
      category: category == _sentinel ? this.category : category as Category?,
      title: title ?? this.title,
      description: description ?? this.description,
      condition: condition == _sentinel
          ? this.condition
          : condition as ItemCondition?,
      expiresAt: expiresAt == _sentinel
          ? this.expiresAt
          : expiresAt as DateTime?,
      price: price == _sentinel ? this.price : price as int?,
      returnDate: returnDate == _sentinel
          ? this.returnDate
          : returnDate as DateTime?,
      wantedInExchange: wantedInExchange ?? this.wantedInExchange,
      neighborhood: neighborhood ?? this.neighborhood,
      safeMeetingPoint: safeMeetingPoint ?? this.safeMeetingPoint,
      latitude: latitude == _sentinel ? this.latitude : latitude as double?,
      longitude: longitude == _sentinel ? this.longitude : longitude as double?,
    );
  }
}

String? validateListingDraft(ListingDraft draft) {
  if (draft.photos.isEmpty) {
    return 'Agrega al menos una foto.';
  }
  if (draft.type == null) {
    return 'Selecciona qué quieres hacer.';
  }
  if (draft.category == null) {
    return 'Selecciona una categoría.';
  }
  if (draft.title.trim().length < 3 || draft.title.trim().length > 80) {
    return 'El título debe tener entre 3 y 80 caracteres.';
  }
  if (draft.description.trim().length < 10 ||
      draft.description.trim().length > 1000) {
    return 'La descripción debe tener entre 10 y 1000 caracteres.';
  }
  if (draft.condition == null) {
    return 'Selecciona el estado del artículo.';
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  if (draft.category == Category.food) {
    if (draft.expiresAt == null) {
      return 'Selecciona la fecha de vencimiento.';
    }
    final expiry = DateTime(
      draft.expiresAt!.year,
      draft.expiresAt!.month,
      draft.expiresAt!.day,
    );
    if (expiry.isBefore(today)) {
      return 'La fecha de vencimiento debe ser futura.';
    }
  }

  if (draft.type == ListingType.sell) {
    if (draft.price == null || draft.price! <= 0) {
      return 'Ingresa un precio válido.';
    }
  }

  if (draft.type == ListingType.lend) {
    if (draft.returnDate == null) {
      return 'Selecciona la fecha de devolución.';
    }
    final returnDay = DateTime(
      draft.returnDate!.year,
      draft.returnDate!.month,
      draft.returnDate!.day,
    );
    if (returnDay.isBefore(today)) {
      return 'La fecha de devolución debe ser futura.';
    }
  }

  if (draft.type == ListingType.exchange) {
    if (draft.wantedInExchange.trim().length < 3) {
      return 'Describe qué te gustaría recibir a cambio.';
    }
  }

  if (draft.neighborhood.trim().isEmpty) {
    return 'Ingresa el barrio.';
  }

  if (draft.latitude == null || draft.longitude == null) {
    return 'Activa la ubicación para publicar.';
  }

  return null;
}
