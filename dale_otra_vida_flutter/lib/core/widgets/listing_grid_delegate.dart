import 'package:flutter/rendering.dart';

/// Grid of [ListingGridCard]s whose rows grow with the column width, so the
/// 4:3 photo and the text block never clip or leave gaps while resizing.
SliverGridDelegate listingGridDelegate({
  double maxTileWidth = 300,
  int minColumns = 1,
  double spacing = 16,
}) {
  return _ListingGridDelegate(
    maxTileWidth: maxTileWidth,
    minColumns: minColumns,
    spacing: spacing,
  );
}

class _ListingGridDelegate extends SliverGridDelegate {
  const _ListingGridDelegate({
    required this.maxTileWidth,
    required this.minColumns,
    required this.spacing,
  });

  final double maxTileWidth;
  final int minColumns;
  final double spacing;

  /// Height of the text block under the photo in ListingGridCard.
  static const _textBlock = 150.0;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final width = constraints.crossAxisExtent;
    var columns = ((width + spacing) / (maxTileWidth + spacing)).ceil();
    if (columns < minColumns) columns = minColumns;
    final tileWidth = (width - spacing * (columns - 1)) / columns;
    final tileHeight = tileWidth * 3 / 4 + _textBlock;
    return SliverGridRegularTileLayout(
      crossAxisCount: columns,
      mainAxisStride: tileHeight + spacing,
      crossAxisStride: tileWidth + spacing,
      childMainAxisExtent: tileHeight,
      childCrossAxisExtent: tileWidth,
      reverseCrossAxis: false,
    );
  }

  @override
  bool shouldRelayout(_ListingGridDelegate oldDelegate) =>
      oldDelegate.maxTileWidth != maxTileWidth ||
      oldDelegate.minColumns != minColumns ||
      oldDelegate.spacing != spacing;
}
