import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given Profile endpoint', (sessionBuilder, endpoints) {
    late TestSessionBuilder member;

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
    });

    test('when signed in without a profile then me returns null', () async {
      expect(await endpoints.profile.me(member), isNull);
    });

    test(
      'when saving then the profile is created with rounded coordinates',
      () async {
        final saved = await endpoints.profile.saveMe(
          member,
          displayName: '  Marlon  ',
          neighborhood: 'Robledo',
          latitude: 6.2771234,
          longitude: -75.5912345,
        );

        expect(saved.displayName, 'Marlon');
        expect(saved.latitude, 6.277);
        expect(saved.longitude, -75.591);
        expect((await endpoints.profile.me(member))?.id, saved.id);
      },
    );

    test('when saving twice then the same profile is updated', () async {
      final first = await endpoints.profile.saveMe(member, displayName: 'Ana');
      final second = await endpoints.profile.saveMe(
        member,
        displayName: 'Ana María',
      );

      expect(second.id, first.id);
      expect(second.displayName, 'Ana María');
    });

    test('when display name is too short then it throws', () async {
      expect(
        () => endpoints.profile.saveMe(member, displayName: 'A'),
        throwsA(anything),
      );
    });

    test('when reading another profile then location is hidden', () async {
      final saved = await endpoints.profile.saveMe(
        member,
        displayName: 'Nico',
        latitude: 6.25,
        longitude: -75.56,
      );

      final public = await endpoints.profile.byId(member, saved.id!);

      expect(public?.displayName, 'Nico');
      expect(public?.latitude, isNull);
      expect(public?.longitude, isNull);
    });

    test('when not signed in then me is rejected', () async {
      final anonymous = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.unauthenticated(),
      );

      await expectLater(
        endpoints.profile.me(anonymous),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });
  });
}
