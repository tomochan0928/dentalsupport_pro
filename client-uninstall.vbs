' DentalSupport Pro 子パソコンのデスクトップアイコンを削除します。
Option Explicit
Dim sh, fso, desktop, n, removed
Set sh  = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
desktop = sh.SpecialFolders("Desktop")
removed = False
For Each n In Array("\DentalSupport Pro.lnk", "\DentalSupport Pro.url")
  If fso.FileExists(desktop & n) Then fso.DeleteFile desktop & n : removed = True
Next
If removed Then
  MsgBox "デスクトップのアイコンを削除しました。", 64, "DentalSupport Pro"
Else
  MsgBox "アイコンは見つかりませんでした。", 64, "DentalSupport Pro"
End If
