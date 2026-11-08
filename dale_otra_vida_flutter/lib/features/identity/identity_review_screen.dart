import 'dart:typed_data';

import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/material.dart';

import '../../client.dart';
import '../../core/format.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';

/// Administrators only: pending identity checks to compare by hand. The
/// server checks the permission on every call; this screen just hides the
/// entry for everyone else.
class IdentityReviewScreen extends StatefulWidget {
  const IdentityReviewScreen({super.key});

  @override
  State<IdentityReviewScreen> createState() => _IdentityReviewScreenState();
}

class _IdentityReviewScreenState extends State<IdentityReviewScreen> {
  List<IdentityReviewItem>? _items;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    try {
      final items = await client.identity.pending();
      if (mounted) setState(() => _items = items);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _open(IdentityReviewItem item) async {
    final reviewed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => _ReviewDetail(item: item),
      ),
    );
    if (reviewed == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Revisar identidades', style: AppTypography.title),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: _failed
          ? EmptyState(
              icon: Icons.wifi_off_rounded,
              title: 'No pudimos cargar las verificaciones',
              message: 'Revisa tu conexión e inténtalo de nuevo.',
              actionLabel: 'Reintentar',
              onAction: _load,
            )
          : items == null
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? const EmptyState(
              icon: Icons.task_alt,
              title: 'No hay verificaciones pendientes',
              message: 'Cuando alguien envíe su cédula aparecerá aquí.',
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.l),
                itemCount: items.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.s),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    tileColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    leading: memberAvatar(
                      item.member.displayName,
                      item.member.avatarUrl,
                    ),
                    title: Text(
                      item.member.displayName,
                      style: AppTypography.bodyStrong,
                    ),
                    subtitle: Text(
                      'Enviada el ${formatDate(item.submittedAt)}',
                      style: AppTypography.caption,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _open(item),
                  );
                },
              ),
            ),
    );
  }
}

class _ReviewDetail extends StatefulWidget {
  const _ReviewDetail({required this.item});

  final IdentityReviewItem item;

  @override
  State<_ReviewDetail> createState() => _ReviewDetailState();
}

class _ReviewDetailState extends State<_ReviewDetail> {
  late final Future<List<ByteData>> _photos = Future.wait([
    client.identity.photo(widget.item.verificationId, 'front'),
    client.identity.photo(widget.item.verificationId, 'selfie'),
  ]);
  bool _busy = false;

  Future<void> _review({required bool approve}) async {
    String? reason;
    if (!approve) {
      reason = await _askReason();
      if (reason == null) return;
    }
    setState(() => _busy = true);
    try {
      await client.identity.review(
        widget.item.verificationId,
        approve: approve,
        reason: reason,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on NotAllowedException catch (e) {
      _snack(e.message);
    } catch (_) {
      _snack('No pudimos guardar la revisión.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _askReason() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Motivo del rechazo'),
        content: AppTextField(
          label: 'Se lo mostraremos a la persona',
          hint: 'Ej: La foto está borrosa',
          controller: controller,
          maxLength: 200,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(item.member.displayName, style: AppTypography.title),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ContentWidth(
            maxWidth: 720,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.l),
                Text(
                  'Cédula declarada: ${item.documentNumber}',
                  style: AppTypography.bodyStrong,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Compara el nombre «${item.member.displayName}», el número '
                  'y la cara de la selfie con la cédula.',
                  style: AppTypography.caption,
                ),
                const SizedBox(height: AppSpacing.l),
                FutureBuilder<List<ByteData>>(
                  future: _photos,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('No pudimos cargar las fotos.');
                    }
                    final photos = snapshot.data;
                    if (photos == null) {
                      return const Padding(
                        padding: EdgeInsets.all(AppSpacing.xxl),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return Column(
                      children: [
                        for (final photo in photos) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(
                              photo.buffer.asUint8List(
                                photo.offsetInBytes,
                                photo.lengthInBytes,
                              ),
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.m),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.m),
                AppPrimaryButton(
                  label: 'Aprobar',
                  isLoading: _busy,
                  onPressed: _busy ? null : () => _review(approve: true),
                ),
                const SizedBox(height: AppSpacing.s),
                AppSecondaryButton(
                  label: 'Rechazar',
                  onPressed: _busy ? null : () => _review(approve: false),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  'Al aprobar o rechazar, las fotos se borran para siempre.',
                  style: AppTypography.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
