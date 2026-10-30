import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/material.dart';

import '../../client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/widgets.dart';
import '../listing/listing_detail_screen.dart';
import '../reports/report_sheet.dart';
import 'profile_body.dart';

/// Another member's profile: trust stats, listings, history and reviews.
class PublicProfileScreen extends StatefulWidget {
  const PublicProfileScreen({
    super.key,
    required this.profileId,
    this.initialTab = ProfileTab.listings,
  });

  final int profileId;
  final ProfileTab initialTab;

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  PublicProfileView? _view;
  bool _failed = false;
  late ProfileTab _tab = widget.initialTab;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    try {
      final view = await client.profile.publicProfile(widget.profileId);
      if (mounted) setState(() => _view = view);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _openListing(ListingView listing) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => ListingDetailScreen(view: listing),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final view = _view;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: view == null
          ? _failed
                ? EmptyState(
                    icon: Icons.wifi_off_rounded,
                    title: 'No pudimos cargar el perfil',
                    message: 'Revisa tu conexión e inténtalo de nuevo.',
                    actionLabel: 'Reintentar',
                    onAction: _load,
                  )
                : const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ProfileBody(
                view: view,
                tab: _tab,
                onTabChanged: (tab) => setState(() => _tab = tab),
                onOpenListing: _openListing,
                onReport: view.isMe
                    ? null
                    : () => showReportSheet(
                        context,
                        title: 'Reportar a ${view.profile.displayName}',
                        reportedUserId: view.profile.id,
                      ),
              ),
            ),
    );
  }
}
