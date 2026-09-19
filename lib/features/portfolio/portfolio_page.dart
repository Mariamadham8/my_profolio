import 'package:flutter/material.dart';
import 'package:mariam_portfolio/core/data/portfolio_data.dart';
import 'package:mariam_portfolio/core/theme/app_theme.dart';
import 'package:mariam_portfolio/features/portfolio/canvas/schematic_canvas.dart';
import 'package:mariam_portfolio/features/portfolio/widgets/component_library.dart';
import 'package:mariam_portfolio/features/portfolio/widgets/profile_avatar.dart';
import 'package:mariam_portfolio/features/portfolio/widgets/section_bodies.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  static const double _mobileBreakpoint = 820;

  final _controller = SchematicController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < _mobileBreakpoint) {
            return const SafeArea(child: _MobileLayout());
          }
          return Row(
            children: [
              ComponentLibrary(controller: _controller),
              Expanded(child: SchematicCanvas(controller: _controller)),
            ],
          );
        },
      ),
    );
  }
}

/// Phones get a vertical list of the same components instead of pan/zoom.
class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ChipCard(
          refDes: 'U1',
          icon: Icons.developer_board,
          title: 'Mariam',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfileAvatar(size: 96),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(PortfolioData.name, style: text.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      PortfolioData.role,
                      style: text.titleMedium?.copyWith(color: scheme.primary),
                    ),
                    Text(PortfolioData.tagline, style: text.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
        for (final s in PortfolioData.sections)
          _ChipCard(
            refDes: s.refDes,
            icon: s.icon,
            title: s.title,
            child: SectionBody(s.id),
          ),
      ],
    );
  }
}

class _ChipCard extends StatelessWidget {
  const _ChipCard({
    required this.refDes,
    required this.icon,
    required this.title,
    required this.child,
  });

  final String refDes;
  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = theme.extension<SchematicColors>()!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.chipBody,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: c.chipBorder, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                refDes,
                style: theme.textTheme.labelMedium?.copyWith(color: c.label),
              ),
              const SizedBox(width: 10),
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
            ],
          ),
          Divider(height: 24, color: c.chipBorder.withAlpha(90)),
          child,
        ],
      ),
    );
  }
}
