import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mariam_portfolio/core/data/portfolio_data.dart';
import 'package:mariam_portfolio/core/theme/app_theme.dart';
import 'package:mariam_portfolio/features/portfolio/canvas/ic_chip.dart';
import 'package:mariam_portfolio/features/portfolio/canvas/painters.dart';
import 'package:mariam_portfolio/features/portfolio/widgets/profile_avatar.dart';
import 'package:mariam_portfolio/features/portfolio/widgets/section_bodies.dart';

/// Lets the sidebar (or anything else) drive the canvas.
class SchematicController {
  final ValueNotifier<SectionId?> active = ValueNotifier(null);
  final ValueNotifier<bool> running = ValueNotifier(false);

  void Function(SectionId id)? _focus;
  VoidCallback? _focusHome;
  VoidCallback? _overview;

  void focus(SectionId id) => _focus?.call(id);
  void focusHome() => _focusHome?.call();
  void overview() => _overview?.call();
  void toggleRun() => running.value = !running.value;

  void dispose() {
    active.dispose();
    running.dispose();
  }
}

class SchematicCanvas extends StatefulWidget {
  const SchematicCanvas({super.key, required this.controller});

  final SchematicController controller;

  @override
  State<SchematicCanvas> createState() => _SchematicCanvasState();
}

