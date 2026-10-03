import 'package:flutter/material.dart';

/// SafeOne's design system: brand colours, the semantic "safety" colours,
/// typography and the look of every Material component, for light and dark.
///
/// Screens should read colours from the theme instead of hard-coding them:
///   * brand / surfaces   -> `Theme.of(context).colorScheme`
///   * SOS / success / warning / info -> `context.safety` ([SafetyColors])
/// so everything adapts to dark mode automatically.
class AppTheme {
  AppTheme._();

  /// Purple from the launcher icon. Used only for the logo mark — the UI
  /// itself is neutral so the SOS red is the one colour that stands out.
  static const Color brand = Color(0xFF6D28D9);

  static const String bodyFont = 'Inter';

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  /// A neutral, hand-picked palette: true greys (no tinted surfaces), ink
  /// for primary actions, and colour reserved for meaning (SOS, status).
  static ColorScheme schemeFor(Brightness brightness) {
    final base = ColorScheme.fromSeed(
      seedColor: const Color(0xFF5B5B66),
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
    );
    if (brightness == Brightness.light) {
      return base.copyWith(
        primary: const Color(0xFF16161A),
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFEDEDF0),
        onPrimaryContainer: const Color(0xFF16161A),
        secondary: const Color(0xFF55555F),
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFFEDEDF0),
        onSecondaryContainer: const Color(0xFF16161A),
        error: const Color(0xFFD92D20),
        onError: Colors.white,
        errorContainer: const Color(0xFFFEF3F2),
        onErrorContainer: const Color(0xFF912018),
        surface: Colors.white,
        onSurface: const Color(0xFF16161A),
        onSurfaceVariant: const Color(0xFF5F5F6B),
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow: const Color(0xFFF6F6F7),
        surfaceContainer: const Color(0xFFF1F1F3),
        surfaceContainerHigh: const Color(0xFFEBEBEE),
        surfaceContainerHighest: const Color(0xFFE4E4E8),
        outline: const Color(0xFFC4C4CC),
        outlineVariant: const Color(0xFFE4E4E8),
        inverseSurface: const Color(0xFF1F1F24),
        onInverseSurface: const Color(0xFFF4F4F5),
        surfaceTint: Colors.transparent,
        shadow: Colors.black,
        scrim: Colors.black,
      );
    }
    return base.copyWith(
      primary: const Color(0xFFF4F4F5),
      onPrimary: const Color(0xFF16161A),
      primaryContainer: const Color(0xFF2A2A30),
      onPrimaryContainer: const Color(0xFFF4F4F5),
      secondary: const Color(0xFFA9A9B4),
      onSecondary: const Color(0xFF16161A),
      secondaryContainer: const Color(0xFF2A2A30),
      onSecondaryContainer: const Color(0xFFF4F4F5),
      error: const Color(0xFFF97066),
      onError: const Color(0xFF16161A),
      errorContainer: const Color(0xFF3A1714),
      onErrorContainer: const Color(0xFFFECDCA),
      surface: const Color(0xFF111114),
      onSurface: const Color(0xFFF4F4F5),
      onSurfaceVariant: const Color(0xFFA9A9B4),
      // Cards and tiles use this role; in dark mode they sit slightly
      // *above* the page rather than looking recessed.
      surfaceContainerLowest: const Color(0xFF18181C),
      surfaceContainerLow: const Color(0xFF19191D),
      surfaceContainer: const Color(0xFF1E1E23),
      surfaceContainerHigh: const Color(0xFF26262C),
      surfaceContainerHighest: const Color(0xFF2E2E35),
      outline: const Color(0xFF55555F),
      outlineVariant: const Color(0xFF2E2E35),
      inverseSurface: const Color(0xFFF4F4F5),
      onInverseSurface: const Color(0xFF16161A),
      surfaceTint: Colors.transparent,
      shadow: Colors.black,
      scrim: Colors.black,
    );
  }

  static ThemeData _build(Brightness brightness) {
    final scheme = schemeFor(brightness);
    final safety = SafetyColors.forScheme(scheme);
    final text = _textTheme(scheme);

    final buttonShape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
    const buttonSize = Size(64, 52);
    final buttonText = text.labelLarge!.copyWith(fontSize: 16);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: bodyFont,
      textTheme: text,
      scaffoldBackgroundColor: scheme.surface,
      extensions: [safety],
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        // Cards are white with a hairline border on the white page — the
        // way most hand-designed Android apps separate content.
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          textStyle: buttonText,
          elevation: 0,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          textStyle: buttonText,
          side: BorderSide(color: scheme.outline),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: buttonShape,
          textStyle: text.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        iconColor: scheme.onSurfaceVariant,
        titleTextStyle: text.titleMedium!.copyWith(fontWeight: FontWeight.w500),
        subtitleTextStyle:
            text.bodyMedium!.copyWith(color: scheme.onSurfaceVariant),
        minVerticalPadding: 12,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.6),
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.secondaryContainer,
        labelTextStyle: WidgetStatePropertyAll(
          text.labelMedium!.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelStyle: text.titleSmall,
        unselectedLabelStyle: text.titleSmall,
        dividerColor: scheme.outlineVariant.withValues(alpha: 0.6),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: text.labelLarge,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: scheme.inverseSurface,
        contentTextStyle:
            text.bodyMedium!.copyWith(color: scheme.onInverseSurface),
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: text.headlineSmall,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme scheme) {
    final base = Typography.material2021(platform: TargetPlatform.android)
        .englishLike
        .apply(
          fontFamily: bodyFont,
          bodyColor: scheme.onSurface,
          displayColor: scheme.onSurface,
        );
    TextStyle display(TextStyle? s, double size, FontWeight w,
            {double spacing = -0.4}) =>
        s!.copyWith(
          fontFamily: bodyFont,
          fontSize: size,
          fontWeight: w,
          letterSpacing: spacing,
          height: 1.2,
        );
    return base.copyWith(
      displayLarge: display(base.displayLarge, 56, FontWeight.w700),
      displayMedium: display(base.displayMedium, 44, FontWeight.w700),
      displaySmall: display(base.displaySmall, 36, FontWeight.w700),
      headlineLarge: display(base.headlineLarge, 30, FontWeight.w700),
      headlineMedium: display(base.headlineMedium, 26, FontWeight.w700),
      headlineSmall: display(base.headlineSmall, 22, FontWeight.w700, spacing: -0.3),
      titleLarge: display(base.titleLarge, 20, FontWeight.w600, spacing: -0.2),
      // Material's default letter-spacing is tuned for Roboto; Inter is
      // already well spaced, so keep it near zero.
      titleMedium: base.titleMedium!.copyWith(
          fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0),
      titleSmall: base.titleSmall!.copyWith(
          fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0),
      bodyLarge: base.bodyLarge!
          .copyWith(fontSize: 16, height: 1.5, letterSpacing: 0),
      bodyMedium: base.bodyMedium!
          .copyWith(fontSize: 14, height: 1.45, letterSpacing: 0),
      bodySmall: base.bodySmall!.copyWith(
          fontSize: 12,
          height: 1.4,
          letterSpacing: 0.1,
          color: scheme.onSurfaceVariant),
      labelLarge: base.labelLarge!.copyWith(
          fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0),
      labelMedium: base.labelMedium!.copyWith(
          fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    );
  }
}

