import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mariam_portfolio/core/data/portfolio_data.dart';
import 'package:mariam_portfolio/core/theme/app_theme.dart';
import 'package:mariam_portfolio/features/portfolio/widgets/drive_embed_stub.dart'
    if (dart.library.js_interop) 'package:mariam_portfolio/features/portfolio/widgets/drive_embed_web.dart';
import 'package:mariam_portfolio/features/portfolio/widgets/phone_frame.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showProjectDialog(BuildContext context, ProjectEntry project) {
  final scrim = Theme.of(context).colorScheme.scrim.withAlpha(190);
  return showDialog<void>(
    context: context,
    barrierColor: scrim,
    builder: (_) => ProjectDialog(project: project),
  );
}

Future<void> _open(String url) =>
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

class ProjectDialog extends StatelessWidget {
  const ProjectDialog({super.key, required this.project});

  final ProjectEntry project;

  static const double _compactBreakpoint = 820;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = theme.extension<SchematicColors>()!;
    final compact = MediaQuery.sizeOf(context).width < _compactBreakpoint;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 40,
        vertical: compact ? 16 : 32,
      ),
      backgroundColor: c.chipBody,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: c.wireLive, width: 2),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1080, maxHeight: 760),
        child: Column(
          children: [
            _Header(project: project),
            Divider(height: 1, color: c.chipBorder.withAlpha(90)),
            Expanded(
              child: compact
                  ? _CompactBody(project: project)
                  : _WideBody(project: project),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.project});

  final ProjectEntry project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = theme.extension<SchematicColors>()!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
      child: Row(
        children: [
          Text(
            project.refDes,
            style: theme.textTheme.labelMedium?.copyWith(color: c.label),
          ),
          const SizedBox(width: 10),
          Icon(project.icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              project.title,
              style: theme.textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

class _WideBody extends StatelessWidget {
  const _WideBody({required this.project});

  final ProjectEntry project;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 11,
            child: SingleChildScrollView(child: _Info(project: project)),
          ),
          const SizedBox(width: 28),
          Expanded(flex: 9, child: PhoneShowcase(project: project)),
        ],
      ),
    );
  }
}

class _CompactBody extends StatelessWidget {
  const _CompactBody({required this.project});

  final ProjectEntry project;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 580, child: PhoneShowcase(project: project)),
          const SizedBox(height: 24),
          _Info(project: project),
        ],
      ),
    );
  }
}

// ---- Text side --------------------------------------------------------------

class _Info extends StatelessWidget {
  const _Info({required this.project});

  final ProjectEntry project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          project.tagline,
          style: text.titleMedium?.copyWith(color: scheme.primary),
        ),
        const SizedBox(height: 14),
        Text(project.description, style: text.bodyLarge?.copyWith(height: 1.55)),
        const SizedBox(height: 22),
        const _Label('Highlights'),
        const SizedBox(height: 8),
        for (final h in project.highlights) _Bullet(h),
        const SizedBox(height: 16),
        const _Label('Stack'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [for (final t in project.tech) _TechChip(t)],
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (project.repoUrl != null)
              FilledButton.icon(
                onPressed: () => _open(project.repoUrl!),
                icon: const Icon(Icons.code),
                label: const Text('GitHub repo'),
              ),
            if (project.demoUrl != null)
              OutlinedButton.icon(
                onPressed: () => _open(project.demoUrl!),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Demo on Drive'),
              ),
          ],
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 10),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  const _TechChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Text(label, style: theme.textTheme.labelMedium),
    );
  }
}

// ---- Phone side -------------------------------------------------------------

/// Phone mockup that shows the screenshots, or the Drive demo video when the
/// project has one.
class PhoneShowcase extends StatefulWidget {
  const PhoneShowcase({super.key, required this.project});

  final ProjectEntry project;

  @override
  State<PhoneShowcase> createState() => _PhoneShowcaseState();
}

class _PhoneShowcaseState extends State<PhoneShowcase> {
  final _pages = PageController();
  int _index = 0;
  bool _demo = false;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(int target) {
    final last = widget.project.screenshots.length - 1;
    _pages.animateToPage(
      target.clamp(0, last).toInt(),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final hasDemo = project.demoFileId != null;

    return Column(
      children: [
        if (hasDemo) ...[
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: false,
                icon: Icon(Icons.photo_library_outlined),
                label: Text('Screens'),
              ),
              ButtonSegment(
                value: true,
                icon: Icon(Icons.play_circle_outline),
                label: Text('Demo'),
              ),
            ],
            selected: {_demo},
            onSelectionChanged: (s) => setState(() => _demo = s.first),
          ),
          const SizedBox(height: 14),
        ],
        Expanded(
          child: Center(
            child: PhoneFrame(
              child: _demo
                  ? buildDriveEmbed(project.demoFileId!, project.demoUrl!)
                  : _Screens(
                      project: project,
                      controller: _pages,
                      onPageChanged: (i) => setState(() => _index = i),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (_demo)
          TextButton.icon(
            onPressed: () => _open(project.demoUrl!),
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Open in Drive'),
          )
        else
          _Pager(
            count: project.screenshots.length,
            index: _index,
            onPrev: () => _go(_index - 1),
            onNext: () => _go(_index + 1),
          ),
      ],
    );
  }
}

class _Screens extends StatelessWidget {
  const _Screens({
    required this.project,
    required this.controller,
    required this.onPageChanged,
  });

  final ProjectEntry project;
  final PageController controller;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ScrollConfiguration(
      // Web defaults exclude the mouse, so allow dragging with it too.
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: PointerDeviceKind.values.toSet(),
      ),
      child: PageView.builder(
        controller: controller,
        itemCount: project.screenshots.length,
        onPageChanged: onPageChanged,
        itemBuilder: (context, i) => Image.asset(
          project.screenshots[i],
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (context, error, stack) => Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _Pager extends StatelessWidget {
  const _Pager({
    required this.count,
    required this.index,
    required this.onPrev,
    required this.onNext,
  });

  final int count;
  final int index;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: 'Previous',
          onPressed: index > 0 ? onPrev : null,
          icon: const Icon(Icons.chevron_left),
        ),
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == index ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: i == index ? scheme.primary : scheme.outlineVariant,
            ),
          ),
        IconButton(
          tooltip: 'Next',
          onPressed: index < count - 1 ? onNext : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
