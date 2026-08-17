#!/usr/bin/env python3
"""Generate SafeOne Play Store graphics (app icon + feature graphic)."""
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

OUT = "."
PURPLE = (124, 58, 237)   # primary
TEAL = (20, 184, 166)     # accent
DEEP = (76, 29, 149)
PINK = (233, 49, 105)     # heart (matches in-app brand)
WHITE = (255, 255, 255)


def vgrad(size, top, bottom):
    w, h = size
    base = Image.new("RGB", size, top)
    grad = Image.new("L", (1, h))
    for y in range(h):
        grad.putpixel((0, y), int(255 * y / h))
    alpha = grad.resize(size)
    overlay = Image.new("RGB", size, bottom)
    base.paste(overlay, (0, 0), alpha)
    return base


def diag_grad(size, c1, c2):
    w, h = size
    img = Image.new("RGB", size, c1)
    px = img.load()
    for y in range(h):
        for x in range(0, w, 1):
            t = (x + y) / (w + h)
            px[x, y] = (
                int(c1[0] + (c2[0] - c1[0]) * t),
                int(c1[1] + (c2[1] - c1[1]) * t),
                int(c1[2] + (c2[2] - c1[2]) * t),
            )
    return img


def font(size, bold=True):
    paths = [
        "/System/Library/Fonts/Helvetica.ttc",
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "/System/Library/Fonts/SFNS.ttf",
    ]
    for p in paths:
        try:
            return ImageFont.truetype(p, size)
        except Exception:
            continue
    return ImageFont.load_default()


def shield(draw, cx, cy, w, h, fill):
    top = cy - h / 2
    pts = [
        (cx, top),
        (cx + w / 2, top + h * 0.18),
        (cx + w / 2, cy + h * 0.12),
        (cx, cy + h / 2),
        (cx - w / 2, cy + h * 0.12),
        (cx - w / 2, top + h * 0.18),
    ]
    draw.polygon(pts, fill=fill)


def make_icon(size=1024):
    s = size
    bg = diag_grad((s, s), PURPLE, TEAL)
    # rounded mask
    mask = Image.new("L", (s, s), 0)
    md = ImageDraw.Draw(mask)
    r = int(s * 0.22)
    md.rounded_rectangle([0, 0, s, s], radius=r, fill=255)
    icon = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    icon.paste(bg, (0, 0), mask)
    d = ImageDraw.Draw(icon)

    cx, cy = s / 2, s * 0.50
    # white shield
    shield(d, cx, cy, s * 0.52, s * 0.62, WHITE)
    # heart inside shield (purple)
    hx, hy = cx, cy - s * 0.02
    hr = s * 0.085
    d.ellipse([hx - hr * 1.6, hy - hr, hx - hr * 0.0, hy + hr], fill=PURPLE)
    d.ellipse([hx + hr * 0.0, hy - hr, hx + hr * 1.6, hy + hr], fill=PURPLE)
    d.polygon([
        (hx - hr * 1.55, hy + hr * 0.25),
        (hx + hr * 1.55, hy + hr * 0.25),
        (hx, hy + hr * 1.9),
    ], fill=PURPLE)
    # signal pulses around heart (teal arcs)
    for i, rad in enumerate([s * 0.16, s * 0.205]):
        bbox = [cx - rad, hy - rad, cx + rad, hy + rad]
        d.arc(bbox, start=205, end=245, fill=TEAL, width=int(s * 0.018))
        d.arc(bbox, start=295, end=335, fill=TEAL, width=int(s * 0.018))
    icon.save(f"{OUT}/app_icon_1024.png")
    icon.resize((512, 512), Image.LANCZOS).save(f"{OUT}/app_icon_512.png")
    print("icon saved")


def make_feature():
    w, h = 1024, 500
    img = diag_grad((w, h), DEEP, TEAL)
    d = ImageDraw.Draw(img)
    # left: shield emblem
    cx, cy = 200, h / 2
    shield(d, cx, cy, 190, 230, WHITE)
    hr = 32
    hx, hy = cx, cy - 6
    d.ellipse([hx - hr * 1.6, hy - hr, hx, hy + hr], fill=PINK)
    d.ellipse([hx, hy - hr, hx + hr * 1.6, hy + hr], fill=PINK)
    d.polygon([(hx - hr * 1.55, hy + hr * 0.25), (hx + hr * 1.55, hy + hr * 0.25), (hx, hy + hr * 1.9)], fill=PINK)
    # right: text
    d.text((420, 150), "SafeOne", font=font(96), fill=WHITE)
    d.text((422, 275), "One-tap SOS. Stay safe.", font=font(38), fill=(220, 220, 240))
    img.save(f"{OUT}/feature_graphic_1024x500.png")
    print("feature graphic saved")


if __name__ == "__main__":
    make_icon()
    make_feature()
