/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _ida;
import 'package:dale_otra_vida_client/src/protocol/app_notification.dart'
    as _irhv3nen;
import 'package:dale_otra_vida_client/src/protocol/category.dart' as _i0m5ztok;
import 'package:dale_otra_vida_client/src/protocol/chat_message.dart'
    as _ir83d1bh;
import 'package:dale_otra_vida_client/src/protocol/conversation_view.dart'
    as _ixj8t0ja;
import 'package:dale_otra_vida_client/src/protocol/greetings/greeting.dart'
    as _iqtlzsy5;
import 'package:dale_otra_vida_client/src/protocol/listing.dart' as _iz1p8yt7;
import 'package:dale_otra_vida_client/src/protocol/listing_request.dart'
    as _iftx1you;
import 'package:dale_otra_vida_client/src/protocol/listing_status.dart'
    as _i9248wmd;
import 'package:dale_otra_vida_client/src/protocol/listing_type.dart'
    as _is804cud;
import 'package:dale_otra_vida_client/src/protocol/listing_view.dart'
    as _ijh8j4ei;
import 'package:dale_otra_vida_client/src/protocol/member_profile.dart'
    as _ibcyrd05;
import 'package:dale_otra_vida_client/src/protocol/message_kind.dart'
    as _i711izxw;
import 'package:dale_otra_vida_client/src/protocol/my_request_view.dart'
    as _ikulhwb6;
import 'package:dale_otra_vida_client/src/protocol/photo_upload.dart'
    as _ihcne4ez;
import 'package:dale_otra_vida_client/src/protocol/public_profile_view.dart'
    as _i25iho9e;
import 'package:dale_otra_vida_client/src/protocol/report.dart' as _is9y7yz2;
import 'package:dale_otra_vida_client/src/protocol/report_reason.dart'
    as _i72va9fa;
import 'package:dale_otra_vida_client/src/protocol/request_view.dart'
    as _isipxjtl;
import 'package:dale_otra_vida_client/src/protocol/review.dart' as _iczk13vq;
import 'package:dale_otra_vida_client/src/protocol/review_view.dart'
    as _iv0fqw25;
