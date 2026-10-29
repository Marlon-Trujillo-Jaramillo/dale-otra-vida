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
import 'package:dale_otra_vida_client/src/protocol/protocol.dart' as _ilolbpul;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'conversation.dart' as _ineda879;
import 'listing_request.dart' as _i0jjpqa3;
import 'listing_view.dart' as _ijuym7ok;
import 'member_profile.dart' as _iuh59zig;

/// A conversation as seen by one of its two participants.
abstract class ConversationView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ConversationView._({
    required this.conversation,
    required this.listing,
    required this.other,
    required this.isOwner,
    int? unreadCount,
    this.request,
  }) : unreadCount = unreadCount ?? 0;

  factory ConversationView({
    required _ineda879.Conversation conversation,
    required _ijuym7ok.ListingView listing,
    required _iuh59zig.MemberProfile other,
    required bool isOwner,
    int? unreadCount,
    _i0jjpqa3.ListingRequest? request,
  }) = _ConversationViewImpl;

  factory ConversationView.fromJson(Map<String, dynamic> jsonSerialization) {
    return ConversationView(
      conversation: _ilolbpul.Protocol().deserialize<_ineda879.Conversation>(
        jsonSerialization['conversation'],
      ),
      listing: _ilolbpul.Protocol().deserialize<_ijuym7ok.ListingView>(
        jsonSerialization['listing'],
      ),
      other: _ilolbpul.Protocol().deserialize<_iuh59zig.MemberProfile>(
        jsonSerialization['other'],
      ),
      isOwner: _isc.BoolJsonExtension.fromJson(jsonSerialization['isOwner']),
      unreadCount: jsonSerialization['unreadCount'] as int?,
      request: jsonSerialization['request'] == null
          ? null
          : _ilolbpul.Protocol().deserialize<_i0jjpqa3.ListingRequest>(
              jsonSerialization['request'],
            ),
    );
  }

  _ineda879.Conversation conversation;

  _ijuym7ok.ListingView listing;

  /// The other participant, without coordinates.
  _iuh59zig.MemberProfile other;

  bool isOwner;

  /// Messages from the other participant not read yet.
  int unreadCount;

  /// The requester's request on the listing.
  _i0jjpqa3.ListingRequest? request;

  /// Returns a shallow copy of this [ConversationView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ConversationView copyWith({
    _ineda879.Conversation? conversation,
    _ijuym7ok.ListingView? listing,
    _iuh59zig.MemberProfile? other,
    bool? isOwner,
    int? unreadCount,
    _i0jjpqa3.ListingRequest? request,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ConversationView',
      'conversation': conversation.toJson(),
      'listing': listing.toJson(),
      'other': other.toJson(),
      'isOwner': isOwner,
      'unreadCount': unreadCount,
      if (request != null) 'request': request?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ConversationView',
      'conversation': conversation.toJsonForProtocol(),
      'listing': listing.toJsonForProtocol(),
      'other': other.toJsonForProtocol(),
      'isOwner': isOwner,
      'unreadCount': unreadCount,
      if (request != null) 'request': request?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ConversationViewImpl extends ConversationView {
  _ConversationViewImpl({
    required _ineda879.Conversation conversation,
    required _ijuym7ok.ListingView listing,
    required _iuh59zig.MemberProfile other,
    required bool isOwner,
    int? unreadCount,
    _i0jjpqa3.ListingRequest? request,
  }) : super._(
         conversation: conversation,
         listing: listing,
         other: other,
         isOwner: isOwner,
         unreadCount: unreadCount,
         request: request,
       );

  /// Returns a shallow copy of this [ConversationView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ConversationView copyWith({
    _ineda879.Conversation? conversation,
    _ijuym7ok.ListingView? listing,
    _iuh59zig.MemberProfile? other,
    bool? isOwner,
    int? unreadCount,
    Object? request = _Undefined,
  }) {
    return ConversationView(
      conversation: conversation ?? this.conversation.copyWith(),
      listing: listing ?? this.listing.copyWith(),
      other: other ?? this.other.copyWith(),
      isOwner: isOwner ?? this.isOwner,
      unreadCount: unreadCount ?? this.unreadCount,
      request: request is _i0jjpqa3.ListingRequest?
          ? request
          : this.request?.copyWith(),
    );
  }
}
