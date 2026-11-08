import 'dart:async';

import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../app/navigation.dart';
import '../../client.dart';
import '../../core/format.dart';
import '../../core/location.dart';
import '../../core/photos.dart';
import '../../core/models/category_ui.dart';
import '../../core/models/listing_type_ui.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_primary_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../map/zone_map.dart';
import '../map/zone_picker_screen.dart';
import 'listing_draft.dart';

class PublishScreen extends StatefulWidget {
  const PublishScreen({
    super.key,
    required this.profile,
    this.editing,
    this.asDialog = false,
  });

  final MemberProfile profile;

  /// Shown in a dialog on wide screens (closes with the dialog) rather than
  /// as its own screen at /publicar.
  final bool asDialog;

  /// The listing to edit. Its type, category and photos stay fixed.
  final Listing? editing;

  @override
  State<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends State<PublishScreen> {
  late ListingDraft _draft;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _wantedController = TextEditingController();
  final _depositController = TextEditingController();
  final _lateFeeController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _meetingPointController = TextEditingController();

  final List<_PhotoUpload> _photos = [];
  bool _gettingLocation = false;
  bool _submitting = false;
  bool _saved = false;

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final editing = widget.editing;
    if (editing != null) {
      _draft = ListingDraft.fromListing(editing);
      _titleController.text = editing.title;
      _descriptionController.text = editing.description;
      _priceController.text = editing.price == null
          ? ''
          : CopInputFormatter.format(editing.price!);
      _wantedController.text = editing.wantedInExchange ?? '';
      _depositController.text = editing.depositAmount == null
          ? ''
          : CopInputFormatter.format(editing.depositAmount!);
      _lateFeeController.text = editing.lateFeePerDay == null
          ? ''
          : CopInputFormatter.format(editing.lateFeePerDay!);
      _conditionsController.text = editing.loanConditions ?? '';
      _meetingPointController.text = editing.safeMeetingPoint ?? '';
    } else {
      _draft = ListingDraft(neighborhood: widget.profile.neighborhood ?? '');
    }
    _neighborhoodController.text = _draft.neighborhood;
    _titleController.addListener(_syncTitle);
    _descriptionController.addListener(_syncDescription);
    _priceController.addListener(_syncPrice);
    _wantedController.addListener(_syncWanted);
    _depositController.addListener(_syncLoanTerms);
    _lateFeeController.addListener(_syncLoanTerms);
    _conditionsController.addListener(_syncLoanTerms);
    _neighborhoodController.addListener(_syncNeighborhood);
    _meetingPointController.addListener(_syncMeetingPoint);
    // No GPS prompt on open: the member chooses the zone on the map or
    // taps "Usar mi ubicación".
  }

  @override
  void dispose() {
    _titleController.removeListener(_syncTitle);
    _descriptionController.removeListener(_syncDescription);
    _priceController.removeListener(_syncPrice);
    _wantedController.removeListener(_syncWanted);
    _depositController.removeListener(_syncLoanTerms);
    _lateFeeController.removeListener(_syncLoanTerms);
    _conditionsController.removeListener(_syncLoanTerms);
    _neighborhoodController.removeListener(_syncNeighborhood);
    _meetingPointController.removeListener(_syncMeetingPoint);
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _wantedController.dispose();
    _depositController.dispose();
    _lateFeeController.dispose();
    _conditionsController.dispose();
    _neighborhoodController.dispose();
    _meetingPointController.dispose();
    super.dispose();
  }

  void _syncTitle() =>
      setState(() => _draft = _draft.copyWith(title: _titleController.text));
  void _syncDescription() => setState(
    () => _draft = _draft.copyWith(description: _descriptionController.text),
  );
  void _syncWanted() => setState(
    () => _draft = _draft.copyWith(wantedInExchange: _wantedController.text),
  );
  void _syncNeighborhood() => setState(
    () => _draft = _draft.copyWith(neighborhood: _neighborhoodController.text),
  );
  void _syncMeetingPoint() => setState(
    () => _draft = _draft.copyWith(
      safeMeetingPoint: _meetingPointController.text,
    ),
  );

  int? _cop(TextEditingController controller) {
    final digits = controller.text.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isEmpty ? null : int.tryParse(digits);
  }