import 'package:http/http.dart' as _i85jenna;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'protocol.dart' as _il2as5qe;

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _iaic.EndpointEmailIdpBase {
  EndpointEmailIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _ida.Future<_isc.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _ida.Future<String> verifyRegistrationCode({
    required _isc.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _ida.Future<_iacc.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _ida.Future<_isc.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _ida.Future<String> verifyPasswordResetCode({
    required _isc.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _ida.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// By extending [GoogleIdpBaseEndpoint], the Google identity provider endpoints
/// are made available on the server and enable Google sign-in on the client.
/// {@category Endpoint}
class EndpointGoogleIdp extends _iaic.EndpointGoogleIdpBase {
  EndpointGoogleIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'googleIdp';

  /// Validates a Google ID token and either logs in the associated user or
  /// creates a new user account if the Google account ID is not yet known.
  ///
  /// If a new user is created an associated [UserProfile] is also created.
  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required String idToken,
    required String? accessToken,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'googleIdp',
    'login',
    {
      'idToken': idToken,
      'accessToken': accessToken,
    },
  );

  /// Validates a Google authorization code from the web OAuth2 PKCE flow and
  /// either logs in the associated user or creates a new account.
  ///
  /// This is the web counterpart of [login], which accepts an ID token directly
  /// (used on native platforms via the `google_sign_in` package).
  ///
  /// If a new user is created an associated [UserProfile] is also created.
  @override
  _ida.Future<_iacc.AuthSuccess> loginWithCode({
    required String code,
    required String codeVerifier,
    required String redirectUri,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'googleIdp',
    'loginWithCode',
    {
      'code': code,
      'codeVerifier': codeVerifier,
      'redirectUri': redirectUri,
    },
  );

  @override
  _ida.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'googleIdp',
    'hasAccount',
    {},
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _iacc.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// If [refreshToken] is omitted, cookie-mode web clients fall back to the
  /// configured HttpOnly refresh cookie. When neither source is present this
  /// throws [RefreshTokenNotFoundException], the same public "no usable refresh
  /// credential" exception used for unknown refresh tokens.
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _ida.Future<_iacc.AuthSuccess> refreshAccessToken({String? refreshToken}) =>
      caller.callServerEndpoint<_iacc.AuthSuccess>(
        'jwtRefresh',
        'refreshAccessToken',
        {'refreshToken': refreshToken},
        authenticated: false,
      );
}

/// Chat between a listing owner and one interested member.
/// {@category Endpoint}
class EndpointChat extends _isc.EndpointRef {
  EndpointChat(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'chat';

  /// Returns the caller's newest 100 conversations, most recent first.
  _ida.Future<List<_ixj8t0ja.ConversationView>> conversations() =>
      caller.callServerEndpoint<List<_ixj8t0ja.ConversationView>>(
        'chat',
        'conversations',
        {},
      );

  /// Returns one of the caller's conversations.
  _ida.Future<_ixj8t0ja.ConversationView> conversation(int conversationId) =>
      caller.callServerEndpoint<_ixj8t0ja.ConversationView>(
        'chat',
        'conversation',
        {'conversationId': conversationId},
      );

  /// Returns a page of messages, newest first. Pass the id of the oldest
  /// message already loaded as [beforeId] to get the previous page.
  _ida.Future<List<_ir83d1bh.ChatMessage>> messages(
    int conversationId, {
    int? beforeId,
    int? limit,
  }) => caller.callServerEndpoint<List<_ir83d1bh.ChatMessage>>(
    'chat',
    'messages',
    {
      'conversationId': conversationId,
      'beforeId': beforeId,
      'limit': limit,
    },
  );

  /// Sends a text message (the default [kind]) or a safe meeting point
  /// proposal.
  _ida.Future<_ir83d1bh.ChatMessage> send(
    int conversationId,
    String text, {
    _i711izxw.MessageKind? kind,
  }) => caller.callServerEndpoint<_ir83d1bh.ChatMessage>(
    'chat',
    'send',
    {
      'conversationId': conversationId,
      'text': text,
      'kind': kind,
    },
  );

  /// Marks the other participant's messages, and the caller's new message
  /// notifications for this conversation, as read.
  _ida.Future<void> markRead(int conversationId) =>
      caller.callServerEndpoint<void>(
        'chat',
        'markRead',
        {'conversationId': conversationId},
      );

  /// Total unread messages across the caller's conversations.
  _ida.Future<int> unreadTotal() => caller.callServerEndpoint<int>(
    'chat',
    'unreadTotal',
    {},
  );

  /// Streams new messages of one conversation.
  _ida.Stream<_ir83d1bh.ChatMessage> subscribe(int conversationId) =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_ir83d1bh.ChatMessage>,
        _ir83d1bh.ChatMessage
      >(
        'chat',
        'subscribe',
        {'conversationId': conversationId},
        {},
      );

  /// Streams every new message in any of the caller's conversations.
  _ida.Stream<_ir83d1bh.ChatMessage> inbox() =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_ir83d1bh.ChatMessage>,
        _ir83d1bh.ChatMessage
      >(
        'chat',
        'inbox',
        {},
        {},
      );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _isc.EndpointRef {
  EndpointGreeting(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _ida.Future<_iqtlzsy5.Greeting> hello(String name) =>
      caller.callServerEndpoint<_iqtlzsy5.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

/// Endpoints for creating and browsing listings.
/// {@category Endpoint}
class EndpointListing extends _isc.EndpointRef {
  EndpointListing(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'listing';

  /// Generates a server-side upload description for a new listing photo.
  _ida.Future<_ihcne4ez.PhotoUpload> photoUploadDescription(
    String fileExtension,
  ) => caller.callServerEndpoint<_ihcne4ez.PhotoUpload>(
    'listing',
    'photoUploadDescription',
    {'fileExtension': fileExtension},
  );

  /// Verifies that a photo was successfully uploaded to the caller's folder.
  _ida.Future<bool> verifyPhotoUpload(String path) =>
      caller.callServerEndpoint<bool>(
        'listing',
        'verifyPhotoUpload',
        {'path': path},
      );

  /// Creates a new listing after validating and sanitizing the input.
  _ida.Future<_ijh8j4ei.ListingView> create(_iz1p8yt7.Listing listing) =>
      caller.callServerEndpoint<_ijh8j4ei.ListingView>(
        'listing',
        'create',
        {'listing': listing},
      );

  /// Edits the text, dates and price of one of the caller's open listings.
  /// Type, category, photos and status stay as they are.
  _ida.Future<_ijh8j4ei.ListingView> update(
    int id,
    _iz1p8yt7.Listing changes,
  ) => caller.callServerEndpoint<_ijh8j4ei.ListingView>(
    'listing',
    'update',
    {
      'id': id,
      'changes': changes,
    },
  );

  /// Returns available listings, optionally filtered.
  ///
  /// With [nearest] and valid coordinates the closest listings come first
  /// (among the newest 300 matches); otherwise the newest come first.
  _ida.Future<List<_ijh8j4ei.ListingView>> feed({
    _is804cud.ListingType? type,
    _i0m5ztok.Category? category,
    String? query,
    double? latitude,
    double? longitude,
    bool? nearest,
    required int limit,
    required int offset,
  }) => caller.callServerEndpoint<List<_ijh8j4ei.ListingView>>(
    'listing',
    'feed',
    {
      'type': type,
      'category': category,
      'query': query,
      'latitude': latitude,
      'longitude': longitude,
      'nearest': nearest,
      'limit': limit,
      'offset': offset,
    },
  );

  /// Available listings inside a map area, at most 200, newest first.
  _ida.Future<List<_ijh8j4ei.ListingView>> inArea({
    required double south,
    required double west,
    required double north,
    required double east,
    _is804cud.ListingType? type,
    _i0m5ztok.Category? category,
    double? latitude,
    double? longitude,
  }) => caller.callServerEndpoint<List<_ijh8j4ei.ListingView>>(
    'listing',
    'inArea',
    {
      'south': south,
      'west': west,
      'north': north,
      'east': east,
      'type': type,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
    },
  );

  /// Returns a single listing by id, regardless of status.
  _ida.Future<_ijh8j4ei.ListingView?> byId(
    int id, {
    double? latitude,
    double? longitude,
  }) => caller.callServerEndpoint<_ijh8j4ei.ListingView?>(
    'listing',
    'byId',
    {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
    },
  );

  /// Returns the caller's listings, newest first.
  _ida.Future<List<_ijh8j4ei.ListingView>> mine() =>
      caller.callServerEndpoint<List<_ijh8j4ei.ListingView>>(
        'listing',
        'mine',
        {},
      );

  /// Updates the status of a listing owned by the caller.
  _ida.Future<_ijh8j4ei.ListingView> updateStatus(
    int id,
    _i9248wmd.ListingStatus status,
  ) => caller.callServerEndpoint<_ijh8j4ei.ListingView>(
    'listing',
    'updateStatus',
    {
      'id': id,
      'status': status,
    },
  );
}

/// In-app notifications for the signed-in member.
/// {@category Endpoint}
class EndpointNotification extends _isc.EndpointRef {
  EndpointNotification(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'notification';

  /// Returns the notifications of the caller, newest first.
  _ida.Future<List<_irhv3nen.AppNotification>> list({
    required int limit,
    required int offset,
  }) => caller.callServerEndpoint<List<_irhv3nen.AppNotification>>(
    'notification',
    'list',
    {
      'limit': limit,
      'offset': offset,
    },
  );

  /// Returns how many notifications the caller has not read yet.
  _ida.Future<int> unreadCount() => caller.callServerEndpoint<int>(
    'notification',
    'unreadCount',
    {},
  );

  /// Marks one notification of the caller as read.
  ///
  /// Notifications owned by other members are silently ignored.
  _ida.Future<void> markRead(int id) => caller.callServerEndpoint<void>(
    'notification',
    'markRead',
    {'id': id},
  );

  /// Marks every unread notification of the caller as read.
  _ida.Future<void> markAllRead() => caller.callServerEndpoint<void>(
    'notification',
    'markAllRead',
    {},
  );
}

/// Profile of the signed-in member. Created right after the first sign-in.
/// {@category Endpoint}
class EndpointProfile extends _isc.EndpointRef {
  EndpointProfile(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'profile';

  /// Returns the signed-in member's profile, or null if they have not
  /// completed onboarding yet.
  _ida.Future<_ibcyrd05.MemberProfile?> me() =>
      caller.callServerEndpoint<_ibcyrd05.MemberProfile?>(
        'profile',
        'me',
        {},
      );

  /// Creates or updates the signed-in member's profile.
  ///
  /// Coordinates are rounded to ~100 m so an exact address is never stored.
  _ida.Future<_ibcyrd05.MemberProfile> saveMe({
    required String displayName,
    String? neighborhood,
    double? latitude,
    double? longitude,
  }) => caller.callServerEndpoint<_ibcyrd05.MemberProfile>(
    'profile',
    'saveMe',
    {
      'displayName': displayName,
      'neighborhood': neighborhood,
      'latitude': latitude,
      'longitude': longitude,
    },
  );

  /// Public profile of any member, used on listing detail and chat headers.
  _ida.Future<_ibcyrd05.MemberProfile?> byId(int profileId) =>
      caller.callServerEndpoint<_ibcyrd05.MemberProfile?>(
        'profile',
        'byId',
        {'profileId': profileId},
      );

  /// Profile screen data for any member: stats, open listings, delivery
  /// history and the newest reviews.
  _ida.Future<_i25iho9e.PublicProfileView> publicProfile(int profileId) =>
      caller.callServerEndpoint<_i25iho9e.PublicProfileView>(
        'profile',
        'publicProfile',
        {'profileId': profileId},
      );
}

/// Reports of members or listings for moderation.
/// {@category Endpoint}
class EndpointReport extends _isc.EndpointRef {
  EndpointReport(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'report';

  /// Reports a member, a listing or both. Repeating the same report within
  /// a day returns the existing one.
  _ida.Future<_is9y7yz2.Report> create(
    _i72va9fa.ReportReason reason, {
    int? reportedUserId,
    int? listingId,
    String? details,
  }) => caller.callServerEndpoint<_is9y7yz2.Report>(
    'report',
    'create',
    {
      'reason': reason,
      'reportedUserId': reportedUserId,
      'listingId': listingId,
      'details': details,
    },
  );
}

/// "Lo quiero" requests on listings.
/// {@category Endpoint}
class EndpointRequest extends _isc.EndpointRef {
  EndpointRequest(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'request';

  /// Creates or reopens a request on an available listing.
  ///
  /// Ensures a conversation with the owner exists, stores a system message
  /// (plus the optional [message]) and notifies the owner. An existing
  /// pending or accepted request is returned unchanged; a cancelled one is
  /// reopened with a fresh createdAt and only the new [message] (null if
  /// none), never the old one.
  _ida.Future<_iftx1you.ListingRequest> create(
    int listingId, {
    String? message,
  }) => caller.callServerEndpoint<_iftx1you.ListingRequest>(
    'request',
    'create',
    {
      'listingId': listingId,
      'message': message,
    },
  );

  /// Returns the newest 100 requests on one of the caller's listings,
  /// pending first and then newest first, with the requester's public
  /// profile and the chat conversation id.
  _ida.Future<List<_isipxjtl.RequestView>> forListing(int listingId) =>
      caller.callServerEndpoint<List<_isipxjtl.RequestView>>(
        'request',
        'forListing',
        {'listingId': listingId},
      );

  /// Returns the newest 100 requests of the caller, newest first, with the
  /// listing view and the chat conversation id.
  _ida.Future<List<_ikulhwb6.MyRequestView>> mine() =>
      caller.callServerEndpoint<List<_ikulhwb6.MyRequestView>>(
        'request',
        'mine',
        {},
      );

  /// Accepts a pending request, reserves the listing and rejects every
  /// other pending request on it.
  ///
  /// Throws [NotAllowedException] when another request on the listing was
  /// already accepted while this call waited for the listing lock.
  _ida.Future<_iftx1you.ListingRequest> accept(int requestId) =>
      caller.callServerEndpoint<_iftx1you.ListingRequest>(
        'request',
        'accept',
        {'requestId': requestId},
      );

  /// Rejects a pending request on one of the caller's listings.
  _ida.Future<_iftx1you.ListingRequest> reject(int requestId) =>
      caller.callServerEndpoint<_iftx1you.ListingRequest>(
        'request',
        'reject',
        {'requestId': requestId},
      );

  /// Cancels one of the caller's requests. Cancelling an accepted request
  /// makes the listing available again and notifies the owner — unless the
  /// listing already progressed: a delivered listing cannot be reopened
  /// (throws [NotAllowedException]) and a withdrawn one is cancelled
  /// silently.
  _ida.Future<_iftx1you.ListingRequest> cancel(int requestId) =>
      caller.callServerEndpoint<_iftx1you.ListingRequest>(
        'request',
        'cancel',
        {'requestId': requestId},
      );
}

/// Ratings that the owner and the receiver leave each other after a delivery.
/// {@category Endpoint}
class EndpointReview extends _isc.EndpointRef {
  EndpointReview(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'review';

  /// Rates the other side of a delivered listing, once per listing.
  _ida.Future<_iczk13vq.Review> create(
    int listingId,
    int rating, {
    String? comment,
  }) => caller.callServerEndpoint<_iczk13vq.Review>(
    'review',
    'create',
    {
      'listingId': listingId,
      'rating': rating,
      'comment': comment,
    },
  );

  /// Newest reviews received by a member.
  _ida.Future<List<_iv0fqw25.ReviewView>> forMember(
    int profileId, {
    int? limit,
    int? offset,
  }) => caller.callServerEndpoint<List<_iv0fqw25.ReviewView>>(
    'review',
    'forMember',
    {
      'profileId': profileId,
      'limit': limit,
      'offset': offset,
    },
  );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _iaic.Caller(client);
    serverpod_auth_core = _iacc.Caller(client);
  }

  late final _iaic.Caller serverpod_auth_idp;

  late final _iacc.Caller serverpod_auth_core;
}

class Client extends _isc.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _isc.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_isc.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
    _i85jenna.Client? httpClientOverride,
  }) : super(
         host,
         _il2as5qe.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
         httpClientOverride: httpClientOverride,
       ) {
    emailIdp = EndpointEmailIdp(this);
    googleIdp = EndpointGoogleIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    chat = EndpointChat(this);
    greeting = EndpointGreeting(this);
    listing = EndpointListing(this);
    notification = EndpointNotification(this);
    profile = EndpointProfile(this);
    report = EndpointReport(this);
    request = EndpointRequest(this);
    review = EndpointReview(this);
    modules = Modules(this);
  }

  late final EndpointEmailIdp emailIdp;

  late final EndpointGoogleIdp googleIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointChat chat;

  late final EndpointGreeting greeting;

  late final EndpointListing listing;

  late final EndpointNotification notification;

  late final EndpointProfile profile;

  late final EndpointReport report;

  late final EndpointRequest request;

  late final EndpointReview review;

  late final Modules modules;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'emailIdp': emailIdp,
    'googleIdp': googleIdp,
    'jwtRefresh': jwtRefresh,
    'chat': chat,
    'greeting': greeting,
    'listing': listing,
    'notification': notification,
    'profile': profile,
    'report': report,
    'request': request,
    'review': review,
  };

  @override
  Map<String, _isc.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
