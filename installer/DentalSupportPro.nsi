; ============================================================
;  DentalSupport Pro  サーバーPC用 フルインストーラー（NSIS 3 / Windows 7 以降）
;  ビルド: python3 tools/build_installer.py
; ============================================================
Unicode true
SetCompressor /SOLID lzma
ManifestDPIAware true
RequestExecutionLevel admin

!ifndef VERSION
  !define VERSION "1.0.0"
!endif
!ifndef STAGE
  !define STAGE "stage"
!endif
!ifndef OUTFILE
  !define OUTFILE "DentalSupportPro-Setup.exe"
!endif

!define APPNAME   "DentalSupport Pro"
!define COMPANY   "DentalSupport Pro"
!define EXENAME   "DentalSupportPro.exe"
!define UNINSTKEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\DentalSupportPro"
!define REGKEY    "Software\DentalSupportPro"
!define FWRULE    "DentalSupport Pro (TCP 3000)"
!define TASKNAME  "DentalSupport Pro Server"

Name "${APPNAME}"
Caption "${APPNAME} セットアップ（サーバーPC用） v${VERSION}"
OutFile "${OUTFILE}"
InstallDir "C:\DentalSupportPro"
InstallDirRegKey HKLM "${REGKEY}" "InstallDir"
BrandingText "${APPNAME} v${VERSION}"

VIProductVersion "${VERSION}.0"
VIAddVersionKey /LANG=1041 "ProductName"     "${APPNAME}"
VIAddVersionKey /LANG=1041 "FileDescription" "${APPNAME} サーバーPC用セットアップ"
VIAddVersionKey /LANG=1041 "FileVersion"     "${VERSION}"
VIAddVersionKey /LANG=1041 "ProductVersion"  "${VERSION}"
VIAddVersionKey /LANG=1041 "CompanyName"     "${COMPANY}"
VIAddVersionKey /LANG=1041 "LegalCopyright"  "${APPNAME}"

!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "FileFunc.nsh"

!define MUI_ICON   "${STAGE}\icon.ico"
!define MUI_UNICON "${STAGE}\icon.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "${STAGE}\wizard.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "${STAGE}\wizard.bmp"
!define MUI_ABORTWARNING
!define MUI_COMPONENTSPAGE_SMALLDESC

!define MUI_WELCOMEPAGE_TITLE "${APPNAME} のセットアップへようこそ"
!define MUI_WELCOMEPAGE_TEXT "このウィザードは、${APPNAME}（歯科チェアサイド説明ツール）を、このPCに「サーバー」としてインストールします。$\r$\n$\r$\n・院内のiPad／子パソコンから、このPCに接続して使います$\r$\n・患者データはこのPCに保存されます（インターネットは使いません）$\r$\n・Node.js などの追加ソフトは不要です$\r$\n$\r$\n以前のバージョンが入っている場合は上書きされます。患者データ（data フォルダ）は残ります。$\r$\n$\r$\n[次へ] を押して続けてください。"
!insertmacro MUI_PAGE_WELCOME

!define MUI_DIRECTORYPAGE_TEXT_TOP "インストール先を選んでください。$\r$\n患者データはこのフォルダ内の data に保存されます。$\r$\n※「Program Files」は書き込みが制限されるため、既定の C:\DentalSupportPro を推奨します。"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES

!define MUI_FINISHPAGE_TITLE "インストールが完了しました"
!define MUI_FINISHPAGE_TEXT "インストールが完了しました。$\r$\n・このPC：デスクトップのアイコンから開く$\r$\n・iPad等：下の「接続先アドレス」で確認$\r$\n最初に画面右上の「設定」で医院名・住所を登録してください。"
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "今すぐ ${APPNAME} を開く"
!define MUI_FINISHPAGE_RUN_FUNCTION LaunchApp
!define MUI_FINISHPAGE_SHOWREADME
!define MUI_FINISHPAGE_SHOWREADME_TEXT "他の端末用の接続先アドレスを表示する"
!define MUI_FINISHPAGE_SHOWREADME_FUNCTION ShowUrl
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "Japanese"

