import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../common/geo.dart';
import '../common/current_profile.dart';
import '../common/uuid.dart';
import '../listings/listing_views.dart';
import '../reviews/review_endpoint.dart';
import '../generated/protocol.dart';

/// Profile of the signed-in member. Created right after the first sign-in.
class ProfileEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Returns the signed-in member's profile, or null if they have not
  /// completed onboarding yet.
  Future<MemberProfile?> me(Session session) async {
    return MemberProfile.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(session.authenticated!.authUserId),
    );
  }

  /// Creates or updates the signed-in member's profile.
  ///
  /// Coordinates are rounded to ~100 m so an exact address is never stored.
  Future<MemberProfile> saveMe(
    Session session, {
    required String displayName,
    String? neighborhood,
    double? latitude,
    double? longitude,
    AccountType? accountType,
  }) async {
    final name = _validName(displayName);

    if (latitude != null || longitude != null) {
      if (latitude == null ||
          longitude == null ||
          !isValidCoordinate(latitude, longitude)) {
        throw ArgumentError.value(
          null,
          'latitude/longitude',
          'Ambas coordenadas deben estar presentes y ser válidas.',
        );
      }
    }

    var neighborhoodTrimmed = neighborhood?.trim();
    if (neighborhoodTrimmed != null && neighborhoodTrimmed.length > 60) {
      throw ArgumentError.value(
        neighborhood,
        'neighborhood',
        'El barrio no puede superar 60 caracteres.',
      );
    }
    if (neighborhoodTrimmed?.isEmpty ?? false) neighborhoodTrimmed = null;

    final existing = await me(session);
    final profile =
        (existing ??
                MemberProfile(
                  authUserId: session.authenticated!.authUserId,
                  displayName: name,
                ))
            .copyWith(
              displayName: name,
              neighborhood: neighborhoodTrimmed,
              latitude: roundCoordinate(latitude),
              longitude: roundCoordinate(longitude),
              accountType: accountType,
            );

    return existing == null
        ? MemberProfile.db.insertRow(session, profile)
        : MemberProfile.db.updateRow(session, profile);
  }

  /// Edits the caller's name, neighborhood and account type, keeping the
  /// stored location and photo.
  Future<MemberProfile> updateMe(
    Session session, {
    required String displayName,
    String? neighborhood,
    AccountType? accountType,
  }) async {
    final profile = await currentProfile(session);
    var hood = neighborhood?.trim();
    if (hood != null && hood.length > 60) {
      throw NotAllowedException(
        message: 'El barrio no puede superar 60 caracteres.',
      );
    }
    if (hood?.isEmpty ?? false) hood = null;

    return MemberProfile.db.updateRow(
      session,
      profile.copyWith(
        displayName: _validName(displayName),
        neighborhood: hood,
        accountType: accountType ?? profile.accountType,
      ),
      columns: (t) => [t.displayName, t.neighborhood, t.accountType],
    );
  }

  /// Where the app uploads a new profile photo.
  Future<PhotoUpload> avatarUploadDescription(
    Session session,
    String fileExtension,
  ) async {
    final ext = fileExtension.trim().toLowerCase();
    if (!const {'jpg', 'jpeg', 'png', 'webp'}.contains(ext)) {
      throw NotAllowedException(
        message: 'Usa una imagen jpg, png o webp.',
      );
    }
    final profile = await currentProfile(session);
    final path = 'avatars/${profile.id}/${uuidV4()}.$ext';
    final description = await session.storage.createUploadDescription(
      storageId: 'public',
      path: path,
    );
    return PhotoUpload(path: path, uploadDescription: description);
  }

  /// Sets the uploaded photo at [path] as the caller's avatar, or removes
  /// the avatar when [path] is null.
  Future<MemberProfile> setAvatar(Session session, String? path) async {
    final profile = await currentProfile(session);
    String? url;
    if (path != null) {
      final ownPath = RegExp(
        '^avatars/${profile.id}/[0-9a-f-]{36}\\.(jpg|jpeg|png|webp)\$',
      ).hasMatch(path);
      if (!ownPath ||
          !await session.storage.fileExists(
            storageId: 'public',
            path: path,
          )) {
        throw NotAllowedException(message: 'No encontramos la foto subida.');
      }
      url = (await session.storage.publicDownloadUrl(
        storageId: 'public',
        path: path,
      )).toString();
    }
    return MemberProfile.db.updateRow(
      session,
      profile.copyWith(avatarUrl: url),
      columns: (t) => [t.avatarUrl],
    );
  }

  String _validName(String displayName) {
    final name = displayName.trim();
    if (name.length < 2 || name.length > 60) {
      throw NotAllowedException(
        message: 'El nombre debe tener entre 2 y 60 caracteres.',
      );
    }
    return name;
  }

  /// Public profile of any member, used on listing detail and chat headers.
  Future<MemberProfile?> byId(Session session, int profileId) async {
    final profile = await MemberProfile.db.findById(session, profileId);
    return profile?.copyWith(latitude: null, longitude: null);
  }

  /// Profile screen data for any member: stats, open listings, delivery
  /// history and the newest reviews.
  Future<PublicProfileView> publicProfile(
    Session session,
    int profileId,
  ) async {
    final caller = await currentProfile(session);
    final profile = await MemberProfile.db.findById(session, profileId);
    if (profile == null) {
      throw NotAllowedException(message: 'Usuario no encontrado.');
    }

    final listings = await Listing.db.find(
      session,
      where: (t) =>
          t.ownerId.equals(profileId) &
          (t.status.equals(ListingStatus.available) |
              t.status.equals(ListingStatus.reserved)),
      orderByList: (t) => [t.createdAt.desc(), t.id.desc()],
      limit: 50,
    );
    final delivered = await Listing.db.find(
      session,
      where: (t) =>
          t.ownerId.equals(profileId) &
          t.status.equals(ListingStatus.delivered),
      orderByList: (t) => [t.updatedAt.desc(), t.id.desc()],
      limit: 50,
    );
    final views = await toViews(session, [...listings, ...delivered], caller);

    return PublicProfileView(
      profile: profile.copyWith(latitude: null, longitude: null),
      isMe: profile.id == caller.id,
      listings: views.take(listings.length).toList(),
      history: views.skip(listings.length).toList(),
      reviews: await reviewViews(session, profileId),
    );
  }
}
