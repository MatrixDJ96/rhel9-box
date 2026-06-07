@echo off

:: https://superuser.com/questions/788924/is-it-possible-to-automatically-run-a-batch-file-as-administrator
:-------------------------------------
REM --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------

cd /d "%~dp0"

title Installing virtual hosts...
echo Installing virtual hosts...

type C:\Windows\System32\drivers\etc\hosts>config\tmp_host

wsl -d RHEL9 sudo bash /vagrant/config/extra/install_virtualhosts.sh

type config\tmp_host>C:\Windows\System32\drivers\etc\hosts
del config\tmp_host>NUL 2>&1

if defined SKIP_PAUSE goto :end

title Done
echo Done

pause
exit /b %errorlevel%

:end
