import 'package:flutter/material.dart';

/// Keeps all routes clear of display cutouts and readable on wide displays.
class AlfAppViewport extends StatelessWidget {
  final Widget child;
  const AlfAppViewport({super.key, required this.child});

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: SizedBox.expand(child: child),
      ),
    ),
  );
}

/// Content sets row height, rather than a fixed aspect ratio. Larger text
/// reduces the column count before it runs out of horizontal space.
class AlfResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double minItemWidth;
  final int maxColumns;
  final double spacing;
  const AlfResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 300,
    this.maxColumns = 3,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      final columns =
          ((constraints.maxWidth + spacing) / (minItemWidth * scale + spacing))
              .floor()
              .clamp(1, maxColumns);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var start = 0; start < children.length; start += columns) ...[
            if (start > 0) SizedBox(height: spacing),
            if (columns == 1)
              children[start]
            else
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var column = 0; column < columns; column++) ...[
                      if (column > 0) SizedBox(width: spacing),
                      Expanded(
                        child: start + column < children.length
                            ? children[start + column]
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ],
      );
    },
  );
}
