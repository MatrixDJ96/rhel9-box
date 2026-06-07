@echo off

cd /d "%~dp0"

set SKIP_PAUSE=1
set SKIP_PREPARE=0

call pull.bat

call export.bat --docker-wsl
call import.bat --wsl-provision

call install_virtualhosts.bat
call install_ssh_key.bat

title Done
echo Done

pause
exit /b %errorlevel%
