' ============================================================
'  DentalSupport Pro を開く（サーバーPC用）
'  ・サーバーが止まっていれば、画面に出さずに起動してから開きます
'  ・引数 /logon：ログオン時の自動表示用（起動時タスクのサーバーを最大15秒待つ）
'  ・Microsoft Edge / Google Chrome があれば専用ウィンドウ（アプリモード）で開きます
' ============================================================
Option Explicit
Dim sh, fso, folder, url, i, browser
Set sh  = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
folder  = fso.GetParentFolderName(WScript.ScriptFullName)
url     = "http://localhost:3000"

' ログオン時の自動起動（/logon）では、起動時タスクのサーバーが立ち上がるのを先に待つ
If WScript.Arguments.Count > 0 Then
  If LCase(WScript.Arguments(0)) = "/logon" Then
    For i = 1 To 30                     ' 最大15秒
      If ServerUp() Then Exit For
      WScript.Sleep 500
    Next
  End If
End If

If Not ServerUp() Then
  sh.Environment("PROCESS")("NO_OPEN") = "1"
  sh.CurrentDirectory = folder
  sh.Run """" & folder & "\DentalSupportPro.exe""", 0, False
  For i = 1 To 40                       ' 最大20秒待つ
    WScript.Sleep 500
    If ServerUp() Then Exit For
  Next
  If Not ServerUp() Then
    MsgBox "サーバーを起動できませんでした。" & vbCrLf & vbCrLf & _
           "・別のソフトがポート3000を使っていないか確認してください。" & vbCrLf & _
           "・PCを再起動してから、もう一度お試しください。", 48, "DentalSupport Pro"
    WScript.Quit
  End If
End If

browser = FindBrowser()
If browser <> "" Then
  sh.Run """" & browser & """ --app=" & url & " --start-maximized", 1, False
Else
  sh.Run url, 1, False
End If

' サーバーが応答しているか（/api/health）
Function ServerUp()
  Dim x, st
  ServerUp = False
  On Error Resume Next
  Set x = CreateObject("MSXML2.ServerXMLHTTP.6.0")
  If Err.Number <> 0 Then Err.Clear : Set x = CreateObject("MSXML2.ServerXMLHTTP")
  x.setTimeouts 1000, 1000, 1500, 1500
  x.open "GET", url & "/api/health?t=" & Timer, False
  x.send
  st = 0
  st = x.status
  If Err.Number <> 0 Then st = 0
  ServerUp = (st = 200)
  Err.Clear
  On Error GoTo 0
End Function

' Edge / Chrome を探す（無ければ空文字）
Function FindBrowser()
  Dim cand, c, pf86, pf, lad
  pf   = sh.ExpandEnvironmentStrings("%ProgramFiles%")
  pf86 = sh.ExpandEnvironmentStrings("%ProgramFiles(x86)%")
  lad  = sh.ExpandEnvironmentStrings("%LOCALAPPDATA%")
  cand = Array(pf86 & "\Microsoft\Edge\Application\msedge.exe", _
               pf   & "\Microsoft\Edge\Application\msedge.exe", _
               pf   & "\Google\Chrome\Application\chrome.exe", _
               pf86 & "\Google\Chrome\Application\chrome.exe", _
               lad  & "\Google\Chrome\Application\chrome.exe")
  FindBrowser = ""
  For Each c In cand
    If FindBrowser = "" And fso.FileExists(c) Then FindBrowser = c
  Next
End Function
