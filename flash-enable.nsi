; example1.nsi
;
; This script is perhaps one of the simplest NSIs you can make. All of the
; optional settings are left to their default settings. The installer simply 
; prompts the user asking them where to install, and drops a copy of example1.nsi
; there. 
;
; example2.nsi expands on this by adding a uninstaller and start menu shortcuts.

;--------------------------------

!include LogicLib.nsh
!include x64.nsh

; The name of the installer
Name "Open Unlight Flash Enable Tool"

; The file to write
OutFile "OpenUnlight-FlashEnable-Tool.exe"

; Request application privileges for Windows Vista
RequestExecutionLevel admin

; Build Unicode installer
Unicode True

; The default installation directory
InstallDir $DESKTOP\Example1

;--------------------------------

; Pages
Page license
Page instfiles

;--------------------------------

!macro makeConfig path
  CreateDirectory ${path}
  IfFileExists "${path}\mms.cfg" 0 +2
    CopyFiles "${path}\mms.cfg" "${path}\mms.cfg.bak"
  CopyFiles ".\mms.cfg" "${path}\mms.cfg"
!macroend

Var sys32path
Var sys64path
Var chromepath
Var edgepath

; The stuff to install
Section "" ;No components page, name is not important

  StrCpy $sys32path "$WINDIR\System32\Macromed\Flash"
  StrCpy $sys64path "$WINDIR\SysWow64\Macromed\Flash"
  StrCpy $chromepath "$PROFILE\AppData\Local\Google\Chrome\User Data\Default\Pepper Data\Shockwave Flash\System"
  StrCpy $edgepath "$PROFILE\AppData\Local\Microsoft\Edge\User Data\Default\Pepper Data\Shockwave Flash\System"
  
  !insertmacro makeConfig $sys32path
  
  ${If} ${RunningX64}
    !insertmacro makeConfig $sys64path
  ${EndIf}

  IfFileExists "$PROFILE\AppData\Local\Google\Chrome\User Data\Default\*.*"  0 +3
    !insertmacro makeConfig $chromepath

  IfFileExists "$PROFILE\AppData\Local\Microsoft\Edge\User Data\Default*.*"  0 +2
    !insertmacro makeConfig $edgepath

SectionEnd ; end the section

Section "" ;
  MessageBox MB_OK "Restart Chrome and Edge to take effect." 0 +1
SectionEnd
