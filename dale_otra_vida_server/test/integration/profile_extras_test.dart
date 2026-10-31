import 'dart:typed_data';

import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import 'package:dale_otra_vida_server/src/common/uuid.dart';
import 'package:dale_otra_vida_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given profile editing and stats', (sessionBuilder, endpoints) {
    late TestSessionBuilder member;
    late MemberProfile profile;

    setUp(() async {
      final authUser = await AuthUser.db.insertRow(
        sessionBuilder.build(),
        AuthUser(scopeNames: {}),
      );
      member = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          authUser.id!.uuid,
          {},
        ),
      );
      profile = await endpoints.profile.saveMe(
        member,
        displayName: 'Ana',
        neighborhood: 'Laureles',
        latitude: 6.2442,
        longitude: -75.5812,
        accountType: AccountType.business,
      );
    });

    test('saveMe stores the account type, defaulting to person', () async {
      expect(profile.accountType, AccountType.business);
    });

    test('updateMe edits text fields and keeps the location', () async {
      final updated = await endpoints.profile.updateMe(
        member,
        displayName: '  Tienda Ana  ',
        neighborhood: '  ',
        accountType: AccountType.organization,
      );
      expect(updated.displayName, 'Tienda Ana');
      expect(updated.neighborhood, isNull);
      expect(updated.accountType, AccountType.organization);
      expect(updated.latitude, profile.latitude);
      expect(updated.longitude, profile.longitude);

      await expectLater(
        endpoints.profile.updateMe(member, displayName: 'A'),
        throwsA(isA<NotAllowedException>()),
      );
    });

    test('setAvatar accepts only the caller\'s uploaded photo', () async {
      final denied = throwsA(isA<NotAllowedException>());
      await expectLater(
        endpoints.profile.setAvatar(member, 'avatars/999/${uuidV4()}.jpg'),
        denied,
      );
      await expectLater(
        endpoints.profile.setAvatar(
          member,
          'avatars/${profile.id}/${uuidV4()}.jpg',
        ),
        denied,
      );

      final upload = await endpoints.profile.avatarUploadDescription(
        member,
        'png',
      );
      expect(upload.path, startsWith('avatars/${profile.id}/'));
      await member.build().storage.storeFile(
        storageId: 'public',
        path: upload.path,
        byteData: ByteData(8),
      );
      final withPhoto = await endpoints.profile.setAvatar(member, upload.path);
      expect(
        withPhoto.avatarUrl,
        contains(Uri.encodeQueryComponent(upload.path)),
      );

      final removed = await endpoints.profile.setAvatar(member, null);
      expect(removed.avatarUrl, isNull);
    });

    test('community stats count members and listings', () async {
      final stats = await endpoints.stats.community(member);
      expect(stats.memberCount, greaterThanOrEqualTo(1));
      expect(stats.deliveredCount, 0);
      expect(stats.foodSavedCount, 0);
      expect(stats.activeCount, 0);
    });
  });
}
