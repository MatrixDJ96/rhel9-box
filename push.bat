@echo off

cd /d "%~dp0"

title Uploading RHEL9...
echo Uploading RHEL9...
wsl -d Ubuntu -u root ./config/extra/env_toolkit.sh --docker-push

if "%SKIP_PAUSE%" == "1" goto :end

title Done
echo Done

pause
exit /b %errorlevel%

:end
