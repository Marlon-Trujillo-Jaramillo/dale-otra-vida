import 'dart:async';
import 'dart:convert';

import 'package:googleapis_auth/auth_io.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Password with the Firebase service account JSON (Project settings →
/// Service accounts → Generate new private key). Without it, pushes are off.
const _serviceAccountPassword = 'firebaseServiceAccount';

const _scope = 'https://www.googleapis.com/auth/firebase.messaging';

/// One authenticated client per service account, refreshed automatically.
String? _clientJson;
Future<({String projectId, AutoRefreshingAuthClient client})>? _client;

String? _serviceAccountJson(Session session) {
  final json = session.serverpod.getPassword(_serviceAccountPassword);
  return json == null || json.trim().isEmpty ? null : json;
}

bool fcmConfigured(Session session) => _serviceAccountJson(session) != null;

Future<({String projectId, AutoRefreshingAuthClient client})> _fcmClient(
  String json,
) {
  if (_clientJson != json || _client == null) {
    _clientJson = json;
    _client = () async {
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      final credentials = ServiceAccountCredentials.fromJson(decoded);
      final client = await clientViaServiceAccount(credentials, [_scope]);
      return (projectId: decoded['project_id'] as String, client: client);
    }();
  }
  return _client!;
}

/// Sends a push notification to every device of [profileId]. Never throws:
/// a failed push must not fail the action that triggered it. Tokens that
/// FCM reports as gone are deleted.
Future<void> sendPush(
  Session session, {
  required int profileId,
  required String title,
  required String body,
  Map<String, String> data = const {},
}) async {
  final json = _serviceAccountJson(session);
  if (json == null) return;

  try {
    final tokens = await PushToken.db.find(
      session,
      where: (t) => t.profileId.equals(profileId),
    );
    if (tokens.isEmpty) return;

    final fcm = await _fcmClient(json);
    final url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/${fcm.projectId}/messages:send',
    );
    final link = _webAppUrl(session);

    for (final token in tokens) {
      // A slow Google must not hold the chat message that triggered this.
      final response = await fcm.client
          .post(
            url,
            headers: {'content-type': 'application/json'},
            body: jsonEncode({
              'message': {
                'token': token.token,
                'notification': {'title': title, 'body': body},
                'data': data,
                'android': {'priority': 'high'},
                if (link != null)
                  'webpush': {
                    'fcm_options': {'link': link},
                  },
              },
            }),
          )
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 404 ||
          (response.statusCode == 400 &&
              response.body.contains('registration token'))) {
        await PushToken.db.deleteRow(session, token);
      } else if (response.statusCode >= 300) {
        session.log(
          'FCM push failed (${response.statusCode}): ${response.body}',
          level: LogLevel.warning,
        );
      }
    }
  } catch (e, stackTrace) {
    session.log(
      'FCM push failed',
      level: LogLevel.warning,
      exception: e,
      stackTrace: stackTrace,
    );
  }
}

/// The public address of the web app, opened when a web push is tapped.
String? _webAppUrl(Session session) {
  final web = session.serverpod.config.webServer;
  if (web == null || web.publicHost == 'localhost') return null;
  return 'https://${web.publicHost}/';
}
