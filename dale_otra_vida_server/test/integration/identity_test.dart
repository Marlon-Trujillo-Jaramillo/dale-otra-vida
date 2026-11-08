import 'dart:typed_data';

import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import 'package:dale_otra_vida_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';

// The administrator email comes from the `identityAdmins` password:
// config/passwords.yaml (test) locally, SERVERPOD_PASSWORD_identityAdmins in CI.
const _adminEmail = 'admin@test.dov';

void main() {
  withServerpod('Given identity checks', (sessionBuilder, endpoints) {
    late TestSessionBuilder member;
    late MemberProfile memberProfile;
    late TestSessionBuilder admin;

    Future<(TestSessionBuilder, MemberProfile)> signUp(
      String name, {
      String? email,
    }) async {
      final authUser = await AuthUser.db.insertRow(
        sessionBuilder.build(),
        AuthUser(scopeNames: {}),
      );
      if (email != null) {
        await EmailAccount.db.insertRow(
          sessionBuilder.build(),
          EmailAccount(
            authUserId: authUser.id!,
            email: email,
            passwordHash: 'x',
          ),
        );
      }
      final builder = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          authUser.id!.uuid,
          {},
        ),
      );
      return (
        builder,
        await endpoints.profile.saveMe(builder, displayName: name),
      );
    }

    /// Uploads both photos for [who] and returns their paths.
    Future<(String, String)> photos(TestSessionBuilder who) async {
      final paths = <String>[];
      for (final kind in ['front', 'selfie']) {
        final upload = await endpoints.identity.uploadDescription(who, kind);
        await who.build().storage.storeFile(
          storageId: 'private',
          path: upload.path,
          byteData: ByteData(8),
        );
        paths.add(upload.path);
      }
      return (paths[0], paths[1]);
    }

    Future<IdentityState> submit(TestSessionBuilder who) async {
      final (front, selfie) = await photos(who);
      return endpoints.identity.submit(
        who,
        documentNumber: '1.020.304.050',
        frontPath: front,
        selfiePath: selfie,
        consent: true,
      );
    }

    setUp(() async {
      (member, memberProfile) = await signUp('Luis');
      (admin, _) = await signUp('Admin', email: _adminEmail);
    });

    test('photos go to the member\'s private folder', () async {
      final upload = await endpoints.identity.uploadDescription(
        member,
        'front',
      );
      expect(
        upload.path,
        matches(RegExp('^identity/${memberProfile.id}/front-.+\\.jpg\$')),
      );
      await expectLater(
        endpoints.identity.uploadDescription(member, 'other'),
        throwsA(isA<NotAllowedException>()),
      );
    });

    test('submitting needs consent, a valid number and own photos', () async {
      final (front, selfie) = await photos(member);
      final denied = throwsA(isA<NotAllowedException>());
      await expectLater(
        endpoints.identity.submit(
          member,
          documentNumber: '1020304050',
          frontPath: front,
          selfiePath: selfie,
          consent: false,
        ),
        denied,
      );
      await expectLater(
        endpoints.identity.submit(
          member,
          documentNumber: 'abc',
          frontPath: front,
          selfiePath: selfie,
          consent: true,
        ),
        denied,
      );
      final (other, _) = await signUp('Caro');
      final (otherFront, otherSelfie) = await photos(other);
      await expectLater(
        endpoints.identity.submit(
          member,
          documentNumber: '1020304050',
          frontPath: otherFront,
          selfiePath: otherSelfie,
          consent: true,
        ),
        denied,
      );

      final state = await submit(member);
      expect(state.status, IdentityStatus.pending);
      final row = await IdentityVerification.db.findFirstRow(
        sessionBuilder.build(),
      );
      expect(row!.documentNumber, '1020304050');
      expect(row.consentAt, isNotNull);
    });

    test('only administrators see and review checks', () async {
      await submit(member);
      final denied = throwsA(isA<NotAllowedException>());
      expect(await endpoints.identity.isAdmin(member), isFalse);
      await expectLater(endpoints.identity.pending(member), denied);

      expect(await endpoints.identity.isAdmin(admin), isTrue);
      final item = (await endpoints.identity.pending(admin)).single;
      expect(item.documentNumber, '1020304050');
      await expectLater(
        endpoints.identity.photo(member, item.verificationId, 'front'),
        denied,
      );
      final bytes = await endpoints.identity.photo(
        admin,
        item.verificationId,
        'front',
      );
      expect(bytes.lengthInBytes, 8);
    });

    test('approving verifies the member and deletes the photos', () async {
      await submit(member);
      final row = (await IdentityVerification.db.findFirstRow(
        sessionBuilder.build(),
      ))!;
      final item = (await endpoints.identity.pending(admin)).single;

      await endpoints.identity.review(
        admin,
        item.verificationId,
        approve: true,
      );

      final session = sessionBuilder.build();
      expect(
        (await MemberProfile.db.findById(
          session,
          memberProfile.id!,
        ))!.isVerified,
        isTrue,
      );
      expect(
        await session.storage.fileExists(
          storageId: 'private',
          path: row.frontPath!,
        ),
        isFalse,
      );
      expect(
        (await endpoints.identity.mine(member)).status,
        IdentityStatus.approved,
      );
    });

    test(
      'a rejection needs a reason and allows a retry the next day',
      () async {
        await submit(member);
        final item = (await endpoints.identity.pending(admin)).single;
        await expectLater(
          endpoints.identity.review(admin, item.verificationId, approve: false),
          throwsA(isA<NotAllowedException>()),
        );
        await endpoints.identity.review(
          admin,
          item.verificationId,
          approve: false,
          reason: 'La foto está borrosa',
        );
        final mine = await endpoints.identity.mine(member);
        expect(mine.status, IdentityStatus.rejected);
        expect(mine.rejectionReason, 'La foto está borrosa');
        await expectLater(
          submit(member),
          throwsA(isA<NotAllowedException>()),
        );
      },
    );
  });
}
