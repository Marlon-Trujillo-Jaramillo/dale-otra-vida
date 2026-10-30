import 'package:cached_network_image/cached_network_image.dart';
import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/material.dart';

import '../../client.dart';
import '../../core/format.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/models/category_ui.dart';
import '../../core/models/listing_type_ui.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../chat/chat_screen.dart';
import '../profile/public_profile_screen.dart';
import '../publish/publish_screen.dart';
import '../reports/report_sheet.dart';
import 'listing_detail_logic.dart';

class ListingDetailScreen extends StatefulWidget {
  const ListingDetailScreen({super.key, required this.view});

  final ListingView view;

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  late ListingView _view;
  int _currentPhoto = 0;
  bool _updating = false;
  bool _galleryHover = false;

  List<RequestView>? _requests;
  bool _loadingRequests = false;

  @override
  void initState() {
    super.initState();
    _view = widget.view;
    if (_view.isMine) {
      _loadRequests();
    }
  }

  Future<void> _refreshView() async {
    final id = _view.listing.id;
    if (id == null) return;
    try {
      final updated = await client.listing.byId(id);
      if (!mounted) return;
      if (updated != null) {
        setState(() => _view = updated.copyWith(distanceKm: _view.distanceKm));
      }
    } catch (_) {
      // Keep the current view if refresh fails.
    }
  }

  Future<void> _updateStatus(ListingStatus status) async {
    setState(() => _updating = true);
    try {
      final updated = await client.listing.updateStatus(
        _view.listing.id!,
        status,
      );
      if (!mounted) return;
      setState(
        () => _view = updated.copyWith(distanceKm: _view.distanceKm),
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showErrorFor(e);
    } finally {
      if (mounted) {
        setState(() => _updating = false);
      }
    }
  }

  Future<void> _withdraw() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirar publicación'),
        content: const Text(
          '¿Seguro que quieres retirar esta publicación? Ya no aparecerá en el feed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Retirar',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) await _updateStatus(ListingStatus.withdrawn);
  }

  Future<void> _loadRequests() async {
    final id = _view.listing.id;
    if (id == null) return;
    setState(() => _loadingRequests = true);
    try {
      final result = await client.request.forListing(id);
      if (!mounted) return;
      setState(() {
        _requests = result;
      });
    } catch (e) {
      if (mounted) {
        _showSnackBar('No pudimos cargar las solicitudes.');
      }
    } finally {
      if (mounted) {
        setState(() => _loadingRequests = false);
      }
    }
  }

  Future<void> _createRequest(String? message) async {
    setState(() => _updating = true);
    try {
      await client.request.create(
        _view.listing.id!,
        message: message,
      );
      if (!mounted) return;
      await _refreshView();
      if (mounted) {
        _showSnackBar('¡Solicitud enviada!');
      }
    } catch (e) {
      _showErrorFor(e);
    } finally {
      if (mounted) {
        setState(() => _updating = false);
      }
    }
  }

