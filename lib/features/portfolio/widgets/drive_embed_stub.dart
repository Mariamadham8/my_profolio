import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Non-web fallback: iframes only exist on the web, so just link out.
Widget buildDriveEmbed(String fileId, String openUrl) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: FilledButton.icon(
        onPressed: () => launchUrl(
          Uri.parse(openUrl),
          mode: LaunchMode.externalApplication,
        ),
        icon: const Icon(Icons.play_circle_outline),
        label: const Text('Open demo'),
      ),
    ),
  );
}
