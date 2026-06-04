' このPCのログオン時に DentalSupport Pro を自動起動するよう登録する。
' （スタートアップフォルダに start-hidden.vbs へのショートカットを作成）
' ダブルクリックで実行してください。解除は autostart-uninstall.vbs。
Set sh  = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
folder  = fso.GetParentFolderName(WScript.ScriptFullName)
exePath = folder & "\DentalSupportPro.exe"

If Not fso.FileExists(exePath) Then
  MsgBox "DentalSupportPro.exe が同じフォルダに見つかりません。" & vbCrLf & _
         "exe とこのスクリプトを同じフォルダに置いてから実行してください。", 48, "DentalSupport Pro"
  WScript.Quit
End If

startup = sh.SpecialFolders("Startup")
Set lnk = sh.CreateShortcut(startup & "\DentalSupport Pro.lnk")
lnk.TargetPath        = "wscript.exe"
lnk.Arguments         = """" & folder & "\start-hidden.vbs"""
lnk.WorkingDirectory  = folder
lnk.IconLocation      = exePath
lnk.Description        = "DentalSupport Pro サーバーを自動起動"
lnk.Save

MsgBox "自動起動を登録しました。" & vbCrLf & vbCrLf & _
       "・次回ログオン時から、サーバーが自動で（画面に出ずに）起動します。" & vbCrLf & _
       "・今すぐ起動するには start-hidden.vbs をダブルクリック。" & vbCrLf & _
       "・各端末は  http://（このPCのIP）:3000  でアクセスします。" & vbCrLf & _
       "・停止は stop-server.bat、解除は autostart-uninstall.vbs。", 64, "DentalSupport Pro"
