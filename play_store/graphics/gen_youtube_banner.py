#!/usr/bin/env python3
"""Generate the YouTube channel banner (2560x1440, flat, no gradients).

YouTube shows a different crop per device; only the centre 1546x423 "safe
area" is visible everywhere, so the logo and text live inside it. Run from
this directory:  python3 gen_youtube_banner.py
"""
import os

from PIL import Image, ImageDraw, ImageFont

from gen_icon import BRAND, draw_mark

W, H = 2560, 1440
SAFE_W, SAFE_H = 1546, 423
SAFE_X, SAFE_Y = (W - SAFE_W) // 2, (H - SAFE_H) // 2
FONTS = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                     "..", "..", "assets", "fonts")
SOFT = (237, 233, 254)     # light violet text on the brand colour
SOFTER = (221, 214, 254)


def inter(weight, size):
    return ImageFont.truetype(os.path.join(FONTS, f"Inter-{weight}.ttf"), size)


def make_banner(out):
    img = Image.new("RGB", (W, H), BRAND)
    d = ImageDraw.Draw(img)

    # Logo mark (supersampled for smooth edges), left side of the safe area.
    ss, size = 4, 340
    mark = Image.new("RGBA", (size * ss, size * ss), (0, 0, 0, 0))
    draw_mark(ImageDraw.Draw(mark), size * ss)
    mark = mark.resize((size, size), Image.LANCZOS)

    title = inter(700, 150)
    line1 = inter(600, 58)
    line2 = inter(500, 42)
    t1, t2, t3 = "SafeOne", "SOS & personal safety app", \
        "Free on Google Play  ·  by Tejovan Labs"

    # Centre the logo + text block horizontally inside the safe area.
    gap = 40
    text_w = max(d.textlength(t, font=f)
                 for t, f in ((t1, title), (t2, line1), (t3, line2)))
    block_w = size + gap + text_w
    x0 = SAFE_X + (SAFE_W - block_w) // 2
    y_mid = H // 2
    img.paste(mark, (int(x0), y_mid - size // 2), mark)

    tx = x0 + size + gap
    # Vertical rhythm: title, then two supporting lines.
    d.text((tx, y_mid - 190), t1, font=title, fill="white")
    d.text((tx + 4, y_mid + 10), t2, font=line1, fill=SOFT)
    d.text((tx + 4, y_mid + 92), t3, font=line2, fill=SOFTER)

    img.save(out, optimize=True)
    print("saved", out, img.size)
    return img


def preview(img, out):
    """Side-by-side preview of the desktop and phone crops, with the safe
    area outlined, for checking only (not for upload)."""
    desktop = img.crop((0, SAFE_Y, W, SAFE_Y + SAFE_H))
    phone = img.crop((SAFE_X, SAFE_Y, SAFE_X + SAFE_W, SAFE_Y + SAFE_H))
    full = img.copy()
    ImageDraw.Draw(full).rectangle(
        [SAFE_X, SAFE_Y, SAFE_X + SAFE_W, SAFE_Y + SAFE_H],
        outline=(255, 214, 10), width=6)
    pw = 1280
    parts = [full.resize((pw, pw * H // W)),
             desktop.resize((pw, pw * SAFE_H // W)),
             phone.resize((pw, pw * SAFE_H // SAFE_W))]
    sheet = Image.new("RGB", (pw, sum(p.height for p in parts) + 40),
                      (240, 240, 240))
    y = 0
    for p in parts:
        sheet.paste(p, (0, y))
        y += p.height + 20
    sheet.save(out)


if __name__ == "__main__":
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    banner = make_banner("youtube_banner_2560x1440.png")
    if os.environ.get("PREVIEW"):
        preview(banner, os.environ["PREVIEW"])
