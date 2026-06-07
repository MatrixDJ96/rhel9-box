@echo off

cd /d "%~dp0"

setlocal
    set SKIP_PREPARE=0
    set SKIP_PAUSE=1
    call prepare.bat
endlocal

title Downloading RHEL9...
echo Downloading RHEL9...
wsl -d Ubuntu -u root ./config/extra/env_toolkit.sh --docker-pull

if "%SKIP_PAUSE%" == "1" goto :end

title Done
echo Done

pause
exit /b %errorlevel%

:end
