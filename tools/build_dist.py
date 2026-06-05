#!/usr/bin/env python3
"""配布パッケージ(zip)を Windows(特にWin7)で文字化けせず動くエンコーディングで生成。
  .vbs -> UTF-16LE(BOM) / .bat -> CP932 / .txt -> UTF-8(BOM) / ファイル名は ASCII。
"""
import os, shutil, zipfile
HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.join(HERE, "..")
DIST = os.path.join(REPO, "dist")

def wr_vbs(src, dst):
    t = open(src, encoding="utf-8").read()
    open(dst, "wb").write(b"\xff\xfe" + t.encode("utf-16-le"))      # UTF-16LE + BOM
def wr_bat(src, dst):
    t = open(src, encoding="utf-8").read().replace("chcp 65001 >nul\n", "")
    open(dst, "wb").write(t.encode("cp932", "replace"))             # Shift-JIS
def wr_txt(src, dst):
    t = open(src, encoding="utf-8").read()
    open(dst, "wb").write(b"\xef\xbb\xbf" + t.encode("utf-8"))      # UTF-8 + BOM
def cp(src, dst):
    shutil.copy2(src, dst)

def build(stage, items):
    p = os.path.join(DIST, stage)
    if os.path.exists(p): shutil.rmtree(p)
    os.makedirs(p)
    for kind, src, rel in items:
        dst = os.path.join(p, rel)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        {"vbs":wr_vbs, "bat":wr_bat, "txt":wr_txt, "bin":cp}[kind](os.path.join(REPO, src), dst)
    zp = os.path.join(DIST, stage + ".zip")
    if os.path.exists(zp): os.remove(zp)
    with zipfile.ZipFile(zp, "w", zipfile.ZIP_DEFLATED) as z:
        for root, _, files in os.walk(p):
            for f in files:
                full = os.path.join(root, f)
                z.write(full, os.path.join(stage, os.path.relpath(full, p)))
    print("built", zp, round(os.path.getsize(zp)/1024/1024, 1), "MB")

# サーバーPC用
build("DentalSupportPro", [
    ("bin","dist/DentalSupportPro.exe","DentalSupportPro.exe"),
    ("vbs","start-hidden.vbs","start-hidden.vbs"),
    ("vbs","autostart-install.vbs","autostart-install.vbs"),
    ("vbs","autostart-uninstall.vbs","autostart-uninstall.vbs"),
    ("bat","stop-server.bat","stop-server.bat"),
    ("bat","open-app.bat","open-app.bat"),
    ("bat","start-windows.bat","start-windows.bat"),
    ("txt","はじめにお読みください.txt","README-First.txt"),
    ("bin","docs/クイックガイド.pdf","Guide/QuickGuide.pdf"),
    ("bin","docs/固定IP設定手順.pdf","Guide/StaticIP-Setup.pdf"),
    ("bin","docs/自動起動チェックリスト.pdf","Guide/AutoStart-Checklist.pdf"),
])
# 子パソコン用
build("DentalSupportPro-Client", [
    ("vbs","client-install.vbs","client-install.vbs"),
    ("vbs","client-uninstall.vbs","client-uninstall.vbs"),
    ("bin","icon.ico","icon.ico"),
    ("txt","子パソコン_はじめにお読みください.txt","README-Client.txt"),
    ("bin","docs/クイックガイド.pdf","QuickGuide.pdf"),
])
