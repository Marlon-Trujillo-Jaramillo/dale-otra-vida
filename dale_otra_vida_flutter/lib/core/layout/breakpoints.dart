import 'package:flutter/material.dart';

enum ScreenSize {
  compact,
  medium,
  expanded;

  factory ScreenSize.of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return ScreenSize.compact;
    if (width < 1024) return ScreenSize.medium;
    return ScreenSize.expanded;
  }

  bool get isCompact => this == ScreenSize.compact;
  bool get isMedium => this == ScreenSize.medium;
  bool get isExpanded => this == ScreenSize.expanded;
}

class ContentWidth extends StatelessWidget {
  const ContentWidth({
    super.key,
    this.maxWidth = 1200,
    required this.child,
  });

  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = ScreenSize.of(context);
    final padding = switch (size) {
      ScreenSize.compact => 20.0,
      ScreenSize.medium => 32.0,
      ScreenSize.expanded => 48.0,
    };

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: child,
        ),
      ),
    );
  }
}
