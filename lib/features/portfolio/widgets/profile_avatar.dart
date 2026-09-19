import 'package:flutter/material.dart';
import 'package:mariam_portfolio/core/data/portfolio_data.dart';
import 'package:mariam_portfolio/core/theme/app_theme.dart';

/// Mariam's photo, framed like a chip. Falls back to initials until the
/// photo exists at [PortfolioData.photoAsset].
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, this.size = 112});

  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final c = theme.extension<SchematicColors>()!;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.wireLive, width: 2),
        boxShadow: [
          BoxShadow(color: c.wireLive.withAlpha(60), blurRadius: 14),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          PortfolioData.photoAsset,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (context, error, stack) => ColoredBox(
            color: scheme.primaryContainer,
            child: Center(
              child: Text(
                'MA',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
