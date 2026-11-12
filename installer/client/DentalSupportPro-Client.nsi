; ============================================================
;  DentalSupport Pro  子パソコン用インストーラー（NSIS 3 / Windows 7 以降）
;  管理者権限不要（ユーザーごとにインストール）
;  サイレント例: DentalSupportPro-Client-Setup.exe /S /IP=192.168.128.201
; ============================================================
Unicode true
SetCompressor /SOLID lzma
ManifestDPIAware true
RequestExecutionLevel user

!ifndef VERSION
  !define VERSION "1.0.0"
!endif
!ifndef STAGE
  !define STAGE "stage"
!endif
!ifndef OUTFILE
  !define OUTFILE "DentalSupportPro-Client-Setup.exe"
!endif
!ifndef DEFAULT_IP
  !define DEFAULT_IP "192.168.1.50"
!endif

!define APPNAME   "DentalSupport Pro"
!define UNINSTKEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\DentalSupportProClient"

Name "${APPNAME}（子パソコン用）"
Caption "${APPNAME} セットアップ（子パソコン用） v${VERSION}"
OutFile "${OUTFILE}"
InstallDir "$LOCALAPPDATA\DentalSupportPro-Client"
BrandingText "${APPNAME} v${VERSION}"

VIProductVersion "${VERSION}.0"
VIAddVersionKey /LANG=1041 "ProductName"     "${APPNAME}"
VIAddVersionKey /LANG=1041 "FileDescription" "${APPNAME} 子パソコン用セットアップ"
VIAddVersionKey /LANG=1041 "FileVersion"     "${VERSION}"
VIAddVersionKey /LANG=1041 "ProductVersion"  "${VERSION}"
VIAddVersionKey /LANG=1041 "LegalCopyright"  "${APPNAME}"

!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "nsDialogs.nsh"
!include "FileFunc.nsh"
!include "WordFunc.nsh"
!include "TextFunc.nsh"

!define MUI_ICON   "${STAGE}\icon.ico"
!define MUI_UNICON "${STAGE}\icon.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "${STAGE}\wizard.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "${STAGE}\wizard.bmp"
!define MUI_ABORTWARNING

Var ServerIP
Var IPBox

!define MUI_WELCOMEPAGE_TITLE "${APPNAME}（子パソコン用）のセットアップ"
!define MUI_WELCOMEPAGE_TEXT "受付・診療室のパソコンから、院内のサーバーPCの ${APPNAME} を使えるようにします。$\r$\n$\r$\n・デスクトップに「${APPNAME}」アイコンを作ります$\r$\n・患者データはサーバーPCに保存されます（このパソコンには残りません）$\r$\n・管理者権限は不要です$\r$\n$\r$\n先にサーバーPCで ${APPNAME} を起動しておいてください。"
!insertmacro MUI_PAGE_WELCOME
Page custom ServerPage ServerPageLeave
!insertmacro MUI_PAGE_INSTFILES

!define MUI_FINISHPAGE_TITLE "セットアップが完了しました"
!define MUI_FINISHPAGE_TEXT "デスクトップのアイコンから開けます。$\r$\n$\r$\nサーバーのIPが変わったときは、スタートメニューの「接続先を変更」で直せます。"
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "今すぐ ${APPNAME} を開く"
!define MUI_FINISHPAGE_RUN_FUNCTION LaunchApp
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "Japanese"

Function .onInit
  StrCpy $ServerIP "${DEFAULT_IP}"
  ; 再インストール時は前回の接続先を使う
  ${If} ${FileExists} "$INSTDIR\server.txt"
    FileOpen $0 "$INSTDIR\server.txt" r
    FileRead $0 $1
    FileClose $0
    ${TrimNewLines} $1 $1
    ${If} $1 != ""
      StrCpy $ServerIP $1
    ${EndIf}
  ${EndIf}
  ; コマンドライン /IP=xxx
  ${GetParameters} $0
  ClearErrors
  ${GetOptions} $0 "/IP=" $1
  ${IfNot} ${Errors}
    StrCpy $ServerIP $1
  ${EndIf}
FunctionEnd

Function ServerPage
  !insertmacro MUI_HEADER_TEXT "サーバーPCの指定" "接続するサーバーPCのIPアドレスを入力してください。"
  nsDialogs::Create 1018
  Pop $0
  ${NSD_CreateLabel} 0 0 100% 36u "サーバーPCのIPアドレスを入力して [次へ] を押してください。その場で接続を確認します。$\r$\n（サーバーPCのスタートメニュー「接続先アドレスを確認」で表示されるアドレスです）"
  Pop $0
  ${NSD_CreateLabel} 0 44u 70u 12u "サーバーのIP："
  Pop $0
  ${NSD_CreateText} 72u 42u 120u 14u "$ServerIP"
  Pop $IPBox
  ${NSD_SetFocus} $IPBox
  SendMessage $IPBox ${EM_SETSEL} 0 -1   ; 全選択（そのまま打てば上書き）
  ${NSD_CreateLabel} 72u 60u 100% 12u "例：192.168.128.201"
  Pop $0
  ${NSD_CreateLabel} 0 84u 100% 30u "※ 後から変更する場合は、スタートメニュー「${APPNAME}」→「接続先を変更」。"
  Pop $0
  nsDialogs::Show