; ------------------------------------------------------------
;  インストール
; ------------------------------------------------------------
Section "!${APPNAME} 本体（必須）" SecCore
  SectionIn RO

  ; 動作中のサーバーを停止（上書きのため）
  nsExec::Exec 'taskkill /IM ${EXENAME} /F'
  Sleep 1200

  ; 以前の自動起動設定をいったん解除（選択された項目で作り直す）
  SetShellVarContext current
  Delete "$SMSTARTUP\${APPNAME}.lnk"
  SetShellVarContext all
  Delete "$SMSTARTUP\${APPNAME}.lnk"
  Delete "$SMSTARTUP\${APPNAME} サーバー.lnk"
  nsExec::Exec 'schtasks /Delete /TN "${TASKNAME}" /F'

  SetOutPath "$INSTDIR"
  SetOverwrite on
  File "${STAGE}\${EXENAME}"
  File "${STAGE}\index.html"
  File "${STAGE}\icon.ico"
  File "${STAGE}\launch.vbs"
  File "${STAGE}\show-url.vbs"
  File "${STAGE}\start-hidden.vbs"
  File "${STAGE}\stop-server.bat"
  File "${STAGE}\README.txt"
  SetOutPath "$INSTDIR\Guide"
  File "${STAGE}\Guide\QuickGuide.pdf"
  File "${STAGE}\Guide\StaticIP-Setup.pdf"
  SetOutPath "$INSTDIR"

  ; 患者データ用フォルダ（既存データは触らない）
  CreateDirectory "$INSTDIR\data"
  ; 通常ユーザーでもデータ保存・画面更新ができるよう書き込み権限を付与（Users = S-1-5-32-545）
  nsExec::Exec 'icacls "$INSTDIR" /grant *S-1-5-32-545:(OI)(CI)M /T /C /Q'

  ; スタートメニュー
  CreateDirectory "$SMPROGRAMS\${APPNAME}"
  CreateShortCut "$SMPROGRAMS\${APPNAME}\${APPNAME} を開く.lnk" "$SYSDIR\wscript.exe" '"$INSTDIR\launch.vbs"' "$INSTDIR\icon.ico" 0
  CreateShortCut "$SMPROGRAMS\${APPNAME}\接続先アドレスを確認.lnk" "$SYSDIR\wscript.exe" '"$INSTDIR\show-url.vbs"' "$SYSDIR\shell32.dll" 13
  CreateShortCut "$SMPROGRAMS\${APPNAME}\サーバーを起動（画面なし）.lnk" "$SYSDIR\wscript.exe" '"$INSTDIR\start-hidden.vbs"' "$INSTDIR\icon.ico" 0
  CreateShortCut "$SMPROGRAMS\${APPNAME}\サーバーを停止.lnk" "$INSTDIR\stop-server.bat" "" "$SYSDIR\shell32.dll" 27
  CreateShortCut "$SMPROGRAMS\${APPNAME}\インストール先フォルダを開く.lnk" "$INSTDIR"
  CreateShortCut "$SMPROGRAMS\${APPNAME}\クイックガイド.lnk" "$INSTDIR\Guide\QuickGuide.pdf"
  CreateShortCut "$SMPROGRAMS\${APPNAME}\固定IP設定手順.lnk" "$INSTDIR\Guide\StaticIP-Setup.pdf"
  CreateShortCut "$SMPROGRAMS\${APPNAME}\はじめにお読みください.lnk" "$INSTDIR\README.txt"
  CreateShortCut "$SMPROGRAMS\${APPNAME}\アンインストール.lnk" "$INSTDIR\uninstall.exe"

  ; アンインストール情報（コントロールパネル「プログラムと機能」）
  WriteRegStr HKLM "${REGKEY}" "InstallDir" "$INSTDIR"
  WriteRegStr HKLM "${REGKEY}" "Version" "${VERSION}"
  WriteRegStr HKLM "${UNINSTKEY}" "DisplayName" "${APPNAME}"
  WriteRegStr HKLM "${UNINSTKEY}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKLM "${UNINSTKEY}" "Publisher" "${COMPANY}"
  WriteRegStr HKLM "${UNINSTKEY}" "DisplayIcon" "$INSTDIR\icon.ico"
  WriteRegStr HKLM "${UNINSTKEY}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "${UNINSTKEY}" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "${UNINSTKEY}" "NoModify" 1
  WriteRegDWORD HKLM "${UNINSTKEY}" "NoRepair" 1
  ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
  IntFmt $0 "0x%08X" $0
  WriteRegDWORD HKLM "${UNINSTKEY}" "EstimatedSize" "$0"
  WriteUninstaller "$INSTDIR\uninstall.exe"
