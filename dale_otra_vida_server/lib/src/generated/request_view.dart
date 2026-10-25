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
import 'package:dale_otra_vida_server/src/generated/protocol.dart' as _iy3gazpv;
import 'package:serverpod/serverpod.dart' as _is;
import 'listing_request.dart' as _i0jjpqa3;
import 'member_profile.dart' as _iuh59zig;

/// A request on one of the caller's listings, with the requester's public profile.
abstract class RequestView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  RequestView._({
    required this.request,
    required this.requester,
    this.conversationId,
  });

  factory RequestView({
    required _i0jjpqa3.ListingRequest request,
    required _iuh59zig.MemberProfile requester,
    int? conversationId,
  }) = _RequestViewImpl;

  factory RequestView.fromJson(Map<String, dynamic> jsonSerialization) {
    return RequestView(
      request: _iy3gazpv.Protocol().deserialize<_i0jjpqa3.ListingRequest>(
        jsonSerialization['request'],
      ),
      requester: _iy3gazpv.Protocol().deserialize<_iuh59zig.MemberProfile>(
        jsonSerialization['requester'],
      ),
      conversationId: jsonSerialization['conversationId'] as int?,
    );
  }

  _i0jjpqa3.ListingRequest request;

  _iuh59zig.MemberProfile requester;

  int? conversationId;

  /// Returns a shallow copy of this [RequestView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RequestView copyWith({
    _i0jjpqa3.ListingRequest? request,
    _iuh59zig.MemberProfile? requester,
    int? conversationId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RequestView',
      'request': request.toJson(),
      'requester': requester.toJson(),
      if (conversationId != null) 'conversationId': conversationId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RequestView',
      'request': request.toJsonForProtocol(),
      'requester': requester.toJsonForProtocol(),
      if (conversationId != null) 'conversationId': conversationId,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RequestViewImpl extends RequestView {
  _RequestViewImpl({
    required _i0jjpqa3.ListingRequest request,
    required _iuh59zig.MemberProfile requester,
    int? conversationId,
  }) : super._(
         request: request,
         requester: requester,
         conversationId: conversationId,
       );

  /// Returns a shallow copy of this [RequestView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RequestView copyWith({
    _i0jjpqa3.ListingRequest? request,
    _iuh59zig.MemberProfile? requester,
    Object? conversationId = _Undefined,
  }) {
    return RequestView(
      request: request ?? this.request.copyWith(),
      requester: requester ?? this.requester.copyWith(),
      conversationId: conversationId is int?
          ? conversationId
          : this.conversationId,
    );
  }
}
