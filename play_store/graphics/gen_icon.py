#!/usr/bin/env python3
"""Generate SafeOne's flat app icon (no gradients).

Same shield + heart geometry as the in-app logo (lib/widgets/app_ui.dart
AppLogo), on solid brand purple. Writes:
  assets/branding/icon_source.png      full icon, square (launcher tool input)
  assets/branding/icon_foreground.png  adaptive-icon foreground (transparent)
  play_store/graphics/app_icon_512.png / app_icon_1024.png  store icon
  docs/assets/safeone-icon.png         website icon

Run from the repo root:  python3 play_store/graphics/gen_icon.py
then:                    dart run flutter_launcher_icons
"""
from PIL import Image, ImageDraw

BRAND = (109, 40, 217)      # #6D28D9 — AppTheme.brand
HEART = (232, 69, 122)      # #E8457A — AppLogo heart
WHITE = (255, 255, 255)
SS = 4                      # supersampling factor for smooth edges


def bezier(p0, p1, p2, p3=None, steps=64):
    """Points along a quadratic (3 pts) or cubic (4 pts) Bezier curve."""
    pts = []
    for i in range(1, steps + 1):
        t = i / steps
        if p3 is None:
            x = (1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t ** 2 * p2[0]
            y = (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t ** 2 * p2[1]
        else:
            x = ((1 - t) ** 3 * p0[0] + 3 * (1 - t) ** 2 * t * p1[0]
                 + 3 * (1 - t) * t ** 2 * p2[0] + t ** 3 * p3[0])
            y = ((1 - t) ** 3 * p0[1] + 3 * (1 - t) ** 2 * t * p1[1]
                 + 3 * (1 - t) * t ** 2 * p2[1] + t ** 3 * p3[1])
        pts.append((x, y))
    return pts


def draw_mark(d, w):
    """Shield + heart in relative coordinates of a w×w canvas."""
    p = lambda x, y: (x * w, y * w)
    shield = [p(0.29, 0.20), p(0.71, 0.20)]
    shield += bezier(p(0.71, 0.20), p(0.76, 0.20), p(0.76, 0.26))
    shield += bezier(p(0.76, 0.26), p(0.76, 0.46), p(0.64, 0.64), p(0.50, 0.80))
    shield += bezier(p(0.50, 0.80), p(0.36, 0.64), p(0.24, 0.46), p(0.24, 0.26))
    shield += bezier(p(0.24, 0.26), p(0.24, 0.20), p(0.29, 0.20))
    d.polygon(shield, fill=WHITE)

    r = 0.052 * w
    for cx in (0.452, 0.548):
        c = p(cx, 0.445)
        d.ellipse([c[0] - r, c[1] - r, c[0] + r, c[1] + r], fill=HEART)
    base = [p(0.403, 0.462)]
    base += bezier(p(0.403, 0.462), p(0.43, 0.53), p(0.50, 0.585))
    base += bezier(p(0.50, 0.585), p(0.57, 0.53), p(0.597, 0.462))
    base += [p(0.50, 0.445)]
    d.polygon(base, fill=HEART)


def render(size, background):
    big = size * SS
    img = Image.new("RGBA", (big, big), background)
    draw_mark(ImageDraw.Draw(img), big)
    return img.resize((size, size), Image.LANCZOS)


if __name__ == "__main__":
    # Full icon: square and full-bleed — Android, iOS and Google Play apply
    # their own corner masks.
    full = render(1024, BRAND + (255,)).convert("RGB")
    full.save("assets/branding/icon_source.png")
    full.save("play_store/graphics/app_icon_1024.png")
    full.resize((512, 512), Image.LANCZOS).save("play_store/graphics/app_icon_512.png")
    full.resize((256, 256), Image.LANCZOS).save("docs/assets/safeone-icon.png")

    # Adaptive-icon foreground: the mark alone on transparency. The launcher
    # config insets it 16%, which lands it in the 72dp safe zone.
    render(1024, (0, 0, 0, 0)).save("assets/branding/icon_foreground.png")
    print("icons written")
