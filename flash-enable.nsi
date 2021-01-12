; example1.nsi
;
; This script is perhaps one of the simplest NSIs you can make. All of the
; optional settings are left to their default settings. The installer simply 
; prompts the user asking them where to install, and drops a copy of example1.nsi
; there. 
;
; example2.nsi expands on this by adding a uninstaller and start menu shortcuts.

;--------------------------------

;--------------------------------
;Include Modern UI

  !include "MUI2.nsh"
  !include "nsDialogs.nsh"
  !include LogicLib.nsh
  !include x64.nsh

; The name of the installer
Name "Open Unlight Flash Enable Tool"

BrandingText " "

; The file to write
OutFile "OpenUnlight-FlashEnable-Tool.exe"

; Request application privileges for Windows Vista
RequestExecutionLevel admin

; Build Unicode installer
Unicode True

!define PRODUCT_NAME "Open Unlight Flash Enable Tool"
!define PRODUCT_VERSION "1.0"
!define PRODUCT_PUBLISHER "Open Unlight"
!define PRODUCT_WEB_SITE "https://unlight.app/"

;--------------------------------
;Interface Settings

  ;!define MUI_ICON "${NSISDIR}\Contrib\Graphics\UltraModernUI\Icon.ico"
  ;!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\UltraModernUI\UnIcon.ico"

  !define MUI_HEADERIMAGE
  !define MUI_HEADER_TRANSPARENT_TEXT
  !define MUI_HEADERIMAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Header\nsis.bmp"
  !define MUI_BGCOLOR "333333"
  !define MUI_TEXTCOLOR "FFFFFF"
  !define MUI_LICENSEPAGE_BGCOLOR "333333"
  !define MUI_INSTFILESPAGE_COLORS "FFFFFF 333333"
  !define MUI_INSTFILESPAGE_PROGRESSBAR "colored"
  
  !define MUI_PAGE_HEADER_TEXT "Open Unlight Flash Enable Tool"
  !define MUI_PAGE_HEADER_SUBTEXT "Enable Flash plugin in Chrome and Edge."
  !define MUI_FINISHPAGE_TEXT "Restart Chrome and Edge to take effect."
  !define MUI_WELCOMEPAGE_TITLE "Open Unlight Flash Enable Tool"
  !define MUI_WELCOMEPAGE_TITLE_3LINES
  !define MUI_WELCOMEPAGE_TEXT "Enable Flash plugin in Chrome and Edge.$\r$\n$\r$\nCredit: Piaf$\r$\n$\r$\nPowered by Open Unlight."

;--------------------------------

; Pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

Function .onInit
  FindWindow $0 "#32770" "" $HWNDPARENT
  GetDlgItem $0 $0 1006
  SetCtlColors $0 0xFF0000 0x00FF00
FunctionEnd

;--------------------------------

!macro writeConfig file
  !define wcUniqueID ${__LINE__}
  ClearErrors
  FileOpen $9 "${file}" w
  IfErrors 0 +2
    MessageBox MB_OK "Write mms.cfg error." 0 done_${wcUniqueID}
  FileWrite $9 "ErrorReportingEnable=1$\r$\n"
  FileWrite $9 "AllowListRootMovieOnly=1$\r$\n"
  FileWrite $9 "TraceOutputFileEnable=1$\r$\n"
  FileWrite $9 "PolicyFileLog=1$\r$\n"
  FileWrite $9 "AutoUpdateDisable=1$\r$\n"
  FileWrite $9 "EOLUninstallDisable=1$\r$\n"
  FileWrite $9 "EnableWhitelist=1$\r$\n"
  FileWrite $9 "EnableAllowList=1$\r$\n"
  FileWrite $9 "AllowListUrlPattern=*://*.unlight.app/$\r$\n"
  FileWrite $9 "AllowListUrlPattern=*://unlight.app/$\r$\n"
  FileWrite $9 "WhitelistUrlPattern=*://*.unlight.app/$\r$\n"
  FileWrite $9 "WhitelistUrlPattern=*://unlight.app/$\r$\n"
  FileWrite $9 "AllowListUrlPattern=https://*.unlight.app:443/$\r$\n"
  FileWrite $9 "AllowListUrlPattern=https://unlight.app:443/$\r$\n"
  FileWrite $9 "WhitelistUrlPattern=https://*.unlight.app:443/$\r$\n"
  FileWrite $9 "WhitelistUrlPattern=https://unlight.app:443/$\r$\n"
  FileClose $9
  DetailPrint "Create file: ${file}$\r$\n"
done_${wcUniqueID}:
  !undef wcUniqueID
!macroend

!macro makeConfig path
  !define mcUniqueID ${__LINE__}
  CreateDirectory ${path}
  IfFileExists "${path}\mms.cfg" 0 +3
    DetailPrint "Backup exist config file.$\r$\n"
    CopyFiles "${path}\mms.cfg" "${path}\mms.cfg.bak"
  !insertmacro writeConfig "${path}\mms.cfg"
  !undef mcUniqueID
!macroend

!macro copyConfig path
  !define mcUniqueID ${__LINE__}
  CreateDirectory ${path}
  IfFileExists "${path}\mms.cfg" 0 +2
    CopyFiles "${path}\mms.cfg" "${path}\mms.cfg.bak"
  CopyFiles "mms.cfg" "${path}\mms.cfg"
  !undef mcUniqueID
!macroend

Var sys32path
Var sys64path
Var chromepath
Var edgepath
Var localpath

; The stuff to install
Section "" ;No components page, name is not important

  StrCpy $sys32path "$WINDIR\System32\Macromed\Flash"
  StrCpy $sys64path "$WINDIR\SysWow64\Macromed\Flash"

  ReadRegStr $localpath HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" "Local AppData"

  StrCpy $chromepath "$localpath\Google\Chrome\User Data\Default\Pepper Data\Shockwave Flash\System"
  StrCpy $edgepath "$localpath\Microsoft\Edge\User Data\Default\Pepper Data\Shockwave Flash\System"
  
  !insertmacro makeConfig $sys32path
  
  ${If} ${RunningX64}
    ${DisableX64FSRedirection}
    !insertmacro makeConfig $sys64path
    ${EnableX64FSRedirection}
  ${EndIf}

  IfFileExists "$localpath\Google\Chrome\User Data\Default\*.*"  0 +3
    !insertmacro makeConfig $chromepath
    WriteRegDWORD HKCU "Software\Policies\Google\Chrome" "AllowOutdatedPlugins" 0x00000001

  IfFileExists "$localpath\Microsoft\Edge\User Data\Default*.*"  0 +2
    !insertmacro makeConfig $edgepath

SectionEnd ; end the section
