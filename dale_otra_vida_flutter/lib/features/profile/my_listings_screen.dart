import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/material.dart';

import '../../client.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/listing_card.dart';
import '../../core/widgets/listing_grid_card.dart';
import '../../core/widgets/section_header.dart';
import '../listing/listing_detail_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  List<ListingView> _listings = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await client.listing.mine();
      if (!mounted) return;
      setState(() {
        _listings = result;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No pudimos cargar tus publicaciones.';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _openDetail(ListingView view) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => ListingDetailScreen(view: view),
      ),
    );
    if (changed == true) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = ScreenSize.of(context);
    final isCompact = size == ScreenSize.compact;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mis publicaciones', style: AppTypography.title),
        centerTitle: size != ScreenSize.compact,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: _buildBody(context, isCompact),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isCompact) {
    if (_loading && _listings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _listings.isEmpty) {
      return EmptyState(
        icon: Icons.wifi_off_rounded,
        title: 'No pudimos cargar tus publicaciones',
        message: 'Revisa tu conexión e inténtalo de nuevo.',
        actionLabel: 'Reintentar',
        onAction: _load,
      );
    }

    if (_listings.isEmpty) {
      return const EmptyState(
        icon: Icons.inbox_outlined,
        title: 'Aún no tienes publicaciones',
        message: 'Empieza por publicar algo que ya no uses.',
      );
    }

    if (isCompact) {
      return ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        itemCount: _listings.length,
        itemBuilder: (context, index) {
          final view = _listings[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.m),
            child: ListingCard.fromView(
              view,
              onTap: () => _openDetail(view),
            ),
          );
        },
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ).copyWith(top: AppSpacing.l, bottom: AppSpacing.m),
            child: SectionHeader(label: 'Tus publicaciones'),
          ),
        ),
        SliverPadding(
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
              (context, index) {
                final view = _listings[index];
                return ListingGridCard.fromView(
                  view,
                  onTap: () => _openDetail(view),
                );
              },
              childCount: _listings.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.xl),
        ),
      ],
    );
  }
}