SectionEnd

Section "ファイアウォールを許可（推奨）" SecFirewall
  nsExec::Exec 'netsh advfirewall firewall delete rule name="${FWRULE}"'
  nsExec::ExecToLog 'netsh advfirewall firewall add rule name="${FWRULE}" dir=in action=allow protocol=TCP localport=3000'
SectionEnd

Section "電源ON時にサーバー自動起動（推奨）" SecAutostart
  ; タスクスケジューラに「起動時（ログイン不要）＋ログオン時」のタスクを登録。
  ; schtasks /SC ONSTART だと既定で72時間で強制終了されるため、XMLで「時間制限なし・異常終了時は再起動」を指定する。
  InitPluginsDir
  FileOpen $0 "$PLUGINSDIR\dsp-task.xml" w
  FileWriteUTF16LE /BOM $0 '<?xml version="1.0" encoding="UTF-16"?>$\r$\n'
  FileWriteUTF16LE $0 '<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">$\r$\n'
  FileWriteUTF16LE $0 '<RegistrationInfo><Description>DentalSupport Pro サーバーを電源ON時に起動（ログイン不要）</Description></RegistrationInfo>$\r$\n'
  FileWriteUTF16LE $0 '<Triggers><BootTrigger><Enabled>true</Enabled></BootTrigger><LogonTrigger><Enabled>true</Enabled></LogonTrigger></Triggers>$\r$\n'
  FileWriteUTF16LE $0 '<Principals><Principal id="Author"><UserId>S-1-5-18</UserId><RunLevel>HighestAvailable</RunLevel></Principal></Principals>$\r$\n'
  FileWriteUTF16LE $0 '<Settings><MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy><DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries><StopIfGoingOnBatteries>false</StopIfGoingOnBatteries><AllowHardTerminate>true</AllowHardTerminate><StartWhenAvailable>true</StartWhenAvailable><RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable><IdleSettings><StopOnIdleEnd>false</StopOnIdleEnd><RestartOnIdle>false</RestartOnIdle></IdleSettings><AllowStartOnDemand>true</AllowStartOnDemand><Enabled>true</Enabled><Hidden>false</Hidden><RunOnlyIfIdle>false</RunOnlyIfIdle><WakeToRun>false</WakeToRun><ExecutionTimeLimit>PT0S</ExecutionTimeLimit><Priority>7</Priority><RestartOnFailure><Interval>PT1M</Interval><Count>3</Count></RestartOnFailure></Settings>$\r$\n'
  FileWriteUTF16LE $0 '<Actions Context="Author"><Exec><Command>$INSTDIR\${EXENAME}</Command><Arguments>--no-open</Arguments><WorkingDirectory>$INSTDIR</WorkingDirectory></Exec></Actions>$\r$\n'
  FileWriteUTF16LE $0 '</Task>$\r$\n'
  FileClose $0
  nsExec::ExecToLog 'schtasks /Create /TN "${TASKNAME}" /XML "$PLUGINSDIR\dsp-task.xml" /F'
  Pop $0
  ${If} $0 == "0"
    DetailPrint "電源ON時の自動起動を登録しました。サーバーを起動します..."
    nsExec::Exec 'schtasks /Run /TN "${TASKNAME}"'
    Sleep 3000
  ${Else}
    ; 登録できなかった場合は従来方式（ログオン時に起動）で代替
    DetailPrint "タスク登録に失敗したため、ログオン時の自動起動で代替します。"
    SetShellVarContext all
    CreateShortCut "$SMSTARTUP\${APPNAME} サーバー.lnk" "$SYSDIR\wscript.exe" '"$INSTDIR\start-hidden.vbs"' "$INSTDIR\icon.ico" 0
  ${EndIf}
