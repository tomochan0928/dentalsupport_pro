' ============================================================
'  接続先（サーバーPCのIPアドレス）を変更する（子パソコン用）
' ============================================================
Option Explicit
Dim sh, fso, folder, p, cur, ip, t, x, st
Set sh  = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
folder  = fso.GetParentFolderName(WScript.ScriptFullName)
p = folder & "\server.txt"
cur = ""
If fso.FileExists(p) Then
  Set t = fso.OpenTextFile(p, 1)
  If Not t.AtEndOfStream Then cur = Trim(t.ReadLine)
  t.Close
End If

ip = InputBox("サーバーPCのIPアドレスを入力してください。" & vbCrLf & vbCrLf & _
              "例: 192.168.128.201" & vbCrLf & _
              "※サーバーPCのスタートメニュー「接続先アドレスを確認」で分かります。", _
              "DentalSupport Pro  接続先の変更", cur)
If Trim(ip) = "" Then WScript.Quit
ip = Trim(ip)
ip = Replace(ip, "http://", "") : ip = Replace(ip, "https://", "")
ip = Replace(ip, ":3000", "")   : ip = Replace(ip, "/", "")

Set t = fso.CreateTextFile(p, True)
t.WriteLine ip
t.Close

st = 0
On Error Resume Next
Set x = CreateObject("MSXML2.ServerXMLHTTP.6.0")
x.setTimeouts 2000, 2000, 3000, 3000
x.open "GET", "http://" & ip & ":3000/api/health?t=" & Timer, False
x.send
st = x.status
If Err.Number <> 0 Then st = 0
Err.Clear
On Error GoTo 0

If st = 200 Then
  MsgBox "接続先を「" & ip & "」に変更しました。" & vbCrLf & "サーバーに接続できました。", vbInformation, "DentalSupport Pro"
Else
  MsgBox "接続先を「" & ip & "」に変更しました。" & vbCrLf & vbCrLf & _
         "ただし、いまサーバーに接続できませんでした。" & vbCrLf & _
         "サーバーPCが起動しているか、同じネットワークにつながっているか確認してください。", vbExclamation, "DentalSupport Pro"
End If
