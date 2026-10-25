import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/foundation.dart';

import '../../client.dart';
import '../../core/location.dart';
import '../../core/models/category_ui.dart';
import '../../core/models/listing_type_ui.dart';

class HomeController extends ChangeNotifier {
  HomeController({required this.profile});

  final MemberProfile profile;

  ListingTypeUi? selectedType;
  CategoryUi? selectedCategory;
  String query = '';
  List<ListingView> listings = [];
  bool loading = false;
  bool loadingMore = false;
  String? error;
  bool hasMore = true;
  ({double lat, double lng})? location;

  static const _limit = 20;

  Future<void> init() async {
    location = await currentApproxLocation();
    await _load(refresh: true);
  }

  Future<void> refresh() => _load(refresh: true);

  Future<void> loadMore() async {
    if (loading || loadingMore || !hasMore) return;
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

  void setQuery(String value) {
    if (query == value) return;
    query = value;
    _load(refresh: true);
  }

  Future<void> _load({required bool refresh}) async {
    if (refresh) {
      loading = true;
      error = null;
      hasMore = true;
      notifyListeners();
    } else {
      loadingMore = true;
      notifyListeners();
    }

    final offset = refresh ? 0 : listings.length;

    try {
      final result = await client.listing.feed(
        type: selectedType?.toServer,
        category: selectedCategory?.toServer,
        query: query.isNotEmpty ? query : null,
        latitude: location?.lat,
        longitude: location?.lng,
        limit: _limit,
        offset: offset,
      );
      if (refresh) {
        listings = result;
      } else {
        listings.addAll(result);
      }
      hasMore = result.length >= _limit;
      error = null;
    } catch (e) {
      error = 'No pudimos cargar las publicaciones.';
    } finally {
      loading = false;
      loadingMore = false;
      notifyListeners();
    }
  }
}
