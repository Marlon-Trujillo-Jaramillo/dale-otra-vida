import 'dart:math' as math;

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../common/geo.dart';
import '../generated/protocol.dart';

/// Endpoints for creating and browsing listings.
class ListingEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<MemberProfile> _currentProfile(Session session) async {
    final profile = await MemberProfile.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(session.authenticated!.authUserId),
    );

    if (profile == null) {
      throw ProfileRequiredException(
        message: 'Debes completar tu perfil para usar esta funcionalidad.',
      );
    }

    return profile;
  }

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

    final profile = await _currentProfile(session);
    final path = 'listings/${profile.id!}/${_uuidV4()}.$ext';
    final uploadDescription = await session.storage.createUploadDescription(
      storageId: 'public',
      path: path,
    );

    return PhotoUpload(path: path, uploadDescription: uploadDescription);
  }

  /// Verifies that a photo was successfully uploaded to the caller's folder.
  Future<bool> verifyPhotoUpload(Session session, String path) async {
    final profile = await _currentProfile(session);
    final prefix = 'listings/${profile.id!}/';

    if (!path.startsWith(prefix)) return false;

    return session.storage.verifyUpload(storageId: 'public', path: path);
  }

  /// Creates a new listing after validating and sanitizing the input.
  Future<ListingView> create(Session session, Listing listing) async {
    final profile = await _currentProfile(session);
    final callerId = profile.id!;
    final now = DateTime.now().toUtc();

    final title = listing.title.trim();
    final description = listing.description.trim();
    final neighborhood = listing.neighborhood.trim();

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
    if (photos.isEmpty || photos.length > 5) {
      throw ArgumentError('Debes subir entre 1 y 5 fotos.');
    }

    final prefix = 'listings/$callerId/';
    for (final path in photos) {
      if (!path.startsWith(prefix)) {
        throw ArgumentError('Foto con ruta inválida.');
      }
      final exists = await session.storage.fileExists(
        storageId: 'public',
        path: path,
      );
      if (!exists) {
        throw ArgumentError('Foto no encontrada en el almacenamiento.');
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

    final latitude = listing.latitude;
    final longitude = listing.longitude;
    if (latitude < -90 || latitude > 90) {
      throw ArgumentError('Latitud inválida.');
    }
    if (longitude < -180 || longitude > 180) {
      throw ArgumentError('Longitud inválida.');
    }

    final toInsert = Listing(
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
      latitude: roundCoordinate(latitude)!,
      longitude: roundCoordinate(longitude)!,
      safeMeetingPoint: listing.safeMeetingPoint?.trim(),
    );

    final created = await Listing.db.insertRow(session, toInsert);
    return _toView(session, created, profile);
  }

  /// Returns available listings, optionally filtered.
  Future<List<ListingView>> feed(
    Session session, {
    ListingType? type,
    Category? category,
    String? query,
    double? latitude,
    double? longitude,
    int limit = 20,
    int offset = 0,
  }) async {
    final profile = await _currentProfile(session);

    if (limit < 1 || limit > 50) {
      throw ArgumentError('limit debe estar entre 1 y 50.');
    }
    if (offset < 0) {
      throw ArgumentError('offset no puede ser negativo.');
    }

    final now = DateTime.now().toUtc();
    final q = query?.trim();

    final rows = await Listing.db.find(
      session,
      where: (t) {
        var expr = t.status.equals(ListingStatus.available);

        if (type != null) expr = expr & t.type.equals(type);
        if (category != null) expr = expr & t.category.equals(category);
        if (q != null && q.isNotEmpty) {
          expr = expr & (t.title.ilike('%$q%') | t.description.ilike('%$q%'));
        }

        expr =
            expr & (t.category.notEquals(Category.food) | (t.expiresAt > now));

        return expr;
      },
      orderByList: (t) => [t.createdAt.desc()],
      limit: limit,
      offset: offset,
    );

    return _toViews(
      session,
      rows,
      profile,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Returns a single listing by id, regardless of status.
  Future<ListingView?> byId(
    Session session,
    int id, {
    double? latitude,
    double? longitude,
  }) async {
    final profile = await _currentProfile(session);
    final listing = await Listing.db.findById(session, id);
    if (listing == null) return null;

    return _toView(
      session,
      listing,
      profile,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Returns the caller's listings, newest first.
  Future<List<ListingView>> mine(Session session) async {
    final profile = await _currentProfile(session);

    final rows = await Listing.db.find(
      session,
      where: (t) => t.ownerId.equals(profile.id!),
      orderByList: (t) => [t.createdAt.desc()],
    );

    return _toViews(session, rows, profile);
  }

  /// Updates the status of a listing owned by the caller.
  Future<ListingView> updateStatus(
    Session session,
    int id,
    ListingStatus status,
  ) async {
    final profile = await _currentProfile(session);
    final listing = await Listing.db.findById(session, id);

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
    final saved = await Listing.db.updateRow(session, updated);

    if (status == ListingStatus.delivered) {
      await MemberProfile.db.updateRow(
        session,
        profile.copyWith(deliveryCount: profile.deliveryCount + 1),
      );
    }

    return _toView(session, saved, profile);
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

  Future<ListingView> _toView(
    Session session,
    Listing listing,
    MemberProfile caller, {
    double? latitude,
    double? longitude,
  }) async {
    final owner = await MemberProfile.db.findById(session, listing.ownerId);
    final publicOwner = owner?.copyWith(latitude: null, longitude: null);

    double? distanceKm;
    if (latitude != null && longitude != null) {
      distanceKm = haversineKm(
        latitude,
        longitude,
        listing.latitude,
        listing.longitude,
      );
    }

    final photoUrls = await Future.wait(
      listing.photoUrls.map((path) async {
        final uri = await session.storage.publicDownloadUrl(
          storageId: 'public',
          path: path,
        );
        return uri.toString();
      }),
    );

    return ListingView(
      listing: listing.copyWith(photoUrls: photoUrls),
      owner: publicOwner!,
      distanceKm: distanceKm,
      isMine: listing.ownerId == caller.id,
    );
  }

  Future<List<ListingView>> _toViews(
    Session session,
    List<Listing> listings,
    MemberProfile caller, {
    double? latitude,
    double? longitude,
  }) async {
    final ownerIds = listings.map((l) => l.ownerId).toSet();
    final owners = ownerIds.isEmpty
        ? <MemberProfile>[]
        : await MemberProfile.db.find(
            session,
            where: (t) => t.id.inSet(ownerIds),
          );
    final ownerById = {
      for (final owner in owners)
        owner.id!: owner.copyWith(latitude: null, longitude: null),
    };

    return Future.wait(
      listings.map((listing) async {
        final photoUrls = await Future.wait(
          listing.photoUrls.map((path) async {
            final uri = await session.storage.publicDownloadUrl(
              storageId: 'public',
              path: path,
            );
            return uri.toString();
          }),
        );

        double? distanceKm;
        if (latitude != null && longitude != null) {
          distanceKm = haversineKm(
            latitude,
            longitude,
            listing.latitude,
            listing.longitude,
          );
        }

        return ListingView(
          listing: listing.copyWith(photoUrls: photoUrls),
          owner: ownerById[listing.ownerId]!,
          distanceKm: distanceKm,
          isMine: listing.ownerId == caller.id,
        );
      }),
    );
  }

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
