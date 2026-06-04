' ============================================================
'  DentalSupport Pro  子パソコン用 インストーラー（受付/診療室の端末）
'  サーバーPCのIPを入力すると、デスクトップに「DentalSupport Pro」
'  アイコンを作成します。ダブルクリックでアプリ専用ウィンドウが開きます。
'  （Microsoft Edge / Google Chrome があればアプリモードで、無ければ既定ブラウザで開きます）
' ============================================================
Option Explicit
Dim sh, fso, folder, ip, url, desktop, icon, browser, lnk, ts

Set sh  = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
folder  = fso.GetParentFolderName(WScript.ScriptFullName)
desktop = sh.SpecialFolders("Desktop")
icon    = folder & "\icon.ico"

' --- サーバーPCのIPを入力 ---
ip = InputBox( _
  "サーバーPC（親パソコン）のIPアドレスを入力してください。" & vbCrLf & vbCrLf & _
  "例: 192.168.1.50" & vbCrLf & _
  "※院内で配布された固定IPを入力（『固定IP設定手順』参照）", _
  "DentalSupport Pro  子パソコン設定", "192.168.1.50")

If Trim(ip) = "" Then WScript.Quit   ' キャンセル
ip  = Trim(ip)
url = "http://" & ip & ":3000"

' --- Edge / Chrome を探す ---
Dim cand(3), i
cand(0) = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
cand(1) = "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
cand(2) = "C:\Program Files\Google\Chrome\Application\chrome.exe"
cand(3) = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
browser = ""
For i = 0 To 3
  If browser = "" And fso.FileExists(cand(i)) Then browser = cand(i)
Next

' --- デスクトップにショートカット作成 ---
If browser <> "" Then
  ' アプリモード（タブ・アドレスバー無しの専用ウィンドウ）
  Set lnk = sh.CreateShortcut(desktop & "\DentalSupport Pro.lnk")
  lnk.TargetPath       = browser
  lnk.Arguments        = "--app=" & url & " --start-maximized"
  lnk.WorkingDirectory = folder
  lnk.Description       = "DentalSupport Pro を開く（" & url & "）"
  If fso.FileExists(icon) Then lnk.IconLocation = icon & ", 0"
  lnk.Save
Else
  ' フォールバック：既定ブラウザで開くインターネットショートカット
  Set ts = fso.CreateTextFile(desktop & "\DentalSupport Pro.url", True)
  ts.WriteLine "[InternetShortcut]"
  ts.WriteLine "URL=" & url
  If fso.FileExists(icon) Then
    ts.WriteLine "IconFile=" & icon
    ts.WriteLine "IconIndex=0"
  End If
  ts.Close
End If

MsgBox "設定が完了しました。" & vbCrLf & vbCrLf & _
       "デスクトップの「DentalSupport Pro」アイコンをダブルクリックすると" & vbCrLf & _
       "アプリが開きます。" & vbCrLf & vbCrLf & _
       "接続先： " & url & vbCrLf & _
       "（先にサーバーPCで DentalSupport Pro が起動している必要があります）", _
       64, "DentalSupport Pro"
