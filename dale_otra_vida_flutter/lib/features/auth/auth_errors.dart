import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart'
    show InvalidEmailException;

/// Spanish, user-facing message for any error raised by the email auth flow.
String authErrorMessage(Object error) {
  return switch (error) {
    EmailAccountLoginException(:final reason) => switch (reason) {
      EmailAccountLoginExceptionReason.invalidCredentials =>
        'Correo o contraseña incorrectos.',
      EmailAccountLoginExceptionReason.tooManyAttempts =>
        'Demasiados intentos. Espera unos minutos e inténtalo de nuevo.',
      _ => 'No pudimos iniciar sesión. Inténtalo de nuevo.',
    },
    EmailAccountRequestException(:final reason) => switch (reason) {
      EmailAccountRequestExceptionReason.expired =>
        'El código expiró. Toca "Reenviar código" para recibir uno nuevo.',
      EmailAccountRequestExceptionReason.invalid =>
        'El código no es correcto. Revísalo e inténtalo de nuevo.',
      EmailAccountRequestExceptionReason.tooManyAttempts =>
        'Demasiados intentos. Espera unos minutos e inténtalo de nuevo.',
      EmailAccountRequestExceptionReason.policyViolation =>
        'La contraseña no cumple los requisitos de seguridad.',
      _ => 'No pudimos crear tu cuenta. Inténtalo de nuevo.',
    },
    EmailAccountPasswordResetException(:final reason) => switch (reason) {
      EmailAccountPasswordResetExceptionReason.expired =>
        'El código expiró. Solicita uno nuevo.',
      EmailAccountPasswordResetExceptionReason.invalid =>
        'El código no es correcto. Revísalo e inténtalo de nuevo.',
      EmailAccountPasswordResetExceptionReason.tooManyAttempts =>
        'Demasiados intentos. Espera unos minutos e inténtalo de nuevo.',
      EmailAccountPasswordResetExceptionReason.policyViolation =>
        'La contraseña no cumple los requisitos de seguridad.',
      _ => 'No pudimos cambiar tu contraseña. Inténtalo de nuevo.',
    },
    InvalidEmailException() => 'Ese correo no es válido.',
    ServerpodClientNetworkException() =>
      'No pudimos conectarnos. Revisa tu conexión a internet.',
    _ => 'Algo salió mal. Inténtalo de nuevo.',
  };
}