  Future<void> _acceptRequest(RequestView requestView) async {
    final name = requestView.requester.displayName;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reservar'),
        content: Text(
          'Se reservará para $name y las demás solicitudes se rechazarán.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _updating = true);
    try {
      await client.request.accept(requestView.request.id!);
      if (!mounted) return;
      await _refreshAfterRequestAction();
    } catch (e) {
      _showErrorFor(e);
      setState(() => _updating = false);
    }
  }

  Future<void> _rejectRequest(RequestView requestView) async {
    setState(() => _updating = true);
    try {
      await client.request.reject(requestView.request.id!);
      if (!mounted) return;
      await _refreshAfterRequestAction();
    } catch (e) {
      _showErrorFor(e);
      setState(() => _updating = false);
    }
  }

  Future<void> _cancelMyRequest() async {
    final myRequest = _view.myRequest;
    if (myRequest?.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar solicitud'),
        content: const Text(
          '¿Seguro que quieres cancelar tu solicitud? Puedes volver a intentarlo después.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No, mantener'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Sí, cancelar',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _updating = true);
    try {
      await client.request.cancel(myRequest!.id!);
      if (!mounted) return;
      await _refreshView();
      if (mounted) {
        _showSnackBar('Solicitud cancelada.');
      }
    } catch (e) {
      _showErrorFor(e);
    } finally {
      if (mounted) {
        setState(() => _updating = false);
      }
    }
  }

  Future<void> _refreshAfterRequestAction() async {
    await _loadRequests();
    await _refreshView();
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _showErrorFor(Object error) {
    final message = error is NotAllowedException
        ? error.message
        : 'Revisa los datos e inténtalo de nuevo.';
    _showSnackBar(message);
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _openChat(int conversationId) {
    Navigator.of(context)
        .push<void>(
          MaterialPageRoute<void>(
            builder: (context) => ChatScreen(conversationId: conversationId),
          ),
        )
        .then((_) => _refreshView());
  }

  /// Opens the requester's conversation with the owner.
  Future<void> _openMyChat() async {
    if (_view.myRequest == null) {
      _showSnackBar('Primero toca «Lo quiero» para hablar con el dueño.');
      return;
    }
    try {
      final conversations = await client.chat.conversations();
      if (!mounted) return;
      for (final conversation in conversations) {
        if (!conversation.isOwner &&
            conversation.conversation.listingId == _view.listing.id) {
          _openChat(conversation.conversation.id!);
          return;
        }
      }
      _showSnackBar('No encontramos la conversación.');
    } catch (_) {
      _showSnackBar('No pudimos abrir el chat.');
    }
  }

  void _openPhotoFullscreen(String url) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _PhotoViewerScreen(imageUrl: url),
      ),
    );
  }

  void _openRequestSheetOrDialog() {
    final size = ScreenSize.of(context);
    final title = '¿Te interesa «${_view.listing.title}»?';
    final isCompact = size == ScreenSize.compact;

    if (isCompact) {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => _RequestForm(
          title: title,
          onSend: (message) async {
            Navigator.of(context).pop();
            await _createRequest(message);
          },
          isLoading: _updating,
        ),
      );
    } else {
      showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: AppColors.surface,
          insetPadding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: _RequestForm(
                title: title,
                onSend: (message) async {
                  Navigator.of(context).pop();
                  await _createRequest(message);
                },
                isLoading: _updating,
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = ScreenSize.of(context);
    if (size == ScreenSize.compact) {
      return _buildCompact(context);
    }
    return _buildWide(context);
  }

  Widget _buildCompact(BuildContext context) {
    final listing = _view.listing;
    final owner = _view.owner;
    final typeUi = ListingTypeUi.fromServer(listing.type);
    final categoryUi = CategoryUi.fromServer(listing.category);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildCarousel(context)),
                  SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildBadges(typeUi, categoryUi),
                        const SizedBox(height: AppSpacing.m),
                        Text(listing.title, style: AppTypography.headline),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Publicado el ${formatDate(listing.createdAt)}',
                          style: AppTypography.caption,
                        ),
                        const SizedBox(height: AppSpacing.l),
                        ..._buildExpiredNotice(listing),
                        _buildInfoCards(listing),
                        const SizedBox(height: AppSpacing.l),
                        _buildDescription(listing),
                        const SizedBox(height: AppSpacing.l),
                        _buildMeetingPoint(listing),
                        const SizedBox(height: AppSpacing.l),
                        _buildOwnerCard(owner),
                        ..._buildReportLink(),
                        if (_view.isMine) ...[
                          const SizedBox(height: AppSpacing.l),
                          _buildRequestsSection(context),
                        ],
                        const SizedBox(height: AppSpacing.xl),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildWide(BuildContext context) {
    final listing = _view.listing;
    final owner = _view.owner;
    final typeUi = ListingTypeUi.fromServer(listing.type);
    final categoryUi = CategoryUi.fromServer(listing.category);

    return Scaffold(
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Volver'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7,
                      child: _buildWideGallery(context),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBadges(typeUi, categoryUi),
                          const SizedBox(height: AppSpacing.m),
                          Text(listing.title, style: AppTypography.headline),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Publicado el ${formatDate(listing.createdAt)}',
                            style: AppTypography.caption,
                          ),
                          const SizedBox(height: AppSpacing.l),
                          ..._buildExpiredNotice(listing),
                          _buildInfoCards(listing),
                          const SizedBox(height: AppSpacing.l),
                          _buildDescription(listing),
                          const SizedBox(height: AppSpacing.l),
                          _buildMeetingPoint(listing),
                          const SizedBox(height: AppSpacing.l),
                          _buildOwnerCard(owner),
                          ..._buildReportLink(),
                          const SizedBox(height: AppSpacing.l),
                          _buildWideActions(),
                          if (_view.isMine) ...[
                            const SizedBox(height: AppSpacing.xl),
                            _buildRequestsSection(context),
                          ],
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarousel(BuildContext context) {
    final photos = _view.listing.photoUrls;
    return Stack(
      children: [
        Container(
          height: 300,
          color: AppColors.surfaceMuted,
          child: photos.isEmpty
              ? const Center(
                  child: Icon(Icons.image, size: 64, color: AppColors.textHint),
                )
              : PageView.builder(
                  itemCount: photos.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPhoto = index),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _openPhotoFullscreen(photos[index]),
                      child: CachedNetworkImage(
                        imageUrl: photos[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.broken_image, size: 48),
                        ),
                      ),
                    );
                  },
                ),
        ),
        Positioned(
          top: AppSpacing.m,
          left: AppSpacing.screenHorizontal,
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        if (photos.length > 1)
          Positioned(
            bottom: AppSpacing.m,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(photos.length, (index) {
                final selected = index == _currentPhoto;
                return Container(
                  width: selected ? 8 : 6,
                  height: selected ? 8 : 6,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildWideGallery(BuildContext context) {
    final photos = _view.listing.photoUrls;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _galleryHover = true),
          onExit: (_) => setState(() => _galleryHover = false),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                color: AppColors.surfaceMuted,
                child: photos.isEmpty
                    ? const Center(
                        child: Icon(
                          Icons.image,
                          size: 64,
                          color: AppColors.textHint,
                        ),
                      )
                    : Stack(
                        children: [
                          Positioned.fill(
                            child: PageView.builder(
                              itemCount: photos.length,
                              onPageChanged: (index) => setState(
                                () => _currentPhoto = index,
                              ),
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () =>
                                      _openPhotoFullscreen(photos[index]),
                                  child: CachedNetworkImage(
                                    imageUrl: photos[index],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 48,
                                          ),
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (photos.length > 1) ...[
                            AnimatedOpacity(
                              opacity: _galleryHover ? 1 : 0,
                              duration: const Duration(milliseconds: 160),
                              child: _GalleryArrow(
                                left: true,
                                onTap: () {
                                  if (_currentPhoto > 0) {
                                    setState(() => _currentPhoto--);
                                  }
                                },
                              ),
                            ),
                            AnimatedOpacity(
                              opacity: _galleryHover ? 1 : 0,
                              duration: const Duration(milliseconds: 160),
                              child: _GalleryArrow(
                                left: false,
                                onTap: () {
                                  if (_currentPhoto < photos.length - 1) {
                                    setState(() => _currentPhoto++);
                                  }
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ),
        if (photos.length > 1) ...[
          const SizedBox(height: AppSpacing.m),
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppSpacing.s),
              itemBuilder: (context, index) {
                final selected = index == _currentPhoto;
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => setState(() => _currentPhoto = index),
                    child: Container(
                      width: 72,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CachedNetworkImage(
                        imageUrl: photos[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const _PlaceholderIcon(),
                        errorWidget: (context, url, error) =>
                            const _PlaceholderIcon(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBadges(ListingTypeUi typeUi, CategoryUi categoryUi) {
    return Wrap(
      spacing: AppSpacing.s,
      children: [
        TypeBadge(type: typeUi),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            categoryUi.label,
            style: AppTypography.badge.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards(Listing listing) {
    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            label: 'Estado',
            value: conditionLabel(listing.condition),
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(child: _typeSpecificCard(listing)),
      ],
    );
  }

  Widget _typeSpecificCard(Listing listing) {
    if (listing.expiresAt != null) {
      return _InfoCard(
        label: 'Fecha de vencimiento',
        value: formatDate(listing.expiresAt!),
        highlight: true,
      );
    }
    return switch (listing.type) {
      ListingType.donate => const SizedBox.shrink(),
      ListingType.sell => _InfoCard(
        label: 'Precio',
        value: listing.price != null ? formatCop(listing.price!) : 'Gratis',
      ),
      ListingType.lend => _InfoCard(
        label: 'Devolver antes de',
        value: listing.returnDate != null
            ? formatDate(listing.returnDate!)
            : 'A convenir',
      ),
      ListingType.exchange => _InfoCard(
        label: 'Busca a cambio',
        value: listing.wantedInExchange?.isNotEmpty == true
            ? listing.wantedInExchange!
            : 'A convenir',
      ),
    };
  }

  Widget _buildDescription(Listing listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Descripción', style: AppTypography.sectionLabel),
        const SizedBox(height: AppSpacing.s),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Text(listing.description, style: AppTypography.body),
        ),
      ],
    );
  }

  Widget _buildMeetingPoint(Listing listing) {
    final distance = _view.distanceKm != null
        ? formatDistance(_view.distanceKm!)
        : null;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary, size: 18),
              const SizedBox(width: AppSpacing.s),
              Text(
                'Punto de encuentro seguro',
                style: AppTypography.bodyStrong,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            listing.safeMeetingPoint ?? 'A convenir en un lugar público',
            style: AppTypography.body,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            distance != null
                ? '${listing.neighborhood} · $distance'
                : listing.neighborhood,
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildExpiredNotice(Listing listing) {
    if (!isExpired(listing) || listing.status != ListingStatus.available) {
      return const [];
    }
    final mine = _view.isMine;
    return [
      Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: const Color(0xFFF6E3CF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.event_busy, color: AppColors.link, size: 20),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Venció el ${formatDate(listing.expiresAt!)}',
                    style: AppTypography.bodyStrong.copyWith(
                      color: AppColors.link,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mine
                        ? 'Ya no aparece en el inicio. Si sigue en buen '
                              'estado, actualiza la fecha.'
                        : 'Este alimento ya pasó su fecha de vencimiento.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.link,
                    ),
                  ),
                  if (mine)
                    TextButton(
                      onPressed: _edit,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 36),
                      ),
                      child: const Text('Actualizar fecha'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.l),
    ];
  }

  List<Widget> _buildReportLink() {
    if (_view.isMine) return const [];
    return [
      const SizedBox(height: AppSpacing.s),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => showReportSheet(
            context,
            title: 'Reportar publicación',
            listingId: _view.listing.id,
            reportedUserId: _view.owner.id,
          ),
          icon: const Icon(
            Icons.flag_outlined,
            size: 18,
            color: AppColors.danger,
          ),
          label: Text(
            'Reportar publicación',
            style: AppTypography.bodyStrong.copyWith(color: AppColors.danger),
          ),
        ),
      ),
    ];
  }

  bool get _canEdit =>
      _view.isMine &&
      (_view.listing.status == ListingStatus.available ||
          _view.listing.status == ListingStatus.reserved);

  Future<void> _edit() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        fullscreenDialog: true,
        builder: (context) =>
            PublishScreen(profile: _view.owner, editing: _view.listing),
      ),
    );
    if (saved == true) {
      await _refreshView();
      _showSnackBar('Cambios guardados.');
    }
  }

  void _openOwnerProfile() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => PublicProfileScreen(profileId: _view.owner.id!),
      ),
    );
  }

  Widget _buildOwnerCard(MemberProfile owner) {
    return InkWell(
      onTap: _openOwnerProfile,
      mouseCursor: SystemMouseCursors.click,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            AppAvatar(initials: initialsFor(owner.displayName)),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          owner.displayName,
                          style: AppTypography.bodyStrong,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (owner.isVerified) ...[
                        const SizedBox(width: AppSpacing.xs),
                        const Icon(
                          Icons.verified,
                          color: AppColors.verified,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '★ ${owner.ratingAvg.toStringAsFixed(1)} · '
                    '${owner.reviewCount} reseñas · '
                    '${owner.deliveryCount} entregas',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Solicitudes', style: AppTypography.sectionLabel),
            const SizedBox(width: AppSpacing.s),
            if (_view.pendingRequestCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${_view.pendingRequestCount}',
                  style: AppTypography.badge.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        if (_loadingRequests && _requests == null)
          const Center(child: CircularProgressIndicator())
        else if (_requests?.isEmpty ?? false)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Aún nadie la ha pedido. Comparte tu publicación.',
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
          )
        else
          ...?_requests?.map((requestView) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.m),
              child: _RequestRow(
                view: requestView,
                onAccept: () => _acceptRequest(requestView),
                onReject: () => _rejectRequest(requestView),
                onChat: requestView.conversationId == null
                    ? null
                    : () => _openChat(requestView.conversationId!),
                busy: _updating,
              ),
            );
          }),
      ],
    );
  }

  Widget _buildBottomBar() {
    final listing = _view.listing;
    final status = listing.status;

    Widget content;
    if (_view.isMine) {
      final actions = allowedOwnerActions(status);
      if (actions.isEmpty) {
        content = const SizedBox.shrink();
      } else {
        final mainAction = actions.first;
        final secondaryActions = actions
            .where((action) => action != OwnerAction.withdraw)
            .toList();
        content = Column(
          children: [
            for (final action in secondaryActions) ...[
              if (action == mainAction)
                AppPrimaryButton(
                  label: _actionLabel(action),
                  onPressed: _updating ? null : () => _executeAction(action),
                )
              else
                AppSecondaryButton(
                  label: _actionLabel(action),
                  onPressed: _updating ? null : () => _executeAction(action),
                ),
              const SizedBox(height: AppSpacing.s),
            ],
            if (_canEdit)
              TextButton.icon(
                onPressed: _updating ? null : _edit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Editar publicación'),
              ),
            if (actions.contains(OwnerAction.withdraw))
              TextButton(
                onPressed: _updating ? null : _withdraw,
                child: Text(
                  'Retirar',
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              ),
          ],
        );
      }
    } else {
      content = _buildRequesterActions(compact: true);
    }

    final banner = status != ListingStatus.available
        ? Container(
            width: double.infinity,
            color: AppColors.surfaceMuted,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
            child: Text(
              _statusLabel(status),
              textAlign: TextAlign.center,
              style: AppTypography.bodyStrong,
            ),
          )
        : const SizedBox.shrink();

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
        children: [
          banner,
          content,
        ],
      ),
    );
  }

  Widget _buildWideActions() {
    final listing = _view.listing;
    final status = listing.status;

    Widget content;
    if (_view.isMine) {
      final actions = allowedOwnerActions(status);
      if (actions.isEmpty) {
        content = const SizedBox.shrink();
      } else {
        final mainAction = actions.first;
        final secondaryActions = actions
            .where((action) => action != OwnerAction.withdraw)
            .toList();
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final action in secondaryActions) ...[
              if (action == mainAction)
                AppPrimaryButton(
                  label: _actionLabel(action),
                  onPressed: _updating ? null : () => _executeAction(action),
                )
              else
                AppSecondaryButton(
                  label: _actionLabel(action),
                  onPressed: _updating ? null : () => _executeAction(action),
                ),
              const SizedBox(height: AppSpacing.s),
            ],
            if (_canEdit)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _updating ? null : _edit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Editar publicación'),
                ),
              ),
            if (actions.contains(OwnerAction.withdraw))
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _updating ? null : _withdraw,
                  child: Text(
                    'Retirar',
                    style: AppTypography.bodyStrong.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ),
          ],
        );
      }
    } else {
      content = _buildRequesterActions(compact: false);
    }

    final banner = status != ListingStatus.available
        ? Container(
            width: double.infinity,
            color: AppColors.surfaceMuted,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
            margin: const EdgeInsets.only(bottom: AppSpacing.m),
            child: Text(
              _statusLabel(status),
              textAlign: TextAlign.center,
              style: AppTypography.bodyStrong,
            ),
          )
        : const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        banner,
        content,
      ],
    );
  }

  Widget _buildRequesterActions({required bool compact}) {
    final state = requesterActionState(_view);

    Widget actionWidget;
    switch (state) {
      case RequesterActionState.canRequest:
        actionWidget = AppPrimaryButton(
          label: 'Lo quiero',
          onPressed: _openRequestSheetOrDialog,
        );
      case RequesterActionState.pending:
        actionWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StatusPill(
              label: 'Solicitud enviada · esperando respuesta',
              backgroundColor: AppColors.surfaceMuted,
              foregroundColor: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.s),
            TextButton(
              onPressed: _updating ? null : _cancelMyRequest,
              child: Text(
                'Cancelar solicitud',
                style: AppTypography.bodyStrong.copyWith(
                  color: AppColors.danger,
                ),
              ),
            ),
          ],
        );
      case RequesterActionState.accepted:
        actionWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: const Color(0xFFD4EDDA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF155724),
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Text(
                        '¡Te lo reservaron!',
                        style: AppTypography.bodyStrong.copyWith(
                          color: const Color(0xFF155724),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Coordina la entrega por el chat.',
                    style: AppTypography.body.copyWith(
                      color: const Color(0xFF155724),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            AppSecondaryButton(
              label: 'Cancelar reserva',
              onPressed: _updating ? null : _cancelMyRequest,
            ),
          ],
        );
      case RequesterActionState.rejected:
        actionWidget = _StatusPill(
          label: 'El dueño eligió a otra persona',
          backgroundColor: AppColors.surfaceMuted,
          foregroundColor: AppColors.textSecondary,
        );
      case RequesterActionState.unavailable:
        actionWidget = const SizedBox.shrink();
    }

    if (compact) {
      return Row(
        children: [
          _ChatButton(onTap: _openMyChat),
          const SizedBox(width: AppSpacing.s),
          Expanded(child: actionWidget),
        ],
      );
    }

    // Wide layout: chat icon stays inline.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChatButton(onTap: _openMyChat),
        const SizedBox(width: AppSpacing.s),
        Expanded(child: actionWidget),
      ],
    );
  }

  void _executeAction(OwnerAction action) {
    switch (action) {
      case OwnerAction.reserve:
        _updateStatus(ListingStatus.reserved);
      case OwnerAction.markAvailable:
        _updateStatus(ListingStatus.available);
      case OwnerAction.markDelivered:
        _updateStatus(ListingStatus.delivered);
      case OwnerAction.withdraw:
        _withdraw();
    }
  }
}

