import 'dart:async';

import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/material.dart';

import '../../core/models/category_ui.dart';
import '../../core/models/listing_type_ui.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/category_tile.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/filter_chip_row.dart';
import '../../core/widgets/listing_card.dart';
import '../../core/widgets/section_header.dart';
import '../listing/listing_detail_screen.dart';
import 'home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.profile});

  final MemberProfile profile;

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = HomeController(profile: widget.profile);
    _controller.init();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void refresh() => _controller.refresh();

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _controller.setQuery(value);
    });
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const _PlaceholderScreen(title: 'Notificaciones'),
      ),
    );
  }

  void _openMap() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const _PlaceholderScreen(title: 'Mapa'),
      ),
    );
  }

  void _openDetail(ListingView view) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ListingDetailScreen(view: view),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
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
                      SliverFillRemaining(child: _buildError(context))
                    else if (_controller.listings.isEmpty)
                      SliverFillRemaining(child: _buildEmpty(context))
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
      },
    );
  }

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
          InkWell(
            onTap: _openNotifications,
            borderRadius: BorderRadius.circular(22),
            child: Container(
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

  Widget _buildFilterChips(BuildContext context) {
    const options = ['Todos', 'Donar', 'Intercambiar', 'Vender', 'Prestar'];
    final selected = _controller.selectedType?.label ?? 'Todos';
    return FilterChipRow(
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
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.m,
            crossAxisSpacing: AppSpacing.m,
            children: categories.map((category) {
              final selected = _controller.selectedCategory == category;
              return InkWell(
                onTap: () => _controller.setCategory(category),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selected ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: CategoryTile(category: category),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.l),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: SectionHeader(
        label: 'Cerca de ti',
        actionLabel: 'Ver mapa',
        onAction: _openMap,
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

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(child: Text('Disponible muy pronto')),
    );
  }
}
