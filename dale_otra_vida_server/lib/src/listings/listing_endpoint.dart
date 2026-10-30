import 'dart:math' as math;

import 'package:serverpod/serverpod.dart';

import '../chat/chat_messages.dart';
import '../common/current_profile.dart';
import '../common/geo.dart';
import '../generated/protocol.dart';
import '../notifications/notify.dart';
import 'listing_views.dart';

/// Endpoints for creating and browsing listings.
class ListingEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Validates that a photo path belongs to the given profile and has a
  /// server-generated UUID file name with an allowed extension.
  bool _isOwnPhotoPath(String path, int profileId) => RegExp(
    '^listings/$profileId/[0-9a-f-]{36}\\.(jpg|jpeg|png|webp)\$',
  ).hasMatch(path);

  /// Generates a server-side upload description for a new listing photo.
  Future<PhotoUpload> photoUploadDescription(
    Session session,
    String fileExtension,
  ) async {
    final ext = fileExtension.trim().toLowerCase();
    const allowedExtensions = {'jpg', 'jpeg', 'png', 'webp'};
    if (!allowedExtensions.contains(ext)) {
      throw ArgumentError.value(
        fileExtension,
        'fileExtension',
        'Extensión no permitida. Use jpg, jpeg, png o webp.',
      );
    }

    final profile = await currentProfile(session);
    final path = 'listings/${profile.id!}/${_uuidV4()}.$ext';
    final uploadDescription = await session.storage.createUploadDescription(
      storageId: 'public',
      path: path,
    );

    return PhotoUpload(path: path, uploadDescription: uploadDescription);
  }

  /// Verifies that a photo was successfully uploaded to the caller's folder.
  Future<bool> verifyPhotoUpload(Session session, String path) async {
    final profile = await currentProfile(session);

    if (!_isOwnPhotoPath(path, profile.id!)) return false;

    return session.storage.verifyUpload(storageId: 'public', path: path);
  }

  /// Creates a new listing after validating and sanitizing the input.
  Future<ListingView> create(Session session, Listing listing) async {
    final profile = await currentProfile(session);
    final toInsert = await _sanitized(session, listing, profile.id!);
    final created = await Listing.db.insertRow(session, toInsert);
    return toView(session, created, profile);
  }

  /// Edits the text, dates and price of one of the caller's open listings.
  /// Type, category, photos and status stay as they are.
  Future<ListingView> update(Session session, int id, Listing changes) async {
    final profile = await currentProfile(session);

    return await session.db.transaction((transaction) async {
      final listing = await Listing.db.findById(
        session,
        id,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (listing == null) {
        throw ArgumentError('Publicación no encontrada.');
      }
      if (listing.ownerId != profile.id!) {
        throw NotAllowedException(
          message: 'No eres el dueño de esta publicación.',
        );
      }
      if (listing.status != ListingStatus.available &&
          listing.status != ListingStatus.reserved) {
        throw NotAllowedException(
          message: 'Esta publicación ya no se puede editar.',
        );
      }

      final clean = await _sanitized(
        session,
        changes.copyWith(
          type: listing.type,
          category: listing.category,
          photoUrls: listing.photoUrls,
        ),
        profile.id!,
        checkPhotos: false,
      );

      final saved = await Listing.db.updateRow(
        session,
        listing.copyWith(
          title: clean.title,
          description: clean.description,
          condition: clean.condition,
          expiresAt: clean.expiresAt,
          price: clean.price,
          returnDate: clean.returnDate,
          wantedInExchange: clean.wantedInExchange,
          neighborhood: clean.neighborhood,
          latitude: clean.latitude,
          longitude: clean.longitude,
          safeMeetingPoint: clean.safeMeetingPoint,
          updatedAt: DateTime.now().toUtc(),
        ),
        transaction: transaction,
      );

      // A new expiry date earns a new "vence pronto" reminder.
      if (!_sameSecond(saved.expiresAt, listing.expiresAt)) {
        await AppNotification.db.deleteWhere(
          session,
          where: (t) =>
              t.userId.equals(profile.id!) &
              t.kind.equals(NotificationKind.listingExpiring) &
              t.refId.equals(id),
          transaction: transaction,
        );
      }

      return toView(session, saved, profile);
    });
  }

  /// Validates [listing] and returns a clean copy owned by [callerId].
  ///
  /// Photos are only checked when [checkPhotos] is true: edits keep the
  /// stored photos.
  Future<Listing> _sanitized(
    Session session,
    Listing listing,
    int callerId, {
    bool checkPhotos = true,
  }) async {
    final now = DateTime.now().toUtc();

    final title = listing.title.trim();
    final description = listing.description.trim();
    final neighborhood = listing.neighborhood.trim();

    var safeMeetingPoint = listing.safeMeetingPoint?.trim();
    if (safeMeetingPoint != null && safeMeetingPoint.length > 120) {
      throw ArgumentError(
        'El punto de encuentro no puede superar 120 caracteres.',
      );
    }
    if (safeMeetingPoint?.isEmpty ?? false) safeMeetingPoint = null;

    if (title.length < 3 || title.length > 80) {
      throw ArgumentError('El título debe tener entre 3 y 80 caracteres.');
    }
    if (description.length < 10 || description.length > 1000) {
      throw ArgumentError(
        'La descripción debe tener entre 10 y 1000 caracteres.',
      );
    }
    if (neighborhood.length < 2 || neighborhood.length > 60) {
      throw ArgumentError('El barrio debe tener entre 2 y 60 caracteres.');
    }

    final photos = listing.photoUrls;
    if (checkPhotos) {
      if (photos.isEmpty || photos.length > 5) {
        throw ArgumentError('Debes subir entre 1 y 5 fotos.');
      }

      final seenPaths = <String>{};
      for (final path in photos) {
        if (!_isOwnPhotoPath(path, callerId)) {
          throw ArgumentError('Foto con ruta inválida.');
        }
        if (!seenPaths.add(path)) {
          throw ArgumentError('Fotos duplicadas no permitidas.');
        }
        final exists = await session.storage.fileExists(
          storageId: 'public',
          path: path,
        );
        if (!exists) {
          throw ArgumentError('Foto no encontrada en el almacenamiento.');
        }
      }
    }

    if (listing.category == Category.food) {
      if (listing.expiresAt == null || !listing.expiresAt!.isAfter(now)) {
        throw ArgumentError(
          'La fecha de vencimiento es obligatoria y debe ser futura.',
        );
      }
    } else if (listing.expiresAt != null) {
      throw ArgumentError(
        'La fecha de vencimiento solo aplica a publicaciones de comida.',
      );
    }

    if (listing.type == ListingType.sell) {
      if (listing.price == null ||
          listing.price! < 1 ||
          listing.price! > 100000000) {
        throw ArgumentError(
          'El precio es obligatorio para ventas y debe estar entre 1 y 100000000.',
        );
      }
    } else if (listing.price != null) {
      throw ArgumentError('El precio solo aplica a ventas.');
    }

    if (listing.type == ListingType.lend) {
      if (listing.returnDate == null || !listing.returnDate!.isAfter(now)) {
        throw ArgumentError(
          'La fecha de devolución es obligatoria y debe ser futura.',
        );
      }
    } else if (listing.returnDate != null) {
      throw ArgumentError(
        'La fecha de devolución solo aplica a préstamos.',
      );
    }

    if (listing.type == ListingType.exchange) {
      final wanted = listing.wantedInExchange?.trim() ?? '';
      if (wanted.length < 3 || wanted.length > 200) {
        throw ArgumentError(
          'Debes indicar qué deseas a cambio (3-200 caracteres).',
        );
      }
    } else if (listing.wantedInExchange != null) {
      throw ArgumentError(
        'El campo "qué deseas a cambio" solo aplica a intercambios.',
      );
    }

    if (!isValidCoordinate(listing.latitude, listing.longitude)) {
      throw ArgumentError('Coordenadas inválidas.');
    }

    return Listing(
      ownerId: callerId,
      title: title,
      description: description,
      type: listing.type,
      category: listing.category,
      condition: listing.condition,
      status: ListingStatus.available,
      photoUrls: photos,
      expiresAt: listing.category == Category.food ? listing.expiresAt : null,
      price: listing.type == ListingType.sell ? listing.price : null,
      returnDate: listing.type == ListingType.lend ? listing.returnDate : null,
      wantedInExchange: listing.type == ListingType.exchange
          ? listing.wantedInExchange!.trim()
          : null,
      neighborhood: neighborhood,
      latitude: roundCoordinate(listing.latitude)!,
      longitude: roundCoordinate(listing.longitude)!,
      safeMeetingPoint: safeMeetingPoint,
    );
  }

  /// Returns available listings, optionally filtered.
  ///
  /// With [nearest] and valid coordinates the closest listings come first
  /// (among the newest 300 matches); otherwise the newest come first.
  Future<List<ListingView>> feed(
    Session session, {
    ListingType? type,
    Category? category,
    String? query,
    double? latitude,
    double? longitude,
    bool? nearest,
    int limit = 20,
    int offset = 0,
  }) async {
    final profile = await currentProfile(session);

    limit = limit.clamp(1, 50);
    offset = math.max(0, offset);

    var q = query?.trim();
    if (q != null && q.length > 80) {
      q = q.substring(0, 80);
    }

    final hasValidCoords =
        latitude != null &&
        longitude != null &&
        isValidCoordinate(latitude, longitude);
    final lat = hasValidCoords ? latitude : null;
    final lng = hasValidCoords ? longitude : null;
    final byDistance = nearest == true && lat != null && lng != null;

    final rows = await Listing.db.find(
      session,
      where: (t) => _visibleWhere(t, type: type, category: category, query: q),
      orderByList: (t) => [t.createdAt.desc(), t.id.desc()],
      limit: byDistance ? 300 : limit,
      offset: byDistance ? 0 : offset,
    );

    var page = rows;
    if (byDistance) {
      // Rounded locations tie often, so the id keeps pages stable.
      final distanceById = {
        for (final row in rows)
          row.id!: haversineKm(lat, lng, row.latitude, row.longitude),
      };
      final sorted = [...rows]
        ..sort((a, b) {
          final byKm = distanceById[a.id]!.compareTo(distanceById[b.id]!);
          return byKm != 0 ? byKm : a.id!.compareTo(b.id!);
        });
      page = sorted.skip(offset).take(limit).toList();
    }

    return toViews(session, page, profile, latitude: lat, longitude: lng);
  }

  /// Available listings inside a map area, at most 200, newest first.
  Future<List<ListingView>> inArea(
    Session session, {
    required double south,
    required double west,
    required double north,
    required double east,
    ListingType? type,
    Category? category,
    double? latitude,
    double? longitude,
  }) async {
    final profile = await currentProfile(session);

    if (!isValidCoordinate(south, west) ||
        !isValidCoordinate(north, east) ||
        south >= north ||
        west >= east) {
      throw ArgumentError('Área inválida.');
    }
    if (north - south > 2 || east - west > 2) {
      throw NotAllowedException(
        message: 'Acerca el mapa para ver las publicaciones.',
      );
    }

    final rows = await Listing.db.find(
      session,
      where: (t) =>
          _visibleWhere(t, type: type, category: category) &
          (t.latitude >= south) &
          (t.latitude <= north) &
          (t.longitude >= west) &
          (t.longitude <= east),
      orderByList: (t) => [t.createdAt.desc(), t.id.desc()],
      limit: 200,
    );

    final hasValidCoords =
        latitude != null &&
        longitude != null &&
        isValidCoordinate(latitude, longitude);
    return toViews(
      session,
      rows,
      profile,
      latitude: hasValidCoords ? latitude : null,
      longitude: hasValidCoords ? longitude : null,
    );
  }

  /// Listings the feed and the map show: available and, for food, not
  /// expired.
  Expression _visibleWhere(
    ListingTable t, {
    ListingType? type,
    Category? category,
    String? query,
  }) {
    final now = DateTime.now().toUtc();
    var expr = t.status.equals(ListingStatus.available);

    if (type != null) expr = expr & t.type.equals(type);
    if (category != null) expr = expr & t.category.equals(category);
    if (query != null && query.isNotEmpty) {
      final escaped = _escapeLikePattern(query);
      expr =
          expr &
          (t.title.ilike('%$escaped%') | t.description.ilike('%$escaped%'));
    }

    return expr & (t.category.notEquals(Category.food) | (t.expiresAt > now));
  }

  /// Returns a single listing by id, regardless of status.
  Future<ListingView?> byId(
    Session session,
    int id, {
    double? latitude,
    double? longitude,
  }) async {
    final profile = await currentProfile(session);
    final listing = await Listing.db.findById(session, id);
    if (listing == null) return null;

    final hasValidCoords =
        latitude != null &&
        longitude != null &&
        isValidCoordinate(latitude, longitude);

    return toView(
      session,
      listing,
      profile,
      latitude: hasValidCoords ? latitude : null,
      longitude: hasValidCoords ? longitude : null,
    );
  }

  /// Returns the caller's listings, newest first.
  Future<List<ListingView>> mine(Session session) async {
    final profile = await currentProfile(session);

    final rows = await Listing.db.find(
      session,
      where: (t) => t.ownerId.equals(profile.id!),
      orderByList: (t) => [t.createdAt.desc(), t.id.desc()],
    );

    return toViews(session, rows, profile);
  }

  /// Updates the status of a listing owned by the caller.
  Future<ListingView> updateStatus(
    Session session,
    int id,
    ListingStatus status,
  ) async {
    final profile = await currentProfile(session);

    final toPublish = <(Conversation, ChatMessage)>[];
    final result = await session.db.transaction((transaction) async {
      // Lock the listing row so concurrent mutations serialize on it.
      final listing = await Listing.db.findById(
        session,
        id,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );

      if (listing == null) {
        throw ArgumentError('Publicación no encontrada.');
      }
      if (listing.ownerId != profile.id!) {
        throw NotAllowedException(
          message: 'No eres el dueño de esta publicación.',
        );
      }

      final current = listing.status;
      final valid = _isValidStatusTransition(current, status);
      if (!valid) {
        throw ArgumentError('Transición de estado inválida.');
      }

      final now = DateTime.now().toUtc();
      final updated = listing.copyWith(
        status: status,
        updatedAt: now,
      );
      final saved = await Listing.db.updateRow(
        session,
        updated,
        transaction: transaction,
      );

      if (status == ListingStatus.delivered) {
        final ownerProfile = await MemberProfile.db.findById(
          session,
          profile.id!,
          transaction: transaction,
          lockMode: LockMode.forUpdate,
        );
        if (ownerProfile != null) {
          await MemberProfile.db.updateRow(
            session,
            ownerProfile.copyWith(
              deliveryCount: ownerProfile.deliveryCount + 1,
            ),
            columns: (t) => [t.deliveryCount],
            transaction: transaction,
          );
        }

        // Tell the receiver and invite both sides to rate each other.
        final accepted = await ListingRequest.db.findFirstRow(
          session,
          where: (t) =>
              t.listingId.equals(listing.id!) &
              t.status.equals(RequestStatus.accepted),
          transaction: transaction,
        );
        if (accepted != null) {
          await notify(
            session,
            userId: accepted.requesterId,
            kind: NotificationKind.deliveryCompleted,
            title: '¡Entrega completada!',
            body: 'Califica a ${profile.displayName} por «${listing.title}».',
            refId: listing.id,
            transaction: transaction,
          );
          final conversation = await Conversation.db.findFirstRow(
            session,
            where: (t) =>
                t.listingId.equals(listing.id!) &
                t.requesterId.equals(accepted.requesterId),
            transaction: transaction,
          );
          if (conversation != null) {
            final message = await insertChatMessage(
              session,
              conversation,
              kind: MessageKind.system,
              text:
                  'Entrega completada. ¡Gracias por darle otra vida! '
                  'Califiquen su experiencia.',
              transaction: transaction,
            );
            toPublish.add((conversation, message));
          }
        }
      }

      // Returning a reserved listing to the feed cancels the accepted
      // request so the owner is free to pick someone else.
      if (status == ListingStatus.available &&
          current == ListingStatus.reserved) {
        final accepted = await ListingRequest.db.findFirstRow(
          session,
          where: (t) =>
              t.listingId.equals(listing.id!) &
              t.status.equals(RequestStatus.accepted),
          transaction: transaction,
        );
        if (accepted != null) {
          await ListingRequest.db.updateRow(
            session,
            accepted.copyWith(status: RequestStatus.cancelled),
            transaction: transaction,
          );

          await notify(
            session,
            userId: accepted.requesterId,
            kind: NotificationKind.requestCancelled,
            title: 'Reserva cancelada',
            body: 'El dueño volvió a publicar «${listing.title}».',
            refId: listing.id,
            transaction: transaction,
          );
        }
      }

      // Withdrawing a listing cancels every open request on it.
      if (status == ListingStatus.withdrawn) {
        final open = await ListingRequest.db.find(
          session,
          where: (t) =>
              t.listingId.equals(listing.id!) &
              (t.status.equals(RequestStatus.pending) |
                  t.status.equals(RequestStatus.accepted)),
          transaction: transaction,
        );
        for (final request in open) {
          await ListingRequest.db.updateRow(
            session,
            request.copyWith(status: RequestStatus.cancelled),
            transaction: transaction,
          );
        }
      }

      return toView(session, saved, profile);
    });

    for (final (conversation, message) in toPublish) {
      await publishChatMessage(session, conversation, message);
    }
    return result;
  }

  /// Dates round-trip through clients with less precision than Postgres.
  bool _sameSecond(DateTime? a, DateTime? b) {
    if (a == null || b == null) return a == b;
    return a.millisecondsSinceEpoch ~/ 1000 == b.millisecondsSinceEpoch ~/ 1000;
  }

  bool _isValidStatusTransition(ListingStatus from, ListingStatus to) {
    if (from == ListingStatus.available && to == ListingStatus.reserved) {
      return true;
    }
    if (from == ListingStatus.reserved && to == ListingStatus.available) {
      return true;
    }
    if (from == ListingStatus.reserved && to == ListingStatus.delivered) {
      return true;
    }
    if ((from == ListingStatus.available || from == ListingStatus.reserved) &&
        to == ListingStatus.withdrawn) {
      return true;
    }
    return false;
  }

  String _escapeLikePattern(String value) => value
      .replaceAll('\\', '\\\\')
      .replaceAll('%', '\\%')
      .replaceAll('_', '\\_');

  String _uuidV4() {
    final random = math.Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0F) | 0x40;
    bytes[8] = (bytes[8] & 0x3F) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }
}