/// The tone of a message or status, used to pick matching [SafetyColors].
enum Tone { danger, warning, info, success, neutral }

/// Semantic colours that Material's [ColorScheme] doesn't have: the SOS red
/// and the success / warning / info states, each with a soft "container"
/// variant for backgrounds and an "on" colour for text and icons on top.
@immutable
class SafetyColors extends ThemeExtension<SafetyColors> {
  const SafetyColors({
    required this.sos,
    required this.onSos,
    required this.sosContainer,
    required this.onSosContainer,
    required this.success,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.info,
    required this.infoContainer,
    required this.onInfoContainer,
  });

  /// The SOS / danger red, solid and unmistakable in both themes.
  final Color sos;
  final Color onSos;
  final Color sosContainer;
  final Color onSosContainer;
  final Color success;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color warning;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color info;
  final Color infoContainer;
  final Color onInfoContainer;

  /// The semantic colours: a warm SOS red and calm status colours, each with
  /// a soft background and a text colour that meets WCAG AA on it.
  factory SafetyColors.forScheme(ColorScheme scheme) {
    if (scheme.brightness == Brightness.light) {
      return const SafetyColors(
        sos: Color(0xFFD92D20),
        onSos: Colors.white,
        sosContainer: Color(0xFFFEF3F2),
        onSosContainer: Color(0xFF912018),
        success: Color(0xFF067647),
        successContainer: Color(0xFFECFDF3),
        onSuccessContainer: Color(0xFF054F31),
        warning: Color(0xFFB54708),
        warningContainer: Color(0xFFFFFAEB),
        onWarningContainer: Color(0xFF7A2E0E),
        info: Color(0xFF175CD3),
        infoContainer: Color(0xFFEFF8FF),
        onInfoContainer: Color(0xFF194185),
      );
    }
    return const SafetyColors(
      sos: Color(0xFFD92D20),
      onSos: Colors.white,
      sosContainer: Color(0xFF3A1714),
      onSosContainer: Color(0xFFFECDCA),
      success: Color(0xFF47CD89),
      successContainer: Color(0xFF0F2A1D),
      onSuccessContainer: Color(0xFFABEFC6),
      warning: Color(0xFFFDB022),
      warningContainer: Color(0xFF33240A),
      onWarningContainer: Color(0xFFFEDF89),
      info: Color(0xFF53B1FD),
      infoContainer: Color(0xFF102A4C),
      onInfoContainer: Color(0xFFB2DDFF),
    );
  }

