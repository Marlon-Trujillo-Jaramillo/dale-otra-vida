import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/material.dart';

import '../../client.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/listing_card.dart';
import '../../core/widgets/listing_grid_card.dart';
import '../listing/listing_detail_screen.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  List<MyRequestView> _requests = [];
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
      final result = await client.request.mine();
      if (!mounted) return;
      setState(() {
        _requests = result;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No pudimos cargar tus solicitudes.';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _openDetail(MyRequestView view) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => ListingDetailScreen(view: view.listing),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = ScreenSize.of(context);
    final isCompact = size == ScreenSize.compact;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mis solicitudes', style: AppTypography.title),
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
    if (_loading && _requests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _requests.isEmpty) {
      return EmptyState(
        icon: Icons.wifi_off_rounded,
        title: 'No pudimos cargar tus solicitudes',
        message: 'Revisa tu conexión e inténtalo de nuevo.',
        actionLabel: 'Reintentar',
        onAction: _load,
      );
    }

    if (_requests.isEmpty) {
      return const EmptyState(
        icon: Icons.favorite_border,
        title: 'Aún no has pedido nada',
        message: 'Cuando solicites una publicación aparecerá aquí.',
      );
    }

    if (isCompact) {
      return ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final view = _requests[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.m),
            child: Stack(
              children: [
                ListingCard.fromView(
                  view.listing,
                  onTap: () => _openDetail(view),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: _StatusChip(status: view.request.status),
                ),
              ],
            ),
          );
        },
      );
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 0.78,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final view = _requests[index];
                return Stack(
                  children: [
                    ListingGridCard.fromView(
                      view.listing,
                      onTap: () => _openDetail(view),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _StatusChip(status: view.request.status),
                    ),
                  ],
                );
              },
              childCount: _requests.length,
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

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
        'Reservado para ti',
        const Color(0xFFD4EDDA),
        const Color(0xFF155724),
      ),
      RequestStatus.rejected => (
        'No disponible',
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