SectionEnd

Section "ログイン時にアプリ画面を自動で開く" SecAutoOpen
  SetShellVarContext all
  CreateShortCut "$SMSTARTUP\${APPNAME}.lnk" "$SYSDIR\wscript.exe" '"$INSTDIR\launch.vbs" /logon' "$INSTDIR\icon.ico" 0
SectionEnd

Section "デスクトップにアイコンを作成" SecDesktop
  SetShellVarContext all
  CreateShortCut "$DESKTOP\${APPNAME}.lnk" "$SYSDIR\wscript.exe" '"$INSTDIR\launch.vbs"' "$INSTDIR\icon.ico" 0
SectionEnd

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecCore}      "サーバー本体・画面・スタートメニュー。患者データ（data）は上書きしません。"
  !insertmacro MUI_DESCRIPTION_TEXT ${SecFirewall}  "ポート3000の受信を許可します。iPad・子パソコンから使うには必須です。"
  !insertmacro MUI_DESCRIPTION_TEXT ${SecAutostart} "PCの電源を入れるだけで、ログインしなくても裏でサーバーが起動します（iPad等からすぐ使えます）。"
  !insertmacro MUI_DESCRIPTION_TEXT ${SecAutoOpen}  "このPCにログインしたとき、アプリの画面を自動で開きます。"
  !insertmacro MUI_DESCRIPTION_TEXT ${SecDesktop}   "デスクトップに「${APPNAME}」アイコンを作ります（サーバーが止まっていれば自動で起動して開きます）。"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; 完了画面の操作は、管理者権限ではなく通常のユーザー権限で起動する（explorer 経由）
Function LaunchApp
  Exec '"$WINDIR\explorer.exe" "$INSTDIR\launch.vbs"'
FunctionEnd
Function ShowUrl
  Exec '"$WINDIR\explorer.exe" "$INSTDIR\show-url.vbs"'
FunctionEnd

; ------------------------------------------------------------
;  アンインストール
; ------------------------------------------------------------
Section "Uninstall"
  nsExec::Exec 'schtasks /End /TN "${TASKNAME}"'
  nsExec::Exec 'schtasks /Delete /TN "${TASKNAME}" /F'
  nsExec::Exec 'taskkill /IM ${EXENAME} /F'
  Sleep 1000
  nsExec::Exec 'netsh advfirewall firewall delete rule name="${FWRULE}"'

  SetShellVarContext all
  Delete "$SMSTARTUP\${APPNAME}.lnk"
  Delete "$SMSTARTUP\${APPNAME} サーバー.lnk"
  Delete "$DESKTOP\${APPNAME}.lnk"
  RMDir /r "$SMPROGRAMS\${APPNAME}"
  SetShellVarContext current
  Delete "$SMSTARTUP\${APPNAME}.lnk"

  Delete "$INSTDIR\${EXENAME}"
  Delete "$INSTDIR\index.html"
  Delete "$INSTDIR\index.html.bak"
  Delete "$INSTDIR\icon.ico"
  Delete "$INSTDIR\launch.vbs"
  Delete "$INSTDIR\show-url.vbs"
  Delete "$INSTDIR\start-hidden.vbs"
  Delete "$INSTDIR\stop-server.bat"
  Delete "$INSTDIR\README.txt"
  RMDir /r "$INSTDIR\Guide"
  Delete "$INSTDIR\uninstall.exe"

  ${If} ${FileExists} "$INSTDIR\data\*.*"
    MessageBox MB_YESNO|MB_ICONEXCLAMATION|MB_DEFBUTTON2 \
      "患者データ・医院共通設定・説明写真（data フォルダ）も削除しますか？$\r$\n$\r$\n通常は「いいえ」を選んでください（再インストール時にそのまま使えます）。$\r$\n「はい」を選ぶと元に戻せません。" \
      /SD IDNO IDNO keepdata
      RMDir /r "$INSTDIR\data"
    keepdata:
  ${EndIf}
  RMDir "$INSTDIR"

  DeleteRegKey HKLM "${UNINSTKEY}"
  DeleteRegKey HKLM "${REGKEY}"
SectionEnd
