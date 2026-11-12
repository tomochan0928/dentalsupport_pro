' ============================================================
'  DentalSupport Pro を開く（子パソコン用）
'  接続先は同じフォルダの server.txt（スタートメニュー「接続先を変更」で変更）
' ============================================================
Option Explicit
Dim sh, fso, folder, ip, url, browser, r
Set sh  = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
folder  = fso.GetParentFolderName(WScript.ScriptFullName)

ip = ReadServer()
If ip = "" Then
  sh.Run "wscript.exe """ & folder & "\change-server.vbs""", 1, True
  ip = ReadServer()
  If ip = "" Then WScript.Quit
End If
url = "http://" & ip & ":3000"

If Not ServerUp(url) Then
  r = MsgBox("サーバー（" & url & "）に接続できません。" & vbCrLf & vbCrLf & _
             "次を確認してください：" & vbCrLf & _
             "　・サーバーPCの電源が入っているか" & vbCrLf & _
             "　・このパソコンがサーバーと同じWi-Fi／LANにつながっているか" & vbCrLf & _
             "　・サーバーのIPが変わっていないか（変わった場合はスタートメニュー" & vbCrLf & _
             "　　「DentalSupport Pro」→「接続先を変更」）" & vbCrLf & vbCrLf & _
             "このまま画面を開きますか？", vbYesNo + vbExclamation, "DentalSupport Pro")
  If r = vbNo Then WScript.Quit
End If

browser = FindBrowser()
If browser <> "" Then
  If InStr(LCase(browser), "firefox") > 0 Then
    sh.Run """" & browser & """ " & url, 1, False
  Else
    sh.Run """" & browser & """ --app=" & url & " --start-maximized", 1, False
  End If
Else
  MsgBox "Microsoft Edge または Google Chrome が見つかりませんでした。" & vbCrLf & _
         "Internet Explorer では正しく動作しないため、Edge か Chrome の導入をおすすめします。" & vbCrLf & vbCrLf & _
         "既定のブラウザで開きます。", vbInformation, "DentalSupport Pro"
  sh.Run url, 1, False
End If

Function ReadServer()
  Dim p, t
  ReadServer = ""
  p = folder & "\server.txt"
  If fso.FileExists(p) Then
    Set t = fso.OpenTextFile(p, 1)
    If Not t.AtEndOfStream Then ReadServer = Trim(t.ReadLine)
    t.Close
  End If
End Function

Function ServerUp(u)
  Dim x, st
  ServerUp = False
  On Error Resume Next
  Set x = CreateObject("MSXML2.ServerXMLHTTP.6.0")
  If Err.Number <> 0 Then Err.Clear : Set x = CreateObject("MSXML2.ServerXMLHTTP")
  x.setTimeouts 2000, 2000, 3000, 3000
  x.open "GET", u & "/api/health?t=" & Timer, False
  x.send
  st = 0
  st = x.status
  If Err.Number <> 0 Then st = 0
  ServerUp = (st = 200)
  Err.Clear
  On Error GoTo 0
End Function

Function FindBrowser()
  Dim cand, c, pf86, pf, lad
  pf   = sh.ExpandEnvironmentStrings("%ProgramFiles%")
  pf86 = sh.ExpandEnvironmentStrings("%ProgramFiles(x86)%")
  lad  = sh.ExpandEnvironmentStrings("%LOCALAPPDATA%")
  cand = Array(pf86 & "\Microsoft\Edge\Application\msedge.exe", _
               pf   & "\Microsoft\Edge\Application\msedge.exe", _
               pf   & "\Google\Chrome\Application\chrome.exe", _
               pf86 & "\Google\Chrome\Application\chrome.exe", _
               lad  & "\Google\Chrome\Application\chrome.exe", _
               pf   & "\Mozilla Firefox\firefox.exe", _
               pf86 & "\Mozilla Firefox\firefox.exe")
  FindBrowser = ""
  For Each c In cand
    If FindBrowser = "" And fso.FileExists(c) Then FindBrowser = c
  Next
End Function
