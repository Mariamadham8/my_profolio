import 'package:flutter/material.dart';
import 'package:mariam_portfolio/core/theme/app_theme.dart';

/// A phone bezel that scales to whatever space it gets (9:19 screen).
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final c = theme.extension<SchematicColors>()!;

    return AspectRatio(
      aspectRatio: 9 / 19,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(34),
          border: Border.all(color: c.wireLive, width: 2),
          boxShadow: [
            BoxShadow(color: c.wireLive.withAlpha(50), blurRadius: 24),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: scheme.surface, child: child),
              // Camera punch-hole.
              Positioned(
                top: 9,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.surfaceContainerLowest,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
