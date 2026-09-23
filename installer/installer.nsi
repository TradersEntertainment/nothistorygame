; Gerçek Tarih Bu Değil — Windows kurulum programı (NSIS 3)
; Derleme:  makensis -DVERSION=0.1.0 -DSRC=..\build\windows -DOUT=..\build\Setup.exe installer.nsi
; Yönetici izni istemez; kullanıcının kendi klasörüne kurar.

Unicode true
!include "MUI2.nsh"

!ifndef VERSION
  !define VERSION "0.1.0"
!endif
!ifndef SRC
  !define SRC "..\build\windows"
!endif
!ifndef OUT
  !define OUT "..\build\GercekTarihBuDegil-Setup-${VERSION}.exe"
!endif

!define APPNAME "Gerçek Tarih Bu Değil"
!define EXENAME "GercekTarihBuDegil.exe"
!define REGKEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\GercekTarihBuDegil"

Name "${APPNAME}"
OutFile "${OUT}"
InstallDir "$LOCALAPPDATA\Programs\GercekTarihBuDegil"
InstallDirRegKey HKCU "Software\GercekTarihBuDegil" "InstallDir"
RequestExecutionLevel user
SetCompressor /SOLID lzma
BrandingText "TradersEntertainment · ${VERSION}"

VIProductVersion "${VERSION}.0"
VIAddVersionKey "ProductName" "${APPNAME}"
VIAddVersionKey "FileDescription" "${APPNAME} kurulumu"
VIAddVersionKey "FileVersion" "${VERSION}"
VIAddVersionKey "CompanyName" "TradersEntertainment"
VIAddVersionKey "LegalCopyright" "TradersEntertainment"

!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TITLE "${APPNAME}"
!define MUI_WELCOMEPAGE_TEXT "Bu oyun gerçek tarih değildir.$\r$\n...ama biraz öyle.$\r$\n$\r$\nKurulum, oyunu bilgisayarına kuracak ve masaüstüne bir kısayol ekleyecek. Yönetici izni gerekmez.$\r$\n$\r$\nDevam etmek için İleri'ye tıkla."
!define MUI_FINISHPAGE_RUN "$INSTDIR\${EXENAME}"
!define MUI_FINISHPAGE_RUN_TEXT "Oyunu şimdi başlat"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "Turkish"
!insertmacro MUI_LANGUAGE "English"

Section "Oyun" SecMain
  SetOutPath "$INSTDIR"
  File "${SRC}\${EXENAME}"
  File "OYNA.txt"
  WriteUninstaller "$INSTDIR\Kaldir.exe"

  CreateDirectory "$SMPROGRAMS\${APPNAME}"
  CreateShortcut "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk" "$INSTDIR\${EXENAME}"
  CreateShortcut "$SMPROGRAMS\${APPNAME}\Kaldır.lnk" "$INSTDIR\Kaldir.exe"
  CreateShortcut "$DESKTOP\${APPNAME}.lnk" "$INSTDIR\${EXENAME}"

  WriteRegStr HKCU "Software\GercekTarihBuDegil" "InstallDir" "$INSTDIR"
  WriteRegStr HKCU "${REGKEY}" "DisplayName" "${APPNAME}"
  WriteRegStr HKCU "${REGKEY}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKCU "${REGKEY}" "Publisher" "TradersEntertainment"
  WriteRegStr HKCU "${REGKEY}" "DisplayIcon" "$INSTDIR\${EXENAME}"
  WriteRegStr HKCU "${REGKEY}" "UninstallString" "$\"$INSTDIR\Kaldir.exe$\""
  WriteRegDWORD HKCU "${REGKEY}" "NoModify" 1
  WriteRegDWORD HKCU "${REGKEY}" "NoRepair" 1
SectionEnd

Section "Uninstall"
  Delete "$INSTDIR\${EXENAME}"
  Delete "$INSTDIR\OYNA.txt"
  Delete "$INSTDIR\Kaldir.exe"
  RMDir "$INSTDIR"
  Delete "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk"
  Delete "$SMPROGRAMS\${APPNAME}\Kaldır.lnk"
  RMDir "$SMPROGRAMS\${APPNAME}"
  Delete "$DESKTOP\${APPNAME}.lnk"
  DeleteRegKey HKCU "${REGKEY}"
  DeleteRegKey HKCU "Software\GercekTarihBuDegil"
SectionEnd
