import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';

/// By extending [GoogleIdpBaseEndpoint], the Google identity provider endpoints
/// are made available on the server and enable Google sign-in on the client.
///
/// Each sign-in method normally creates its own user. Here, the first Google
/// sign-in of someone who already registered with the same email joins that
/// account instead of creating a second one: Google verified the email, and
/// an email account only exists after its code was confirmed.
class GoogleIdpEndpoint extends GoogleIdpBaseEndpoint {
  @override
  Future<AuthSuccess> login(
    Session session, {
    required String idToken,
    required String? accessToken,
  }) async {
    await _joinEmailAccount(
      session,
      idToken: idToken,
      accessToken: accessToken,
    );
    return super.login(session, idToken: idToken, accessToken: accessToken);
  }

  @override
  Future<AuthSuccess> loginWithCode(
    Session session, {
    required String code,
    required String codeVerifier,
    required String redirectUri,
  }) async {
    // The code can only be exchanged once, so exchange it here and log in
    // with the resulting tokens.
    final tokens = await googleIdp.utils.exchangeCodeForToken(
      session,
      code: code,
      codeVerifier: codeVerifier,
      redirectUri: redirectUri,
    );
    await _joinEmailAccount(
      session,
      idToken: tokens.idToken,
      accessToken: tokens.accessToken,
    );
    return googleIdp.login(
      session,
      idToken: tokens.idToken,
      accessToken: tokens.accessToken,
    );
  }

  /// Links this Google account to the email account with the same verified
  /// email, before the login would create a separate user for it.
  Future<void> _joinEmailAccount(
    Session session, {
    required String idToken,
    required String? accessToken,
  }) async {
    final details = await googleIdp.utils.fetchAccountDetails(
      session,
      idToken: idToken,
      accessToken: accessToken,
    );
    if (details.verifiedEmail != true) return;

    final known = await GoogleAccount.db.findFirstRow(
      session,
      where: (t) => t.userIdentifier.equals(details.userIdentifier),
    );
    if (known != null) return;

    final emailAccount = await EmailAccount.db.findFirstRow(
      session,
      where: (t) => t.email.equals(details.email.toLowerCase()),
    );
    if (emailAccount == null) return;

    await googleIdp.utils.linkGoogleAuthentication(
      session,
      authUserId: emailAccount.authUserId,
      accountDetails: details,
    );
  }
}
