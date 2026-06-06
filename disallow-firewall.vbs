' DentalSupport Pro - 追加したファイアウォール許可ルール(ポート3000)を削除する
' ダブルクリックすると「管理者として実行」の確認が出ます → 「はい」を押してください。
Option Explicit
Dim sh, ruleName, cmd
ruleName = "DentalSupport Pro (TCP 3000)"
cmd = "/c netsh advfirewall firewall delete rule name=""" & ruleName & """" & _
      " & echo. & echo ファイアウォールの許可ルールを削除しました。 & echo. & pause"
Set sh = CreateObject("Shell.Application")
sh.ShellExecute "cmd.exe", cmd, "", "runas", 1
