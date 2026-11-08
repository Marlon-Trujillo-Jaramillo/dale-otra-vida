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
    this.depositAmount,
    this.lateFeePerDay,
    this.loanConditions = '',
    this.wantedInExchange = '',
    this.neighborhood = '',
    this.safeMeetingPoint = '',
    this.latitude,
    this.longitude,
  });

  /// Prefills a draft from an existing listing for editing.
  factory ListingDraft.fromListing(Listing listing) => ListingDraft(
    photos: listing.photoUrls,
    type: listing.type,
    category: listing.category,
    title: listing.title,
    description: listing.description,
    condition: listing.condition,
    expiresAt: listing.expiresAt?.toLocal(),
    price: listing.price,
    returnDate: listing.returnDate?.toLocal(),
    depositAmount: listing.depositAmount,
    lateFeePerDay: listing.lateFeePerDay,
    loanConditions: listing.loanConditions ?? '',
    wantedInExchange: listing.wantedInExchange ?? '',
    neighborhood: listing.neighborhood,
    safeMeetingPoint: listing.safeMeetingPoint ?? '',
    latitude: listing.latitude,
    longitude: listing.longitude,
  );

  final List<String> photos;
  final ListingType? type;
  final Category? category;
  final String title;
  final String description;
  final ItemCondition? condition;
  final DateTime? expiresAt;
  final int? price;
  final DateTime? returnDate;

  /// Loans: refundable guarantee in COP (optional).
  final int? depositAmount;

  /// Loans: agreed charge in COP per day late (optional).
  final int? lateFeePerDay;

  /// Loans: conditions of use (optional).
  final String loanConditions;
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
    Object? depositAmount = _sentinel,
    Object? lateFeePerDay = _sentinel,
    String? loanConditions,
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
      depositAmount: depositAmount == _sentinel
          ? this.depositAmount
          : depositAmount as int?,
      lateFeePerDay: lateFeePerDay == _sentinel
          ? this.lateFeePerDay
          : lateFeePerDay as int?,
      loanConditions: loanConditions ?? this.loanConditions,
      wantedInExchange: wantedInExchange ?? this.wantedInExchange,
      neighborhood: neighborhood ?? this.neighborhood,
      safeMeetingPoint: safeMeetingPoint ?? this.safeMeetingPoint,
      latitude: latitude == _sentinel ? this.latitude : latitude as double?,
      longitude: longitude == _sentinel ? this.longitude : longitude as double?,
    );
  }

  Listing toListing({required int ownerId}) {
    return Listing(
      ownerId: ownerId,
      title: title.trim(),
      description: description.trim(),
      type: type!,
      category: category!,
      condition: condition!,
      photoUrls: photos,
      neighborhood: neighborhood.trim(),
      latitude: latitude!,
      longitude: longitude!,
      safeMeetingPoint: safeMeetingPoint.trim().isEmpty
          ? null
          : safeMeetingPoint.trim(),
      expiresAt: category == Category.food ? expiresAt : null,
      price: type == ListingType.sell ? price : null,
      returnDate: type == ListingType.lend ? returnDate : null,
      depositAmount: type == ListingType.lend ? depositAmount : null,
      lateFeePerDay: type == ListingType.lend ? lateFeePerDay : null,
      loanConditions:
          type == ListingType.lend && loanConditions.trim().isNotEmpty
          ? loanConditions.trim()
          : null,
      wantedInExchange: type == ListingType.exchange
          ? (wantedInExchange.trim().isEmpty ? null : wantedInExchange.trim())
          : null,
    );
  }
}

/// The longest loan the server accepts.
const maxLoanDays = 30;

String? validateListingDraft(ListingDraft draft) {
  if (draft.photos.isEmpty) {
    return 'Agrega al menos una foto.';
  }
  if (draft.photos.length > 5) {
    return 'No puedes subir más de 5 fotos.';
  }
  if (draft.type == null) {
    return 'Selecciona qué quieres hacer.';
  }
  if (draft.category == null) {
    return 'Selecciona una categoría.';
  }
  final title = draft.title.trim();
  if (title.length < 3 || title.length > 80) {
    return 'El título debe tener entre 3 y 80 caracteres.';
  }
  final description = draft.description.trim();
  if (description.length < 10 || description.length > 1000) {
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
    if (!expiry.isAfter(today)) {
      return 'La fecha de vencimiento debe ser futura.';
    }
  }

  if (draft.type == ListingType.sell) {
    if (draft.price == null || draft.price! < 1 || draft.price! > 100000000) {
      return 'Ingresa un precio entre \$1 y \$100.000.000.';
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
    if (!returnDay.isAfter(today)) {
      return 'La fecha de devolución debe ser futura.';
    }
    if (returnDay.isAfter(today.add(const Duration(days: maxLoanDays)))) {
      return 'Un préstamo puede durar como máximo $maxLoanDays días.';
    }
    final deposit = draft.depositAmount;
    if (deposit != null && (deposit < 1000 || deposit > 10000000)) {
      return 'La garantía debe estar entre \$1.000 y \$10.000.000.';
    }
    final fee = draft.lateFeePerDay;
    if (fee != null) {
      if (fee < 500 || fee > 1000000) {
        return 'El recargo por día debe estar entre \$500 y \$1.000.000.';
      }
      if (deposit != null && fee > deposit) {
        return 'El recargo por día no puede superar la garantía.';
      }
    }
    if (draft.loanConditions.trim().length > 300) {
      return 'Las condiciones no pueden superar 300 caracteres.';
    }
  }

  if (draft.type == ListingType.exchange) {
    final wanted = draft.wantedInExchange.trim();
    if (wanted.length < 3 || wanted.length > 200) {
      return 'Describe qué te gustaría recibir a cambio (3 a 200 caracteres).';
    }
  }

  final neighborhood = draft.neighborhood.trim();
  if (neighborhood.length < 2 || neighborhood.length > 60) {
    return 'El barrio debe tener entre 2 y 60 caracteres.';
  }

  final meetingPoint = draft.safeMeetingPoint.trim();
  if (meetingPoint.length > 120) {
    return 'El punto de encuentro no puede superar 120 caracteres.';
  }

  if (draft.latitude == null || draft.longitude == null) {
    return 'Elige la zona en el mapa o usa tu ubicación.';
  }

  return null;
}
