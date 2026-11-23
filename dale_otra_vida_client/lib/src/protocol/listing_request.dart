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
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'request_status.dart' as _iq8zsng0;

/// A "Lo quiero" request from a user on a listing.
abstract class ListingRequest
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ListingRequest._({
    this.id,
    required this.listingId,
    required this.requesterId,
    this.message,
    _iq8zsng0.RequestStatus? status,
    this.acceptedTermsAt,
    DateTime? createdAt,
  }) : status = status ?? _iq8zsng0.RequestStatus.pending,
       createdAt = createdAt ?? DateTime.now();

  factory ListingRequest({
    int? id,
    required int listingId,
    required int requesterId,
    String? message,
    _iq8zsng0.RequestStatus? status,
    DateTime? acceptedTermsAt,
    DateTime? createdAt,
  }) = _ListingRequestImpl;

  factory ListingRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return ListingRequest(
      id: jsonSerialization['id'] as int?,
      listingId: jsonSerialization['listingId'] as int,
      requesterId: jsonSerialization['requesterId'] as int,
      message: jsonSerialization['message'] as String?,
      status: jsonSerialization['status'] == null
          ? null
          : _iq8zsng0.RequestStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      acceptedTermsAt: jsonSerialization['acceptedTermsAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['acceptedTermsAt'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int listingId;

  int requesterId;

  String? message;

  _iq8zsng0.RequestStatus status;

  /// Loans: when the requester accepted the owner's loan conditions.
  DateTime? acceptedTermsAt;

  DateTime createdAt;

  /// Returns a shallow copy of this [ListingRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ListingRequest copyWith({
    int? id,
    int? listingId,
    int? requesterId,
    String? message,
    _iq8zsng0.RequestStatus? status,
    DateTime? acceptedTermsAt = const _isc.$UndefinedDateTime(),
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ListingRequest',
      if (id != null) 'id': id,
      'listingId': listingId,
      'requesterId': requesterId,
      if (message != null) 'message': message,
      'status': status.toJson(),
      if (acceptedTermsAt != null) 'acceptedTermsAt': acceptedTermsAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ListingRequest',
      if (id != null) 'id': id,
      'listingId': listingId,
      'requesterId': requesterId,
      if (message != null) 'message': message,
      'status': status.toJson(),
      if (acceptedTermsAt != null) 'acceptedTermsAt': acceptedTermsAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ListingRequestImpl extends ListingRequest {
  _ListingRequestImpl({
    int? id,
    required int listingId,
    required int requesterId,
    String? message,
    _iq8zsng0.RequestStatus? status,
    DateTime? acceptedTermsAt,
    DateTime? createdAt,
  }) : super._(
         id: id,
         listingId: listingId,
         requesterId: requesterId,
         message: message,
         status: status,
         acceptedTermsAt: acceptedTermsAt,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ListingRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ListingRequest copyWith({
    Object? id = _Undefined,
    int? listingId,
    int? requesterId,
    Object? message = _Undefined,
    _iq8zsng0.RequestStatus? status,
    DateTime? acceptedTermsAt = const _isc.$UndefinedDateTime(),
    DateTime? createdAt,
  }) {
    return ListingRequest(
      id: id is int? ? id : this.id,
      listingId: listingId ?? this.listingId,
      requesterId: requesterId ?? this.requesterId,
      message: message is String? ? message : this.message,
      status: status ?? this.status,
      acceptedTermsAt: acceptedTermsAt is _isc.UndefinedSentinel
          ? this.acceptedTermsAt
          : acceptedTermsAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
