import 'dart:async';

import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/material.dart';

import '../../client.dart';
import '../../core/format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import 'chat_screen.dart';

typedef ConversationsFetch = Future<List<ConversationView>> Function();
typedef InboxStream = Stream<ChatMessage> Function();

/// Width from which the list and the open chat are shown side by side.
const _splitWidth = 840.0;

/// The Mensajes tab: every conversation of the member, updated live.
class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({
    super.key,
    this.fetchConversations,
    this.inbox,
    this.onUnreadChanged,
  });

  final ConversationsFetch? fetchConversations;
  final InboxStream? inbox;

  /// Called when messages arrive or are read, to refresh the tab badge.
  final VoidCallback? onUnreadChanged;

  @override
  State<ConversationsScreen> createState() => ConversationsScreenState();
}

class ConversationsScreenState extends State<ConversationsScreen> {
  List<ConversationView>? _conversations;
  bool _loading = true;
  bool _failed = false;
  int? _selectedId;

  StreamSubscription<ChatMessage>? _subscription;
  Timer? _retryTimer;
  Timer? _refreshDebounce;

  @override
  void initState() {
    super.initState();
    refresh();
    _listenInbox();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _retryTimer?.cancel();
    _refreshDebounce?.cancel();
    super.dispose();
  }

  Future<void> refresh() async {
    setState(() {
      _loading = _conversations == null;
      _failed = false;
    });
    try {
      final fetch =
          widget.fetchConversations ?? () => client.chat.conversations();
      final conversations = await fetch();
      if (!mounted) return;
      setState(() {
        _conversations = conversations;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failed = _conversations == null;
        _loading = false;
      });
    }
  }

  void _listenInbox() {
    _subscription?.cancel();
    try {
      final stream = widget.inbox?.call() ?? client.chat.inbox();
      _subscription = stream.listen(
        (_) => _scheduleRefresh(),
        onError: (_) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
        cancelOnError: true,
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      _listenInbox();
      _scheduleRefresh();
    });
  }

  /// Bursts of messages trigger a single reload.
  void _scheduleRefresh() {
    _refreshDebounce?.cancel();
    _refreshDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      refresh();
      widget.onUnreadChanged?.call();
    });
  }

  void _onChatChanged() {
    _scheduleRefresh();
  }

  Future<void> _open(ConversationView view, {required bool split}) async {
    if (split) {
      setState(() => _selectedId = view.conversation.id);
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => ChatScreen(
          conversationId: view.conversation.id!,
          initialView: view,
          onChanged: _onChatChanged,
        ),
      ),
    );
    if (mounted) refresh();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final split = constraints.maxWidth >= _splitWidth;
        final list = _buildList(split: split);
        if (!split) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text('Mensajes', style: AppTypography.headline),
              backgroundColor: AppColors.background,
              surfaceTintColor: Colors.transparent,
            ),
            body: list,
          );
        }

        final selectedId = _selectedId;
        ConversationView? selected;
        for (final view in _conversations ?? <ConversationView>[]) {
          if (view.conversation.id == selectedId) selected = view;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Row(
            children: [
              SizedBox(
                width: 360,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xxl,
                        AppSpacing.xxl,
                        AppSpacing.xxl,
                        AppSpacing.m,
                      ),
                      child: Text('Mensajes', style: AppTypography.headline),
                    ),
                    Expanded(child: list),
                  ],
                ),
              ),
              const VerticalDivider(width: 1, thickness: 1),
              Expanded(
                child: selectedId == null
                    ? const EmptyState(
                        icon: Icons.forum_outlined,
                        title: 'Elige una conversación',
                        message:
                            'Aquí verás los mensajes para coordinar la entrega.',
                      )
                    : ChatScreen(
                        key: ValueKey(selectedId),
                        conversationId: selectedId,
                        initialView: selected,
                        embedded: true,
                        onChanged: _onChatChanged,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildList({required bool split}) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_failed) {
      return EmptyState(
        icon: Icons.wifi_off_rounded,
        title: 'No pudimos cargar tus mensajes',
        message: 'Revisa tu conexión e inténtalo de nuevo.',
        actionLabel: 'Reintentar',
        onAction: refresh,
      );
    }
    final conversations = _conversations ?? [];
    if (conversations.isEmpty) {
      return RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          children: const [
            SizedBox(height: 80),
            EmptyState(
              icon: Icons.chat_bubble_outline,
              title: 'Aún no tienes conversaciones',
              message:
                  'Cuando pidas algo o alguien pida lo tuyo, podrán hablar '
                  'aquí.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
        itemCount: conversations.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          indent: 84,
          color: AppColors.borderLight,
        ),
        itemBuilder: (context, index) {
          final view = conversations[index];
          return _ConversationTile(
            view: view,
            selected: split && view.conversation.id == _selectedId,
            onTap: () => _open(view, split: split),
          );
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.view,
    required this.selected,
    required this.onTap,
  });

  final ConversationView view;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = view.unreadCount > 0;
    final preview = view.conversation.lastMessagePreview ?? '';

    return Material(
      color: selected ? AppColors.categoryCircle : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        mouseCursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.m,
          ),
          child: Row(
            children: [
              AppAvatar(initials: initialsFor(view.other.displayName)),
              const SizedBox(width: AppSpacing.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            view.other.displayName,
                            style: AppTypography.bodyStrong,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s),
                        Text(
                          formatRelative(view.conversation.lastMessageAt),
                          style: AppTypography.caption.copyWith(
                            color: unread
                                ? AppColors.accentStrong
                                : AppColors.textSecondary,
                            fontWeight: unread
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      view.listing.listing.title,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.link,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            preview,
                            style: AppTypography.body.copyWith(
                              color: unread
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontWeight: unread
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: AppSpacing.s),
                          Container(
                            constraints: const BoxConstraints(minWidth: 22),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Text(
                              view.unreadCount > 9
                                  ? '9+'
                                  : '${view.unreadCount}',
                              style: AppTypography.badge.copyWith(
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