FunctionEnd

Function ServerPageLeave
  ${NSD_GetText} $IPBox $ServerIP
  ; 入力のゆらぎを補正（http:// や :3000 を付けて入力しても可）
  ${WordReplace} $ServerIP "http://" "" "+" $ServerIP
  ${WordReplace} $ServerIP "https://" "" "+" $ServerIP
  ${WordReplace} $ServerIP ":3000" "" "+" $ServerIP
  ${WordReplace} $ServerIP "/" "" "+" $ServerIP
  ${WordReplace} $ServerIP " " "" "+" $ServerIP
  ${If} $ServerIP == ""
    MessageBox MB_ICONEXCLAMATION "サーバーPCのIPアドレスを入力してください。"
    Abort
  ${EndIf}
  InitPluginsDir
  File "/oname=$PLUGINSDIR\check.vbs" "${STAGE}\check.vbs"
  Delete "$PLUGINSDIR\check.txt"
  nsExec::Exec '"$SYSDIR\cscript.exe" //nologo //B "$PLUGINSDIR\check.vbs" $ServerIP "$PLUGINSDIR\check.txt"'
  Pop $0
  StrCpy $1 ""
  ClearErrors
  FileOpen $0 "$PLUGINSDIR\check.txt" r
  ${IfNot} ${Errors}
    FileRead $0 $1
    FileClose $0
  ${EndIf}
  ${If} $1 != "OK"
    MessageBox MB_YESNO|MB_ICONEXCLAMATION "サーバー（http://$ServerIP:3000）に接続できませんでした。$\r$\n$\r$\n・サーバーPCで ${APPNAME} が起動しているか$\r$\n・同じWi-Fi／LANにつながっているか$\r$\n・IPアドレスが正しいか$\r$\nを確認してください。$\r$\n$\r$\nこのままインストールを続けますか？（後から「接続先を変更」で直せます）" IDYES keepgoing
    Abort
    keepgoing:
  ${EndIf}
FunctionEnd

Section "Install"
  SetOutPath "$INSTDIR"
  File "${STAGE}\icon.ico"
  File "${STAGE}\open.vbs"
  File "${STAGE}\change-server.vbs"
  File "${STAGE}\check.vbs"
  File "${STAGE}\README.txt"
  FileOpen $0 "$INSTDIR\server.txt" w
  FileWrite $0 "$ServerIP$\r$\n"
  FileClose $0

  ; 旧「client-install.vbs」で作ったアイコンを整理
  Delete "$DESKTOP\${APPNAME}.url"

  CreateShortCut "$DESKTOP\${APPNAME}.lnk" "$SYSDIR\wscript.exe" '"$INSTDIR\open.vbs"' "$INSTDIR\icon.ico" 0
  CreateDirectory "$SMPROGRAMS\${APPNAME}"
  CreateShortCut "$SMPROGRAMS\${APPNAME}\${APPNAME} を開く.lnk" "$SYSDIR\wscript.exe" '"$INSTDIR\open.vbs"' "$INSTDIR\icon.ico" 0
  CreateShortCut "$SMPROGRAMS\${APPNAME}\接続先を変更.lnk" "$SYSDIR\wscript.exe" '"$INSTDIR\change-server.vbs"' "$SYSDIR\shell32.dll" 13
  CreateShortCut "$SMPROGRAMS\${APPNAME}\はじめにお読みください.lnk" "$INSTDIR\README.txt"
  CreateShortCut "$SMPROGRAMS\${APPNAME}\アンインストール（子パソコン用）.lnk" "$INSTDIR\uninstall.exe"

  WriteRegStr HKCU "${UNINSTKEY}" "DisplayName" "${APPNAME}（子パソコン用）"
  WriteRegStr HKCU "${UNINSTKEY}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKCU "${UNINSTKEY}" "Publisher" "${APPNAME}"
  WriteRegStr HKCU "${UNINSTKEY}" "DisplayIcon" "$INSTDIR\icon.ico"
  WriteRegStr HKCU "${UNINSTKEY}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKCU "${UNINSTKEY}" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKCU "${UNINSTKEY}" "NoModify" 1
  WriteRegDWORD HKCU "${UNINSTKEY}" "NoRepair" 1
  WriteUninstaller "$INSTDIR\uninstall.exe"
SectionEnd

Function LaunchApp
  Exec '"$SYSDIR\wscript.exe" "$INSTDIR\open.vbs"'
FunctionEnd

Section "Uninstall"
  Delete "$DESKTOP\${APPNAME}.lnk"
  RMDir /r "$SMPROGRAMS\${APPNAME}"
  Delete "$INSTDIR\icon.ico"
  Delete "$INSTDIR\open.vbs"
  Delete "$INSTDIR\change-server.vbs"
  Delete "$INSTDIR\check.vbs"
  Delete "$INSTDIR\README.txt"
  Delete "$INSTDIR\server.txt"
  Delete "$INSTDIR\uninstall.exe"
  RMDir "$INSTDIR"
  DeleteRegKey HKCU "${UNINSTKEY}"
SectionEnd
