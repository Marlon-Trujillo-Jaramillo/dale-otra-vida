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
import 'package:dale_otra_vida_server/src/generated/app_notification.dart'
    as _i8mrzz0i;
import 'package:dale_otra_vida_server/src/generated/chat_message.dart'
    as _icgl1ktv;
import 'package:dale_otra_vida_server/src/generated/conversation_view.dart'
    as _inonxfdt;
import 'package:dale_otra_vida_server/src/generated/listing_view.dart'
    as _ilhjw925;
import 'package:dale_otra_vida_server/src/generated/my_request_view.dart'
    as _ij0l268m;
import 'package:dale_otra_vida_server/src/generated/request_view.dart'
    as _ivx3bzvp;
import 'package:dale_otra_vida_server/src/generated/review_view.dart'
    as _iwzyt887;
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
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

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'app_notification',
      dartName: 'AppNotification',
      schema: 'public',
      module: 'dale_otra_vida',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:NotificationKind',
        ),
        _isp.ColumnDefinition(
          name: 'title',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'body',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'refId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'readAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'app_notification_fk_0',
          columns: ['userId'],
          referenceTable: 'member_profile',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'app_notification_user_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'chat_message',
      dartName: 'ChatMessage',
      schema: 'public',
      module: 'dale_otra_vida',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'conversationId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'senderId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:MessageKind',
          columnDefault: '\'text\'',
        ),
        _isp.ColumnDefinition(
          name: 'text',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'readAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'chat_message_fk_0',
          columns: ['conversationId'],
          referenceTable: 'conversation',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'chat_message_fk_1',
          columns: ['senderId'],
          referenceTable: 'member_profile',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.setNull,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'chat_message_conversation_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'conversationId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'conversation',
      dartName: 'Conversation',
      schema: 'public',
      module: 'dale_otra_vida',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'listingId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'ownerId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'requesterId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'lastMessageAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'lastMessagePreview',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'conversation_fk_0',
          columns: ['listingId'],
          referenceTable: 'listing',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'conversation_fk_1',
          columns: ['ownerId'],
          referenceTable: 'member_profile',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'conversation_fk_2',
          columns: ['requesterId'],
          referenceTable: 'member_profile',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'conversation_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'listingId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'requesterId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'conversation_owner_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'ownerId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'conversation_requester_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'requesterId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'listing',
      dartName: 'Listing',
      schema: 'public',
      module: 'dale_otra_vida',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'ownerId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'title',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'description',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'type',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:ListingType',
        ),
        _isp.ColumnDefinition(
          name: 'category',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:Category',
        ),
        _isp.ColumnDefinition(
          name: 'condition',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:ItemCondition',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:ListingStatus',
          columnDefault: '\'available\'',
        ),
        _isp.ColumnDefinition(
          name: 'photoUrls',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'List<String>',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'price',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'returnDate',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'wantedInExchange',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'neighborhood',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'latitude',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'longitude',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'safeMeetingPoint',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'listing_fk_0',
          columns: ['ownerId'],
          referenceTable: 'member_profile',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'listing_status_created_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'status',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'listing_owner_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'ownerId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'listing_category_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'category',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'listing_request',
      dartName: 'ListingRequest',
      schema: 'public',
      module: 'dale_otra_vida',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'listingId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'requesterId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'message',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:RequestStatus',
          columnDefault: '\'pending\'',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'listing_request_fk_0',
          columns: ['listingId'],
          referenceTable: 'listing',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'listing_request_fk_1',
          columns: ['requesterId'],
          referenceTable: 'member_profile',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'listing_request_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'listingId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'requesterId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'member_profile',
      dartName: 'MemberProfile',
      schema: 'public',
      module: 'dale_otra_vida',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'authUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'displayName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'neighborhood',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'latitude',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'longitude',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'avatarUrl',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'isVerified',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'ratingAvg',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'reviewCount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'deliveryCount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'accountType',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:AccountType',
          columnDefault: '\'person\'',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'member_profile_fk_0',
          columns: ['authUserId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'member_profile_auth_user_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'report',
      dartName: 'Report',
      schema: 'public',
      module: 'dale_otra_vida',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'reporterId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'reportedUserId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'listingId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'reason',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:ReportReason',
        ),
        _isp.ColumnDefinition(
          name: 'details',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'report_fk_0',
          columns: ['reporterId'],
          referenceTable: 'member_profile',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'report_fk_1',
          columns: ['reportedUserId'],
          referenceTable: 'member_profile',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'report_fk_2',
          columns: ['listingId'],
          referenceTable: 'listing',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'review',
      dartName: 'Review',
      schema: 'public',
      module: 'dale_otra_vida',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'listingId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'reviewerId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'revieweeId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'rating',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'comment',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'review_fk_0',
          columns: ['listingId'],
          referenceTable: 'listing',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'review_fk_1',
          columns: ['reviewerId'],
          referenceTable: 'member_profile',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'review_fk_2',
          columns: ['revieweeId'],
          referenceTable: 'member_profile',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'review_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'listingId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'reviewerId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'review_reviewee_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'revieweeId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._iais.Protocol.targetTableDefinitions,
    ..._iacs.Protocol.targetTableDefinitions,
    ..._isp.Protocol.targetTableDefinitions,
  ];

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
      } on _is.DeserializationClassNameNotFoundException catch (_) {
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
    if (t == _is.getType<_itrmkf8a.AccountType?>()) {
      return (data != null ? _itrmkf8a.AccountType.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ip1vhxmg.AppNotification?>()) {
      return (data != null ? _ip1vhxmg.AppNotification.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_issw2w8j.Category?>()) {
      return (data != null ? _issw2w8j.Category.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ivuncx2e.ChatMessage?>()) {
      return (data != null ? _ivuncx2e.ChatMessage.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iukzfy8n.CommunityImpact?>()) {
      return (data != null ? _iukzfy8n.CommunityImpact.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ineda879.Conversation?>()) {
      return (data != null ? _ineda879.Conversation.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iz4kexi3.ConversationView?>()) {
      return (data != null ? _iz4kexi3.ConversationView.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ittj06x2.ItemCondition?>()) {
      return (data != null ? _ittj06x2.ItemCondition.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ir9e9w84.Listing?>()) {
      return (data != null ? _ir9e9w84.Listing.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i0jjpqa3.ListingRequest?>()) {
      return (data != null ? _i0jjpqa3.ListingRequest.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_igczfm3x.ListingStatus?>()) {
      return (data != null ? _igczfm3x.ListingStatus.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i1ntjlwm.ListingType?>()) {
      return (data != null ? _i1ntjlwm.ListingType.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ijuym7ok.ListingView?>()) {
      return (data != null ? _ijuym7ok.ListingView.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iuh59zig.MemberProfile?>()) {
      return (data != null ? _iuh59zig.MemberProfile.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ibvtcu73.MessageKind?>()) {
      return (data != null ? _ibvtcu73.MessageKind.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ioyw6oo5.MyRequestView?>()) {
      return (data != null ? _ioyw6oo5.MyRequestView.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_icn336wo.NotAllowedException?>()) {
      return (data != null
              ? _icn336wo.NotAllowedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ipnxo26v.NotificationKind?>()) {
      return (data != null ? _ipnxo26v.NotificationKind.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ihl17tin.PhotoUpload?>()) {
      return (data != null ? _ihl17tin.PhotoUpload.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iarivcoc.ProfileRequiredException?>()) {
      return (data != null
              ? _iarivcoc.ProfileRequiredException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_io3x196o.PublicProfileView?>()) {
      return (data != null ? _io3x196o.PublicProfileView.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i2t8i3ij.Report?>()) {
      return (data != null ? _i2t8i3ij.Report.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ijgj7dn0.ReportReason?>()) {
      return (data != null ? _ijgj7dn0.ReportReason.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iq8zsng0.RequestStatus?>()) {
      return (data != null ? _iq8zsng0.RequestStatus.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iv1530zw.RequestView?>()) {
      return (data != null ? _iv1530zw.RequestView.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_itqm5y01.Review?>()) {
      return (data != null ? _itqm5y01.Review.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_io58qecx.ReviewView?>()) {
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
    if (t == List<_inonxfdt.ConversationView>) {
      return (data as List)
              .map((e) => deserialize<_inonxfdt.ConversationView>(e))
              .toList()
          as T;
    }
    if (t == List<_icgl1ktv.ChatMessage>) {
      return (data as List)
              .map((e) => deserialize<_icgl1ktv.ChatMessage>(e))
              .toList()
          as T;
    }
    if (t == List<_ilhjw925.ListingView>) {
      return (data as List)
              .map((e) => deserialize<_ilhjw925.ListingView>(e))
              .toList()
          as T;
    }
    if (t == List<_i8mrzz0i.AppNotification>) {
      return (data as List)
              .map((e) => deserialize<_i8mrzz0i.AppNotification>(e))
              .toList()
          as T;
    }
    if (t == List<_ivx3bzvp.RequestView>) {
      return (data as List)
              .map((e) => deserialize<_ivx3bzvp.RequestView>(e))
              .toList()
          as T;
    }
    if (t == List<_ij0l268m.MyRequestView>) {
      return (data as List)
              .map((e) => deserialize<_ij0l268m.MyRequestView>(e))
              .toList()
          as T;
    }
    if (t == List<_iwzyt887.ReviewView>) {
      return (data as List)
              .map((e) => deserialize<_iwzyt887.ReviewView>(e))
              .toList()
          as T;
    }
    try {
      return _iais.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacs.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
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
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
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
      return _iais.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacs.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iais.Protocol().registerHostProtocol('dale_otra_vida', this);
    _iacs.Protocol().registerHostProtocol('dale_otra_vida', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _ip1vhxmg.AppNotification:
        return _ip1vhxmg.AppNotification.t;
      case _ivuncx2e.ChatMessage:
        return _ivuncx2e.ChatMessage.t;
      case _ineda879.Conversation:
        return _ineda879.Conversation.t;
      case _ir9e9w84.Listing:
        return _ir9e9w84.Listing.t;
      case _i0jjpqa3.ListingRequest:
        return _i0jjpqa3.ListingRequest.t;
      case _iuh59zig.MemberProfile:
        return _iuh59zig.MemberProfile.t;
      case _i2t8i3ij.Report:
        return _i2t8i3ij.Report.t;
      case _itqm5y01.Review:
        return _itqm5y01.Review.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

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
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
