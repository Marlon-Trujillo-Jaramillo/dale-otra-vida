import 'dart:async';

import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../client.dart';
import '../../core/location.dart';
import '../../core/models/category_ui.dart';
import '../../core/models/listing_type_ui.dart';

typedef ListingFeedFetch =
    Future<List<ListingView>> Function({
      ListingType? type,
      Category? category,
      String? query,
      double? latitude,
      double? longitude,
      bool? nearest,
      required int limit,
      required int offset,
    });

class HomeController extends ChangeNotifier {
  HomeController({
    required this.profile,
    ListingFeedFetch? fetchFeed,
  }) : _fetchFeed = fetchFeed ?? client.listing.feed;

  final MemberProfile profile;
  final ListingFeedFetch _fetchFeed;

  ListingTypeUi? selectedType;
  CategoryUi? selectedCategory;
  String query = '';
  List<ListingView> listings = [];
  bool loading = false;
  bool loadingMore = false;
  String? error;
  String? loadMoreError;
  bool hasMore = true;
  ({double lat, double lng})? location;

  /// Closest first instead of newest first; needs a location.
  bool nearest = false;

  static const _limit = 20;
  int _gen = 0;
  bool _disposed = false;

  Future<void> init() async {
    location = await currentApproxLocation();
    if (_disposed) return;
    await _load(refresh: true);
  }

  Future<void> refresh() => _load(refresh: true);

  Future<void> loadMore() async {
    if (loading || loadingMore || !hasMore || _disposed) return;
    await _load(refresh: false);
  }

  void setType(ListingTypeUi? type) {
    if (selectedType == type) return;
    selectedType = type;
    _load(refresh: true);
  }

  void setCategory(CategoryUi? category) {
    if (selectedCategory == category) {
      selectedCategory = null;
    } else {
      selectedCategory = category;
    }
    _load(refresh: true);
  }

  void setNearest(bool value) {
    if (nearest == value) return;
    nearest = value;
    _load(refresh: true);
  }

  void setQuery(String value) {
    if (query == value) return;
    query = value;
    _load(refresh: true);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _load({required bool refresh}) async {
    if (_disposed) return;

    final gen = ++_gen;

    if (refresh) {
      loading = true;
      error = null;
      loadMoreError = null;
      hasMore = true;
    } else {
      loadingMore = true;
    }
    _safeNotify();

    final offset = refresh ? 0 : listings.length;

    try {
      final result = await _fetchFeed(
        type: selectedType?.toServer,
        category: selectedCategory?.toServer,
        query: query.isNotEmpty ? query : null,
        latitude: location?.lat,
        longitude: location?.lng,
        nearest: nearest && location != null ? true : null,
        limit: _limit,
        offset: offset,
      );
      if (gen != _gen || _disposed) return;

      if (refresh) {
        listings = result;
      } else {
        listings.addAll(result);
      }
      hasMore = result.length >= _limit;
      if (refresh) error = null;
      loadMoreError = null;
    } catch (e) {
      if (gen != _gen || _disposed) return;

      if (refresh) {
        error = 'No pudimos cargar las publicaciones.';
      } else {
        loadMoreError = 'No pudimos cargar más.';
      }
    } finally {
      if (gen == _gen && !_disposed) {
        if (refresh) loading = false;
        loadingMore = false;
        _safeNotify();
      }
    }
  }
}
