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
import 'report_reason.dart' as _ijgj7dn0;

abstract class Report
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Report._({
    this.id,
    required this.reporterId,
    this.reportedUserId,
    this.listingId,
    required this.reason,
    this.details,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Report({
    int? id,
    required int reporterId,
    int? reportedUserId,
    int? listingId,
    required _ijgj7dn0.ReportReason reason,
    String? details,
    DateTime? createdAt,
  }) = _ReportImpl;

  factory Report.fromJson(Map<String, dynamic> jsonSerialization) {
    return Report(
      id: jsonSerialization['id'] as int?,
      reporterId: jsonSerialization['reporterId'] as int,
      reportedUserId: jsonSerialization['reportedUserId'] as int?,
      listingId: jsonSerialization['listingId'] as int?,
      reason: _ijgj7dn0.ReportReason.fromJson(
        (jsonSerialization['reason'] as String),
      ),
      details: jsonSerialization['details'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int reporterId;

  int? reportedUserId;

  int? listingId;

  _ijgj7dn0.ReportReason reason;

  String? details;

  DateTime createdAt;

  /// Returns a shallow copy of this [Report]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Report copyWith({
    int? id,
    int? reporterId,
    int? reportedUserId,
    int? listingId,
    _ijgj7dn0.ReportReason? reason,
    String? details,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Report',
      if (id != null) 'id': id,
      'reporterId': reporterId,
      if (reportedUserId != null) 'reportedUserId': reportedUserId,
      if (listingId != null) 'listingId': listingId,
      'reason': reason.toJson(),
      if (details != null) 'details': details,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Report',
      if (id != null) 'id': id,
      'reporterId': reporterId,
      if (reportedUserId != null) 'reportedUserId': reportedUserId,
      if (listingId != null) 'listingId': listingId,
      'reason': reason.toJson(),
      if (details != null) 'details': details,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ReportImpl extends Report {
  _ReportImpl({
    int? id,
    required int reporterId,
    int? reportedUserId,
    int? listingId,
    required _ijgj7dn0.ReportReason reason,
    String? details,
    DateTime? createdAt,
  }) : super._(
         id: id,
         reporterId: reporterId,
         reportedUserId: reportedUserId,
         listingId: listingId,
         reason: reason,
         details: details,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Report]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Report copyWith({
    Object? id = _Undefined,
    int? reporterId,
    Object? reportedUserId = _Undefined,
    Object? listingId = _Undefined,
    _ijgj7dn0.ReportReason? reason,
    Object? details = _Undefined,
    DateTime? createdAt,
  }) {
    return Report(
      id: id is int? ? id : this.id,
      reporterId: reporterId ?? this.reporterId,
      reportedUserId: reportedUserId is int?
          ? reportedUserId
          : this.reportedUserId,
      listingId: listingId is int? ? listingId : this.listingId,
      reason: reason ?? this.reason,
      details: details is String? ? details : this.details,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
