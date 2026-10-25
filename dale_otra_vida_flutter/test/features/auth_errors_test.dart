import 'package:dale_otra_vida_flutter/features/auth/auth_errors.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart';

void main() {
  test('invalid credentials are explained in Spanish', () {
    expect(
      authErrorMessage(
        EmailAccountLoginException(
          reason: EmailAccountLoginExceptionReason.invalidCredentials,
        ),
      ),
      'Correo o contraseña incorrectos.',
    );
  });

  test('an expired code asks to resend it', () {
    expect(
      authErrorMessage(
        EmailAccountRequestException(
          reason: EmailAccountRequestExceptionReason.expired,
        ),
      ),
      contains('Reenviar código'),
    );
  });

  test('unknown errors fall back to a generic Spanish message', () {
    expect(
      authErrorMessage(StateError('x')),
      'Algo salió mal. Inténtalo de nuevo.',
    );
  });
}
