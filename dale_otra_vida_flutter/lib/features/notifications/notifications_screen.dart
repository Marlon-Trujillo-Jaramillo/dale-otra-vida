import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/material.dart';

import '../../client.dart';
import '../../core/format.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/empty_state.dart';
import '../chat/chat_screen.dart';
import '../listing/listing_detail_screen.dart';
import '../profile/profile_body.dart';
import '../profile/public_profile_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<AppNotification> _notifications = [];
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  bool _hasMore = true;

  static const _limit = 30;

  @override
  void initState() {
    super.initState();
    _load(refresh: true);
  }

  Future<void> _load({required bool refresh}) async {
    if (_loading || _loadingMore) return;

    setState(() {
      if (refresh) {
        _loading = true;
        _error = null;
      } else {
        _loadingMore = true;
      }
    });

    try {
      final offset = refresh ? 0 : _notifications.length;
      final result = await client.notification.list(
        limit: _limit,
        offset: offset,
      );
      if (!mounted) return;

      setState(() {
        if (refresh) {
          _notifications
            ..clear()
            ..addAll(result);
        } else {
          _notifications.addAll(result);
        }
        _hasMore = result.length >= _limit;
        if (refresh) _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (refresh) {
          _error = 'No pudimos cargar tus notificaciones.';
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  Future<void> _markAllRead() async {
    try {
      await client.notification.markAllRead();
      if (!mounted) return;
      setState(() {
        for (var i = 0; i < _notifications.length; i++) {
          _notifications[i] = _notifications[i].copyWith(
            readAt: DateTime.now(),
          );
        }
      });
    } catch (_) {
      if (mounted) {
        _showSnackBar('No pudimos marcar las notificaciones como leídas.');
      }
    }
  }

  Future<void> _markReadAndOpen(AppNotification notification) async {
    try {
      await client.notification.markRead(notification.id!);
    } catch (_) {
      // Still navigate even if marking read failed.
    }

    if (!mounted) return;

    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index >= 0) {
        _notifications[index] = notification.copyWith(readAt: DateTime.now());
      }
    });

    _navigateFor(notification);
  }

  void _navigateFor(AppNotification notification) {
    final kind = notification.kind;
    final refId = notification.refId;

    final isListingKind =
        kind == NotificationKind.newRequest ||
        kind == NotificationKind.requestAccepted ||
        kind == NotificationKind.requestRejected ||
        kind == NotificationKind.requestCancelled ||
        kind == NotificationKind.deliveryCompleted ||
        kind == NotificationKind.listingExpiring;

    if (isListingKind && refId != null) {
      _openListing(refId);
      return;
    }

    if (kind == NotificationKind.newReview) {
      _openMyReviews();
      return;
    }

    if (kind == NotificationKind.newMessage && refId != null) {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (context) => ChatScreen(conversationId: refId),
        ),
      );
      return;
    }

    _showSnackBar('Disponible muy pronto');
  }

  Future<void> _openMyReviews() async {
    try {
      final me = await client.profile.me();
      if (!mounted || me == null) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (context) => PublicProfileScreen(
            profileId: me.id!,
            initialTab: ProfileTab.reviews,
          ),
        ),
      );
    } catch (_) {
      if (mounted) _showSnackBar('No pudimos abrir tus reseñas.');
    }
  }

  Future<void> _openListing(int listingId) async {
    try {
      final view = await client.listing.byId(listingId);
      if (!mounted) return;
      if (view == null) {
        _showSnackBar('La publicación ya no está disponible.');
        return;
      }
      await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (context) => ListingDetailScreen(view: view),
        ),
      );
    } catch (_) {
      if (mounted) {
        _showSnackBar('No pudimos abrir la publicación.');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  IconData _iconFor(NotificationKind kind) {
    return switch (kind) {
      NotificationKind.newRequest => Icons.front_hand_outlined,
      NotificationKind.requestAccepted => Icons.check_circle_outlined,
      NotificationKind.requestRejected => Icons.info_outline,
      NotificationKind.newMessage => Icons.chat_bubble_outline,
      NotificationKind.newReview => Icons.star_outline_rounded,
      NotificationKind.listingExpiring => Icons.info_outline,
      NotificationKind.requestCancelled => Icons.info_outline,
      NotificationKind.deliveryCompleted => Icons.volunteer_activism_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final size = ScreenSize.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Notificaciones', style: AppTypography.title),
        centerTitle: size != ScreenSize.compact,
        actions: [
          TextButton(
            onPressed: _notifications.any((n) => n.readAt == null)
                ? _markAllRead
                : null,
            child: Text(
              'Marcar todo como leído',
              style: AppTypography.bodyStrong.copyWith(
                color: AppColors.link,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading && _notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _notifications.isEmpty) {
      return EmptyState(
        icon: Icons.wifi_off_rounded,
        title: 'No pudimos cargar tus notificaciones',
        message: 'Revisa tu conexión e inténtalo de nuevo.',
        actionLabel: 'Reintentar',
        onAction: () => _load(refresh: true),
      );
    }

    if (_notifications.isEmpty) {
      return const EmptyState(
        icon: Icons.notifications_none,
        title: 'No tienes notificaciones',
        message: 'Aquí verás lo que pasa con tus publicaciones y solicitudes.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => _load(refresh: true),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 200) {
            if (_hasMore && !_loadingMore) {
              _load(refresh: false);
            }
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.s,
          ),
          itemCount: _notifications.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _notifications.length) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.l),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final notification = _notifications[index];
            return _NotificationRow(
              notification: notification,
              icon: _iconFor(notification.kind),
              onTap: () => _markReadAndOpen(notification),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({
    required this.notification,
    required this.icon,
    required this.onTap,
  });

  final AppNotification notification;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = notification.readAt == null;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: AppSpacing.m,
        ),
        decoration: BoxDecoration(
          color: unread
              ? AppColors.categoryCircle.withValues(alpha: 0.4)
              : null,
          border: Border(
            bottom: BorderSide(color: AppColors.borderLight),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.categoryCircle,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: unread
                        ? AppTypography.bodyStrong
                        : AppTypography.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    notification.body,
                    style: AppTypography.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    formatRelative(notification.createdAt),
                    style: AppTypography.caption,
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
