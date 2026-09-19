import 'package:flutter/material.dart';
import 'package:mariam_portfolio/core/data/portfolio_data.dart';
import 'package:mariam_portfolio/features/portfolio/widgets/project_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

/// The content shown inside a section, on the canvas chip or the mobile card.
class SectionBody extends StatelessWidget {
  const SectionBody(this.id, {super.key});

  final SectionId id;

  @override
  Widget build(BuildContext context) => switch (id) {
        SectionId.about => const _AboutBody(),
        SectionId.skills => const _SkillsBody(),
        SectionId.experience => const _ExperienceBody(),
        SectionId.projects => const _ProjectsBody(),
        SectionId.education => const _EducationBody(),
        SectionId.volunteering => const _VolunteeringBody(),
        SectionId.contact => const _ContactBody(),
      };
}

class _AboutBody extends StatelessWidget {
  const _AboutBody();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          PortfolioData.summary,
          style: text.bodyLarge?.copyWith(height: 1.5),
        ),
        const SizedBox(height: 14),
        Text(
          PortfolioData.aboutExtra,
          style: text.bodyMedium?.copyWith(
            height: 1.5,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SkillsBody extends StatelessWidget {
  const _SkillsBody();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in PortfolioData.skills) ...[
          Text(
            group.label,
            style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final item in group.items) _SkillChip(item)],
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: scheme.outline),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class _ExperienceBody extends StatelessWidget {
  const _ExperienceBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in PortfolioData.experience) ...[
          _Entry(entry),
          const SizedBox(height: 18),
        ],
      ],
    );
  }
}

class _VolunteeringBody extends StatelessWidget {
  const _VolunteeringBody();

  @override
  Widget build(BuildContext context) => _Entry(PortfolioData.volunteering);
}

class _Entry extends StatelessWidget {
  const _Entry(this.entry);

  final ExperienceEntry entry;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(entry.role, style: text.titleMedium),
        const SizedBox(height: 2),
        Text(
          '${entry.org}, ${entry.period}',
          style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        for (final b in entry.bullets) _Bullet(b),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 10),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.45,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EducationBody extends StatelessWidget {
  const _EducationBody();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(PortfolioData.degree, style: text.titleMedium),
        const SizedBox(height: 6),
        Text(PortfolioData.university, style: text.bodyMedium),
        const SizedBox(height: 6),
        Text(
          PortfolioData.educationMeta,
          style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _ProjectsBody extends StatelessWidget {
  const _ProjectsBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final p in PortfolioData.projects) _ProjectRow(p),
      ],
    );
  }
}

class _ProjectRow extends StatelessWidget {
  const _ProjectRow(this.project);

  final ProjectEntry project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => showProjectDialog(context, project),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: scheme.outline),
                ),
                child: Icon(project.icon, size: 20, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.title, style: theme.textTheme.titleMedium),
                    Text(
                      project.tagline,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_outward, size: 18, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactBody extends StatelessWidget {
  const _ContactBody();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LinkRow(
          icon: Icons.mail_outline,
          label: PortfolioData.email,
          url: 'mailto:${PortfolioData.email}',
        ),
        _LinkRow(
          icon: Icons.link,
          label: 'LinkedIn',
          url: PortfolioData.linkedinUrl,
        ),
        _LinkRow(
          icon: Icons.code,
          label: 'GitHub',
          url: PortfolioData.githubUrl,
        ),
        const SizedBox(height: 4),
        Text(
          PortfolioData.location,
          style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.label,
    required this.url,
  });

  final IconData icon;
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: scheme.primary),
            const SizedBox(width: 10),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
