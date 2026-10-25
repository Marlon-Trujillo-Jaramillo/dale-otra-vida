import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';

/// Returns the profile of the signed-in member.
///
/// Throws [ProfileRequiredException] when the member has not completed
/// onboarding yet.
Future<MemberProfile> currentProfile(Session session) async {
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
