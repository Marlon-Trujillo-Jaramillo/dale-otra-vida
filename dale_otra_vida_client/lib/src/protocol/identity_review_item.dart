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
import 'member_profile.dart' as _iuh59zig;

/// A pending identity check as an administrator reviews it.
abstract class IdentityReviewItem
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  IdentityReviewItem._({
    required this.verificationId,
    required this.member,
    required this.documentNumber,
    required this.submittedAt,
  });

  factory IdentityReviewItem({
    required int verificationId,
    required _iuh59zig.MemberProfile member,
    required String documentNumber,
    required DateTime submittedAt,
  }) = _IdentityReviewItemImpl;

  factory IdentityReviewItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return IdentityReviewItem(
      verificationId: jsonSerialization['verificationId'] as int,
      member: _ilolbpul.Protocol().deserialize<_iuh59zig.MemberProfile>(
        jsonSerialization['member'],
      ),
      documentNumber: jsonSerialization['documentNumber'] as String,
      submittedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['submittedAt'],
      ),
    );
  }

  int verificationId;

  _iuh59zig.MemberProfile member;

  String documentNumber;

  DateTime submittedAt;

  /// Returns a shallow copy of this [IdentityReviewItem]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  IdentityReviewItem copyWith({
    int? verificationId,
    _iuh59zig.MemberProfile? member,
    String? documentNumber,
    DateTime? submittedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IdentityReviewItem',
      'verificationId': verificationId,
      'member': member.toJson(),
      'documentNumber': documentNumber,
      'submittedAt': submittedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'IdentityReviewItem',
      'verificationId': verificationId,
      'member': member.toJsonForProtocol(),
      'documentNumber': documentNumber,
      'submittedAt': submittedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _IdentityReviewItemImpl extends IdentityReviewItem {
  _IdentityReviewItemImpl({
    required int verificationId,
    required _iuh59zig.MemberProfile member,
    required String documentNumber,
    required DateTime submittedAt,
  }) : super._(
         verificationId: verificationId,
         member: member,
         documentNumber: documentNumber,
         submittedAt: submittedAt,
       );

  /// Returns a shallow copy of this [IdentityReviewItem]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  IdentityReviewItem copyWith({
    int? verificationId,
    _iuh59zig.MemberProfile? member,
    String? documentNumber,
    DateTime? submittedAt,
  }) {
    return IdentityReviewItem(
      verificationId: verificationId ?? this.verificationId,
      member: member ?? this.member.copyWith(),
      documentNumber: documentNumber ?? this.documentNumber,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }
}
