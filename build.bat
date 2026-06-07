@echo off

cd /d "%~dp0"

setlocal enabledelayedexpansion

if not defined SKIP_BUILD (
    set /P "SKIP=Do you want to skip build? [y/N] "
    if /I "!SKIP!"=="Y" set "SKIP_BUILD=1"
)

if "%SKIP_BUILD%" == "1" goto :end

setlocal
    set SKIP_PREPARE=0
    set SKIP_PAUSE=1
    call prepare.bat
endlocal

title Building RHEL9...
echo Building RHEL9...
wsl -d Ubuntu -u root ./config/extra/env_toolkit.sh --docker-build

if "%SKIP_PAUSE%" == "1" goto :end

title Done
echo Done

pause
exit /b %errorlevel%

:end
