import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/material.dart';

import '../../client.dart';
import '../../core/format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../listing/listing_detail_screen.dart';
import 'chat_logic.dart';

const _pageSize = 50;

/// One conversation, updated live through the chat stream.
///
/// With [embedded] the screen is shown next to the conversation list on wide
/// layouts and has no back button.
class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.conversationId,
    this.initialView,
    this.embedded = false,
    this.onChanged,
  });

  final int conversationId;
  final ConversationView? initialView;
  final bool embedded;

  /// Called after the caller sent or read messages.
  final VoidCallback? onChanged;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ConversationView? _view;
  List<ChatMessage> _messages = [];
  bool _loading = true;
  String? _error;
  bool _loadingOlder = false;
  bool _hasMore = true;
  bool _sending = false;

  StreamSubscription<ChatMessage>? _subscription;
  Timer? _retryTimer;

  final _input = TextEditingController();
  final _scroll = ScrollController();

  int? get _myProfileId {
    final view = _view;
    if (view == null) return null;
    return view.isOwner
        ? view.conversation.ownerId
        : view.conversation.requesterId;
  }

  @override
  void initState() {
    super.initState();
    _view = widget.initialView;
    _scroll.addListener(_onScroll);
    _load();
    _subscribe();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _retryTimer?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        client.chat.conversation(widget.conversationId),
        client.chat.messages(widget.conversationId, limit: _pageSize),
      ]);
      if (!mounted) return;
      final page = results[1] as List<ChatMessage>;
      setState(() {
        _view = results[0] as ConversationView;
        _messages = mergeMessages(_messages, page);
        _hasMore = page.length == _pageSize;
        _loading = false;
      });
      _markRead();
    } on NotAllowedException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'No pudimos cargar la conversación.';
        _loading = false;
      });
    }
  }

  Future<void> _reloadView() async {
    try {
      final view = await client.chat.conversation(widget.conversationId);
      if (mounted) setState(() => _view = view);
    } catch (_) {
      // Keep the current header if the refresh fails.
    }
  }

  void _subscribe() {
    _subscription?.cancel();
    _subscription = client.chat
        .subscribe(widget.conversationId)
        .listen(
          _onIncoming,
          onError: (_) => _scheduleResubscribe(),
          onDone: _scheduleResubscribe,
          cancelOnError: true,
        );
  }

  /// Reconnects after a dropped stream and catches up on missed messages.
  void _scheduleResubscribe() {
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;
      _subscribe();
      try {
        final page = await client.chat.messages(
          widget.conversationId,
          limit: _pageSize,
        );
        if (mounted) {
          setState(() => _messages = mergeMessages(_messages, page));
        }
      } catch (_) {
        // The next reconnect tries again.
      }
    });
  }

  void _onIncoming(ChatMessage message) {
    if (!mounted) return;
    setState(() => _messages = mergeMessages(_messages, [message]));
    if (message.kind == MessageKind.system) {
      // Reservations and deliveries change the listing header.
      _reloadView();
    }
    if (message.senderId != null && message.senderId != _myProfileId) {
      _markRead();
    }
  }

  Future<void> _markRead() async {
    try {
      await client.chat.markRead(widget.conversationId);
      widget.onChanged?.call();
    } catch (_) {
      // Unread counts catch up on the next refresh.
    }
  }

  void _onScroll() {
    // The list is reversed: the oldest messages are at the max extent.
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      _loadOlder();
    }
  }

  Future<void> _loadOlder() async {
    if (_loadingOlder || !_hasMore || _messages.isEmpty) return;
    setState(() => _loadingOlder = true);
    try {
      final page = await client.chat.messages(
        widget.conversationId,
        beforeId: _messages.first.id,
        limit: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _messages = mergeMessages(_messages, page);
        _hasMore = page.length == _pageSize;
      });
    } catch (_) {
      // Scrolling up again retries.
    } finally {
      if (mounted) setState(() => _loadingOlder = false);
    }
  }

  Future<void> _send(String text, {MessageKind? kind}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final message = await client.chat.send(
        widget.conversationId,
        trimmed,
        kind: kind,
      );
      if (!mounted) return;
      setState(() => _messages = mergeMessages(_messages, [message]));
      if (kind == null) _input.clear();
      if (_scroll.hasClients) {
        unawaited(
          _scroll.animateTo(
            0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          ),
        );
      }
      widget.onChanged?.call();
    } on NotAllowedException catch (e) {
      _showSnackBar(e.message);
      if (e.message == 'Esta conversación está cerrada.') _reloadView();
    } catch (_) {
      _showSnackBar('No pudimos enviar el mensaje. Inténtalo de nuevo.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _onQuickReply(QuickReply reply) {
    switch (reply) {
      case QuickReply.proposeSafePoint:
        _proposeSafePoint();
      case QuickReply.stillAvailable:
        _send('¿Sigue disponible?');
      case QuickReply.markDelivered:
        _markDelivered();
    }
  }

  Future<void> _proposeSafePoint() async {
    final place = await showDialog<String>(
      context: context,
      builder: (context) => _SafePointDialog(
        initialPlace: _view?.listing.listing.safeMeetingPoint,
      ),
    );
    if (place != null) {
      await _send(place, kind: MessageKind.safePointProposal);
    }
  }

  Future<void> _markDelivered() async {
    final view = _view;
    if (view == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Ya lo entregaste?'),
        content: Text(
          'Marcaremos «${view.listing.listing.title}» como entregado a '
          '${view.other.displayName}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sí, entregado'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await client.listing.updateStatus(
        view.listing.listing.id!,
        ListingStatus.delivered,
      );
      await _reloadView();
      _showSnackBar('¡Entrega registrada! Gracias por darle otra vida.');
      widget.onChanged?.call();
    } on NotAllowedException catch (e) {
      _showSnackBar(e.message);
    } catch (_) {
      _showSnackBar('No pudimos actualizar la publicación.');
    }
  }

  Future<void> _openListing() async {
    final view = _view;
    if (view == null) return;
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => ListingDetailScreen(view: view.listing),
      ),
    );
    await _reloadView();
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final view = _view;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        titleSpacing: widget.embedded ? AppSpacing.l : 0,
        shape: const Border(bottom: BorderSide(color: AppColors.border)),
        title: view == null ? null : _Header(member: view.other),
        actions: [
          if (view != null)
            IconButton(
              tooltip: 'Reportar',
              icon: const Icon(Icons.flag_outlined),
              onPressed: () => _showSnackBar('Disponible muy pronto'),
            ),
        ],
      ),
      body: _buildBody(view),
    );
  }

  Widget _buildBody(ConversationView? view) {
    if (_loading && view == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final error = _error;
    if (error != null || view == null) {
      return EmptyState(
        icon: Icons.chat_bubble_outline,
        title: 'No pudimos abrir el chat',
        message: error ?? 'Inténtalo de nuevo.',
        actionLabel: 'Reintentar',
        onAction: _load,
      );
    }

    final closed = isConversationClosed(view);
    final replies = quickRepliesFor(view);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: Column(
          children: [
            _ListingStrip(view: view, onTap: _openListing),
            const _SafetyBanner(),
            Expanded(child: _buildMessages()),
            if (replies.isNotEmpty)
              _QuickReplies(
                replies: replies,
                enabled: !_sending,
                onSelected: _onQuickReply,
              ),
            if (closed)
              const _ClosedBanner()
            else
              _Composer(
                controller: _input,
                sending: _sending,
                onSend: () => _send(_input.text),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessages() {
    if (_messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Text(
            'Escribe el primer mensaje para coordinar la entrega.',
            style: AppTypography.caption,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final myId = _myProfileId;
    final count = _messages.length + (_loadingOlder ? 1 : 0);
    return ListView.builder(
      controller: _scroll,
      reverse: true,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.m,
      ),
      itemCount: count,
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.m),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        final message = _messages[_messages.length - 1 - index];
        if (message.kind == MessageKind.system) {
          return _SystemMessage(message: message);
        }
        return _Bubble(message: message, mine: message.senderId == myId);
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.member});

  final MemberProfile member;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppAvatar(initials: initialsFor(member.displayName), size: 40),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                member.displayName,
                style: AppTypography.bodyStrong,
                overflow: TextOverflow.ellipsis,
              ),
              Text.rich(
                TextSpan(
                  text: 'Calificación ${formatRating(member.ratingAvg)} · ',
                  children: [
                    TextSpan(
                      text: 'Ver perfil',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.link,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ListingStrip extends StatelessWidget {
  const _ListingStrip({required this.view, required this.onTap});

  final ConversationView view;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final listing = view.listing.listing;
    final photo = listing.photoUrls.isEmpty ? null : listing.photoUrls.first;
    final available = listing.status == ListingStatus.available;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.m,
        AppSpacing.l,
        0,
      ),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    child: photo == null
                        ? const ColoredBox(color: AppColors.surfaceMuted)
                        : CachedNetworkImage(
                            imageUrl: photo,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) =>
                                const ColoredBox(color: AppColors.surfaceMuted),
                          ),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title,
                        style: AppTypography.bodyStrong,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        listingSubtitle(listing),
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: available
                        ? AppColors.categoryCircle
                        : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    listingStatusLabel(listing.status),
                    style: AppTypography.badge.copyWith(
                      color: available
                          ? AppColors.verified
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SafetyBanner extends StatelessWidget {
  const _SafetyBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.s,
        AppSpacing.l,
        0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF6E3CF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.security, color: AppColors.link, size: 16),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              'Por tu seguridad, acuerden la entrega en un punto público y '
              'no compartas datos bancarios.',
              style: AppTypography.caption.copyWith(color: AppColors.link),
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemMessage extends StatelessWidget {
  const _SystemMessage({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.xs + 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.text,
            style: AppTypography.caption,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.mine});

  final ChatMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final safePoint = message.kind == MessageKind.safePointProposal;
    final background = safePoint
        ? const Color(0xFFF6E3CF)
        : mine
        ? AppColors.primary
        : AppColors.surface;
    final foreground = safePoint
        ? const Color(0xFF6E300B)
        : mine
        ? AppColors.onPrimary
        : AppColors.textPrimary;
    const radius = Radius.circular(18);
    const tail = Radius.circular(4);

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75 > 520
              ? 520
              : MediaQuery.sizeOf(context).width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        decoration: BoxDecoration(
          color: background,
          border: mine || safePoint
              ? null
              : Border.all(color: AppColors.border),
          borderRadius: BorderRadius.only(
            topLeft: radius,
            topRight: radius,
            bottomLeft: mine ? radius : tail,
            bottomRight: mine ? tail : radius,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (safePoint) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.place_outlined, size: 16, color: foreground),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Punto de encuentro propuesto',
                    style: AppTypography.badge.copyWith(color: foreground),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
            Text(
              message.text,
              style: (safePoint ? AppTypography.bodyStrong : AppTypography.body)
                  .copyWith(color: foreground),
            ),
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                formatMessageTime(message.createdAt),
                style: AppTypography.caption.copyWith(
                  fontSize: 11,
                  color: foreground.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickReplies extends StatelessWidget {
  const _QuickReplies({
    required this.replies,
    required this.enabled,
    required this.onSelected,
  });

  final List<QuickReply> replies;
  final bool enabled;
  final ValueChanged<QuickReply> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        itemCount: replies.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.s),
        itemBuilder: (context, index) {
          final reply = replies[index];
          return Center(
            child: ActionChip(
              avatar: Icon(switch (reply) {
                QuickReply.proposeSafePoint => Icons.place_outlined,
                QuickReply.stillAvailable => Icons.help_outline,
                QuickReply.markDelivered => Icons.check_circle_outline,
              }, size: 16),
              label: Text(quickReplyLabel(reply)),
              labelStyle: AppTypography.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              backgroundColor: AppColors.surface,
              side: const BorderSide(color: AppColors.border),
              shape: const StadiumBorder(),
              onPressed: enabled ? () => onSelected(reply) : null,
            ),
          );
        },
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.xs,
          AppSpacing.s,
          AppSpacing.s,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                maxLength: 1000,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                style: AppTypography.body,
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje…',
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.l,
                    vertical: AppSpacing.m,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            IconButton.filled(
              tooltip: 'Enviar',
              onPressed: sending ? null : onSend,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                fixedSize: const Size(48, 48),
              ),
              icon: sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.onPrimary,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClosedBanner extends StatelessWidget {
  const _ClosedBanner();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(AppSpacing.l),
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Esta conversación está cerrada.',
          style: AppTypography.caption,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _SafePointDialog extends StatefulWidget {
  const _SafePointDialog({this.initialPlace});

  final String? initialPlace;

  @override
  State<_SafePointDialog> createState() => _SafePointDialogState();
}

class _SafePointDialogState extends State<_SafePointDialog> {
  late final _controller = TextEditingController(text: widget.initialPlace);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final place = _controller.text.trim();
    if (place.isEmpty) return;
    Navigator.of(context).pop(place);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Proponer punto seguro'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Elige un lugar público y concurrido, como una estación del '
              'metro, una biblioteca o un centro comercial.',
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              label: 'Lugar',
              hint: 'Ej: Biblioteca de Robledo, entrada principal',
              controller: _controller,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Proponer')),
      ],
    );
  }
}
