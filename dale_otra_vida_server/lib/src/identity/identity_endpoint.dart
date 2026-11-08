import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../common/current_profile.dart';
import '../common/uuid.dart';
import '../generated/protocol.dart';
import '../notifications/notify.dart';

/// Comma-separated emails of the administrators who review identity checks
/// (`scloud password set identityAdmins "a@x.com,b@y.com"`).
const _adminsPassword = 'identityAdmins';

/// Photos go to private storage only: never a public URL.
const _storage = 'private';

const _photoOptions = UploadOptions(
  maxFileSize: 5 * 1024 * 1024,
  preventOverwrite: true,
);

/// Identity checks for loans: the member uploads a photo of the cédula and a
/// selfie holding it, an administrator compares them by hand, and the photos
/// are deleted right after. Approved members get `isVerified` and can ask
/// for loans.
class IdentityEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// The caller's own check, without number or photos.
  Future<IdentityState> mine(Session session) async {
    final profile = await currentProfile(session);
    final row = await IdentityVerification.db.findFirstRow(
      session,
      where: (t) => t.profileId.equals(profile.id!),
    );
    return IdentityState(
      status: row?.status,
      rejectionReason: row?.rejectionReason,
      submittedAt: row?.submittedAt,
    );
  }

  /// Where to upload one photo (`front` or `selfie`) in private storage.
  Future<PhotoUpload> uploadDescription(Session session, String kind) async {
    final profile = await currentProfile(session);
    if (kind != 'front' && kind != 'selfie') {
      throw NotAllowedException(message: 'Tipo de foto inválido.');
    }
    final path = 'identity/${profile.id}/$kind-${uuidV4()}.jpg';
    final description = await session.storage.createUploadDescription(
      storageId: _storage,
      path: path,
      options: _photoOptions,
    );
    return PhotoUpload(path: path, uploadDescription: description);
  }

  /// Sends the check for review. [consent] must be the member's express
  /// authorization; it is stored with its date.
  Future<IdentityState> submit(
    Session session, {
    required String documentNumber,
    required String frontPath,
    required String selfiePath,
    required bool consent,
  }) async {
    final profile = await currentProfile(session);
    final me = profile.id!;

    if (!consent) {
      throw NotAllowedException(
        message: 'Necesitamos tu autorización para revisar tu cédula.',
      );
    }
    final number = documentNumber.replaceAll(RegExp(r'[\s.\-]'), '');
    if (!RegExp(r'^[0-9]{6,10}$').hasMatch(number)) {
      throw NotAllowedException(
        message: 'Escribe el número de tu cédula, solo dígitos (6 a 10).',
      );
    }
    final ownPath = RegExp(
      '^identity/$me/(front|selfie)-[0-9a-f-]{36}\\.jpg\$',
    );
    if (!ownPath.hasMatch(frontPath) ||
        !ownPath.hasMatch(selfiePath) ||
        !frontPath.contains('/front-') ||
        !selfiePath.contains('/selfie-')) {
      throw NotAllowedException(message: 'Fotos inválidas.');
    }
    for (final path in [frontPath, selfiePath]) {
      if (!await session.storage.fileExists(storageId: _storage, path: path)) {
        throw NotAllowedException(message: 'No encontramos una de las fotos.');
      }
    }

    final now = DateTime.now().toUtc();
    return session.db.transaction((transaction) async {
      final existing = await IdentityVerification.db.findFirstRow(
        session,
        where: (t) => t.profileId.equals(me),
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (existing?.status == IdentityStatus.approved) {
        throw NotAllowedException(message: 'Tu identidad ya está verificada.');
      }
      if (existing?.status == IdentityStatus.pending) {
        throw NotAllowedException(
          message: 'Tu verificación ya está en revisión.',
        );
      }
      // Against abuse of manual reviews: one new try a day after a rejection.
      final reviewedAt = existing?.reviewedAt;
      if (reviewedAt != null &&
          now.difference(reviewedAt) < const Duration(days: 1)) {
        throw NotAllowedException(
          message: 'Podrás volver a intentarlo mañana.',
        );
      }

      final row = IdentityVerification(
        profileId: me,
        status: IdentityStatus.pending,
        documentNumber: number,
        frontPath: frontPath,
        selfiePath: selfiePath,
        consentAt: now,
        submittedAt: now,
      );
      if (existing == null) {
        await IdentityVerification.db.insertRow(
          session,
          row,
          transaction: transaction,
        );
      } else {
        await IdentityVerification.db.updateRow(
          session,
          row.copyWith(id: existing.id),
          transaction: transaction,
        );
      }
      return IdentityState(status: IdentityStatus.pending, submittedAt: now);
    });
  }

  // --- Administrators -----------------------------------------------------

  /// Whether the caller reviews identity checks.
  Future<bool> isAdmin(Session session) => _isAdmin(session);

  /// Pending checks, oldest first.
  Future<List<IdentityReviewItem>> pending(Session session) async {
    await _requireAdmin(session);
    final rows = await IdentityVerification.db.find(
      session,
      where: (t) => t.status.equals(IdentityStatus.pending),
      orderBy: (t) => t.submittedAt,
      limit: 50,
    );
    if (rows.isEmpty) return [];
    final members = await MemberProfile.db.find(
      session,
      where: (t) => t.id.inSet(rows.map((r) => r.profileId).toSet()),
    );
    final byId = {
      for (final member in members)
        member.id!: member.copyWith(latitude: null, longitude: null),
    };
    return [
      for (final row in rows)
        if (byId[row.profileId] case final member?)
          IdentityReviewItem(
            verificationId: row.id!,
            member: member,
            documentNumber: row.documentNumber,
            submittedAt: row.submittedAt,
          ),
    ];
  }

  /// The bytes of one photo of a pending check (`front` or `selfie`), read
  /// from private storage. Never exposed as a URL.
  Future<ByteData> photo(
    Session session,
    int verificationId,
    String kind,
  ) async {
    await _requireAdmin(session);
    final row = await IdentityVerification.db.findById(session, verificationId);
    final path = kind == 'front' ? row?.frontPath : row?.selfiePath;
    if (row == null || row.status != IdentityStatus.pending || path == null) {
      throw NotAllowedException(message: 'Foto no disponible.');
    }
    return session.storage.retrieveFile(storageId: _storage, path: path);
  }

  /// Approves or rejects a pending check and deletes its photos.
  Future<void> review(
    Session session,
    int verificationId, {
    required bool approve,
    String? reason,
  }) async {
    final admin = await _requireAdmin(session);
    final note = reason?.trim();
    if (!approve && (note == null || note.length < 5 || note.length > 200)) {
      throw NotAllowedException(
        message: 'Explica el motivo del rechazo (5 a 200 caracteres).',
      );
    }

    final paths = await session.db.transaction((transaction) async {
      final row = await IdentityVerification.db.findById(
        session,
        verificationId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (row == null || row.status != IdentityStatus.pending) {
        throw NotAllowedException(message: 'Esta verificación ya se revisó.');
      }
      if (row.profileId == admin.id) {
        throw NotAllowedException(
          message: 'No puedes revisar tu propia verificación.',
        );
      }
      await IdentityVerification.db.updateRow(
        session,
        row.copyWith(
          status: approve ? IdentityStatus.approved : IdentityStatus.rejected,
          reviewedAt: DateTime.now().toUtc(),
          reviewedBy: admin.id,
          rejectionReason: approve ? null : note,
          frontPath: null,
          selfiePath: null,
        ),
        transaction: transaction,
      );
      if (approve) {
        final member = await MemberProfile.db.findById(
          session,
          row.profileId,
          transaction: transaction,
          lockMode: LockMode.forUpdate,
        );
        if (member != null) {
          await MemberProfile.db.updateRow(
            session,
            member.copyWith(isVerified: true),
            columns: (t) => [t.isVerified],
            transaction: transaction,
          );
        }
      }
      await notify(
        session,
        userId: row.profileId,
        kind: NotificationKind.identityReviewed,
        title: approve ? '¡Identidad verificada!' : 'Verificación rechazada',
        body: approve
            ? 'Ya puedes pedir préstamos. Tu perfil muestra «Usuario '
                  'verificado».'
            : 'Motivo: $note. Puedes intentarlo de nuevo mañana.',
        transaction: transaction,
      );
      return [row.frontPath, row.selfiePath];
    });

    // Data minimization: the photos are not needed after the review.
    for (final path in paths) {
      if (path == null) continue;
      try {
        await session.storage.deleteFile(storageId: _storage, path: path);
      } catch (e) {
        session.log(
          'Could not delete identity photo $path',
          level: LogLevel.warning,
          exception: e,
        );
      }
    }
  }

  Future<bool> _isAdmin(Session session) async {
    final admins = (session.serverpod.getPassword(_adminsPassword) ?? '')
        .split(',')
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet();
    if (admins.isEmpty) return false;
    final authUserId = session.authenticated!.authUserId;
    final emails = <String>{
      for (final account in await EmailAccount.db.find(
        session,
        where: (t) => t.authUserId.equals(authUserId),
      ))
        account.email.toLowerCase(),
      for (final account in await GoogleAccount.db.find(
        session,
        where: (t) => t.authUserId.equals(authUserId),
      ))
        account.email.toLowerCase(),
    };
    return emails.any(admins.contains);
  }

  Future<MemberProfile> _requireAdmin(Session session) async {
    if (!await _isAdmin(session)) {
      throw NotAllowedException(message: 'No tienes permiso.');
    }
    return currentProfile(session);
  }
}
