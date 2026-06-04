' DentalSupport Pro の自動起動（ログオン時起動）を解除する。
Set sh  = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
lnkPath = sh.SpecialFolders("Startup") & "\DentalSupport Pro.lnk"
If fso.FileExists(lnkPath) Then
  fso.DeleteFile lnkPath
  MsgBox "自動起動を解除しました。", 64, "DentalSupport Pro"
Else
  MsgBox "自動起動は登録されていません。", 64, "DentalSupport Pro"
End If
