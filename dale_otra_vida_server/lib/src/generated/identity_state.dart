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
import 'package:serverpod/serverpod.dart' as _is;
import 'identity_status.dart' as _i3lgiogf;

/// What a member sees of their own identity check (no number, no photos).
abstract class IdentityState
    implements _is.SerializableModel, _is.ProtocolSerialization {
  IdentityState._({
    this.status,
    this.rejectionReason,
    this.submittedAt,
  });

  factory IdentityState({
    _i3lgiogf.IdentityStatus? status,
    String? rejectionReason,
    DateTime? submittedAt,
  }) = _IdentityStateImpl;

  factory IdentityState.fromJson(Map<String, dynamic> jsonSerialization) {
    return IdentityState(
      status: jsonSerialization['status'] == null
          ? null
          : _i3lgiogf.IdentityStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      rejectionReason: jsonSerialization['rejectionReason'] as String?,
      submittedAt: jsonSerialization['submittedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['submittedAt'],
            ),
    );
  }

  /// Null when they never submitted one.
  _i3lgiogf.IdentityStatus? status;

  String? rejectionReason;

  DateTime? submittedAt;

  /// Returns a shallow copy of this [IdentityState]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  IdentityState copyWith({
    _i3lgiogf.IdentityStatus? status,
    String? rejectionReason,
    DateTime? submittedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IdentityState',
      if (status != null) 'status': status?.toJson(),
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
      if (submittedAt != null) 'submittedAt': submittedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'IdentityState',
      if (status != null) 'status': status?.toJson(),
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
      if (submittedAt != null) 'submittedAt': submittedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IdentityStateImpl extends IdentityState {
  _IdentityStateImpl({
    _i3lgiogf.IdentityStatus? status,
    String? rejectionReason,
    DateTime? submittedAt,
  }) : super._(
         status: status,
         rejectionReason: rejectionReason,
         submittedAt: submittedAt,
       );

  /// Returns a shallow copy of this [IdentityState]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  IdentityState copyWith({
    Object? status = _Undefined,
    Object? rejectionReason = _Undefined,
    Object? submittedAt = _Undefined,
  }) {
    return IdentityState(
      status: status is _i3lgiogf.IdentityStatus? ? status : this.status,
      rejectionReason: rejectionReason is String?
          ? rejectionReason
          : this.rejectionReason,
      submittedAt: submittedAt is DateTime? ? submittedAt : this.submittedAt,
    );
  }
}
