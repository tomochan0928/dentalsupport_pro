#!/bin/bash
cd "$(dirname "$0")"
if ! command -v node >/dev/null 2>&1; then
  echo "[!] Node.js が見つかりません。"
  echo "    実行ファイル版 DentalSupportPro-mac を使うか、https://nodejs.org/ja から Node.js を入れてください。"
  read -n 1 -s -r -p "キーを押すと閉じます"
  exit 1
fi
echo "DentalSupport Pro サーバーを起動します..."
node server.js
