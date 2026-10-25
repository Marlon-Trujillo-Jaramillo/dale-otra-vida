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
import 'listing_view.dart' as _ijuym7ok;

/// One of the caller's requests, with the listing view and chat conversation.
abstract class MyRequestView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  MyRequestView._({
    required this.request,
    required this.listing,
    this.conversationId,
  });

  factory MyRequestView({
    required _i0jjpqa3.ListingRequest request,
    required _ijuym7ok.ListingView listing,
    int? conversationId,
  }) = _MyRequestViewImpl;

  factory MyRequestView.fromJson(Map<String, dynamic> jsonSerialization) {
    return MyRequestView(
      request: _iy3gazpv.Protocol().deserialize<_i0jjpqa3.ListingRequest>(
        jsonSerialization['request'],
      ),
      listing: _iy3gazpv.Protocol().deserialize<_ijuym7ok.ListingView>(
        jsonSerialization['listing'],
      ),
      conversationId: jsonSerialization['conversationId'] as int?,
    );
  }

  _i0jjpqa3.ListingRequest request;

  _ijuym7ok.ListingView listing;

  int? conversationId;

  /// Returns a shallow copy of this [MyRequestView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  MyRequestView copyWith({
    _i0jjpqa3.ListingRequest? request,
    _ijuym7ok.ListingView? listing,
    int? conversationId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MyRequestView',
      'request': request.toJson(),
      'listing': listing.toJson(),
      if (conversationId != null) 'conversationId': conversationId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MyRequestView',
      'request': request.toJsonForProtocol(),
      'listing': listing.toJsonForProtocol(),
      if (conversationId != null) 'conversationId': conversationId,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MyRequestViewImpl extends MyRequestView {
  _MyRequestViewImpl({
    required _i0jjpqa3.ListingRequest request,
    required _ijuym7ok.ListingView listing,
    int? conversationId,
  }) : super._(
         request: request,
         listing: listing,
         conversationId: conversationId,
       );

  /// Returns a shallow copy of this [MyRequestView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  MyRequestView copyWith({
    _i0jjpqa3.ListingRequest? request,
    _ijuym7ok.ListingView? listing,
    Object? conversationId = _Undefined,
  }) {
    return MyRequestView(
      request: request ?? this.request.copyWith(),
      listing: listing ?? this.listing.copyWith(),
      conversationId: conversationId is int?
          ? conversationId
          : this.conversationId,
    );
  }
}
