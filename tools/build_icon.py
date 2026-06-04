#!/usr/bin/env python3
import cairosvg, io, os
from PIL import Image
S=256
svg=f'''<svg xmlns="http://www.w3.org/2000/svg" width="{S}" height="{S}" viewBox="0 0 {S} {S}">
<defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
<stop offset="0" stop-color="#38b0d6"/><stop offset="1" stop-color="#2a8bab"/></linearGradient></defs>
<rect x="0" y="0" width="{S}" height="{S}" rx="56" fill="url(#g)"/>
<path d="M128 56 C96 56 74 76 74 110 C74 134 82 152 90 178 C95 196 99 212 108 212 C118 212 117 176 121 160 C123 152 133 152 135 160 C139 176 138 212 148 212 C157 212 161 196 166 178 C174 152 182 134 182 110 C182 76 160 56 128 56 Z"
 fill="#ffffff" stroke="#eaf7fc" stroke-width="2"/>
<path d="M92 120 C108 132 148 132 164 120" fill="none" stroke="#cfeaf3" stroke-width="4" stroke-linecap="round"/>
</svg>'''
png=cairosvg.svg2png(bytestring=svg.encode(), output_width=S, output_height=S)
im=Image.open(io.BytesIO(png)).convert("RGBA")
out=os.path.join(os.path.dirname(__file__),"..","icon.ico")
im.save(out, sizes=[(16,16),(32,32),(48,48),(64,64),(128,128),(256,256)])
im.save(os.path.join(os.path.dirname(__file__),"..","icon.png"))
print("wrote", out)
