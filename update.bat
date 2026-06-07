@echo off

cd /d "%~dp0"

title Updating RHEL9...
echo Updating RHEL9...

wsl -d RHEL9 -u root ./config/extra/env_toolkit.sh --wsl-export
wsl -d RHEL9 -u root ./config/extra/env_toolkit.sh --wsl-configure

wsl --terminate RHEL9

wsl -d RHEL9 -u root bash --login /vagrant/config/provision.sh
wsl -d RHEL9 -u root ./config/extra/env_toolkit.sh --wsl-provision

wsl --terminate RHEL9

title Done
echo Done

pause
exit /b %errorlevel%
