import 'package:flutter/material.dart';

enum SectionId {
  about,
  skills,
  experience,
  projects,
  education,
  volunteering,
  contact,
}

/// One component on the schematic. [rect] is its place in canvas coordinates
/// (pins included).
class PortfolioSection {
  const PortfolioSection({
    required this.id,
    required this.title,
    required this.refDes,
    required this.icon,
    required this.rect,
  });

  final SectionId id;
  final String title;
  final String refDes;
  final IconData icon;
  final Rect rect;
}

class SkillGroup {
  const SkillGroup(this.label, this.items);
  final String label;
  final List<String> items;
}

class ExperienceEntry {
  const ExperienceEntry({
    required this.role,
    required this.org,
    required this.period,
    required this.bullets,
  });

  final String role;
  final String org;
  final String period;
  final List<String> bullets;
}

/// One project datasheet: opens in a dialog with a phone mockup.
class ProjectEntry {
  const ProjectEntry({
    required this.refDes,
    required this.title,
    required this.tagline,
    required this.icon,
    required this.description,
    required this.highlights,
    required this.tech,
    required this.screenshots,
    this.demoFileId,
    this.repoUrl,
  });

  final String refDes;
  final String title;
  final String tagline;
  final IconData icon;
  final String description;
  final List<String> highlights;
  final List<String> tech;
  final List<String> screenshots;

  /// Google Drive file id of the demo video (null when there is no demo).
  final String? demoFileId;
  final String? repoUrl;

  String? get demoUrl => demoFileId == null
      ? null
      : 'https://drive.google.com/file/d/$demoFileId/view?usp=sharing';
}

abstract final class PortfolioData {
  // ---- Identity ----------------------------------------------------------
  static const name = 'Mariam Adham Abdelfattah';
  static const role = 'Flutter Engineer';
  static const tagline = 'Mobile Applications Developer';

  /// Drop your photo here (any size, square-ish crops best).
  static const photoAsset = 'assets/images/mariam.jpg';

  // ---- Canvas layout -----------------------------------------------------
  static const worldSize = Size(3200, 2200);
  static const mcuRect = Rect.fromLTWH(1370, 940, 460, 320);

  static const sections = <PortfolioSection>[
    PortfolioSection(
      id: SectionId.about,
      title: 'About',
      refDes: 'U2',
      icon: Icons.person_outline,
      rect: Rect.fromLTWH(420, 300, 620, 380),
    ),
    PortfolioSection(
      id: SectionId.skills,
      title: 'Skills',
      refDes: 'U3',
      icon: Icons.tune,
      rect: Rect.fromLTWH(2180, 260, 640, 480),
    ),
    PortfolioSection(
      id: SectionId.experience,
      title: 'Experience',
      refDes: 'U4',
      icon: Icons.work_outline,
      rect: Rect.fromLTWH(260, 1240, 700, 620),
    ),
    PortfolioSection(
      id: SectionId.projects,
      title: 'Projects',
      refDes: 'U5',
      icon: Icons.rocket_launch_outlined,
      rect: Rect.fromLTWH(2280, 850, 560, 300),
    ),
    PortfolioSection(
      id: SectionId.education,
      title: 'Education',
      refDes: 'U6',
      icon: Icons.school_outlined,
      rect: Rect.fromLTWH(1340, 1680, 520, 260),
    ),
    PortfolioSection(
      id: SectionId.volunteering,
      title: 'Volunteering',
      refDes: 'U7',
      icon: Icons.volunteer_activism_outlined,
      rect: Rect.fromLTWH(2240, 1300, 640, 420),
    ),
    PortfolioSection(
      id: SectionId.contact,
      title: 'Contact',
      refDes: 'J1',
      icon: Icons.alternate_email,
      rect: Rect.fromLTWH(1340, 240, 520, 260),
    ),
  ];

  static PortfolioSection byId(SectionId id) =>
      sections.firstWhere((s) => s.id == id);

  // ---- About -------------------------------------------------------------
  static const summary =
      'Flutter engineer who designs and ships scalable cross-platform mobile '
      'apps. I work with Clean Architecture, Cubit/BLoC, Dio and REST APIs, '
      'and I delivered a 50+ endpoint workforce management platform and a '
      'real-time donation tracker on my own. I care about clean code, modular '
      'architecture, and learning something new on every project.';

  static const aboutExtra =
      'I also supervised an embedded systems group for 2+ years, which is why '
      'this portfolio looks like a schematic.';

  // ---- Skills ------------------------------------------------------------
  static const skills = <SkillGroup>[
    SkillGroup('Languages', ['Dart', 'C++', 'C']),
    SkillGroup('Frameworks & SDKs', ['Flutter', 'Firebase', 'Dio']),
    SkillGroup('State management', ['Cubit', 'BLoC']),
    SkillGroup('Architecture', [
      'Clean Architecture',
      'MVVM',
      'SOLID',
      'OOP',
      'Design Patterns',
    ]),
    SkillGroup('Mobile', [
      'Async programming',
      'Animations',
      'Push notifications',
      'Deep linking',
      'SQLite',
      'Hive',
    ]),
    SkillGroup('APIs & integrations', [
      'RESTful APIs',
      'JWT authentication',
      'Third-party SDKs',
    ]),
    SkillGroup('Tools', [
      'Git',
      'GitHub',
      'VS Code',
      'Android Studio',
      'Figma',
      'Postman',
    ]),
    SkillGroup('Testing', ['Widget testing', 'Unit testing']),
  ];

