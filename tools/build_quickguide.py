#!/usr/bin/env python3
import os
from weasyprint import HTML, CSS
from weasyprint.text.fonts import FontConfiguration
REPO="/home/user/dentalsupport_pro"; OUT=os.path.join(REPO,"docs")
fc=FontConfiguration()

HTMLDOC = """
<html><head><meta charset='utf-8'></head><body>
<div class="hd">
  <div class="logo">🦷 DentalSupport Pro</div>
  <div class="sub">クイックガイド（院内掲示用）</div>
</div>

<div class="urlbox">
  <div class="ul">この医院のアクセス先（サーバーPCのIP）</div>
  <div class="ua">http://<span class="blank">　　　　　　　　　　</span>:3000</div>
  <div class="un">↑ このURLを iPad / PC のお気に入り・ホーム画面に登録</div>
</div>

<h2>毎日の使い方</h2>
<div class="steps">
  <div class="step"><div class="no">1</div><div class="t"><b>サーバーPCの電源を入れる</b><br><span>自動起動で準備完了（画面操作は不要）</span></div></div>
  <div class="step"><div class="no">2</div><div class="t"><b>iPad / PC で上のURLを開く</b><br><span>歯列チャートが表示されればOK</span></div></div>
  <div class="step"><div class="no">3</div><div class="t"><b>患者番号を入力 → 歯をタップして記録 → 💾保存</b><br><span>番号はタップでテンキーが出ます</span></div></div>
</div>

<h2>基本操作</h2>
<table class="ops">
  <tr><td class="k">操作モード</td><td><b>プロブレムリスト</b>（う蝕／根尖性歯周炎／補綴）と <b>歯式作成</b>（欠損／ブリッジ／補綴／残根…）をタブで切替。う蝕は歯の<b>部位をクリック</b>して指定。</td></tr>
  <tr><td class="k">保存 / 読込</td><td>患者番号を入れて <b>💾 保存</b>・<b>📥 読込</b>。どの端末からでも同じ患者を呼び出せます。</td></tr>
  <tr><td class="k">印刷</td><td><b>🖨 印刷（患者用）</b>で、治療計画 説明書をA4で印刷。医院名は「医院共通設定」で固定。</td></tr>
</table>

<h2>困ったとき</h2>
<div class="trouble">
  <div class="tb"><div class="th">つながらない</div>サーバーPCが起動しているか／端末が<b>同じWi-Fi/LAN</b>か／URLのIPが合っているか を確認</div>
  <div class="tb"><div class="th">画面が古い</div>ブラウザを<b>再読込（更新）</b>する</div>
  <div class="tb"><div class="th">保存・共有できない</div>必ず <b>http://（IP）:3000</b> で開く。<br>ファイル(index.html)を直接開かない</div>
</div>

<div class="foot">※ データはサーバーPCの <b>data</b> フォルダに保存されます。インターネット・クラウドは使用しません（院内LANのみ）。　停止: stop-server.bat　／　このPCで開く: open-app.bat</div>
</body></html>
"""

CSSDOC = """
@font-face { font-family:'JP'; src:url('file:///usr/share/fonts/truetype/fonts-japanese-gothic.ttf'); }
@page { size:A4; margin:12mm; }
*{ font-family:'JP',sans-serif; box-sizing:border-box; }
body{ color:#2e3a44; margin:0; }
.hd{ background:linear-gradient(120deg,#38b0d6,#2a8bab); color:#fff; border-radius:14px; padding:14px 20px; display:flex; align-items:baseline; gap:14px; }
.hd .logo{ font-size:24pt; font-weight:800; }
.hd .sub{ font-size:13pt; opacity:.95; }
.urlbox{ border:3px solid #38b0d6; border-radius:14px; padding:12px 16px; margin:14px 0; text-align:center; background:#f2fafd; }
.urlbox .ul{ font-size:11pt; color:#2a8bab; font-weight:700; }
.urlbox .ua{ font-size:26pt; font-weight:800; color:#1f5066; letter-spacing:1px; margin:4px 0; }
.urlbox .ua .blank{ border-bottom:2px solid #2a8bab; }
.urlbox .un{ font-size:10.5pt; color:#6c7c89; }
h2{ font-size:15pt; color:#2a8bab; border-left:6px solid #38b0d6; padding-left:9px; margin:16px 0 8px; }
.steps{ display:flex; flex-direction:column; gap:9px; }
.step{ display:flex; align-items:center; gap:12px; border:1px solid #d6e2ea; border-radius:11px; padding:10px 12px; background:#fbfdff; }
.step .no{ flex:none; width:34px; height:34px; border-radius:50%; background:#38b0d6; color:#fff; font-size:17pt; font-weight:800; text-align:center; line-height:34px; }
.step .t{ font-size:12.5pt; } .step .t span{ font-size:10.5pt; color:#6c7c89; }
table.ops{ width:100%; border-collapse:collapse; }
table.ops td{ border:1px solid #cfdce4; padding:8px 10px; font-size:11pt; vertical-align:top; }
table.ops td.k{ width:120px; background:#eaf4f9; color:#2a8bab; font-weight:700; white-space:nowrap; }
.trouble{ display:flex; gap:10px; }
.trouble .tb{ flex:1; border:1px solid #d6e2ea; border-radius:11px; padding:9px 11px; font-size:10.5pt; background:#fbfdff; }
.trouble .th{ font-weight:800; color:#c0392b; margin-bottom:4px; font-size:11pt; }
.foot{ margin-top:14px; font-size:9.5pt; color:#555; border-top:1px dashed #aaa; padding-top:8px; }
"""

HTML(string=HTMLDOC, base_url=REPO).write_pdf(os.path.join(OUT,"クイックガイド.pdf"),
    stylesheets=[CSS(string=CSSDOC, font_config=fc)], font_config=fc)
print("wrote クイックガイド.pdf")
