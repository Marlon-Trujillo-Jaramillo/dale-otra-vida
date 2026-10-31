import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../client.dart';
import '../../core/format.dart';
import '../../core/photos.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import 'account_type_selector.dart';

/// Edits the member's photo, name, neighborhood and account type. Pops with
/// the saved profile.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final MemberProfile profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final _name = TextEditingController(text: widget.profile.displayName);
  late final _neighborhood = TextEditingController(
    text: widget.profile.neighborhood ?? '',
  );
  late AccountType _accountType = widget.profile.accountType;

  /// New photo picked but not saved yet.
  Uint8List? _newPhoto;
  bool _removePhoto = false;
  bool _saving = false;
  String? _nameError;

  @override
  void dispose() {
    _name.dispose();
    _neighborhood.dispose();
    super.dispose();
  }

  Future<void> _choosePhoto() async {
    final source = kIsWeb
        ? ImageSource.gallery
        : await showModalBottomSheet<ImageSource>(
            context: context,
            showDragHandle: true,
            builder: (context) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.photo_camera_outlined),
                    title: const Text('Tomar foto'),
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
    try {
      final bytes = await pickPhoto(source);
      if (bytes != null && mounted) {
        setState(() {
          _newPhoto = bytes;
          _removePhoto = false;
        });
      }
    } catch (_) {
      _showSnackBar('No pudimos abrir esa foto.');
    }
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.length < 2 || name.length > 60) {
      setState(() => _nameError = 'Usa entre 2 y 60 caracteres.');
      return;
    }
    setState(() {
      _saving = true;
      _nameError = null;
    });
    try {
      var profile = await client.profile.updateMe(
        displayName: name,
        neighborhood: _neighborhood.text,
        accountType: _accountType,
      );
      final photo = _newPhoto;
      if (photo != null) {
        final upload = await client.profile.avatarUploadDescription('jpg');
        if (!await uploadPhoto(upload.uploadDescription, photo)) {
          throw Exception('upload failed');
        }
        profile = await client.profile.setAvatar(upload.path);
      } else if (_removePhoto) {
        profile = await client.profile.setAvatar(null);
      }
      if (mounted) Navigator.of(context).pop(profile);
    } on NotAllowedException catch (e) {
      _showSnackBar(e.message);
    } catch (_) {
      _showSnackBar('No pudimos guardar los cambios. Inténtalo de nuevo.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto =
        _newPhoto != null ||
        (!_removePhoto && (widget.profile.avatarUrl ?? '').isNotEmpty);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Editar perfil', style: AppTypography.title),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: _buildPhoto()),
                  const SizedBox(height: AppSpacing.s),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: _saving ? null : _choosePhoto,
                        icon: const Icon(Icons.photo_camera_outlined, size: 18),
                        label: Text(hasPhoto ? 'Cambiar foto' : 'Agregar foto'),
                      ),
                      if (hasPhoto)
                        TextButton(
                          onPressed: _saving
                              ? null
                              : () => setState(() {
                                  _newPhoto = null;
                                  _removePhoto = true;
                                }),
                          child: Text(
                            'Quitar',
                            style: AppTypography.bodyStrong.copyWith(
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.l),
                  AppTextField(
                    label: 'Nombre',
                    hint: 'Tu nombre, el de tu negocio u organización',
                    controller: _name,
                    maxLength: 60,
                    errorText: _nameError,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AppTextField(
                    label: 'Barrio',
                    hint: 'Ej: Robledo',
                    controller: _neighborhood,
                    maxLength: 60,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: AppSpacing.l),
                  AccountTypeSelector(
                    value: _accountType,
                    onChanged: (type) => setState(() => _accountType = type),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppPrimaryButton(
                    label: 'Guardar cambios',
                    isLoading: _saving,
                    onPressed: _saving ? null : _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoto() {
    const size = 104.0;
    final photo = _newPhoto;
    if (photo != null) {
      return ClipOval(
        child: Image.memory(
          photo,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }
    return AppAvatar(
      initials: initialsFor(_name.text),
      imageUrl: _removePhoto ? null : widget.profile.avatarUrl,
      size: size,
    );
  }
}
