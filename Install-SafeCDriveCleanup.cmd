@echo off
setlocal EnableExtensions

set "APP_NAME=SafeCDriveCleanup"
set "INSTALL_DIR=%LOCALAPPDATA%\Programs\%APP_NAME%"
set "START_MENU=%APPDATA%\Microsoft\Windows\Start Menu\Programs\%APP_NAME%"
set "SCRIPT_SRC=%~dp0SafeCDriveCleanup.ps1"

if not exist "%SCRIPT_SRC%" (
  echo Cannot find SafeCDriveCleanup.ps1 next to this installer.
  pause
  exit /b 1
)

mkdir "%INSTALL_DIR%" >nul 2>nul
mkdir "%START_MENU%" >nul 2>nul

copy /y "%SCRIPT_SRC%" "%INSTALL_DIR%\SafeCDriveCleanup.ps1" >nul

(
  echo @echo off
  echo powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%%LOCALAPPDATA%%\Programs\%APP_NAME%\SafeCDriveCleanup.ps1"
) > "%INSTALL_DIR%\Run Safe C Drive Cleanup.cmd"

(
  echo @echo off
  echo powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%%LOCALAPPDATA%%\Programs\%APP_NAME%\SafeCDriveCleanup.ps1" -DryRun
) > "%INSTALL_DIR%\Preview Safe C Drive Cleanup.cmd"

(
  echo @echo off
  echo rmdir /s /q "%%LOCALAPPDATA%%\Programs\%APP_NAME%%"
  echo del /q "%%APPDATA%%\Microsoft\Windows\Start Menu\Programs\%APP_NAME%\*.lnk" 2^>nul
  echo rmdir "%%APPDATA%%\Microsoft\Windows\Start Menu\Programs\%APP_NAME%" 2^>nul
) > "%INSTALL_DIR%\Uninstall Safe C Drive Cleanup.cmd"

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ws=New-Object -ComObject WScript.Shell; $s=$ws.CreateShortcut('%START_MENU%\Run Safe C Drive Cleanup.lnk'); $s.TargetPath='%INSTALL_DIR%\Run Safe C Drive Cleanup.cmd'; $s.WorkingDirectory='%INSTALL_DIR%'; $s.Save(); $s=$ws.CreateShortcut('%START_MENU%\Preview Safe C Drive Cleanup.lnk'); $s.TargetPath='%INSTALL_DIR%\Preview Safe C Drive Cleanup.cmd'; $s.WorkingDirectory='%INSTALL_DIR%'; $s.Save(); $s=$ws.CreateShortcut('%START_MENU%\Uninstall Safe C Drive Cleanup.lnk'); $s.TargetPath='%INSTALL_DIR%\Uninstall Safe C Drive Cleanup.cmd'; $s.WorkingDirectory='%INSTALL_DIR%'; $s.Save()"

echo.
echo Installed to:
echo %INSTALL_DIR%
echo.
echo Start menu shortcuts have been created under:
echo %START_MENU%
echo.
choice /c YN /m "Run cleanup now"
if errorlevel 2 goto done
call "%INSTALL_DIR%\Run Safe C Drive Cleanup.cmd"

:done
echo.
echo Done.
pause
