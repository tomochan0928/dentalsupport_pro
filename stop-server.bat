@echo off
title DentalSupport Pro 停止
taskkill /IM DentalSupportPro.exe /F >nul 2>nul
if errorlevel 1 (
  echo サーバーは起動していませんでした。
) else (
  echo DentalSupport Pro サーバーを停止しました。
)
timeout /t 2 >nul
