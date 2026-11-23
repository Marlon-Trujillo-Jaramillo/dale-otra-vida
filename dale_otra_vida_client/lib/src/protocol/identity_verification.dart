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
import 'identity_status.dart' as _i3lgiogf;

/// A member's identity check for loans: a photo of the cédula and a selfie
/// holding it, reviewed by hand by an administrator. Sensitive data (Ley 1581
/// de 2015): photos live in private storage and are deleted right after the
/// review; only an administrator ever reads this row.
abstract class IdentityVerification
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  IdentityVerification._({
    this.id,
    required this.profileId,
    _i3lgiogf.IdentityStatus? status,
    required this.documentNumber,
    this.frontPath,
    this.selfiePath,
    required this.consentAt,
    DateTime? submittedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.rejectionReason,
  }) : status = status ?? _i3lgiogf.IdentityStatus.pending,
       submittedAt = submittedAt ?? DateTime.now();

  factory IdentityVerification({
    int? id,
    required int profileId,
    _i3lgiogf.IdentityStatus? status,
    required String documentNumber,
    String? frontPath,
    String? selfiePath,
    required DateTime consentAt,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    int? reviewedBy,
    String? rejectionReason,
  }) = _IdentityVerificationImpl;

  factory IdentityVerification.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return IdentityVerification(
      id: jsonSerialization['id'] as int?,
      profileId: jsonSerialization['profileId'] as int,
      status: jsonSerialization['status'] == null
          ? null
          : _i3lgiogf.IdentityStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      documentNumber: jsonSerialization['documentNumber'] as String,
      frontPath: jsonSerialization['frontPath'] as String?,
      selfiePath: jsonSerialization['selfiePath'] as String?,
      consentAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['consentAt'],
      ),
      submittedAt: jsonSerialization['submittedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['submittedAt'],
            ),
      reviewedAt: jsonSerialization['reviewedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['reviewedAt'],
            ),
      reviewedBy: jsonSerialization['reviewedBy'] as int?,
      rejectionReason: jsonSerialization['rejectionReason'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int profileId;

  _i3lgiogf.IdentityStatus status;

  /// Cédula number, digits only. Kept for a police report after a theft.
  String documentNumber;

  /// Private storage paths; cleared when the photos are deleted.
  String? frontPath;

  String? selfiePath;

  /// When the member gave express consent to this processing.
  DateTime consentAt;

  DateTime submittedAt;

  DateTime? reviewedAt;

  /// Profile id of the administrator who reviewed it.
  int? reviewedBy;

  String? rejectionReason;

  /// Returns a shallow copy of this [IdentityVerification]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  IdentityVerification copyWith({
    int? id,
    int? profileId,
    _i3lgiogf.IdentityStatus? status,
    String? documentNumber,
    String? frontPath,
    String? selfiePath,
    DateTime? consentAt,
    DateTime? submittedAt,
    DateTime? reviewedAt = const _isc.$UndefinedDateTime(),
    int? reviewedBy,
    String? rejectionReason,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IdentityVerification',
      if (id != null) 'id': id,
      'profileId': profileId,
      'status': status.toJson(),
      'documentNumber': documentNumber,
      if (frontPath != null) 'frontPath': frontPath,
      if (selfiePath != null) 'selfiePath': selfiePath,
      'consentAt': consentAt.toJson(),
      'submittedAt': submittedAt.toJson(),
      if (reviewedAt != null) 'reviewedAt': reviewedAt?.toJson(),
      if (reviewedBy != null) 'reviewedBy': reviewedBy,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'IdentityVerification',
      if (id != null) 'id': id,
      'profileId': profileId,
      'status': status.toJson(),
      'documentNumber': documentNumber,
      if (frontPath != null) 'frontPath': frontPath,
      if (selfiePath != null) 'selfiePath': selfiePath,
      'consentAt': consentAt.toJson(),
      'submittedAt': submittedAt.toJson(),
      if (reviewedAt != null) 'reviewedAt': reviewedAt?.toJson(),
      if (reviewedBy != null) 'reviewedBy': reviewedBy,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IdentityVerificationImpl extends IdentityVerification {
  _IdentityVerificationImpl({
    int? id,
    required int profileId,
    _i3lgiogf.IdentityStatus? status,
    required String documentNumber,
    String? frontPath,
    String? selfiePath,
    required DateTime consentAt,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    int? reviewedBy,
    String? rejectionReason,
  }) : super._(
         id: id,
         profileId: profileId,
         status: status,
         documentNumber: documentNumber,
         frontPath: frontPath,
         selfiePath: selfiePath,
         consentAt: consentAt,
         submittedAt: submittedAt,
         reviewedAt: reviewedAt,
         reviewedBy: reviewedBy,
         rejectionReason: rejectionReason,
       );

  /// Returns a shallow copy of this [IdentityVerification]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  IdentityVerification copyWith({
    Object? id = _Undefined,
    int? profileId,
    _i3lgiogf.IdentityStatus? status,
    String? documentNumber,
    Object? frontPath = _Undefined,
    Object? selfiePath = _Undefined,
    DateTime? consentAt,
    DateTime? submittedAt,
    DateTime? reviewedAt = const _isc.$UndefinedDateTime(),
    Object? reviewedBy = _Undefined,
    Object? rejectionReason = _Undefined,
  }) {
    return IdentityVerification(
      id: id is int? ? id : this.id,
      profileId: profileId ?? this.profileId,
      status: status ?? this.status,
      documentNumber: documentNumber ?? this.documentNumber,
      frontPath: frontPath is String? ? frontPath : this.frontPath,
      selfiePath: selfiePath is String? ? selfiePath : this.selfiePath,
      consentAt: consentAt ?? this.consentAt,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt is _isc.UndefinedSentinel
          ? this.reviewedAt
          : reviewedAt,
      reviewedBy: reviewedBy is int? ? reviewedBy : this.reviewedBy,
      rejectionReason: rejectionReason is String?
          ? rejectionReason
          : this.rejectionReason,
    );
  }
}
