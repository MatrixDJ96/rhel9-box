@echo off

cd /d "%~dp0"

if "%~1" == "--docker" (
    goto :import
)

set "IMPORT_DIR=%APPDATA%/WSL/RHEL9"
if not exist "%IMPORT_DIR%" (
    mkdir "%IMPORT_DIR%"
)

title Cleaning system...
echo Cleaning system...
wsl --unregister RHEL9

:import

title Importing RHEL9...
echo Importing RHEL9...
if "%~1" == "--docker" (
    wsl -d Ubuntu -u root ./config/extra/env_toolkit.sh --docker-import
) else (
    wsl --import RHEL9 "%IMPORT_DIR%" RHEL9.wsl

    title Configuring RHEL9...
    echo Configuring RHEL9...
    wsl -d RHEL9 ./config/extra/env_toolkit.sh --root --wsl-configure

    if "%~1" == "--wsl-provision" (
        title Provisioning RHEL9...
        echo Provisioning RHEL9...
        wsl -d RHEL9 ./config/extra/env_toolkit.sh --root --wsl-provision
    )

    wsl --set-default RHEL9
    wsl --terminate RHEL9
)

:pause

if "%SKIP_PAUSE%" == "1" goto :end

title Done
echo Done

pause
exit /b %errorlevel%

:end
