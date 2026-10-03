#!/usr/bin/env python3
"""Generate captioned Play Store screenshots (1080x1920) and the feature graphic.

Raw app captures live in screenshots/; output goes to store_screenshots/.
Run from this directory: python3 gen_screenshots.py
"""
import os
from PIL import Image, ImageDraw, ImageFont

from gen_graphics import diag_grad, shield

W, H = 1080, 1920
DEEP = (59, 22, 120)
PURPLE = (124, 58, 237)
PINK = (233, 49, 105)
WHITE = (255, 255, 255)
SOFT = (228, 220, 250)

SHOTS = [
    ("01_home_sos.png", "One tap to send SOS",
     "Your location goes to the people you trust"),
    ("04_settings.png", "Shake or press to send SOS",
     "Hands-free triggers, even when the phone is locked"),
    ("02_fake_call.png", "Fake call to get away",
     "A realistic incoming call whenever you need an exit"),
    ("03_helplines.png", "Every helpline in one place",
     "112, police, ambulance, women's helpline and more"),
]


def avenir(size, weight="Bold"):
    path = "/System/Library/Fonts/Avenir Next.ttc"
    for i in range(12):
        try:
            f = ImageFont.truetype(path, size, index=i)
        except Exception:
            break
        if f.getname()[1] == weight:
            return f
    return ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", size)


def centered(d, y, text, font, fill):
    w = d.textlength(text, font=font)
    d.text(((W - w) / 2, y), text, font=font, fill=fill)


def make_shot(src, title, sub, out):
    canvas = diag_grad((W, H), DEEP, PURPLE)
    d = ImageDraw.Draw(canvas)
    centered(d, 124, title, avenir(68), WHITE)
    centered(d, 232, sub, avenir(38, "Medium"), SOFT)

    shot = Image.open(src).convert("RGB")
    pw = 820
    ph = int(shot.height * pw / shot.width)
    shot = shot.resize((pw, ph), Image.LANCZOS)
    x, y = (W - pw) // 2, 360
    border = 14
    # Phone body: dark rounded frame around the screenshot, running off the bottom.
    d.rounded_rectangle([x - border, y - border, x + pw + border, y + ph + border],
                        radius=70, fill=(18, 12, 32))
    mask = Image.new("L", (pw, ph), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, pw, ph], radius=56, fill=255)
    canvas.paste(shot, (x, y), mask)
    canvas.save(out)
    print("saved", out)


def make_feature(out):
    w, h = 1024, 500
    img = diag_grad((w, h), DEEP, PURPLE)
    d = ImageDraw.Draw(img)
    cx, cy = 210, h / 2
    shield(d, cx, cy, 190, 230, WHITE)
    hr = 32
    hx, hy = cx, cy - 6
    d.ellipse([hx - hr * 1.6, hy - hr, hx, hy + hr], fill=PINK)
    d.ellipse([hx, hy - hr, hx + hr * 1.6, hy + hr], fill=PINK)
    d.polygon([(hx - hr * 1.55, hy + hr * 0.25), (hx + hr * 1.55, hy + hr * 0.25),
               (hx, hy + hr * 1.9)], fill=PINK)
    d.text((410, 140), "SafeOne", font=avenir(104), fill=WHITE)
    d.text((414, 285), "SOS & personal safety", font=avenir(40, "Demi Bold"), fill=SOFT)
    d.text((414, 340), "Private. No ads. No sign-up.", font=avenir(32, "Medium"), fill=SOFT)
    img.save(out)
    print("saved", out)


if __name__ == "__main__":
    os.makedirs("store_screenshots", exist_ok=True)
    for i, (src, title, sub) in enumerate(SHOTS, 1):
        make_shot(os.path.join("screenshots", src), title, sub,
                  f"store_screenshots/{i:02d}_{os.path.splitext(src)[0][3:]}.png")
    make_feature("feature_graphic_1024x500.png")
