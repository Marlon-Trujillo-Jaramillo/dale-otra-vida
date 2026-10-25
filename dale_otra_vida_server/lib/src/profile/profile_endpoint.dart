import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

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
  }) async {
    final name = displayName.trim();
    if (name.length < 2 || name.length > 60) {
      throw ArgumentError.value(displayName, 'displayName');
    }

    final existing = await me(session);
    final profile =
        (existing ??
                MemberProfile(
                  authUserId: session.authenticated!.authUserId,
                  displayName: name,
                ))
            .copyWith(
              displayName: name,
              neighborhood: neighborhood?.trim(),
              latitude: roundCoordinate(latitude),
              longitude: roundCoordinate(longitude),
            );

    return existing == null
        ? MemberProfile.db.insertRow(session, profile)
        : MemberProfile.db.updateRow(session, profile);
  }

  /// Public profile of any member, used on listing detail and chat headers.
  Future<MemberProfile?> byId(Session session, int profileId) async {
    final profile = await MemberProfile.db.findById(session, profileId);
    return profile?.copyWith(latitude: null, longitude: null);
  }
}

double? roundCoordinate(double? value) =>
    value == null ? null : (value * 1000).roundToDouble() / 1000;
