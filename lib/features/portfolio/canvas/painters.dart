import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mariam_portfolio/core/data/portfolio_data.dart';
import 'package:mariam_portfolio/core/theme/app_theme.dart';

enum PinSide { left, right, top, bottom }

/// Schematic grid with a heavier line every [majorEvery] cells.
class GridPainter extends CustomPainter {
  GridPainter(this.colors);

  final SchematicColors colors;

  static const double step = 40;
  static const int majorEvery = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final minor = Paint()
      ..color = colors.gridMinor
      ..strokeWidth = 1;
    final major = Paint()
      ..color = colors.gridMajor
      ..strokeWidth = 1;

    var i = 0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        i % majorEvery == 0 ? major : minor,
      );
      i++;
    }
    i = 0;
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        i % majorEvery == 0 ? major : minor,
      );
      i++;
    }
  }

  @override
  bool shouldRepaint(GridPainter old) => old.colors != colors;
}

/// One wire from the MCU to a section.
class WireRoute {
  WireRoute({
    required this.id,
    required this.path,
    required this.start,
    required this.end,
  }) : metric = path.computeMetrics().first;

  final SectionId id;
  final Path path;
  final Offset start;
  final Offset end;
  final PathMetric metric;
}

/// Builds orthogonal wires from the MCU pins to every section, like a
/// hand-routed schematic.
class WireRoutes {
  WireRoutes._();

  static PinSide _sideOf(Rect r, Rect mcu) {
    final dx = r.center.dx - mcu.center.dx;
    final dy = r.center.dy - mcu.center.dy;
    if (dx.abs() < mcu.width) return dy < 0 ? PinSide.top : PinSide.bottom;
    return dx < 0 ? PinSide.left : PinSide.right;
  }

  static Map<PinSide, List<PortfolioSection>> _grouped() {
    const mcu = PortfolioData.mcuRect;
    final groups = {for (final s in PinSide.values) s: <PortfolioSection>[]};
    for (final s in PortfolioData.sections) {
      groups[_sideOf(s.rect, mcu)]!.add(s);
    }
    for (final e in groups.entries) {
      final horizontal = e.key == PinSide.left || e.key == PinSide.right;
      e.value.sort(
        (a, b) => horizontal
            ? a.rect.center.dy.compareTo(b.rect.center.dy)
            : a.rect.center.dx.compareTo(b.rect.center.dx),
      );
    }
    return groups;
  }

  /// Pin count per side for the MCU chip, matching the wires below.
  static Map<PinSide, int> mcuPins() => {
        for (final e in _grouped().entries) e.key: e.value.length,
      };

  static List<WireRoute> build() {
    const mcu = PortfolioData.mcuRect;
    final routes = <WireRoute>[];

    _grouped().forEach((side, list) {
      final n = list.length;
      for (var i = 0; i < n; i++) {
        final s = list[i].rect;
        final f = (i + 1) / (n + 1);
        final shift = (i - (n - 1) / 2) * 36;
        final path = Path();
        late final Offset start;
        late final Offset end;

        switch (side) {
          case PinSide.left:
          case PinSide.right:
            {
              final startX = side == PinSide.left ? mcu.left : mcu.right;
              final endX = side == PinSide.left ? s.right : s.left;
              final startY = mcu.top + mcu.height * f;
              final midX = (startX + endX) / 2 + shift;
              start = Offset(startX, startY);
              end = Offset(endX, s.center.dy);
              path
                ..moveTo(start.dx, start.dy)
                ..lineTo(midX, start.dy)
                ..lineTo(midX, end.dy)
                ..lineTo(end.dx, end.dy);
            }
          case PinSide.top:
          case PinSide.bottom:
            {
              final startY = side == PinSide.top ? mcu.top : mcu.bottom;
              final endY = side == PinSide.top ? s.bottom : s.top;
              final startX = mcu.left + mcu.width * f;
              final midY = (startY + endY) / 2 + shift;
              start = Offset(startX, startY);
              end = Offset(s.center.dx, endY);
              path
                ..moveTo(start.dx, start.dy)
                ..lineTo(start.dx, midY)
                ..lineTo(end.dx, midY)
                ..lineTo(end.dx, end.dy);
            }
        }

        routes.add(
          WireRoute(id: list[i].id, path: path, start: start, end: end),
        );
      }
    });
    return routes;
  }
}

/// Draws the wires. While the simulation runs, dots travel from the MCU to
/// each section.
class WirePainter extends CustomPainter {
  WirePainter({
    required this.routes,
    required this.colors,
    required this.pulse,
    required this.running,
    required this.active,
  }) : super(repaint: Listenable.merge([pulse, running, active]));

  final List<WireRoute> routes;
  final SchematicColors colors;
  final Animation<double> pulse;
  final ValueListenable<bool> running;
  final ValueListenable<SectionId?> active;

  static const int _dotsPerWire = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final activeId = active.value;

    for (final r in routes) {
      final isActive = r.id == activeId;
      final color = isActive ? colors.wireLive : colors.wire;

      canvas.drawPath(
        r.path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = isActive ? 4 : 3
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round
          ..color = color,
      );

      final joint = Paint()..color = color;
      canvas.drawCircle(r.start, 5, joint);
      canvas.drawCircle(r.end, 5, joint);
    }

    if (!running.value) return;

    final glow = Paint()..color = colors.wireLive.withAlpha(70);
    final core = Paint()..color = colors.wireLive;
    for (final r in routes) {
      for (var k = 0; k < _dotsPerWire; k++) {
        final t = (pulse.value + k / _dotsPerWire) % 1.0;
        final pos = r.metric.getTangentForOffset(t * r.metric.length)?.position;
        if (pos == null) continue;
        canvas.drawCircle(pos, 9, glow);
        canvas.drawCircle(pos, 4, core);
      }
    }
  }

  @override
  bool shouldRepaint(WirePainter old) =>
      old.routes != routes || old.colors != colors;
}
