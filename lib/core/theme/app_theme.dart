import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  /// The only raw color in the whole app. Everything else is derived from
  /// the ColorScheme, so changing this one value re-themes the portfolio.
  static const Color _seed = Color(0xFF1FA463);

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
    );

    final body = GoogleFonts.ibmPlexSansTextTheme(base.textTheme).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    TextStyle? mono(TextStyle? style, FontWeight weight) =>
        GoogleFonts.jetBrainsMono(textStyle: style, fontWeight: weight);

    final textTheme = body.copyWith(
      headlineMedium: mono(body.headlineMedium, FontWeight.w700),
      headlineSmall: mono(body.headlineSmall, FontWeight.w700),
      titleLarge: mono(body.titleLarge, FontWeight.w700),
      titleMedium: mono(body.titleMedium, FontWeight.w600),
      labelLarge: mono(body.labelLarge, FontWeight.w500),
      labelMedium: mono(body.labelMedium, FontWeight.w500),
      labelSmall: mono(body.labelSmall, FontWeight.w500),
    );

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      extensions: [SchematicColors.fromScheme(scheme)],
    );
  }
}

/// Colors used by the schematic canvas, all derived from the ColorScheme.
@immutable
class SchematicColors extends ThemeExtension<SchematicColors> {
  const SchematicColors({
    required this.board,
    required this.gridMinor,
    required this.gridMajor,
    required this.chipBody,
    required this.chipBorder,
    required this.pin,
    required this.wire,
    required this.wireLive,
    required this.led,
    required this.label,
  });

  factory SchematicColors.fromScheme(ColorScheme s) => SchematicColors(
        board: s.surface,
        gridMinor: s.outlineVariant.withAlpha(45),
        gridMajor: s.outlineVariant.withAlpha(110),
        chipBody: s.surfaceContainer,
        chipBorder: s.outline,
        pin: s.onSurfaceVariant,
        wire: s.primary.withAlpha(120),
        wireLive: s.primary,
        led: s.tertiary,
        label: s.onSurfaceVariant,
      );

  final Color board;
  final Color gridMinor;
  final Color gridMajor;
  final Color chipBody;
  final Color chipBorder;
  final Color pin;
  final Color wire;
  final Color wireLive;
  final Color led;
  final Color label;

  @override
  SchematicColors copyWith({
    Color? board,
    Color? gridMinor,
    Color? gridMajor,
    Color? chipBody,
    Color? chipBorder,
    Color? pin,
    Color? wire,
    Color? wireLive,
    Color? led,
    Color? label,
  }) {
    return SchematicColors(
      board: board ?? this.board,
      gridMinor: gridMinor ?? this.gridMinor,
      gridMajor: gridMajor ?? this.gridMajor,
      chipBody: chipBody ?? this.chipBody,
      chipBorder: chipBorder ?? this.chipBorder,
      pin: pin ?? this.pin,
      wire: wire ?? this.wire,
      wireLive: wireLive ?? this.wireLive,
      led: led ?? this.led,
      label: label ?? this.label,
    );
  }

  @override
  SchematicColors lerp(ThemeExtension<SchematicColors>? other, double t) {
    if (other is! SchematicColors) return this;
    return SchematicColors(
      board: Color.lerp(board, other.board, t)!,
      gridMinor: Color.lerp(gridMinor, other.gridMinor, t)!,
      gridMajor: Color.lerp(gridMajor, other.gridMajor, t)!,
      chipBody: Color.lerp(chipBody, other.chipBody, t)!,
      chipBorder: Color.lerp(chipBorder, other.chipBorder, t)!,
      pin: Color.lerp(pin, other.pin, t)!,
      wire: Color.lerp(wire, other.wire, t)!,
      wireLive: Color.lerp(wireLive, other.wireLive, t)!,
      led: Color.lerp(led, other.led, t)!,
      label: Color.lerp(label, other.label, t)!,
    );
  }
}
