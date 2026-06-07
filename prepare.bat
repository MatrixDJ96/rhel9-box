@echo off

cd /d "%~dp0"

setlocal enabledelayedexpansion

if not defined SKIP_PREPARE (
    set /P "SKIP=Do you want to skip prepare? [y/N] "
    if /I "!SKIP!"=="Y" set "SKIP_PREPARE=1"
)

if "%SKIP_PREPARE%" == "1" goto :end

set "TMP_FILE=%temp%\wsl.txt"
set "UBUNTU_INSTALLED=0"

wsl -l -q > "%TMP_FILE%"
more < "%TMP_FILE%" | findstr /I /X "Ubuntu" >nul
if not errorlevel 1 set "UBUNTU_INSTALLED=1"
del "%TMP_FILE%" >nul 2>&1

if "%UBUNTU_INSTALLED%" == "0" (
    title Installing Ubuntu...
    echo Installing Ubuntu...
    wsl --install -d Ubuntu -n
)

title Configuring Ubuntu...
echo Configuring Ubuntu...
wsl -d Ubuntu -u root ./config/extra/env_toolkit.sh --docker-install
wsl --terminate Ubuntu

if "%SKIP_PAUSE%" == "1" goto :end

title Done
echo Done

pause
exit /b %errorlevel%

:end
