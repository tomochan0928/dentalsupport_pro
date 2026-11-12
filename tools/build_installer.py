#!/usr/bin/env python3
"""サーバーPC用フルインストーラー（dist/DentalSupportPro-Setup.exe）を作る。
  必要: makensis（NSIS 3）。exe は先に `npm run build:win` で作っておくこと。
  .vbs -> UTF-16LE(BOM) / .bat -> CP932 / .txt -> UTF-8(BOM) に変換してから同梱する。
"""
import json, os, shutil, subprocess, sys
HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
DIST = os.path.join(REPO, "dist")
STAGE = os.path.join(DIST, "installer-stage")

def rd(p): return open(os.path.join(REPO, p), encoding="utf-8").read()
def vbs(src, dst): open(dst, "wb").write(b"\xff\xfe" + rd(src).replace("\r\n", "\n").replace("\n", "\r\n").encode("utf-16-le"))
def bat(src, dst): open(dst, "wb").write(rd(src).replace("chcp 65001 >nul\n", "").replace("\r\n", "\n").replace("\n", "\r\n").encode("cp932", "replace"))
def txt(src, dst): open(dst, "wb").write(b"\xef\xbb\xbf" + rd(src).replace("\r\n", "\n").replace("\n", "\r\n").encode("utf-8"))
def cp(src, dst):  shutil.copy2(os.path.join(REPO, src), dst)

exe = os.path.join(DIST, "DentalSupportPro.exe")
if not os.path.exists(exe): sys.exit("dist/DentalSupportPro.exe がありません。先に npm run build:win を実行してください。")
version = json.load(open(os.path.join(REPO, "package.json"), encoding="utf-8"))["version"]

if os.path.exists(STAGE): shutil.rmtree(STAGE)
os.makedirs(os.path.join(STAGE, "Guide"))
S = lambda *p: os.path.join(STAGE, *p)
cp("dist/DentalSupportPro.exe", S("DentalSupportPro.exe"))
cp("index.html", S("index.html"))
cp("icon.ico", S("icon.ico"))
cp("installer/wizard.bmp", S("wizard.bmp"))
vbs("installer/launch.vbs", S("launch.vbs"))
vbs("installer/show-url.vbs", S("show-url.vbs"))
vbs("start-hidden.vbs", S("start-hidden.vbs"))
bat("stop-server.bat", S("stop-server.bat"))
txt("installer/README-Install.txt", S("README.txt"))
cp("docs/クイックガイド.pdf", S("Guide", "QuickGuide.pdf"))
cp("docs/固定IP設定手順.pdf", S("Guide", "StaticIP-Setup.pdf"))

# ---- 子パソコン用ステージ ----
CSTAGE = os.path.join(DIST, "installer-stage-client")
if os.path.exists(CSTAGE): shutil.rmtree(CSTAGE)
os.makedirs(CSTAGE)
C = lambda *p: os.path.join(CSTAGE, *p)
cp("icon.ico", C("icon.ico"))
cp("installer/wizard.bmp", C("wizard.bmp"))
for f in ["open.vbs", "change-server.vbs"]:
    vbs("installer/client/" + f, C(f))
# check.vbs は英数字のみ（文字コードに依存せず動く）→ CRLF にしてそのまま同梱
open(C("check.vbs"), "wb").write(rd("installer/client/check.vbs").replace("\r\n", "\n").replace("\n", "\r\n").encode("ascii"))
txt("installer/client/README-Client.txt", C("README.txt"))
DEFAULT_IP = os.environ.get("DSP_DEFAULT_IP", "192.168.128.201")

out = os.path.join(DIST, "DentalSupportPro-Setup.exe")
cmd = ["makensis", "-V2", "-INPUTCHARSET", "UTF8",
       f"-DVERSION={version}", f"-DSTAGE={STAGE}", f"-DOUTFILE={out}",
       os.path.join(REPO, "installer", "DentalSupportPro.nsi")]
r = subprocess.run(cmd, capture_output=True, text=True)
print(r.stdout[-3000:]); print(r.stderr[-3000:])
if r.returncode != 0: sys.exit("makensis failed")
print("built", out, round(os.path.getsize(out) / 1024 / 1024, 1), "MB  (v%s)" % version)

cout = os.path.join(DIST, "DentalSupportPro-Client-Setup.exe")
cmd = ["makensis", "-V2", "-INPUTCHARSET", "UTF8",
       f"-DVERSION={version}", f"-DSTAGE={CSTAGE}", f"-DOUTFILE={cout}", f"-DDEFAULT_IP={DEFAULT_IP}",
       os.path.join(REPO, "installer", "client", "DentalSupportPro-Client.nsi")]
r = subprocess.run(cmd, capture_output=True, text=True)
print(r.stdout[-3000:]); print(r.stderr[-3000:])
if r.returncode != 0: sys.exit("makensis (client) failed")
print("built", cout, round(os.path.getsize(cout) / 1024, 1), "KB  (v%s, default IP %s)" % (version, DEFAULT_IP))
