#!/usr/bin/env python3
import markdown, os
from weasyprint import HTML, CSS
from weasyprint.text.fonts import FontConfiguration

REPO = "/home/user/dentalsupport_pro"
OUT = os.path.join(REPO, "docs")
font_config = FontConfiguration()

DOC_CSS = """
@font-face { font-family: 'JP'; src: url('file:///usr/share/fonts/truetype/fonts-japanese-gothic.ttf'); }
@page { size: A4; margin: 16mm 15mm; @bottom-center { content: counter(page) " / " counter(pages); font-family:'JP'; font-size:9px; color:#888; } }
* { font-family: 'JP', sans-serif; }
body { color:#2e3a44; font-size: 11pt; line-height: 1.6; }
h1 { font-size: 19pt; color:#2a8bab; border-bottom: 3px solid #38b0d6; padding-bottom:6px; margin:0 0 12px; }
h2 { font-size: 14pt; color:#2a8bab; margin: 18px 0 6px; border-left:5px solid #38b0d6; padding-left:8px; }
h3 { font-size: 12pt; color:#2e3a44; margin: 12px 0 4px; }
p, li { font-size: 11pt; }
code { background:#eef4f8; padding:1px 5px; border-radius:4px; font-family:'JP'; font-size:10.5pt; }
pre { background:#0f2733; color:#dff3fb; padding:8px 12px; border-radius:8px; overflow:auto; }
pre code { background:transparent; color:inherit; }
table { border-collapse: collapse; width:100%; margin:8px 0; }
th,td { border:1px solid #c9d8e2; padding:5px 8px; font-size:10.5pt; text-align:left; vertical-align:top; }
th { background:#eaf4f9; color:#2a8bab; }
blockquote { background:#eaf7fc; border-left:4px solid #38b0d6; margin:8px 0; padding:6px 12px; color:#2a6b85; border-radius:6px; }
ul,ol { margin:4px 0 8px; padding-left:22px; }
hr { border:none; border-top:1px dashed #aaa; margin:14px 0; }
strong { color:#1f5066; }
"""

def md_to_pdf(md_path, pdf_path, title):
    text = open(md_path, encoding="utf-8").read()
    body = markdown.markdown(text, extensions=["tables","fenced_code","sane_lists"])
    html = f"<html><head><meta charset='utf-8'></head><body>{body}</body></html>"
    HTML(string=html, base_url=REPO).write_pdf(pdf_path, stylesheets=[CSS(string=DOC_CSS, font_config=font_config)], font_config=font_config)
    print("wrote", pdf_path)

md_to_pdf(os.path.join(OUT,"固定IP設定手順.md"), os.path.join(OUT,"固定IP設定手順.pdf"), "固定IP設定手順")
md_to_pdf(os.path.join(OUT,"自動起動チェックリスト.md"), os.path.join(OUT,"自動起動チェックリスト.pdf"), "自動起動チェックリスト")
