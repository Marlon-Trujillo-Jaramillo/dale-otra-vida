import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../client.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/legal.dart';
import '../../core/photos.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';

/// "Verificar identidad": a photo of the cédula and a selfie holding it,
/// reviewed by hand, so the member can ask for loans. Shows the privacy
/// notice and asks for express consent first (Ley 1581 de 2015).
class IdentityScreen extends StatefulWidget {
  const IdentityScreen({super.key});

  @override
  State<IdentityScreen> createState() => _IdentityScreenState();
}

class _IdentityScreenState extends State<IdentityScreen> {
  IdentityState? _state;
  bool _loading = true;
  bool _failed = false;

  final _number = TextEditingController();
  bool _consent = false;
  _Photo? _front;
  _Photo? _selfie;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _number.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final state = await client.identity.mine();
      if (mounted) setState(() => _state = state);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pick(String kind) async {
    final selfie = kind == 'selfie';
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(selfie ? 'Tomar selfie' : 'Tomar foto'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final bytes = await pickPhoto(source, selfie: selfie, jpeg: true);
    if (bytes == null || !mounted) return;
    final photo = _Photo(bytes);
    setState(() => selfie ? _selfie = photo : _front = photo);
    await _upload(kind, photo);
  }

  /// Uploads straight to private storage while the member keeps filling in.
  Future<void> _upload(String kind, _Photo photo) async {
    setState(() {
      photo.uploading = true;
      photo.failed = false;
    });
    try {
      final description = await client.identity.uploadDescription(kind);
      final ok = await uploadPhoto(description.uploadDescription, photo.bytes);
      if (!ok) throw Exception('upload failed');
      photo.path = description.path;
    } catch (_) {
      photo.failed = true;
    } finally {
      if (mounted) setState(() => photo.uploading = false);
    }
  }

  bool get _ready =>
      _consent &&
      RegExp(r'^[0-9]{6,10}$').hasMatch(_digits) &&
      _front?.path != null &&
      _selfie?.path != null;

  String get _digits => _number.text.replaceAll(RegExp(r'[^0-9]'), '');

  Future<void> _submit() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final state = await client.identity.submit(
        documentNumber: _digits,
        frontPath: _front!.path!,
        selfiePath: _selfie!.path!,
        consent: _consent,
      );
      if (mounted) setState(() => _state = state);
    } on NotAllowedException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'No pudimos enviarla. Inténtalo de nuevo.');
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Verificar identidad', style: AppTypography.title),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_failed) {
      return EmptyState(
        icon: Icons.wifi_off_rounded,
        title: 'No pudimos cargar tu verificación',
        message: 'Revisa tu conexión e inténtalo de nuevo.',
        actionLabel: 'Reintentar',
        onAction: _load,
      );
    }
    final status = _state?.status;
    if (status == IdentityStatus.approved) {
      return const EmptyState(
        icon: Icons.verified,
        title: 'Tu identidad está verificada',
        message:
            'Ya puedes pedir préstamos. Tu perfil muestra «Usuario '
            'verificado».',
      );
    }
    if (status == IdentityStatus.pending) {
      return const EmptyState(
        icon: Icons.hourglass_top_rounded,
        title: 'Estamos revisando tu cédula',
        message:
            'Te avisaremos por notificación. Después de la revisión '
            'borramos las fotos.',
      );
    }

    return SingleChildScrollView(
      child: ContentWidth(
        maxWidth: 640,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.l),
            if (status == IdentityStatus.rejected) ...[
              _Notice(
                icon: Icons.error_outline,
                color: AppColors.danger,
                text:
                    'No pudimos verificarte: '
                    '${_state?.rejectionReason ?? 'inténtalo de nuevo'}.',
              ),
              const SizedBox(height: AppSpacing.l),
            ],
            Text(
              'Para pedir préstamos necesitamos confirmar que eres quien dices '
              'ser. Así, si alguien no devuelve lo que le prestaron, hay '
              'datos reales para hacer la denuncia.',
              style: AppTypography.body,
            ),
            const SizedBox(height: AppSpacing.l),
            const _PrivacyNotice(),
            const SizedBox(height: AppSpacing.l),
            AppTextField(
              label: 'Número de cédula',
              hint: 'Solo números',
              controller: _number,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
            Row(
              children: [
                Expanded(
                  child: _PhotoSlot(
                    label: 'Frente de la cédula',
                    icon: Icons.badge_outlined,
                    photo: _front,
                    onTap: _sending ? null : () => _pick('front'),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: _PhotoSlot(
                    label: 'Selfie con la cédula',
                    icon: Icons.face_outlined,
                    photo: _selfie,
                    onTap: _sending ? null : () => _pick('selfie'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Que se lean tu nombre, tu número y tu foto. En la selfie, '
              'sostén la cédula junto a tu cara.',
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.m),
            CheckboxListTile(
              value: _consent,
              onChanged: _sending
                  ? null
                  : (value) => setState(() => _consent = value ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                'Autorizo de forma expresa el tratamiento de mi cédula y mi '
                'foto para verificar mi identidad, según el aviso de '
                'privacidad.',
                style: AppTypography.body,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.s),
              Text(
                _error!,
                style: AppTypography.caption.copyWith(color: AppColors.danger),
              ),
            ],
            const SizedBox(height: AppSpacing.l),
            AppPrimaryButton(
              label: 'Enviar para revisión',
              isLoading: _sending,
              onPressed: _ready && !_sending ? _submit : null,
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _Photo {
  _Photo(this.bytes);

  final Uint8List bytes;
  String? path;
  bool uploading = false;
  bool failed = false;
}

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({
    required this.label,
    required this.icon,
    required this.photo,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final _Photo? photo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final photo = this.photo;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(
              color: photo?.failed == true
                  ? AppColors.danger
                  : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: photo == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 36, color: AppColors.textSecondary),
                    const SizedBox(height: AppSpacing.s),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s,
                      ),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: AppTypography.caption,
                      ),
                    ),
                  ],
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(photo.bytes, fit: BoxFit.cover),
                    if (photo.uploading)
                      const ColoredBox(
                        color: Color(0x66000000),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (photo.failed)
                      const ColoredBox(
                        color: Color(0x99000000),
                        child: Center(
                          child: Text(
                            'Toca para reintentar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Text(text, style: AppTypography.body.copyWith(color: color)),
        ),
      ],
    );
  }
}

/// Aviso de privacidad for this processing (Ley 1581 de 2015, Decreto 1377
/// de 2013): who, what, why, how long, and the member's rights.
class _PrivacyNotice extends StatelessWidget {
  const _PrivacyNotice();

  @override
  Widget build(BuildContext context) {
    Widget item(String title, String body) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$title: ', style: AppTypography.bodyStrong),
            TextSpan(text: body, style: AppTypography.body),
          ],
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aviso de privacidad', style: AppTypography.sectionLabel),
          const SizedBox(height: AppSpacing.m),
          item(
            'Quién',
            'El equipo de Dale Otra Vida es el responsable de estos datos.',
          ),
          item(
            'Qué',
            'El número de tu cédula, una foto de su frente y una selfie '
                'sosteniéndola.',
          ),
          item(
            'Para qué',
            'Solo para verificar tu identidad antes de pedir préstamos y, si '
                'un préstamo no se devuelve, entregar tu nombre y número a '
                'las autoridades que lo soliciten.',
          ),
          item(
            'Cómo',
            'Las fotos se guardan cifradas en un almacenamiento privado, sin '
                'enlaces públicos. Solo un administrador las ve para '
                'compararlas, y las borramos apenas termina la revisión. El '
                'número se conserva mientras tengas tu cuenta.',
          ),
          item(
            'Tus derechos',
            'Puedes conocer, actualizar, rectificar y pedir que borremos tus '
                'datos, o retirar esta autorización, escribiendo a '
                '$privacyContactEmail. Respondemos en máximo 15 días hábiles. '
                'La verificación es opcional: sin ella puedes usar todo menos '
                'pedir préstamos.',
          ),
          TextButton.icon(
            onPressed: openPrivacyPolicy,
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Leer la política de datos completa'),
          ),
        ],
      ),
    );
  }
}