  // ---- Experience --------------------------------------------------------
  static const experience = <ExperienceEntry>[
    ExperienceEntry(
      role: 'Flutter Developer Trainee',
      org: 'NTI Winter Training',
      period: '2+ months, 120+ hours',
      bullets: [
        'Cubit state management across 3+ mini-projects.',
        'Real-time chat app with Firebase Auth and Firestore in two weeks.',
        'Notes and News apps with live APIs and response caching.',
      ],
    ),
    ExperienceEntry(
      role: 'Software Trainee, Flutter Track',
      org: 'DEPI Program',
      period: '6+ months, 180+ hours',
      bullets: [
        'Delivered 4+ projects: StudyMate (capstone), e-commerce, chatbot '
            'integration, and task management.',
        'Firebase authentication and real-time data in 2+ applications.',
        'Modular architecture across 4+ projects.',
      ],
    ),
    ExperienceEntry(
      role: 'Flutter Developer',
      org: 'Freelance',
      period: 'Part-time',
      bullets: [
        '3 client projects end to end for corporate and startup clients, '
            'with 100% on-time delivery across milestones.',
      ],
    ),
  ];

  // ---- Education ---------------------------------------------------------
  static const degree = 'Bachelor of Computer Science';
  static const university =
      'Mansoura University, Faculty of Computers and Information';
  static const educationMeta = '2022 - 2026 (4th year), GPA: Excellent';

  // ---- Volunteering ------------------------------------------------------
  static const volunteering = ExperienceEntry(
    role: 'Embedded Systems Supervisor & Flutter Member',
    org: 'Student Activity',
    period: '2+ years',
    bullets: [
      'Led 5+ technical sessions and mentored 20+ students.',
      'Flutter team member for 3 months across 5+ development sprints.',
    ],
  );

  // ---- Projects ----------------------------------------------------------
  static const projects = <ProjectEntry>[
    ProjectEntry(
      refDes: 'P1',
      title: 'SyncVerse',
      tagline: 'AI-powered project management platform',
      icon: Icons.hub_outlined,
      description:
          'A multi-role project management platform for companies, connected '
          'to a real backend with role-based authentication. I built the '
          'Flutter frontend, from six role-specific dashboards to the AI '
          'features that turn meetings and project data into decisions.',
      highlights: [
        'Role-based authentication and dashboards for HR, Manager, Team '
            'Leader, PM, Employee and Admin.',
        'AI insights: risk forecast, workload, timeline, project health and '
            'goal alignment.',
        'AI sprint planner, Echo chatbot, and meeting summaries that become '
            'tasks assigned by skill.',
        'Unity virtual office embedded in Flutter, with voice chat.',
      ],
      tech: [
        'Flutter',
        'Clean Architecture',
        'Cubit',
        'Dio',
        'GoRouter',
        'GetIt',
        'fl_chart',
        'Unity',
      ],
      screenshots: [
        'images/projects/syncverse_1.png',
        'images/projects/syncverse_2.png',
        'images/projects/syncverse_3.png',
        'images/projects/syncverse_4.png',
      ],
      demoFileId: '19IA4NLDKELLmApGiE4nhzPQcuGT2G3fP',
      repoUrl: 'https://github.com/syncverse12/Flutter-SyncVerce-App',
    ),
    ProjectEntry(
      refDes: 'P2',
      title: 'Sadaqa',
      tagline: 'Group giving and donation tracker',
      icon: Icons.volunteer_activism_outlined,
      description:
          'A charitable giving app where members join giving groups, pay '
          'their monthly contribution, and see in real time who has paid. '
          'Each group runs on its own payment cycle, with admin and member '
          'roles and invite links.',
      highlights: [
        'Real-time contribution tracking with Firestore.',
        'Per-group payment cycles, not calendar months.',
        'Admin and member roles, invite links, and a paid or pending status '
            'for every member.',
        'Scheduled GitHub Actions jobs mark unpaid members and reset each '
            'cycle.',
      ],
      tech: ['Flutter', 'Firebase', 'Cubit', 'GoRouter', 'GitHub Actions'],
      screenshots: [
        'images/projects/sadaqa_1.png',
        'images/projects/sadaqa_2.png',
        'images/projects/sadaqa_3.png',
      ],
      demoFileId: '18u8OF00PaIjbQweY6lXoJZAn_WNs-6Eb',
      repoUrl: 'https://github.com/Mariamadham8/Sadaqa-App',
    ),
    ProjectEntry(
      refDes: 'P3',
      title: 'Taiar',
      tagline: 'Delivery for restaurants and individuals',
      icon: Icons.delivery_dining_outlined,
      description: 'A delivery marketplace that connects customers, riders and '
          'restaurants. Customers can order food or send a package from '
          'person to person, pick the pickup point on a map, and choose '
          'from the offers of nearby riders.',
      highlights: [
        'Two flows in one app: order food, or send a package anywhere.',
        'Map-based pickup selection.',
        'Nearby rider offers with price, rating, vehicle and ETA.',
        'Trip completion with a clear arrival state and total.',
      ],
      tech: ['Flutter', 'Maps'],
      screenshots: [
        'images/projects/taiar_1.png',
        'images/projects/taiar_2.png',
        'images/projects/taiar_3.png',
        'images/projects/taiar_4.png',
      ],
      repoUrl: 'https://github.com/Mariamadham8/taiar',
    ),
  ];

  // ---- Contact -----------------------------------------------------------
  static const email = 'mariamadham07@gmail.com';
  static const linkedinUrl = 'https://www.linkedin.com/in/mariam-adham-dev/';
  static const githubUrl = 'https://github.com/Mariamadham8';
  static const location = 'Mansoura, Dakahlia, Egypt';
}
