import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mariam_portfolio/core/theme/app_theme.dart';
import 'package:mariam_portfolio/features/portfolio/canvas/painters.dart';

/// A schematic IC: rounded body, pins on the sides, pin-1 marker, and an LED
/// that blinks while the simulation runs. [size] includes the pins.
class IcChip extends StatefulWidget {
  const IcChip({
    super.key,
    required this.size,
    required this.refDes,
    required this.title,
    required this.icon,
    required this.pins,
    required this.pulse,
    required this.running,
    required this.child,
    this.active = false,
    this.ledPhase = 0,
    this.onTap,
  });

  final Size size;
  final String refDes;
  final String title;
  final IconData icon;
  final Map<PinSide, int> pins;
  final Animation<double> pulse;
  final ValueListenable<bool> running;
  final Widget child;
  final bool active;
  final double ledPhase;
  final VoidCallback? onTap;

  static const double pinLength = 18;

  /// Odd pin counts per side, so the middle pin always exists (wires land there).
  static Map<PinSide, int> autoPins(Size size) {
    int odd(double length) {
      final n = math.max(1, (length / 70).floor());
      return n.isEven ? n + 1 : n;
    }

    return {
      PinSide.left: odd(size.height),
      PinSide.right: odd(size.height),
      PinSide.top: odd(size.width),
      PinSide.bottom: odd(size.width),
    };
  }

  @override
  State<IcChip> createState() => _IcChipState();
}

class _IcChipState extends State<IcChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final c = theme.extension<SchematicColors>()!;
    final highlighted = widget.active || _hover;

    return MouseRegion(
      cursor: widget.onTap == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox.fromSize(
          size: widget.size,
          child: CustomPaint(
            painter: _PinsPainter(
              pins: widget.pins,
              length: IcChip.pinLength,
              color: highlighted ? c.wireLive : c.pin,
            ),
            child: Padding(
              padding: const EdgeInsets.all(IcChip.pinLength),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: c.chipBody,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: highlighted ? c.wireLive : c.chipBorder,
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    // Pin-1 marker.
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: c.label, width: 1.5),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 14, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.refDes,
                                style: text.labelMedium?.copyWith(
                                  color: c.label,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                widget.icon,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.title,
                                  style: text.titleMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _Led(
                                pulse: widget.pulse,
                                running: widget.running,
                                phase: widget.ledPhase,
                              ),
                            ],
                          ),
                          Divider(
                            height: 22,
                            thickness: 1,
                            color: c.chipBorder.withAlpha(90),
                          ),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, box) => ClipRect(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.topLeft,
                                  child: SizedBox(
                                    width: box.maxWidth,
                                    child: widget.child,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinsPainter extends CustomPainter {
  _PinsPainter({
    required this.pins,
    required this.length,
    required this.color,
  });

  final Map<PinSide, int> pins;
  final double length;
  final Color color;

  static const double _thickness = 8;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    for (final entry in pins.entries) {
      final n = entry.value;
      for (var i = 1; i <= n; i++) {
        final f = i / (n + 1);
        final rect = switch (entry.key) {
          PinSide.left => Rect.fromLTWH(
              0,
              size.height * f - _thickness / 2,
              length,
              _thickness,
            ),
          PinSide.right => Rect.fromLTWH(
              size.width - length,
              size.height * f - _thickness / 2,
              length,
              _thickness,
            ),
          PinSide.top => Rect.fromLTWH(
              size.width * f - _thickness / 2,
              0,
              _thickness,
              length,
            ),
          PinSide.bottom => Rect.fromLTWH(
              size.width * f - _thickness / 2,
              size.height - length,
              _thickness,
              length,
            ),
        };
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(2)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_PinsPainter old) =>
      old.color != color || old.length != length || !mapEquals(old.pins, pins);
}

class _Led extends StatelessWidget {
  const _Led({
    required this.pulse,
    required this.running,
    required this.phase,
  });

  final Animation<double> pulse;
  final ValueListenable<bool> running;
  final double phase;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<SchematicColors>()!;

    return ListenableBuilder(
      listenable: Listenable.merge([pulse, running]),
      builder: (context, _) {
        final on = running.value;
        final v = on
            ? 0.5 + 0.5 * math.sin(2 * math.pi * (pulse.value + phase))
            : 0.0;
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.lerp(c.chipBorder, c.led, v),
            boxShadow: on
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
