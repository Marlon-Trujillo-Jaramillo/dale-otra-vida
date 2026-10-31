import 'dart:async';

import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/material.dart';

import '../../client.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/models/category_ui.dart';
import '../../core/models/listing_type_ui.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/category_tile.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/filter_chip_row.dart';
import '../../core/widgets/listing_card.dart';
import '../../core/widgets/listing_grid_card.dart';
import '../../core/widgets/listing_grid_delegate.dart';
import '../../core/widgets/section_header.dart';
import '../listing/listing_detail_screen.dart';
import '../map/map_screen.dart';
import '../notifications/notifications_badge_controller.dart';
import '../notifications/notifications_screen.dart';
import 'home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.profile,
    this.fetchFeed,
    this.badgeController,
  });

  final MemberProfile profile;
  final ListingFeedFetch? fetchFeed;
  final NotificationsBadgeController? badgeController;

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;
  final _searchController = TextEditingController();
  Timer? _debounce;
  CommunityImpact? _impact;

  @override
  void initState() {
    super.initState();
    _controller = HomeController(
      profile: widget.profile,
      fetchFeed: widget.fetchFeed,
    );
    _controller.init();
    _loadImpact();
  }

  /// The banner is optional: on any failure it simply stays hidden.
  Future<void> _loadImpact() async {
    try {
      final impact = await client.stats.community();
      if (mounted) setState(() => _impact = impact);
    } catch (_) {}
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void refresh() {
    _controller.refresh();
    _loadImpact();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _controller.setQuery(value);
    });
  }

  void _openNotifications() {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (context) => const NotificationsScreen(),
          ),
        )
        .then((_) {
          if (mounted) {
            widget.badgeController?.refresh();
          }
        });
  }

  void _openMap() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const MapScreen(),
      ),
    );
  }

  Future<void> _openDetail(ListingView view) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => ListingDetailScreen(view: view),
      ),
    );
    if (changed == true) {
      _controller.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final size = ScreenSize.of(context);
        if (size == ScreenSize.compact) {
          return _buildCompact(context);
        }
        return _buildWide(context, size);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Compact layout (kept exactly as before)
  // ---------------------------------------------------------------------------
  Widget _buildCompact(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _controller.refresh,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 200) {
                _controller.loadMore();
              }
              return false;
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context)),
                SliverToBoxAdapter(child: _buildSearch(context)),
                SliverToBoxAdapter(child: _buildFilterChips(context)),
                SliverToBoxAdapter(child: _buildCategories(context)),
                SliverToBoxAdapter(child: _buildSectionHeader(context)),
                if (_controller.loading && _controller.listings.isEmpty)
                  SliverToBoxAdapter(child: _buildSkeleton(context))
                else if (_controller.error != null &&
                    _controller.listings.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildError(context),
                  )
                else if (_controller.listings.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmpty(context),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == _controller.listings.length) {
                            if (_controller.loadingMore) {
                              return const Padding(
                                padding: EdgeInsets.all(AppSpacing.l),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (_controller.loadMoreError != null) {
                              return _buildLoadMoreError(context);
                            }
                            return const SizedBox.shrink();
                          }
                          final view = _controller.listings[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.m,
                            ),
                            child: ListingCard.fromView(
                              view,
                              onTap: () => _openDetail(view),
                            ),
                          );
                        },
                        childCount: _controller.listings.length + 1,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xl),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Wide layout (medium + expanded)
  // ---------------------------------------------------------------------------
  Widget _buildWide(BuildContext context, ScreenSize size) {
    final isExpanded = size == ScreenSize.expanded;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: ContentWidth(
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xl),
            child: isExpanded
                ? _buildExpandedBody(context)
                : _buildMediumBody(context),
          ),
        ),
      ),
    );
  }

  Widget _buildMediumBody(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _controller.refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 200) {
            _controller.loadMore();
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildWideHeader(
                context,
                inlineSearch: false,
                showBell: true,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.l,
                  bottom: AppSpacing.l,
                ),
                child: _buildSearchField(maxWidth: 520),
              ),
            ),
            SliverToBoxAdapter(child: _buildFilterChips(context)),
            SliverToBoxAdapter(child: _buildWideCategories(context)),
            SliverToBoxAdapter(child: _buildSectionHeader(context)),
            _buildResults(context),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.xl),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedBody(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 260,
          child: SingleChildScrollView(
            child: _buildSidebar(context),
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          child: Column(
            children: [
              _buildWideHeader(
                context,
                inlineSearch: true,
                showBell: false,
              ),
              const SizedBox(height: AppSpacing.l),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _controller.refresh,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.pixels >=
                          notification.metrics.maxScrollExtent - 200) {
                        _controller.loadMore();
                      }
                      return false;
                    },
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(child: _buildSectionHeader(context)),
                        _buildResults(context),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: AppSpacing.xl),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Sidebar (expanded only)
  // ---------------------------------------------------------------------------
  Widget _buildSidebar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Qué buscas', style: AppTypography.sectionLabel),
        const SizedBox(height: AppSpacing.m),
        ...ListingTypeUi.values.map((type) {
          final selected = _controller.selectedType == type;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: SizedBox(
              width: double.infinity,
              child: _SidebarTypeRow(
                type: type,
                selected: selected,
                onTap: () => _controller.setType(selected ? null : type),
              ),
            ),
          );
        }),
        const SizedBox(height: AppSpacing.xl),
        Text('Categorías', style: AppTypography.sectionLabel),
        const SizedBox(height: AppSpacing.m),
        ...CategoryUi.values.map((category) {
          final selected = _controller.selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: _SidebarCategoryRow(
              category: category,
              selected: selected,
              onTap: () => _controller.setCategory(category),
            ),
          );
        }),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Header / search
  // ---------------------------------------------------------------------------
  Widget _buildWideHeader(
    BuildContext context, {
    required bool inlineSearch,
    required bool showBell,
  }) {
    final greeting = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hola, ${widget.profile.displayName}',
          style: AppTypography.caption,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text('Dale Otra Vida', style: AppTypography.headline),
      ],
    );

    final search = _buildSearchField(maxWidth: 520);

    if (inlineSearch) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: greeting),
          const SizedBox(width: AppSpacing.xl),
          // The results column can be narrower than greeting + 520px search.
          Flexible(child: search),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: greeting),
        if (showBell)
          AnimatedBuilder(
            animation: widget.badgeController ?? Listenable.merge([]),
            builder: (context, child) {
              final controller = widget.badgeController;
              return _HomeBell(
                countLabel: controller?.label ?? '',
                hasUnread: controller?.hasUnread ?? false,
                onTap: _openNotifications,
              );
            },
          ),
      ],
    );
  }

  Widget _buildSearchField({double? maxWidth}) {
    final field = TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.search, color: AppColors.textHint),
        hintText: 'Busca ropa, libros, alimentos…',
      ),
    );
    if (maxWidth != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: field,
      );
    }
    return field;
  }

  // ---------------------------------------------------------------------------
  // Filters & categories
  // ---------------------------------------------------------------------------
  Widget _buildFilterChips(BuildContext context) {
    const options = ['Todos', 'Donar', 'Intercambiar', 'Vender', 'Prestar'];
    final selected = _controller.selectedType?.label ?? 'Todos';
    return FilterChipRow(
      padding: ScreenSize.of(context).isCompact
          ? const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal)
          : EdgeInsets.zero,
      options: options,
      selected: selected,
      onSelected: (label) {
        _controller.setType(_typeFromLabel(label));
      },
    );
  }

  Widget _buildCategories(BuildContext context) {
    final categories = CategoryUi.values.take(8).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Categorías', style: AppTypography.sectionLabel),
          const SizedBox(height: AppSpacing.m),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            // Fixed row height (what 0.85 gave on a 390 px phone), so tiles
            // never clip on narrower screens.
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: AppSpacing.m,
              crossAxisSpacing: AppSpacing.s,
              mainAxisExtent: 96,
            ),
            children: categories.map((category) {
              final selected = _controller.selectedCategory == category;
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: InkWell(
                  onTap: () => _controller.setCategory(category),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: CategoryTile(category: category),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.l),
        ],
      ),
    );
  }

  Widget _buildWideCategories(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.l),
        Text('Categorías', style: AppTypography.sectionLabel),
        const SizedBox(height: AppSpacing.m),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: CategoryUi.values.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSpacing.s),
            itemBuilder: (context, index) {
              final category = CategoryUi.values[index];
              final selected = _controller.selectedCategory == category;
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: InkWell(
                  onTap: () => _controller.setCategory(category),
                  borderRadius: BorderRadius.circular(18),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: CategoryTile(category: category, width: 100),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Section header & results
  // ---------------------------------------------------------------------------
  /// Compact screens pad each section; wide ones sit inside ContentWidth.
  EdgeInsets _sectionPadding(BuildContext context) =>
      ScreenSize.of(context).isCompact
      ? const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal)
      : EdgeInsets.zero;

  Widget _buildSectionHeader(BuildContext context) {
    return Padding(
      padding: _sectionPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_impact != null) ...[
            _ImpactBanner(impact: _impact!),
            const SizedBox(height: AppSpacing.l),
          ],
          SectionHeader(
            label: 'Cerca de ti',
            actionLabel: 'Ver mapa',
            onAction: _openMap,
          ),
          if (_controller.location != null) ...[
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: AppSpacing.s,
              children: [
                _SortChip(
                  label: 'Más recientes',
                  selected: !_controller.nearest,
                  onTap: () => _controller.setNearest(false),
                ),
                _SortChip(
                  label: 'Más cerca',
                  icon: Icons.near_me_outlined,
                  selected: _controller.nearest,
                  onTap: () => _controller.setNearest(true),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    if (_controller.loading && _controller.listings.isEmpty) {
      return _buildGridSkeleton(context);
    }
    if (_controller.error != null && _controller.listings.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildError(context),
      );
    }
    if (_controller.listings.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildEmpty(context),
      );
    }

    return SliverPadding(
      padding: _sectionPadding(context),
      sliver: SliverGrid(
        gridDelegate: listingGridDelegate(spacing: 20),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == _controller.listings.length) {
              if (_controller.loadingMore) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_controller.loadMoreError != null) {
                return _buildLoadMoreError(context);
              }
              return const SizedBox.shrink();
            }
            final view = _controller.listings[index];
            return ListingGridCard.fromView(
              view,
              onTap: () => _openDetail(view),
            );
          },
          childCount: _controller.listings.length + 1,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // States
  // ---------------------------------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ).copyWith(top: AppSpacing.l),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, ${widget.profile.displayName}',
                  style: AppTypography.caption,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('Dale Otra Vida', style: AppTypography.headline),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: widget.badgeController ?? Listenable.merge([]),
            builder: (context, child) {
              final controller = widget.badgeController;
              return _HomeBell(
                countLabel: controller?.label ?? '',
                hasUnread: controller?.hasUnread ?? false,
                onTap: _openNotifications,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.l,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search, color: AppColors.textHint),
          hintText: 'Busca ropa, libros, alimentos…',
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Column(
        children: List.generate(3, (_) => const _SkeletonCard()),
      ),
    );
  }

  Widget _buildGridSkeleton(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.78,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => const _SkeletonGridCard(),
          childCount: 6,
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return const EmptyState(
      icon: Icons.inbox_outlined,
      title: 'Aún no hay publicaciones por aquí',
      message: 'Sé el primero en darle otra vida a algo.',
    );
  }

  Widget _buildError(BuildContext context) {
    return EmptyState(
      icon: Icons.wifi_off_rounded,
      title: 'No pudimos cargar las publicaciones',
      message: 'Revisa tu conexión e inténtalo de nuevo.',
      actionLabel: 'Reintentar',
      onAction: _controller.refresh,
    );
  }

  Widget _buildLoadMoreError(BuildContext context) {
    return InkWell(
      onTap: () => _controller.loadMore(),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No pudimos cargar más',
              style: AppTypography.caption,
            ),
            Text(
              ' · ',
              style: AppTypography.caption,
            ),
            Text(
              'Reintentar',
              style: AppTypography.bodyStrong.copyWith(
                color: AppColors.link,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

ListingTypeUi? _typeFromLabel(String label) {
  return switch (label) {
    'Donar' => ListingTypeUi.donar,
    'Intercambiar' => ListingTypeUi.intercambiar,
    'Vender' => ListingTypeUi.vender,
    'Prestar' => ListingTypeUi.prestar,
    _ => null,
  };
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Container(
                    width: 140,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonGridCard extends StatelessWidget {
  const _SkeletonGridCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Container(
                  width: 120,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarTypeRow extends StatelessWidget {
  const _SidebarTypeRow({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final ListingTypeUi type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type.label,
                style: AppTypography.bodyStrong.copyWith(
                  color: selected ? AppColors.onPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                type.description,
                style: AppTypography.caption.copyWith(
                  color: selected
                      ? AppColors.onPrimary.withValues(alpha: 0.85)
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarCategoryRow extends StatelessWidget {
  const _SidebarCategoryRow({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final CategoryUi category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.s,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.categoryCircle : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                category.icon,
                size: 18,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.s),
              Text(
                category.label,
                style: AppTypography.bodyStrong.copyWith(
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeBell extends StatelessWidget {
  const _HomeBell({
    required this.countLabel,
    required this.hasUnread,
    required this.onTap,
  });

  final String countLabel;
  final bool hasUnread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textPrimary,
            ),
          ),
          if (hasUnread)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: const BoxDecoration(
                  color: AppColors.accentStrong,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Center(
                  child: Text(
                    countLabel,
                    style: AppTypography.badge.copyWith(
                      color: AppColors.onPrimary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.onPrimary : AppColors.textPrimary;
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      avatar: icon == null ? null : Icon(icon, size: 16, color: color),
      label: Text(label),
      labelStyle: AppTypography.caption.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.border,
      ),
      shape: const StadiumBorder(),
    );
  }
}

/// Community impact: a reason to keep sharing (objective 3.2.3).
class _ImpactBanner extends StatelessWidget {
  const _ImpactBanner({required this.impact});

  final CommunityImpact impact;

  @override
  Widget build(BuildContext context) {
    final delivered = impact.deliveredCount;
    final headline = delivered == 0
        ? 'Sé de los primeros en darle otra vida a algo'
        : delivered == 1
        ? 'Entre todos ya le dimos otra vida a 1 cosa'
        : 'Entre todos ya le dimos otra vida a $delivered cosas';

    Widget stat(IconData icon, String text) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.accent),
        const SizedBox(width: AppSpacing.xs),
        Text(
          text,
          style: AppTypography.caption.copyWith(color: AppColors.onPrimary),
        ),
      ],
    );

    return Semantics(
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.eco_outlined, color: AppColors.accent),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Text(
                    headline,
                    style: AppTypography.bodyStrong.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: AppSpacing.l,
              runSpacing: AppSpacing.xs,
              children: [
                stat(
                  Icons.restaurant_outlined,
                  '${impact.foodSavedCount} alimentos salvados',
                ),
                stat(
                  Icons.inventory_2_outlined,
                  '${impact.activeCount} disponibles ahora',
                ),
                stat(Icons.groups_outlined, '${impact.memberCount} vecinos'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
