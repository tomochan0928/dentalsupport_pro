@echo off
title DentalSupport Pro 停止
set "IMG=DentalSupportPro.exe"

tasklist /FI "IMAGENAME eq %IMG%" 2>nul | find /I "%IMG%" >nul
if errorlevel 1 goto notrunning

taskkill /IM %IMG% /F >nul 2>nul
tasklist /FI "IMAGENAME eq %IMG%" 2>nul | find /I "%IMG%" >nul
if errorlevel 1 goto stopped

rem 自動起動（システム権限）で動いているサーバーは管理者権限が必要
net session >nul 2>&1
if not errorlevel 1 goto failed
echo 管理者の確認画面が出たら「はい」を押してください...
echo Set s = CreateObject("Shell.Application") : s.ShellExecute "%~f0", "", "", "runas", 1 > "%TEMP%\dsp_stop_elev.vbs"
wscript "%TEMP%\dsp_stop_elev.vbs"
exit /b

:stopped
echo DentalSupport Pro サーバーを停止しました。
echo （次にPCを起動したとき、または「DentalSupport Pro を開く」で再び起動します）
goto end

:notrunning
echo サーバーは起動していませんでした。
goto end

:failed
echo サーバーを停止できませんでした。PCを再起動してください。

:end
timeout /t 3 >nul