  /// The strong colour for a [tone] (icons, accents).
  Color accent(Tone tone, ColorScheme scheme) => switch (tone) {
        Tone.danger => sos,
        Tone.warning => warning,
        Tone.info => info,
        Tone.success => success,
        Tone.neutral => scheme.onSurfaceVariant,
      };

  /// The soft background colour for a [tone].
  Color container(Tone tone, ColorScheme scheme) => switch (tone) {
        Tone.danger => sosContainer,
        Tone.warning => warningContainer,
        Tone.info => infoContainer,
        Tone.success => successContainer,
        Tone.neutral => scheme.surfaceContainerHigh,
      };

  /// The text colour to use on top of [container].
  Color onContainer(Tone tone, ColorScheme scheme) => switch (tone) {
        Tone.danger => onSosContainer,
        Tone.warning => onWarningContainer,
        Tone.info => onInfoContainer,
        Tone.success => onSuccessContainer,
        Tone.neutral => scheme.onSurface,
      };

  @override
  SafetyColors copyWith() => this;

  @override
  SafetyColors lerp(SafetyColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return SafetyColors(
      sos: l(sos, other.sos),
      onSos: l(onSos, other.onSos),
      sosContainer: l(sosContainer, other.sosContainer),
      onSosContainer: l(onSosContainer, other.onSosContainer),
      success: l(success, other.success),
      successContainer: l(successContainer, other.successContainer),
      onSuccessContainer: l(onSuccessContainer, other.onSuccessContainer),
      warning: l(warning, other.warning),
      warningContainer: l(warningContainer, other.warningContainer),
      onWarningContainer: l(onWarningContainer, other.onWarningContainer),
      info: l(info, other.info),
      infoContainer: l(infoContainer, other.infoContainer),
      onInfoContainer: l(onInfoContainer, other.onInfoContainer),
    );
  }
}

extension SafetyColorsContext on BuildContext {
  /// The app's semantic safety colours for the current theme. Falls back to
  /// colours derived from the active scheme if [AppTheme] isn't installed
  /// (e.g. a widget test that pumps a bare MaterialApp).
  SafetyColors get safety {
    final theme = Theme.of(this);
    return theme.extension<SafetyColors>() ??
        SafetyColors.forScheme(theme.colorScheme);
  }
}
