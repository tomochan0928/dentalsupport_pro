' ============================================================
'  院内の他の端末（iPad・子パソコン）から開くアドレスを表示
' ============================================================
Option Explicit
Dim wmi, cfgs, c, ip, list, state, x, st
Set wmi  = GetObject("winmgmts:\\.\root\cimv2")
Set cfgs = wmi.ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")
list = ""
For Each c In cfgs
  If Not IsNull(c.IPAddress) Then
    For Each ip In c.IPAddress
      If InStr(ip, ":") = 0 And Left(ip, 4) <> "169." And ip <> "0.0.0.0" And Left(ip, 4) <> "127." Then
        list = list & "      http://" & ip & ":3000" & vbCrLf
      End If
    Next
  End If
Next
If list = "" Then list = "      （ネットワークに接続されていません）" & vbCrLf

state = "停止中（スタートメニューの「DentalSupport Pro を開く」で起動）"
On Error Resume Next
Set x = CreateObject("MSXML2.ServerXMLHTTP.6.0")
x.setTimeouts 1000, 1000, 1500, 1500
x.open "GET", "http://localhost:3000/api/health?t=" & Timer, False
x.send
st = 0
st = x.status
If Err.Number <> 0 Then st = 0
If st = 200 Then state = "起動中"
Err.Clear
On Error GoTo 0

MsgBox "サーバーの状態： " & state & vbCrLf & vbCrLf & _
       "院内の他の端末（iPad・子パソコン）からは、次のアドレスで開きます：" & vbCrLf & vbCrLf & _
       list & vbCrLf & _
       "※ このPC自身では  http://localhost:3000" & vbCrLf & _
       "※ アドレスが変わらないよう、このPCのIPは固定してください（ガイド参照）。", _
       64, "DentalSupport Pro  接続先アドレス"
