#!/usr/bin/env python3
"""Generate the Play Store screenshots (1080x1920) and feature graphic.

Flat, neutral style that matches the app: light grey canvas, ink headline in
Inter, a dark phone bezel around a real app capture. No gradients.

Raw captures live in screenshots/ (taken on an emulator with Android demo
mode for a clean status bar). Run from this directory:
    python3 gen_screenshots.py
"""
import os

from PIL import Image, ImageDraw, ImageFont

from gen_icon import BRAND, draw_mark

W, H = 1080, 1920
CANVAS = (244, 244, 245)     # neutral light grey
INK = (22, 22, 26)           # AppTheme primary / text
MUTED = (95, 95, 107)        # onSurfaceVariant
BEZEL = (22, 22, 26)
FONTS = os.path.join(os.path.dirname(__file__), "..", "..", "assets", "fonts")

# (raw capture, headline, subtitle) in store order — lead with the SOS.
SHOTS = [
    ("home.png", "Help in one tap",
     "Your SOS goes to the people you trust"),
    ("countdown.png", "A countdown you can cancel",
     "Stops accidental alerts before they go out"),
    ("tools.png", "Every safety tool in one place",
     "Helplines, live tracking, check-in timer and more"),
    ("fakecall.png", "Fake call to get away",
     "A realistic call whenever you need an exit"),
    ("medical.png", "A Medical ID for responders",
     "Blood group, allergies and who to call"),
    ("helplines.png", "India's helplines, one tap away",
     "112, women's helpline, ambulance and more"),
    ("settings.png", "Hands-free SOS",
     "Shake or press volume, even when locked"),
]


def inter(weight, size):
    return ImageFont.truetype(os.path.join(FONTS, f"Inter-{weight}.ttf"), size)


def centered(d, y, text, font, fill, width=W):
    w = d.textlength(text, font=font)
    d.text(((width - w) / 2, y), text, font=font, fill=fill)


def fit_font(d, text, weight, size, max_width):
    """Largest size <= [size] at which [text] fits on one line."""
    while size > 20:
        f = inter(weight, size)
        if d.textlength(text, font=f) <= max_width:
            return f
        size -= 2
    return inter(weight, size)


def make_shot(src, title, sub, out):
    canvas = Image.new("RGB", (W, H), CANVAS)
    d = ImageDraw.Draw(canvas)
    centered(d, 112, title, fit_font(d, title, 700, 64, W - 120), INK)
    centered(d, 206, sub, fit_font(d, sub, 500, 34, W - 120), MUTED)

    shot = Image.open(src).convert("RGB")
    pw = 800
    ph = int(shot.height * pw / shot.width)
    shot = shot.resize((pw, ph), Image.LANCZOS)
    x, y = (W - pw) // 2, 330
    bezel = 16
    # Phone body: the bezel runs off the bottom edge of the canvas.
    d.rounded_rectangle([x - bezel, y - bezel, x + pw + bezel, y + ph + bezel],
                        radius=72, fill=BEZEL)
    mask = Image.new("L", (pw, ph), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, pw, ph], radius=56, fill=255)
    canvas.paste(shot, (x, y), mask)
    canvas.save(out, optimize=True)
    print("saved", out)


def make_feature(out):
    w, h = 1024, 500
    img = Image.new("RGB", (w, h), BRAND)
    # Logo mark drawn straight onto the flat brand colour, at 4x for
    # smooth edges.
    ss = 4
    size = 300
    mark = Image.new("RGBA", (size * ss, size * ss), (0, 0, 0, 0))
    draw_mark(ImageDraw.Draw(mark), size * ss)
    mark = mark.resize((size, size), Image.LANCZOS)
    img.paste(mark, (70, (h - size) // 2), mark)

    d = ImageDraw.Draw(img)
    d.text((400, 138), "SafeOne", font=inter(700, 104), fill="white")
    d.text((404, 282), "SOS & personal safety",
           font=inter(600, 40), fill=(237, 233, 254))
    d.text((404, 340), "Private. No ads. No sign-up.",
           font=inter(500, 30), fill=(221, 214, 254))
    img.save(out, optimize=True)
    print("saved", out)


if __name__ == "__main__":
    here = os.path.dirname(os.path.abspath(__file__))
    os.chdir(here)
    os.makedirs("store_screenshots", exist_ok=True)
    for i, (src, title, sub) in enumerate(SHOTS, 1):
        name = os.path.splitext(src)[0]
        make_shot(os.path.join("screenshots", src), title, sub,
                  f"store_screenshots/{i:02d}_{name}.png")
    make_feature("feature_graphic_1024x500.png")
