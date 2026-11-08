import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart'
    show GoogleAccount;

import '../generated/protocol.dart';

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
class EmailIdpEndpoint extends EmailIdpBaseEndpoint {
  /// Someone who already signs in with Google would otherwise get a second,
  /// separate account here: point them to Google instead.
  @override
  Future<UuidValue> startRegistration(
    Session session, {
    required String email,
  }) async {
    final google = await GoogleAccount.db.findFirstRow(
      session,
      where: (t) => t.email.equals(email.trim().toLowerCase()),
    );
    if (google != null) {
      throw NotAllowedException(
        message:
            'Este correo ya tiene cuenta con Google. Toca «Continuar con '
            'Google» para entrar.',
      );
    }
    return super.startRegistration(session, email: email);
  }
}