  void _syncLoanTerms() => setState(
    () => _draft = _draft.copyWith(
      depositAmount: _cop(_depositController),
      lateFeePerDay: _cop(_lateFeeController),
      loanConditions: _conditionsController.text,
    ),
  );

  void _syncPrice() {
    final digits = _priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final value = digits.isEmpty ? null : int.tryParse(digits);
    setState(() => _draft = _draft.copyWith(price: value));
  }

  Future<void> _getLocation() async {
    setState(() => _gettingLocation = true);
    final loc = await currentApproxLocation();
    if (!mounted) return;
    setState(() {
      // A refused or failed GPS keeps whatever zone was chosen before.
      if (loc != null) {
        _draft = _draft.copyWith(latitude: loc.lat, longitude: loc.lng);
      }
      _gettingLocation = false;
    });
    if (loc == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No pudimos usar tu ubicación. Elige tu zona en el mapa.',
          ),
        ),
      );
    }
  }

  Future<void> _pickOnMap() async {
    final lat = _draft.latitude;
    final lng = _draft.longitude;
    final picked = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute<LatLng>(
        builder: (context) => ZonePickerScreen(
          initial: lat == null || lng == null ? null : LatLng(lat, lng),
        ),
      ),
    );
    if (picked == null || !mounted) return;
    setState(
      () => _draft = _draft.copyWith(
        latitude: picked.latitude,
        longitude: picked.longitude,
      ),
    );
  }

  bool get _hasUnsavedChanges {
    final editing = widget.editing;
    if (editing != null) {
      if (_saved) return false;
      final initial = ListingDraft.fromListing(editing);
      return _draft.title.trim() != initial.title ||
          _draft.description.trim() != initial.description ||
          _draft.condition != initial.condition ||
          _draft.expiresAt != initial.expiresAt ||
          _draft.price != initial.price ||
          _draft.returnDate != initial.returnDate ||
          _draft.wantedInExchange.trim() != initial.wantedInExchange ||
          _draft.neighborhood.trim() != initial.neighborhood ||
          _draft.safeMeetingPoint.trim() != initial.safeMeetingPoint;
    }
    return _photos.isNotEmpty ||
        _draft.type != null ||
        _draft.category != null ||
        _draft.title.trim().isNotEmpty ||
        _draft.description.trim().isNotEmpty ||
        _draft.condition != null ||
        _draft.expiresAt != null ||
        _draft.price != null ||
        _draft.returnDate != null ||
        _draft.wantedInExchange.trim().isNotEmpty ||
        _draft.safeMeetingPoint.trim().isNotEmpty;
  }

  Future<bool> _confirmDiscard() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Descartar publicación?'),
        content: const Text(
          'Tienes cambios sin guardar. Si sales, se perderán.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Seguir editando'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Descartar',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _onClose() async {
    if (_hasUnsavedChanges && !await _confirmDiscard()) return;
    if (!mounted) return;
    _close();
  }

  void _close([bool? published]) {
    if (widget.asDialog) {
      Navigator.of(context).pop(published);
    } else {
      closeScreen(context, published);
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final Uint8List? bytes;
    try {
      bytes = await pickPhoto(source);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No pudimos abrir esa foto.')),
        );
      }
      return;
    }
    if (!mounted || bytes == null) return;

    final upload = _PhotoUpload(bytes: bytes);
    setState(() => _photos.add(upload));
    await _uploadPhoto(upload);
  }

  Future<void> _uploadPhoto(_PhotoUpload upload) async {
    setState(() {
      upload.loading = true;
      upload.error = false;
    });
    try {
      final description = await client.listing.photoUploadDescription(
        photoExtension,
      );
      if (!mounted) return;
      final ok = await uploadPhoto(description.uploadDescription, upload.bytes);
      if (!mounted) return;
      if (!ok) throw Exception('upload failed');
      // No separate verify call: listing.create checks every photo exists,
      // which saves a round trip per photo.

      setState(() {
        upload.path = description.path;
        upload.loading = false;
      });
      _syncPhotos();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        upload.loading = false;
        upload.error = true;
      });
    }
  }

  void _syncPhotos() {
    setState(() {
      _draft = _draft.copyWith(
        photos: _photos
            .where((p) => p.path != null)
            .map((p) => p.path!)
            .toList(),
      );
    });
  }

  void _removePhoto(int index) {
    setState(() => _photos.removeAt(index));
    _syncPhotos();
  }

  void _showPhotoSourceSheet() {
    if (!askPhotoSource) {
      _pickPhoto(ImageSource.gallery);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.of(context).pop();
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de la galería'),
              onTap: () {
                Navigator.of(context).pop();
                _pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isExpiry}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: isExpiry
          ? DateTime(now.year + 10, 12, 31)
          : now.add(const Duration(days: maxLoanDays)),
    );
    if (picked == null) return;
    setState(() {
      _draft = isExpiry
          ? _draft.copyWith(expiresAt: picked)
          : _draft.copyWith(returnDate: picked);
    });
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final error = validateListingDraft(_draft);
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    setState(() => _submitting = true);
    try {
      final listing = _draft.toListing(ownerId: widget.profile.id!);
      final editing = widget.editing;
      if (editing != null) {
        await client.listing.update(editing.id!, listing);
      } else {
        await client.listing.create(listing);
      }
      if (!mounted) return;
      setState(() => _saved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            editing != null
                ? 'Cambios guardados.'
                : '¡Publicado! Gracias por darle otra vida.',
          ),
        ),
      );
      _close(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revisa los datos e inténtalo de nuevo.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final validationError = validateListingDraft(_draft);
    final hasUploading = _photos.any((p) => p.loading);
    final hasError = _photos.any((p) => p.error);
    final canSubmit =
        validationError == null && !_submitting && !hasUploading && !hasError;

    // On the web every close goes through _close (browser back), so the
    // router doesn't record the return as a new visit.
    return PopScope(
      canPop: !kIsWeb && !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_hasUnsavedChanges && !await _confirmDiscard()) return;
        if (mounted) _close();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _onClose,
          ),
          title: Text(
            _isEditing ? 'Editar publicación' : 'Publicar algo',
            style: AppTypography.title,
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                    vertical: AppSpacing.l,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isEditing)
                        _buildEditingNote()
                      else ...[
                        _buildPhotosSection(),
                        const SizedBox(height: AppSpacing.xl),
                        _buildTypeSection(),
                        const SizedBox(height: AppSpacing.xl),
                        _buildCategorySection(),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      AppTextField(
                        label: 'Título',
                        hint: 'Ej: Silla de madera usada',
                        controller: _titleController,
                        maxLength: 80,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: AppSpacing.l),
                      _buildDescriptionField(),
                      const SizedBox(height: AppSpacing.xl),
                      _buildConditionSection(),
                      const SizedBox(height: AppSpacing.xl),
                      _buildConditionalFields(),
                      const SizedBox(height: AppSpacing.xl),
                      AppTextField(
                        label: 'Barrio',
                        hint: 'Ej: Laureles',
                        controller: _neighborhoodController,
                        maxLength: 60,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: AppSpacing.l),
                      AppTextField(
                        label: 'Punto de encuentro sugerido',
                        hint: 'Ej: Estación Metro Floresta',
                        controller: _meetingPointController,
                        maxLength: 120,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: AppSpacing.l),
                      _buildZoneSection(),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(
                canSubmit,
                validationError,
                hasUploading,
                hasError,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fotos', style: AppTypography.sectionLabel),
        const SizedBox(height: AppSpacing.s),
        SizedBox(
          height: 96,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._photos.asMap().entries.map((entry) {
                final index = entry.key;
                final photo = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.s),
                  child: _PhotoThumbnail(
                    upload: photo,
                    onRemove: () => _removePhoto(index),
                    onRetry: () => _uploadPhoto(photo),
                  ),
                );
              }),
              if (_photos.length < 5)
                _AddPhotoTile(onTap: _showPhotoSourceSheet),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('¿Qué quieres hacer?', style: AppTypography.sectionLabel),
        const SizedBox(height: AppSpacing.m),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          // Fixed card height: a ratio made the cards huge in the wide
          // dialog. Two columns on phones, all four in one row when wide.
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.sizeOf(context).width >= 600 ? 4 : 2,
            mainAxisSpacing: AppSpacing.m,
            crossAxisSpacing: AppSpacing.m,
            mainAxisExtent: 104,
          ),
          children: ListingTypeUi.values.map((type) {
            final selected = _draft.type == type.toServer;
            return InkWell(
              onTap: () {
                if (_draft.type == type.toServer) return;
                _priceController.text = '';
                _wantedController.text = '';
                _depositController.text = '';
                _lateFeeController.text = '';
                _conditionsController.text = '';
                setState(
                  () => _draft = _draft.copyWith(
                    type: type.toServer,
                    price: null,
                    returnDate: null,
                    wantedInExchange: '',
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.surface,
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      type.label,
                      style: AppTypography.bodyStrong.copyWith(
                        color: selected
                            ? AppColors.onPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      type.description,
                      style: AppTypography.caption.copyWith(
                        color: selected
                            ? AppColors.onPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Categoría', style: AppTypography.sectionLabel),
        const SizedBox(height: AppSpacing.m),
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          children: CategoryUi.values.map((category) {
            final selected = _draft.category == category.toServer;
            return ChoiceChip(
              label: Text(category.label),
              selected: selected,
              onSelected: (_) => setState(
                () => _draft = _draft.copyWith(
                  category: selected ? null : category.toServer,
                  expiresAt: null,
                ),
              ),
              selectedColor: AppColors.accentStrong,
              labelStyle: TextStyle(
                color: selected ? AppColors.onPrimary : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Descripción', style: AppTypography.sectionLabel),
        const SizedBox(height: AppSpacing.s),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          maxLength: 1000,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Describe el artículo, su uso, estado...',
          ),
        ),
      ],
    );
  }

  Widget _buildConditionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Estado del artículo', style: AppTypography.sectionLabel),
        const SizedBox(height: AppSpacing.m),
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          children: ItemCondition.values.map((condition) {
            final selected = _draft.condition == condition;
            return ChoiceChip(
              label: Text(conditionLabel(condition)),
              selected: selected,
              onSelected: (_) => setState(
                () => _draft = _draft.copyWith(
                  condition: selected ? null : condition,
                ),
              ),
              labelStyle: TextStyle(
                color: selected ? AppColors.onPrimary : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildConditionalFields() {
    final category = _draft.category;
    final type = _draft.type;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (category == Category.food) ...[
          _buildDateField(
            label: 'Fecha de vencimiento',
            value: _draft.expiresAt,
            hint: 'Selecciona una fecha',
            onTap: () => _pickDate(isExpiry: true),
          ),
          const SizedBox(height: AppSpacing.l),
        ],
        if (type == ListingType.sell) ...[
          AppTextField(
            label: 'Precio (COP)',
            hint: 'Ej: 25.000',
            controller: _priceController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CopInputFormatter(),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
        ],
        if (type == ListingType.lend) ...[
          _buildDateField(
            label: 'Devolver antes de (máx. $maxLoanDays días)',
            value: _draft.returnDate,
            hint: 'Selecciona una fecha',
            onTap: () => _pickDate(isExpiry: false),
          ),
          const SizedBox(height: AppSpacing.l),
          AppTextField(
            label: 'Garantía (opcional, COP)',
            hint: 'Ej: 50.000',
            controller: _depositController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CopInputFormatter(),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Dinero que te dejan al recibirlo y les devuelves completo '
            'cuando te lo regresen en buen estado.',
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.l),
          AppTextField(
            label: 'Recargo por día de retraso (opcional, COP)',
            hint: 'Ej: 2.000',
            controller: _lateFeeController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CopInputFormatter(),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Se acuerda entre ustedes y se descuenta de la garantía; la app '
            'no cobra dinero.',
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.l),
          AppTextField(
            label: 'Condiciones de uso (opcional)',
            hint: 'Ej: Devolverlo limpio, solo uso en casa',
            controller: _conditionsController,
            maxLength: 300,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: AppSpacing.l),
        ],
        if (type == ListingType.exchange) ...[
          AppTextField(
            label: '¿Qué te gustaría recibir a cambio?',
            hint: 'Ej: Un libro de cocina',
            controller: _wantedController,
            maxLength: 200,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: AppSpacing.l),
        ],
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required String hint,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
        child: Text(
          value != null ? formatDate(value) : hint,
          style: AppTypography.body.copyWith(
            color: value != null ? AppColors.textPrimary : AppColors.textHint,
          ),
        ),
      ),
    );
  }

  Widget _buildEditingNote() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.categoryCircle,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              'Las fotos, el tipo y la categoría no se pueden cambiar. Si '
              'necesitas cambiarlos, retira esta publicación y crea una nueva.',
              style: AppTypography.caption,
            ),
          ),
        ],
      ),
    );
  }

  /// Where the listing shows up: chosen on the map or from GPS. Others only
  /// ever see the ~1 km zone.
  Widget _buildZoneSection() {
    final lat = _draft.latitude;
    final lng = _draft.longitude;
    final hasZone = lat != null && lng != null;

    final buttons = Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.s,
      children: [
        FilledButton.icon(
          onPressed: _gettingLocation ? null : _pickOnMap,
          icon: const Icon(Icons.map_outlined, size: 18),
          label: Text(hasZone ? 'Cambiar en el mapa' : 'Elegir en el mapa'),
        ),
        OutlinedButton.icon(
          onPressed: _gettingLocation ? null : _getLocation,
          icon: _gettingLocation
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location, size: 18),
          label: const Text('Usar mi ubicación'),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Zona', style: AppTypography.sectionLabel),
        const SizedBox(height: AppSpacing.xs),
        Text(
          hasZone
              ? 'Así verán los demás la ubicación: solo la zona, nunca tu '
                    'dirección.'
              : 'Elige en qué zona está. Los demás solo verán un círculo de '
                    '~1 km, nunca tu dirección.',
          style: AppTypography.caption,
        ),
        const SizedBox(height: AppSpacing.m),
        if (hasZone) ...[
          ZoneMap(
            latitude: lat,
            longitude: lng,
            label: _draft.neighborhood.trim().isEmpty
                ? null
                : _draft.neighborhood.trim(),
          ),
          const SizedBox(height: AppSpacing.m),
        ],
        buttons,
      ],
    );
  }

  Widget _buildBottomBar(
    bool canSubmit,
    String? validationError,
    bool hasUploading,
    bool hasError,
  ) {
    String? uploadHint;
    if (hasUploading) {
      uploadHint = 'Esperando que terminen de subir las fotos';
    } else if (hasError) {
      uploadHint = 'Quita o reintenta las fotos con error';
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.screenHorizontal,
        right: AppSpacing.screenHorizontal,
        top: AppSpacing.m,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.m,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (validationError != null) ...[
            Text(
              validationError,
              style: AppTypography.caption.copyWith(color: AppColors.danger),
            ),
            const SizedBox(height: AppSpacing.s),
          ],
          if (uploadHint != null) ...[
            Text(
              uploadHint,
              style: AppTypography.caption.copyWith(color: AppColors.danger),
            ),
            const SizedBox(height: AppSpacing.s),
          ],
          AppPrimaryButton(
            label: _isEditing ? 'Guardar cambios' : 'Publicar',
            isLoading: _submitting,
            onPressed: canSubmit ? _submit : null,
          ),
        ],
      ),
    );
  }
}

