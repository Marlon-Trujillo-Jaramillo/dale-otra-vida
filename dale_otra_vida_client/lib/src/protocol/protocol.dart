/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dale_otra_vida_client/src/protocol/app_notification.dart'
    as _irhv3nen;
import 'package:dale_otra_vida_client/src/protocol/chat_message.dart'
    as _ir83d1bh;
import 'package:dale_otra_vida_client/src/protocol/conversation_view.dart'
    as _ixj8t0ja;
import 'package:dale_otra_vida_client/src/protocol/listing_view.dart'
    as _ijh8j4ei;
import 'package:dale_otra_vida_client/src/protocol/my_request_view.dart'
    as _ikulhwb6;
import 'package:dale_otra_vida_client/src/protocol/request_view.dart'
    as _isipxjtl;
import 'package:dale_otra_vida_client/src/protocol/review_view.dart'
    as _iv0fqw25;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'account_type.dart' as _itrmkf8a;
import 'app_notification.dart' as _ip1vhxmg;
import 'category.dart' as _issw2w8j;
import 'chat_message.dart' as _ivuncx2e;
import 'community_impact.dart' as _iukzfy8n;
import 'conversation.dart' as _ineda879;
import 'conversation_view.dart' as _iz4kexi3;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'item_condition.dart' as _ittj06x2;
import 'listing.dart' as _ir9e9w84;
import 'listing_request.dart' as _i0jjpqa3;
import 'listing_status.dart' as _igczfm3x;
import 'listing_type.dart' as _i1ntjlwm;
import 'listing_view.dart' as _ijuym7ok;
import 'member_profile.dart' as _iuh59zig;
import 'message_kind.dart' as _ibvtcu73;
import 'my_request_view.dart' as _ioyw6oo5;
import 'not_allowed_exception.dart' as _icn336wo;
import 'notification_kind.dart' as _ipnxo26v;
import 'photo_upload.dart' as _ihl17tin;
import 'profile_required_exception.dart' as _iarivcoc;
import 'public_profile_view.dart' as _io3x196o;
import 'report.dart' as _i2t8i3ij;
import 'report_reason.dart' as _ijgj7dn0;
import 'request_status.dart' as _iq8zsng0;
import 'request_view.dart' as _iv1530zw;
import 'review.dart' as _itqm5y01;
import 'review_view.dart' as _io58qecx;
export 'account_type.dart';
export 'app_notification.dart';
export 'category.dart';
export 'chat_message.dart';
export 'community_impact.dart';
export 'conversation.dart';
export 'conversation_view.dart';
export 'greetings/greeting.dart';
export 'item_condition.dart';
export 'listing.dart';
export 'listing_request.dart';
export 'listing_status.dart';
export 'listing_type.dart';
export 'listing_view.dart';
export 'member_profile.dart';
export 'message_kind.dart';
export 'my_request_view.dart';
export 'not_allowed_exception.dart';
export 'notification_kind.dart';
export 'photo_upload.dart';
export 'profile_required_exception.dart';
export 'public_profile_view.dart';
export 'report.dart';
export 'report_reason.dart';
export 'request_status.dart';
export 'request_view.dart';
export 'review.dart';
export 'review_view.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _itrmkf8a.AccountType) {
      return _itrmkf8a.AccountType.fromJson(data) as T;
    }
    if (t == _ip1vhxmg.AppNotification) {
      return _ip1vhxmg.AppNotification.fromJson(data) as T;
    }
    if (t == _issw2w8j.Category) {
      return _issw2w8j.Category.fromJson(data) as T;
    }
    if (t == _ivuncx2e.ChatMessage) {
      return _ivuncx2e.ChatMessage.fromJson(data) as T;
    }
    if (t == _iukzfy8n.CommunityImpact) {
      return _iukzfy8n.CommunityImpact.fromJson(data) as T;
    }
    if (t == _ineda879.Conversation) {
      return _ineda879.Conversation.fromJson(data) as T;
    }
    if (t == _iz4kexi3.ConversationView) {
      return _iz4kexi3.ConversationView.fromJson(data) as T;
    }
    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _ittj06x2.ItemCondition) {
      return _ittj06x2.ItemCondition.fromJson(data) as T;
    }
    if (t == _ir9e9w84.Listing) {
      return _ir9e9w84.Listing.fromJson(data) as T;
    }
    if (t == _i0jjpqa3.ListingRequest) {
      return _i0jjpqa3.ListingRequest.fromJson(data) as T;
    }
    if (t == _igczfm3x.ListingStatus) {
      return _igczfm3x.ListingStatus.fromJson(data) as T;
    }
    if (t == _i1ntjlwm.ListingType) {
      return _i1ntjlwm.ListingType.fromJson(data) as T;
    }
    if (t == _ijuym7ok.ListingView) {
      return _ijuym7ok.ListingView.fromJson(data) as T;
    }
    if (t == _iuh59zig.MemberProfile) {
      return _iuh59zig.MemberProfile.fromJson(data) as T;
    }
    if (t == _ibvtcu73.MessageKind) {
      return _ibvtcu73.MessageKind.fromJson(data) as T;
    }
    if (t == _ioyw6oo5.MyRequestView) {
      return _ioyw6oo5.MyRequestView.fromJson(data) as T;
    }
    if (t == _icn336wo.NotAllowedException) {
      return _icn336wo.NotAllowedException.fromJson(data) as T;
    }
    if (t == _ipnxo26v.NotificationKind) {
      return _ipnxo26v.NotificationKind.fromJson(data) as T;
    }
    if (t == _ihl17tin.PhotoUpload) {
      return _ihl17tin.PhotoUpload.fromJson(data) as T;
    }
    if (t == _iarivcoc.ProfileRequiredException) {
      return _iarivcoc.ProfileRequiredException.fromJson(data) as T;
    }
    if (t == _io3x196o.PublicProfileView) {
      return _io3x196o.PublicProfileView.fromJson(data) as T;
    }
    if (t == _i2t8i3ij.Report) {
      return _i2t8i3ij.Report.fromJson(data) as T;
    }
    if (t == _ijgj7dn0.ReportReason) {
      return _ijgj7dn0.ReportReason.fromJson(data) as T;
    }
    if (t == _iq8zsng0.RequestStatus) {
      return _iq8zsng0.RequestStatus.fromJson(data) as T;
    }
    if (t == _iv1530zw.RequestView) {
      return _iv1530zw.RequestView.fromJson(data) as T;
    }
    if (t == _itqm5y01.Review) {
      return _itqm5y01.Review.fromJson(data) as T;
    }
    if (t == _io58qecx.ReviewView) {
      return _io58qecx.ReviewView.fromJson(data) as T;
    }
    if (t == _isc.getType<_itrmkf8a.AccountType?>()) {
      return (data != null ? _itrmkf8a.AccountType.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ip1vhxmg.AppNotification?>()) {
      return (data != null ? _ip1vhxmg.AppNotification.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_issw2w8j.Category?>()) {
      return (data != null ? _issw2w8j.Category.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ivuncx2e.ChatMessage?>()) {
      return (data != null ? _ivuncx2e.ChatMessage.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iukzfy8n.CommunityImpact?>()) {
      return (data != null ? _iukzfy8n.CommunityImpact.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ineda879.Conversation?>()) {
      return (data != null ? _ineda879.Conversation.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iz4kexi3.ConversationView?>()) {
      return (data != null ? _iz4kexi3.ConversationView.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ittj06x2.ItemCondition?>()) {
      return (data != null ? _ittj06x2.ItemCondition.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ir9e9w84.Listing?>()) {
      return (data != null ? _ir9e9w84.Listing.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i0jjpqa3.ListingRequest?>()) {
      return (data != null ? _i0jjpqa3.ListingRequest.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_igczfm3x.ListingStatus?>()) {
      return (data != null ? _igczfm3x.ListingStatus.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i1ntjlwm.ListingType?>()) {
      return (data != null ? _i1ntjlwm.ListingType.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ijuym7ok.ListingView?>()) {
      return (data != null ? _ijuym7ok.ListingView.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iuh59zig.MemberProfile?>()) {
      return (data != null ? _iuh59zig.MemberProfile.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ibvtcu73.MessageKind?>()) {
      return (data != null ? _ibvtcu73.MessageKind.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ioyw6oo5.MyRequestView?>()) {
      return (data != null ? _ioyw6oo5.MyRequestView.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_icn336wo.NotAllowedException?>()) {
      return (data != null
              ? _icn336wo.NotAllowedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ipnxo26v.NotificationKind?>()) {
      return (data != null ? _ipnxo26v.NotificationKind.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ihl17tin.PhotoUpload?>()) {
      return (data != null ? _ihl17tin.PhotoUpload.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iarivcoc.ProfileRequiredException?>()) {
      return (data != null
              ? _iarivcoc.ProfileRequiredException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_io3x196o.PublicProfileView?>()) {
      return (data != null ? _io3x196o.PublicProfileView.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i2t8i3ij.Report?>()) {
      return (data != null ? _i2t8i3ij.Report.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ijgj7dn0.ReportReason?>()) {
      return (data != null ? _ijgj7dn0.ReportReason.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iq8zsng0.RequestStatus?>()) {
      return (data != null ? _iq8zsng0.RequestStatus.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iv1530zw.RequestView?>()) {
      return (data != null ? _iv1530zw.RequestView.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_itqm5y01.Review?>()) {
      return (data != null ? _itqm5y01.Review.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_io58qecx.ReviewView?>()) {
      return (data != null ? _io58qecx.ReviewView.fromJson(data) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_ijuym7ok.ListingView>) {
      return (data as List)
              .map((e) => deserialize<_ijuym7ok.ListingView>(e))
              .toList()
          as T;
    }
    if (t == List<_io58qecx.ReviewView>) {
      return (data as List)
              .map((e) => deserialize<_io58qecx.ReviewView>(e))
              .toList()
          as T;
    }
    if (t == List<_ixj8t0ja.ConversationView>) {
      return (data as List)
              .map((e) => deserialize<_ixj8t0ja.ConversationView>(e))
              .toList()
          as T;
    }
    if (t == List<_ir83d1bh.ChatMessage>) {
      return (data as List)
              .map((e) => deserialize<_ir83d1bh.ChatMessage>(e))
              .toList()
          as T;
    }
    if (t == List<_ijh8j4ei.ListingView>) {
      return (data as List)
              .map((e) => deserialize<_ijh8j4ei.ListingView>(e))
              .toList()
          as T;
    }
    if (t == List<_irhv3nen.AppNotification>) {
      return (data as List)
              .map((e) => deserialize<_irhv3nen.AppNotification>(e))
              .toList()
          as T;
    }
    if (t == List<_isipxjtl.RequestView>) {
      return (data as List)
              .map((e) => deserialize<_isipxjtl.RequestView>(e))
              .toList()
          as T;
    }
    if (t == List<_ikulhwb6.MyRequestView>) {
      return (data as List)
              .map((e) => deserialize<_ikulhwb6.MyRequestView>(e))
              .toList()
          as T;
    }
    if (t == List<_iv0fqw25.ReviewView>) {
      return (data as List)
              .map((e) => deserialize<_iv0fqw25.ReviewView>(e))
              .toList()
          as T;
    }
    try {
      return _iaic.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacc.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _itrmkf8a.AccountType => 'AccountType',
      _ip1vhxmg.AppNotification => 'AppNotification',
      _issw2w8j.Category => 'Category',
      _ivuncx2e.ChatMessage => 'ChatMessage',
      _iukzfy8n.CommunityImpact => 'CommunityImpact',
      _ineda879.Conversation => 'Conversation',
      _iz4kexi3.ConversationView => 'ConversationView',
      _izw8z7ou.Greeting => 'Greeting',
      _ittj06x2.ItemCondition => 'ItemCondition',
      _ir9e9w84.Listing => 'Listing',
      _i0jjpqa3.ListingRequest => 'ListingRequest',
      _igczfm3x.ListingStatus => 'ListingStatus',
      _i1ntjlwm.ListingType => 'ListingType',
      _ijuym7ok.ListingView => 'ListingView',
      _iuh59zig.MemberProfile => 'MemberProfile',
      _ibvtcu73.MessageKind => 'MessageKind',
      _ioyw6oo5.MyRequestView => 'MyRequestView',
      _icn336wo.NotAllowedException => 'NotAllowedException',
      _ipnxo26v.NotificationKind => 'NotificationKind',
      _ihl17tin.PhotoUpload => 'PhotoUpload',
      _iarivcoc.ProfileRequiredException => 'ProfileRequiredException',
      _io3x196o.PublicProfileView => 'PublicProfileView',
      _i2t8i3ij.Report => 'Report',
      _ijgj7dn0.ReportReason => 'ReportReason',
      _iq8zsng0.RequestStatus => 'RequestStatus',
      _iv1530zw.RequestView => 'RequestView',
      _itqm5y01.Review => 'Review',
      _io58qecx.ReviewView => 'ReviewView',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst(
        'dale_otra_vida.',
        '',
      );
    }

    switch (data) {
      case _itrmkf8a.AccountType():
        return 'AccountType';
      case _ip1vhxmg.AppNotification():
        return 'AppNotification';
      case _issw2w8j.Category():
        return 'Category';
      case _ivuncx2e.ChatMessage():
        return 'ChatMessage';
      case _iukzfy8n.CommunityImpact():
        return 'CommunityImpact';
      case _ineda879.Conversation():
        return 'Conversation';
      case _iz4kexi3.ConversationView():
        return 'ConversationView';
      case _izw8z7ou.Greeting():
        return 'Greeting';
      case _ittj06x2.ItemCondition():
        return 'ItemCondition';
      case _ir9e9w84.Listing():
        return 'Listing';
      case _i0jjpqa3.ListingRequest():
        return 'ListingRequest';
      case _igczfm3x.ListingStatus():
        return 'ListingStatus';
      case _i1ntjlwm.ListingType():
        return 'ListingType';
      case _ijuym7ok.ListingView():
        return 'ListingView';
      case _iuh59zig.MemberProfile():
        return 'MemberProfile';
      case _ibvtcu73.MessageKind():
        return 'MessageKind';
      case _ioyw6oo5.MyRequestView():
        return 'MyRequestView';
      case _icn336wo.NotAllowedException():
        return 'NotAllowedException';
      case _ipnxo26v.NotificationKind():
        return 'NotificationKind';
      case _ihl17tin.PhotoUpload():
        return 'PhotoUpload';
      case _iarivcoc.ProfileRequiredException():
        return 'ProfileRequiredException';
      case _io3x196o.PublicProfileView():
        return 'PublicProfileView';
      case _i2t8i3ij.Report():
        return 'Report';
      case _ijgj7dn0.ReportReason():
        return 'ReportReason';
      case _iq8zsng0.RequestStatus():
        return 'RequestStatus';
      case _iv1530zw.RequestView():
        return 'RequestView';
      case _itqm5y01.Review():
        return 'Review';
      case _io58qecx.ReviewView():
        return 'ReviewView';
    }
    className = _iaic.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacc.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AccountType') {
      return deserialize<_itrmkf8a.AccountType>(data['data']);
    }
    if (dataClassName == 'AppNotification') {
      return deserialize<_ip1vhxmg.AppNotification>(data['data']);
    }
    if (dataClassName == 'Category') {
      return deserialize<_issw2w8j.Category>(data['data']);
    }
    if (dataClassName == 'ChatMessage') {
      return deserialize<_ivuncx2e.ChatMessage>(data['data']);
    }
    if (dataClassName == 'CommunityImpact') {
      return deserialize<_iukzfy8n.CommunityImpact>(data['data']);
    }
    if (dataClassName == 'Conversation') {
      return deserialize<_ineda879.Conversation>(data['data']);
    }
    if (dataClassName == 'ConversationView') {
      return deserialize<_iz4kexi3.ConversationView>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName == 'ItemCondition') {
      return deserialize<_ittj06x2.ItemCondition>(data['data']);
    }
    if (dataClassName == 'Listing') {
      return deserialize<_ir9e9w84.Listing>(data['data']);
    }
    if (dataClassName == 'ListingRequest') {
      return deserialize<_i0jjpqa3.ListingRequest>(data['data']);
    }
    if (dataClassName == 'ListingStatus') {
      return deserialize<_igczfm3x.ListingStatus>(data['data']);
    }
    if (dataClassName == 'ListingType') {
      return deserialize<_i1ntjlwm.ListingType>(data['data']);
    }
    if (dataClassName == 'ListingView') {
      return deserialize<_ijuym7ok.ListingView>(data['data']);
    }
    if (dataClassName == 'MemberProfile') {
      return deserialize<_iuh59zig.MemberProfile>(data['data']);
    }
    if (dataClassName == 'MessageKind') {
      return deserialize<_ibvtcu73.MessageKind>(data['data']);
    }
    if (dataClassName == 'MyRequestView') {
      return deserialize<_ioyw6oo5.MyRequestView>(data['data']);
    }
    if (dataClassName == 'NotAllowedException') {
      return deserialize<_icn336wo.NotAllowedException>(data['data']);
    }
    if (dataClassName == 'NotificationKind') {
      return deserialize<_ipnxo26v.NotificationKind>(data['data']);
    }
    if (dataClassName == 'PhotoUpload') {
      return deserialize<_ihl17tin.PhotoUpload>(data['data']);
    }
    if (dataClassName == 'ProfileRequiredException') {
      return deserialize<_iarivcoc.ProfileRequiredException>(data['data']);
    }
    if (dataClassName == 'PublicProfileView') {
      return deserialize<_io3x196o.PublicProfileView>(data['data']);
    }
    if (dataClassName == 'Report') {
      return deserialize<_i2t8i3ij.Report>(data['data']);
    }
    if (dataClassName == 'ReportReason') {
      return deserialize<_ijgj7dn0.ReportReason>(data['data']);
    }
    if (dataClassName == 'RequestStatus') {
      return deserialize<_iq8zsng0.RequestStatus>(data['data']);
    }
    if (dataClassName == 'RequestView') {
      return deserialize<_iv1530zw.RequestView>(data['data']);
    }
    if (dataClassName == 'Review') {
      return deserialize<_itqm5y01.Review>(data['data']);
    }
    if (dataClassName == 'ReviewView') {
      return deserialize<_io58qecx.ReviewView>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iaic.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacc.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iaic.Protocol().registerHostProtocol('dale_otra_vida', this);
    _iacc.Protocol().registerHostProtocol('dale_otra_vida', this);
  }

  @override
  String getModuleName() => 'dale_otra_vida';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
