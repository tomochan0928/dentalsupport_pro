' DentalSupport Pro - Windows ファイアウォールでポート3000(TCP)の受信を許可する
' iPad など院内の他端末から http://(このPCのIP):3000 に接続できるようにします。
' ダブルクリックすると「管理者として実行」の確認が出ます → 「はい」を押してください。
Option Explicit
Dim sh, ruleName, cmd
ruleName = "DentalSupport Pro (TCP 3000)"
' 既存の同名ルールを消してから追加（重複防止）。完了後に結果を表示して一時停止。
cmd = "/c netsh advfirewall firewall delete rule name=""" & ruleName & """ >nul 2>nul" & _
      " & netsh advfirewall firewall add rule name=""" & ruleName & """ dir=in action=allow protocol=TCP localport=3000" & _
      " & echo. & echo ポート3000(TCP)の受信を許可しました。 & echo iPad等から http://(このPCのIP):3000 で開けます。 & echo. & pause"
Set sh = CreateObject("Shell.Application")
' "runas" で管理者権限に昇格してコマンド実行（ウィンドウ表示=1）
sh.ShellExecute "cmd.exe", cmd, "", "runas", 1