class _PhotoUpload {
  _PhotoUpload({required this.bytes});

  final Uint8List bytes;
  String? path;
  bool loading = false;
  bool error = false;
}

class _PhotoThumbnail extends StatelessWidget {
  const _PhotoThumbnail({
    required this.upload,
    required this.onRemove,
    required this.onRetry,
  });

  final _PhotoUpload upload;
  final VoidCallback onRemove;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 84,
            height: 84,
            color: AppColors.surfaceMuted,
            child: Image.memory(
              upload.bytes,
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (upload.loading)
          const Positioned.fill(
            child: Center(child: CircularProgressIndicator()),
          ),
        if (upload.error)
          Positioned.fill(
            child: Container(
              color: Colors.black45,
              child: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: onRetry,
              ),
            ),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(
            color: AppColors.border,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, color: AppColors.textHint),
            SizedBox(height: AppSpacing.xs),
            Text('Agregar', style: TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class CopInputFormatter extends TextInputFormatter {
  /// "20.000" for 20000, as the field shows it.
  static String format(int value) =>
      NumberFormat('#,##0', 'es_CO').format(value);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return newValue.copyWith(text: '');
    }
    if (digits.length > 9) {
      return oldValue;
    }
    final value = int.tryParse(digits);
    if (value == null) {
      return oldValue;
    }
    final formatted = NumberFormat('#,##0', 'es_CO').format(value);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