enum OwnerAction { reserve, markAvailable, markDelivered, withdraw }

List<OwnerAction> allowedOwnerActions(ListingStatus status) {
  return switch (status) {
    ListingStatus.available => [
      OwnerAction.reserve,
      OwnerAction.withdraw,
    ],
    ListingStatus.reserved => [
      OwnerAction.markAvailable,
      OwnerAction.markDelivered,
      OwnerAction.withdraw,
    ],
    ListingStatus.delivered || ListingStatus.withdrawn => [],
  };
}

String _actionLabel(OwnerAction action) {
  return switch (action) {
    OwnerAction.reserve => 'Reservar',
    OwnerAction.markAvailable => 'Marcar como disponible',
    OwnerAction.markDelivered => 'Marcar como entregado',
    OwnerAction.withdraw => 'Retirar',
  };
}

String _statusLabel(ListingStatus status) {
  return switch (status) {
    ListingStatus.available => '',
    ListingStatus.reserved => 'Reservado',
    ListingStatus.delivered => 'Entregado',
    ListingStatus.withdrawn => 'Retirado',
  };
}

class _ChatButton extends StatelessWidget {
  const _ChatButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.chat_bubble_outline),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTypography.bodyStrong.copyWith(color: foregroundColor),
      ),
    );
  }
}

