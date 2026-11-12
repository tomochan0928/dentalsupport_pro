' Installer helper: writes "OK" to Arguments(1) if http://Arguments(0):3000/api/health returns 200, else "NG".
' Result is returned via a file (not the exit code); if this script fails, the installer treats it as "not connected".
' Keep this file ASCII-only so it runs regardless of script encoding.
Option Explicit
Dim x, st, fso, t
If WScript.Arguments.Count < 2 Then WScript.Quit 1
st = 0
On Error Resume Next
Set x = CreateObject("MSXML2.ServerXMLHTTP.6.0")
If Err.Number <> 0 Then Err.Clear : Set x = CreateObject("MSXML2.ServerXMLHTTP")
x.setTimeouts 2000, 2000, 3000, 3000
x.open "GET", "http://" & WScript.Arguments(0) & ":3000/api/health?t=" & Timer, False
x.send
st = x.status
If Err.Number <> 0 Then st = 0
Err.Clear
On Error GoTo 0
Set fso = CreateObject("Scripting.FileSystemObject")
Set t = fso.CreateTextFile(WScript.Arguments(1), True)
If st = 200 Then
  t.Write "OK"
Else
  t.Write "NG"
End If
t.Close
