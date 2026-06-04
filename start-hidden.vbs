' DentalSupport Pro をバックグラウンド（ウィンドウ非表示・ブラウザ自動起動なし）で起動する。
' 自動起動やスタッフ用の静かな起動に使う。停止は stop-server.bat。
Set sh  = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
folder  = fso.GetParentFolderName(WScript.ScriptFullName)
' 自動でブラウザを開かない（サーバーPCはホスト役のため）
sh.Environment("PROCESS")("NO_OPEN") = "1"
' 0 = ウィンドウ非表示, False = 終了を待たない
sh.Run """" & folder & "\DentalSupportPro.exe""", 0, False
