#!/usr/bin/env python3
"""個別の歯PNG(32本: tools/teeth_src/tooth_outline_01..32.png)から
歯列チャート(tooth-chart.png)とシルエットマスク(tooth-mask.png)を合成し、
各歯の座標(TEETH_GEOM)を index.html 用に出力する。

  python3 tools/compose.py
依存: pillow numpy （pip install pillow numpy）
"""
from PIL import Image
import numpy as np, os
from collections import deque

HERE = os.path.dirname(os.path.abspath(__file__))
SRC  = os.path.join(HERE, "teeth_src")
OUT  = os.path.join(HERE, "..")

def load_trim(n):
    im = Image.open(os.path.join(SRC, f"tooth_outline_{n:02d}.png")).convert("RGBA")
    a = np.array(im); alpha = a[:,:,3] > 40
    ys, xs = np.where(alpha)
    return im.crop((xs.min(), ys.min(), xs.max()+1, ys.max()+1)) if len(xs) else im

def silhouette(im):
    """outlineを壁に外側をflood、内側=塗りつぶし（白シルエット bool）。"""
    a = np.array(im); H, W = a.shape[:2]; pad = 2
    ink = np.zeros((H+2*pad, W+2*pad), bool); ink[pad:pad+H, pad:pad+W] = a[:,:,3] > 60
    bg = np.zeros_like(ink); dq = deque([(0,0)]); bg[0,0] = True
    HH, WW = ink.shape
    while dq:
        y, x = dq.popleft()
        for dy, dx in ((1,0),(-1,0),(0,1),(0,-1)):
            ny, nx = y+dy, x+dx
            if 0 <= ny < HH and 0 <= nx < WW and not bg[ny,nx] and not ink[ny,nx]:
                bg[ny,nx] = True; dq.append((ny,nx))
    return (~bg)[pad:pad+H, pad:pad+W]

UPPER, LOWER = list(range(1,17)), list(range(17,33))
GAP, ARCH_GAP = 6, 70

def prep(nums, root_up):
    out = []
    for n in nums:
        im = load_trim(n); sil = silhouette(im); wp = sil.sum(axis=1); h = len(wp)
        if (wp[:h//4].mean() < wp[3*h//4:].mean()) != root_up:
            im = im.transpose(Image.FLIP_TOP_BOTTOM); sil = silhouette(im)
        out.append((im, sil))
    return out

up = prep(UPPER, True); lo = prep(LOWER, False)
up_maxh = max(im.size[1] for im,_ in up); lo_maxh = max(im.size[1] for im,_ in lo)
W = max(sum(im.size[0] for im,_ in up)+GAP*15, sum(im.size[0] for im,_ in lo)+GAP*15)
H = up_maxh + ARCH_GAP + lo_maxh
chart = Image.new("RGBA",(W,H),(0,0,0,0)); mask = Image.new("RGBA",(W,H),(0,0,0,0)); geom = []

def place(items, arch, mode, y_ref):
    x = (W - (sum(im.size[0] for im,_ in items)+GAP*(len(items)-1)))//2
    for k,(im,sil) in enumerate(items):
        w,h = im.size
        top, bot = (y_ref-h, y_ref) if mode=="bottom" else (y_ref, y_ref+h)
        si = np.zeros((h,w,4),np.uint8); si[sil] = (255,255,255,255); si = Image.fromarray(si,"RGBA")
        mask.alpha_composite(si,(x,top)); chart.alpha_composite(si,(x,top)); chart.alpha_composite(im,(x,top))
        geom.append({"a":arch,"i":k+1,"cx":(x+w/2)/W,"top":top/H,"bot":bot/H,"w":w/W})
        x += w + GAP

place(up,"U","bottom", up_maxh); place(lo,"L","top", up_maxh+ARCH_GAP)
bg = Image.new("RGBA",(W,H),(255,255,255,255)); bg.alpha_composite(chart)
bg.convert("RGB").save(os.path.join(OUT,"tooth-chart.png"))
mask.save(os.path.join(OUT,"tooth-mask.png"))

# index.html の TEETH_GEOM 用配列を出力
rows = [f'{{id:"{g["a"]}{g["i"]}",a:"{g["a"]}",cx:{g["cx"]*W:.1f},w:{g["w"]*W:.1f},top:{g["top"]*H:.1f},bot:{g["bot"]*H:.1f}}}' for g in geom]
print(f"// VBW={W}, VBH={H}")
print("const TEETH_GEOM = [\n" + "\n".join("  "+",".join(rows[i:i+4])+("," if i+4 < len(rows) else "") for i in range(0,len(rows),4)) + "\n];")
