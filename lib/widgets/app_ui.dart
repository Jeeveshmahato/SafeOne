import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Small shared building blocks so every screen looks and behaves the same.

/// Shows a floating snackbar with an icon whose colour matches [tone].
///
/// Use this instead of a hand-coloured `SnackBar` (e.g. green/red
/// backgrounds), which looked inconsistent and broke in dark mode.
void showAppSnack(BuildContext context, String message,
    {Tone tone = Tone.neutral}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  final scheme = Theme.of(context).colorScheme;
  final icon = switch (tone) {
    Tone.danger => Icons.error_rounded,
    Tone.warning => Icons.warning_amber_rounded,
    Tone.info => Icons.info_rounded,
    Tone.success => Icons.check_circle_rounded,
    Tone.neutral => null,
  };
  // The snackbar sits on an inverse (dark-on-light / light-on-dark) surface,
  // so take the accent from the *opposite* theme to keep it readable.
  final inverse = SafetyColors.forScheme(AppTheme.schemeFor(
    Theme.of(context).brightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark,
  ));
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: inverse.accent(tone, scheme), size: 22),
              const SizedBox(width: 12),
            ],
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}

/// A rounded square holding an icon: neutral grey by default; pass [color]
/// only when the colour carries meaning (danger, success, warning, info).
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    this.color,
    this.background,
    this.size = 44,
  });

  final IconData icon;
  final Color? color;
  final Color? background;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = color ?? scheme.onSurface;
    final bg = background ??
        (color == null
            ? scheme.surfaceContainerHigh
            : Color.alphaBlend(fg.withValues(alpha: 0.12), scheme.surface));
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(icon, color: fg, size: size * 0.52),
    );
  }
}

/// A section heading: small, bold and muted, with optional trailing action.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.title, {super.key, this.padding, this.trailing});

  final String title;
  final EdgeInsetsGeometry? padding;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(4, 28, 4, 12),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: theme.textTheme.titleSmall!.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// A tinted notice box (tip, warning, error, success) with an icon.
///
/// Replaces the many hand-made `Colors.red[50]` + border boxes so they all
/// share one shape and work in dark mode.
class NoticeCard extends StatelessWidget {
  const NoticeCard({
    super.key,
    required this.tone,
    required this.message,
    this.title,
    this.icon,
    this.action,
    this.margin = EdgeInsets.zero,
  });

  final Tone tone;
  final String message;
  final String? title;
  final IconData? icon;
  final Widget? action;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final s = context.safety;
    final fg = s.onContainer(tone, scheme);
    final defaultIcon = switch (tone) {
      Tone.danger => Icons.error_outline_rounded,
      Tone.warning => Icons.warning_amber_rounded,
      Tone.info => Icons.info_outline_rounded,
      Tone.success => Icons.check_circle_outline_rounded,
      Tone.neutral => Icons.lightbulb_outline_rounded,
    };
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: s.container(tone, scheme),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? defaultIcon, color: s.accent(tone, scheme), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(title!,
                      style: theme.textTheme.titleSmall!.copyWith(color: fg)),
                  const SizedBox(height: 2),
                ],
                Text(message,
                    style: theme.textTheme.bodyMedium!.copyWith(color: fg)),
                if (action != null) ...[
                  const SizedBox(height: 8),
                  action!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A friendly centred placeholder for empty lists.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: scheme.onSecondaryContainer),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: theme.textTheme.bodyMedium!
                    .copyWith(color: scheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// SafeOne's logo mark: a flat version of the launcher icon (white shield
/// with a heart on the brand purple). Drawn in code so it stays crisp at any
/// size and carries no gradient. It is the only place the brand purple shows.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'SafeOne',
      image: true,
      child: CustomPaint(
        size: Size.square(size),
        painter: _LogoPainter(),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  static const _heart = Color(0xFFE8457A);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    Offset p(double x, double y) => Offset(x * w, y * w);

    // Background tile.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(w * 0.24)),
      Paint()..color = AppTheme.brand,
    );

    // Shield: flat top with rounded corners, curving down to a point.
    final shield = Path()
      ..moveTo(p(0.29, 0.20).dx, p(0.29, 0.20).dy)
      ..lineTo(p(0.71, 0.20).dx, p(0.71, 0.20).dy)
      ..quadraticBezierTo(p(0.76, 0.20).dx, p(0.76, 0.20).dy,
          p(0.76, 0.26).dx, p(0.76, 0.26).dy)
      ..cubicTo(p(0.76, 0.46).dx, p(0.76, 0.46).dy, p(0.64, 0.64).dx,
          p(0.64, 0.64).dy, p(0.50, 0.80).dx, p(0.50, 0.80).dy)
      ..cubicTo(p(0.36, 0.64).dx, p(0.36, 0.64).dy, p(0.24, 0.46).dx,
          p(0.24, 0.46).dy, p(0.24, 0.26).dx, p(0.24, 0.26).dy)
      ..quadraticBezierTo(p(0.24, 0.20).dx, p(0.24, 0.20).dy,
          p(0.29, 0.20).dx, p(0.29, 0.20).dy)
      ..close();
    canvas.drawPath(shield, Paint()..color = Colors.white);

    // Heart: two lobes and a pointed base.
    final heart = Paint()..color = _heart;
    final r = w * 0.052;
    canvas.drawCircle(p(0.452, 0.445), r, heart);
    canvas.drawCircle(p(0.548, 0.445), r, heart);
    final base = Path()
      ..moveTo(p(0.403, 0.462).dx, p(0.403, 0.462).dy)
      ..quadraticBezierTo(p(0.43, 0.53).dx, p(0.43, 0.53).dy,
          p(0.50, 0.585).dx, p(0.50, 0.585).dy)
      ..quadraticBezierTo(p(0.57, 0.53).dx, p(0.57, 0.53).dy,
          p(0.597, 0.462).dx, p(0.597, 0.462).dy)
      ..lineTo(p(0.50, 0.445).dx, p(0.50, 0.445).dy)
      ..close();
    canvas.drawPath(base, heart);
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) => false;
}
