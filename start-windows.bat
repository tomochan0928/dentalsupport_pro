@echo off
cd /d "%~dp0"
title DentalSupport Pro サーバー
where node >nul 2>nul
if errorlevel 1 (
  echo.
  echo [!] Node.js が見つかりません。
  echo     次のどちらかで起動してください:
  echo       A) 実行ファイル版 DentalSupportPro-win.exe をダブルクリック（Node.js不要）
  echo       B) https://nodejs.org/ja から Node.js をインストール後、この start-windows.bat を実行
  echo.
  pause
  exit /b 1
)
echo DentalSupport Pro サーバーを起動します...
node server.js
echo.
echo サーバーが停止しました。
pause
