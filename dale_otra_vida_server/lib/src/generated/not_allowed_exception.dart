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

/// Thrown when a caller is not allowed to perform an operation.
abstract class NotAllowedException
    implements
        _is.SerializableException,
        _is.SerializableModel,
        _is.ProtocolSerialization {
  NotAllowedException._({required this.message});

  factory NotAllowedException({required String message}) =
      _NotAllowedExceptionImpl;

  factory NotAllowedException.fromJson(Map<String, dynamic> jsonSerialization) {
    return NotAllowedException(message: jsonSerialization['message'] as String);
  }

  String message;

  /// Returns a shallow copy of this [NotAllowedException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  NotAllowedException copyWith({String? message});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'NotAllowedException',
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'NotAllowedException',
      'message': message,
    };
  }

  @override
  String toString() {
    return 'NotAllowedException(message: $message)';
  }
}

class _NotAllowedExceptionImpl extends NotAllowedException {
  _NotAllowedExceptionImpl({required String message})
    : super._(message: message);

  /// Returns a shallow copy of this [NotAllowedException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  NotAllowedException copyWith({String? message}) {
    return NotAllowedException(message: message ?? this.message);
  }
}