class _RequestForm extends StatefulWidget {
  const _RequestForm({
    required this.title,
    required this.onSend,
    required this.isLoading,
  });

  final String title;
  final Future<void> Function(String? message) onSend;
  final bool isLoading;

  @override
  State<_RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<_RequestForm> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: AppTypography.title),
            const SizedBox(height: AppSpacing.l),
            AppTextField(
              label: 'Mensaje (opcional)',
              hint: 'Cuéntale cuándo podrías recogerlo…',
              controller: _controller,
              maxLength: 300,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSpacing.m),
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: const Color(0xFFF6E3CF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.security,
                    color: Color(0xFF8A3D10),
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      'Por tu seguridad, acuerden la entrega en un punto '
                      'público y no compartan datos bancarios.',
                      style: AppTypography.body.copyWith(
                        color: const Color(0xFF8A3D10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            AppPrimaryButton(
              label: 'Enviar solicitud',
              isLoading: widget.isLoading,
              onPressed: widget.isLoading
                  ? null
                  : () => widget.onSend(_textOrNull(_controller.text)),
            ),
            const SizedBox(height: AppSpacing.m),
          ],
        ),
      ),
    );
  }

  String? _textOrNull(String text) {
    final trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _RequestRow extends StatelessWidget {
  const _RequestRow({
    required this.view,
    required this.onAccept,
    required this.onReject,
    this.onChat,
    required this.busy,
  });

  final RequestView view;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback? onChat;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final requester = view.requester;
    final request = view.request;
    final isPending = request.status == RequestStatus.pending;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppAvatar(initials: initialsFor(requester.displayName)),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      requester.displayName,
                      style: AppTypography.bodyStrong,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '★ ${requester.ratingAvg.toStringAsFixed(1)} · '
                      '${requester.deliveryCount} entregas',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      formatRelative(request.createdAt),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _RequestStatusChip(status: request.status),
                  if (onChat != null)
                    IconButton(
                      tooltip: 'Abrir chat',
                      onPressed: onChat,
                      icon: const Icon(Icons.chat_bubble_outline, size: 20),
                    ),
                ],
              ),
            ],
          ),
          if (request.message != null && request.message!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '"${request.message}"',
                style: AppTypography.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          if (isPending) ...[
            const SizedBox(height: AppSpacing.m),
            Row(
              children: [
                Expanded(
                  child: AppPrimaryButton(
                    label: 'Aceptar',
                    onPressed: busy ? null : onAccept,
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: TextButton(
                    onPressed: busy ? null : onReject,
                    child: Text(
                      'Rechazar',
                      style: AppTypography.bodyStrong.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RequestStatusChip extends StatelessWidget {
  const _RequestStatusChip({required this.status});

  final RequestStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, background, foreground) = switch (status) {
      RequestStatus.pending => (
        'Pendiente',
        const Color(0xFFF6E3CF),
        const Color(0xFF6E300B),
      ),
      RequestStatus.accepted => (
        'Aceptada',
        const Color(0xFFD4EDDA),
        const Color(0xFF155724),
      ),
      RequestStatus.rejected => (
        'Rechazada',
        AppColors.surfaceMuted,
        AppColors.textSecondary,
      ),
      RequestStatus.cancelled => (
        'Cancelada',
        AppColors.surfaceMuted,
        AppColors.textSecondary,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTypography.badge.copyWith(color: foreground),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFF6E3CF) : AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: highlight ? const Color(0xFF8A3D10) : null,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.bodyStrong.copyWith(
              color: highlight ? const Color(0xFF8A3D10) : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryArrow extends StatelessWidget {
  const _GalleryArrow({required this.left, required this.onTap});

  final bool left;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left ? AppSpacing.m : null,
      right: left ? null : AppSpacing.m,
      top: 0,
      bottom: 0,
      child: Center(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                left ? Icons.arrow_back : Icons.arrow_forward,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceholderIcon extends StatelessWidget {
  const _PlaceholderIcon();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.image, color: AppColors.textHint, size: 32),
    );
  }
}

class _PhotoViewerScreen extends StatelessWidget {
  const _PhotoViewerScreen({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: Center(
                child: CachedNetworkImage(imageUrl: imageUrl),
              ),
            ),
            Positioned(
              top: AppSpacing.m,
              left: AppSpacing.screenHorizontal,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