class _SchematicCanvasState extends State<SchematicCanvas>
    with TickerProviderStateMixin {
  static const double _minScale = 0.1;
  static const double _maxScale = 3.0;

  final _tc = TransformationController();
  late final AnimationController _cam;
  late final AnimationController _pulse;
  final List<WireRoute> _routes = WireRoutes.build();
  final Map<PinSide, int> _mcuPins = WireRoutes.mcuPins();

  Size _viewport = Size.zero;
  bool _placed = false;

  /// Bumped to cancel a running guided tour.
  int _tourToken = 0;
  static const _homeDwell = Duration(milliseconds: 2400);
  static const _sectionDwell = Duration(milliseconds: 3600);

  // Camera tween state: scale, translateX, translateY.
  double _s0 = 1, _x0 = 0, _y0 = 0, _s1 = 1, _x1 = 0, _y1 = 0;

  @override
  void initState() {
    super.initState();
    _cam = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..addListener(_onCameraTick);
    _pulse =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));

    final c = widget.controller;
    c._focus = (id) {
      _stopTour();
      _focus(id);
    };
    c._focusHome = () {
      _stopTour();
      _focusHome();
    };
    c._overview = () {
      _stopTour();
      _overview();
    };
    c.running.addListener(_onRunningChanged);
  }

  @override
  void dispose() {
    _stopTour();
    final c = widget.controller;
    c.running.removeListener(_onRunningChanged);
    c._focus = null;
    c._focusHome = null;
    c._overview = null;
    _cam.dispose();
    _pulse.dispose();
    _tc.dispose();
    super.dispose();
  }

  // ---- Simulation --------------------------------------------------------

  void _onRunningChanged() {
    if (widget.controller.running.value) {
      _pulse.repeat();
      unawaited(_startTour());
    } else {
      _pulse
        ..stop()
        ..value = 0;
      _stopTour();
    }
  }

  // ---- Guided tour -------------------------------------------------------

  void _stopTour() => _tourToken++;

  /// While the simulation runs, the camera visits every chip in order, then
  /// zooms out to the overview. Touching the canvas, using the sidebar or
  /// stopping the simulation cancels it.
  Future<void> _startTour() async {
    final token = ++_tourToken;
    bool alive() =>
        mounted && token == _tourToken && widget.controller.running.value;

    _focusHome();
    await Future<void>.delayed(_homeDwell);

    for (final s in PortfolioData.sections) {
      if (!alive()) return;
      _focus(s.id);
      await Future<void>.delayed(_sectionDwell);
    }

    if (!alive()) return;
    _overview();
  }

  // ---- Camera ------------------------------------------------------------

  Matrix4 _matrix(double s, double x, double y) =>
      Matrix4(s, 0, 0, 0, 0, s, 0, 0, 0, 0, 1, 0, x, y, 0, 1);

  /// Scale and translation that center [target] in the viewport.
  (double, double, double) _frame(Rect target, double pad) {
    final s = math
        .min(
          _viewport.width / (target.width * pad),
          _viewport.height / (target.height * pad),
        )
        .clamp(_minScale, _maxScale)
        .toDouble();
    return (
      s,
      _viewport.width / 2 - target.center.dx * s,
      _viewport.height / 2 - target.center.dy * s,
    );
  }

  void _flyTo(Rect target, {double pad = 1.3}) {
    if (_viewport.isEmpty) return;
    final m = _tc.value.storage;
    _s0 = m[0];
    _x0 = m[12];
    _y0 = m[13];
    final (s, x, y) = _frame(target, pad);
    _s1 = s;
    _x1 = x;
    _y1 = y;
    _cam.forward(from: 0);
  }

  void _onCameraTick() {
    final t = Curves.easeInOutCubic.transform(_cam.value);
    _tc.value = _matrix(
      _s0 + (_s1 - _s0) * t,
      _x0 + (_x1 - _x0) * t,
      _y0 + (_y1 - _y0) * t,
    );
  }

  void _focus(SectionId id) {
    widget.controller.active.value = id;
    _flyTo(PortfolioData.byId(id).rect);
  }

  void _focusHome() {
    widget.controller.active.value = null;
    _flyTo(PortfolioData.mcuRect, pad: 1.6);
  }

  void _overview() {
    widget.controller.active.value = null;
    _flyTo(Offset.zero & PortfolioData.worldSize, pad: 1.0);
  }

  // ---- Build -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        _viewport = constraints.biggest;

        if (!_placed && !_viewport.isEmpty) {
          _placed = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final (s, x, y) =
                _frame(Offset.zero & PortfolioData.worldSize, 1.0);
            _tc.value = _matrix(s, x, y);
          });
        }

        return ColoredBox(
          color: scheme.surface,
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  transformationController: _tc,
                  constrained: false,
                  minScale: _minScale,
                  maxScale: _maxScale,
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  onInteractionStart: (_) {
                    _stopTour();
                    _cam.stop();
                    widget.controller.active.value = null;
                  },
                  child: SizedBox.fromSize(
                    size: PortfolioData.worldSize,
                    child: _buildWorld(),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 20,
                child: Center(child: _Toolbar(controller: widget.controller)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorld() {
    final c = Theme.of(context).extension<SchematicColors>()!;
    final controller = widget.controller;

    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(painter: GridPainter(c)),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: WirePainter(
              routes: _routes,
              colors: c,
              pulse: _pulse,
              running: controller.running,
              active: controller.active,
            ),
          ),
        ),
        Positioned.fill(
          child: ValueListenableBuilder<SectionId?>(
            valueListenable: controller.active,
            builder: (context, activeId, _) => Stack(
              children: [
                _positioned(
                  PortfolioData.mcuRect,
                  IcChip(
                    size: PortfolioData.mcuRect.size,
                    refDes: 'U1',
                    title: 'Mariam',
                    icon: Icons.developer_board,
                    pins: _mcuPins,
                    pulse: _pulse,
                    running: controller.running,
                    onTap: _focusHome,
                    child: const _McuBody(),
                  ),
                ),
                for (final (i, s) in PortfolioData.sections.indexed)
                  _positioned(
                    s.rect,
                    IcChip(
                      size: s.rect.size,
                      refDes: s.refDes,
                      title: s.title,
                      icon: s.icon,
                      pins: IcChip.autoPins(s.rect.size),
                      pulse: _pulse,
                      running: controller.running,
                      ledPhase: i * 0.17,
                      active: activeId == s.id,
                      onTap: () => _focus(s.id),
                      child: SectionBody(s.id),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _positioned(Rect r, Widget child) =>
      Positioned(left: r.left, top: r.top, child: child);
}

class _McuBody extends StatelessWidget {
  const _McuBody();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileAvatar(size: 112),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
        const SizedBox(height: 14),
        Text(
          'Tap a chip to open it, or run the simulation.',
          style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.controller});

  final SchematicController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHigh,
      shape: StadiumBorder(side: BorderSide(color: scheme.outlineVariant)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: controller.running,
              builder: (context, running, _) => TextButton.icon(
                onPressed: controller.toggleRun,
                icon: Icon(running ? Icons.stop : Icons.play_arrow),
                label: Text(running ? 'Stop simulation' : 'Run simulation'),
              ),
            ),
            TextButton.icon(
              onPressed: controller.overview,
              icon: const Icon(Icons.zoom_out_map),
              label: const Text('Overview'),
            ),
          ],
        ),
      ),
    );
  }
}
