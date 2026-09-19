import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mariam_portfolio/core/data/portfolio_data.dart';
import 'package:mariam_portfolio/core/theme/app_theme.dart';
import 'package:mariam_portfolio/features/portfolio/canvas/schematic_canvas.dart';

/// Left sidebar, styled like Proteus' device list. Every tab is a small IC:
/// pins on both sides, a pin-1 marker and an LED. Hovering warms it up,
/// selecting lights it, and tapping sends a pulse of current around the pins.
class ComponentLibrary extends StatefulWidget {
  const ComponentLibrary({super.key, required this.controller});

  final SchematicController controller;

  @override
  State<ComponentLibrary> createState() => _ComponentLibraryState();
}

class _ComponentLibraryState extends State<ComponentLibrary>
    with SingleTickerProviderStateMixin {
  /// Drives every LED. Always ticking (gently) so the sidebar feels alive
  /// even before the simulation is started.
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse
        ..stop()
        ..value = 0;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final scheme = theme.colorScheme;
    final c = theme.extension<SchematicColors>()!;
    final controller = widget.controller;

    return Container(
      width: 264,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(right: BorderSide(color: c.chipBorder.withAlpha(120))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Text('Devices', style: text.titleLarge),
          ),
          Expanded(
            child: ValueListenableBuilder<SectionId?>(
              valueListenable: controller.active,
              builder: (context, activeId, _) => ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                children: [
                  _ChipTab(
                    icon: Icons.developer_board,
                    title: 'Mariam',
                    refDes: 'U1',
                    selected: false,
                    onTap: controller.focusHome,
                    pulse: _pulse,
                    running: controller.running,
                    phase: 0,
                  ),
                  for (final (i, s) in PortfolioData.sections.indexed)
                    _ChipTab(
                      icon: s.icon,
                      title: s.title,
                      refDes: s.refDes,
                      selected: activeId == s.id,
                      onTap: () => controller.focus(s.id),
                      pulse: _pulse,
                      running: controller.running,
                      phase: (i + 1) * 0.17,
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Drag to pan, scroll to zoom, tap a chip to open it.',
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipTab extends StatefulWidget {
  const _ChipTab({
    required this.icon,
    required this.title,
    required this.refDes,
    required this.selected,
    required this.onTap,
    required this.pulse,
    required this.running,
    required this.phase,
  });

  final IconData icon;
  final String title;
  final String refDes;
  final bool selected;
  final VoidCallback onTap;
  final Animation<double> pulse;
  final ValueListenable<bool> running;
  final double phase;

  @override
  State<_ChipTab> createState() => _ChipTabState();
}

class _ChipTabState extends State<_ChipTab>
    with SingleTickerProviderStateMixin {
  static const double _pinLength = 9;
  static const double _height = 54;

  /// One-shot animation played on tap: a flash plus a sweep along the pins.
  late final AnimationController _flash;
  bool _hover = false;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _flash = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _flash.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!MediaQuery.disableAnimationsOf(context)) {
      _flash.forward(from: 0);
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final scheme = theme.colorScheme;
    final c = theme.extension<SchematicColors>()!;
    final selected = widget.selected;
    final target = selected ? 1.0 : (_hover ? 0.55 : 0.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: _handleTap,
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1,
            duration: const Duration(milliseconds: 90),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: target),
              duration: const Duration(milliseconds: 220),
              builder: (context, lit, _) => AnimatedBuilder(
                animation: _flash,
                builder: (context, _) {
                  final sweeping = _flash.isAnimating;
                  final double flash = sweeping
                      ? 1 - Curves.easeOut.transform(_flash.value)
                      : 0.0;
                  final glow = math.max(lit, flash);

                  return SizedBox(
                    height: _height,
                    child: CustomPaint(
                      painter: _PinsPainter(
                        pinColor: c.pin,
                        liveColor: c.wireLive,
                        length: _pinLength,
                        glow: lit,
                        sweep: sweeping ? _flash.value : null,
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: _pinLength),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.lerp(
                              c.chipBody,
                              scheme.primaryContainer,
                              lit * 0.85,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color:
                                  Color.lerp(c.chipBorder, c.wireLive, glow)!,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    c.wireLive.withAlpha((110 * glow).round()),
                                blurRadius: 16 * glow,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Pin-1 marker, same as the big chips.
                              Positioned(
                                top: 6,
                                left: 6,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Color.lerp(
                                        c.label,
                                        c.wireLive,
                                        glow,
                                      )!,
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(18, 0, 12, 0),
                                  child: Row(
                                    children: [
                                      Text(
                                        widget.refDes,
                                        style: text.labelMedium?.copyWith(
                                          color: selected
                                              ? scheme.onPrimaryContainer
                                              : c.label,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Icon(
                                        widget.icon,
                                        size: 20,
                                        color: Color.lerp(
                                          scheme.onSurfaceVariant,
                                          scheme.primary,
                                          glow,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          widget.title,
                                          style: text.bodyLarge?.copyWith(
                                            color: selected
                                                ? scheme.onPrimaryContainer
                                                : scheme.onSurface,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      _Led(
                                        pulse: widget.pulse,
                                        running: widget.running,
                                        phase: widget.phase,
                                        steady: selected,
                                        boost: flash,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// LED that breathes faintly at idle, blinks fully while the simulation runs,
/// stays lit on the selected tab and flashes on tap.
class _Led extends StatelessWidget {
  const _Led({
    required this.pulse,
    required this.running,
    required this.phase,
    required this.steady,
    required this.boost,
  });

  final Animation<double> pulse;
  final ValueListenable<bool> running;
  final double phase;
  final bool steady;
  final double boost;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<SchematicColors>()!;

    return ListenableBuilder(
      listenable: Listenable.merge([pulse, running]),
      builder: (context, _) {
        final wave = 0.5 + 0.5 * math.sin(2 * math.pi * (pulse.value + phase));
        final amplitude = running.value ? 1.0 : 0.3;
        final v = math.max(steady ? 1.0 : wave * amplitude, boost);

        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.lerp(c.chipBorder, c.led, v),
            boxShadow: v > 0.05
                ? [
                    BoxShadow(
                      color: c.led.withAlpha((140 * v).round()),
                      blurRadius: 10 * v + 2,
                    ),
                  ]
                : null,
          ),
        );
      },
    );
  }
}

/// Pins on the left and right edge. [glow] lights them all (hover/selected);
/// [sweep] (0..1) runs a bright spot down the left pins and back up the right
/// ones, like current going around the chip.
class _PinsPainter extends CustomPainter {
  _PinsPainter({
    required this.pinColor,
    required this.liveColor,
    required this.length,
    required this.glow,
    required this.sweep,
  });

  final Color pinColor;
  final Color liveColor;
  final double length;
  final double glow;
  final double? sweep;

  static const int _pinsPerSide = 4;
  static const double _thickness = 5;

  double _level(int index) {
    var level = glow;
    final s = sweep;
    if (s != null) {
      const total = _pinsPerSide * 2;
      final position = s * (total + 2) - 1;
      level = math.max(
        level,
        (1 - (index - position).abs() / 1.8).clamp(0.0, 1.0).toDouble(),
      );
    }
    return level;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var side = 0; side < 2; side++) {
      for (var i = 0; i < _pinsPerSide; i++) {
        final index = side == 0 ? i : _pinsPerSide + (_pinsPerSide - 1 - i);
        final level = _level(index);
        final f = (i + 1) / (_pinsPerSide + 1);
        final rect = Rect.fromLTWH(
          side == 0 ? 0 : size.width - length,
          size.height * f - _thickness / 2,
          length,
          _thickness,
        );

        if (level > 0.05) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect.inflate(2), const Radius.circular(3)),
            Paint()
              ..color = liveColor.withAlpha((80 * level).round())
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
          );
        }
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(2)),
          Paint()..color = Color.lerp(pinColor, liveColor, level)!,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_PinsPainter old) =>
      old.glow != glow ||
      old.sweep != sweep ||
      old.pinColor != pinColor ||
      old.liveColor != liveColor ||
      old.length != length;
}
