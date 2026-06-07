@echo off

cd /d "%~dp0"

title Exporting RHEL9...
echo Exporting RHEL9...

if "%~1" == "--docker-wsl" (
    wsl -d Ubuntu -u root ./config/extra/env_toolkit.sh --docker-export --wsl
) else if "%~1" == "--docker" (
    wsl -d Ubuntu -u root ./config/extra/env_toolkit.sh --docker-export
) else (
    wsl --export RHEL9 RHEL9.wsl --format tar.gz
)

if "%SKIP_PAUSE%" == "1" goto :end

title Done
echo Done

pause
exit /b %errorlevel%

:end
