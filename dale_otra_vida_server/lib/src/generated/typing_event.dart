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

/// "Someone is typing" in a conversation. Never stored, only streamed.
abstract class TypingEvent
    implements _is.SerializableModel, _is.ProtocolSerialization {
  TypingEvent._({required this.profileId});

  factory TypingEvent({required int profileId}) = _TypingEventImpl;

  factory TypingEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return TypingEvent(profileId: jsonSerialization['profileId'] as int);
  }

  int profileId;

  /// Returns a shallow copy of this [TypingEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TypingEvent copyWith({int? profileId});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TypingEvent',
      'profileId': profileId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TypingEvent',
      'profileId': profileId,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _TypingEventImpl extends TypingEvent {
  _TypingEventImpl({required int profileId}) : super._(profileId: profileId);

  /// Returns a shallow copy of this [TypingEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TypingEvent copyWith({int? profileId}) {
    return TypingEvent(profileId: profileId ?? this.profileId);
  }
}
