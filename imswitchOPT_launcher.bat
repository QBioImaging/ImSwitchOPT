@echo off
setlocal EnableExtensions DisableDelayedExpansion
rem Run from the directory that should contain ImSwitchOPT, or the repo itself.
set "archive_url=https://github.com/QBioImaging/ImSwitchOPT/archive/refs/heads/master.zip"
set "download_dir="
set "project_pushed="
set "exit_code=1"
set "project_dir=%CD%\ImSwitchOPT"
for %%I in ("%CD%") do set "current_name=%%~nxI"
if /I "%current_name%"=="ImSwitchOPT" if exist "imswitch\" if exist "requirements.lock" set "project_dir=%CD%"

if exist "%project_dir%\" goto project_ready
if exist "%project_dir%" (
    echo Error: "%project_dir%" exists but is not a directory. >&2
    goto finish
)
where curl.exe >nul 2>&1
if errorlevel 1 (
    echo Error: curl must be installed first. >&2
    goto finish
)
where powershell.exe >nul 2>&1
if errorlevel 1 (
    echo Error: Windows PowerShell is required to extract the ZIP. >&2
    goto finish
)

rem Keep extraction on the same filesystem as the destination.
:choose_download_dir
set "download_candidate=%CD%\.imswitch-download.%RANDOM%.%RANDOM%"
if exist "%download_candidate%" goto choose_download_dir
mkdir "%download_candidate%"
if errorlevel 1 goto finish
set "download_dir=%download_candidate%"
echo Downloading ImSwitchOPT...
curl.exe -fL --retry 3 "%archive_url%" -o "%download_dir%\master.zip"
if errorlevel 1 goto finish
powershell.exe -NoLogo -NoProfile -NonInteractive -Command "$ErrorActionPreference = 'Stop'; Expand-Archive -LiteralPath (Join-Path $env:download_dir 'master.zip') -DestinationPath $env:download_dir"
if errorlevel 1 goto finish
move "%download_dir%\ImSwitchOPT-master" "%project_dir%" >nul
if errorlevel 1 goto finish

:project_ready
pushd "%project_dir%"
if errorlevel 1 goto finish
set "project_pushed=1"
if not exist "imswitch\" goto invalid_project
if not exist "requirements.lock" goto invalid_project

rem Prefer the project's existing environment when one is available.
if not exist ".venv\Scripts\activate.bat" goto try_launch
call ".venv\Scripts\activate.bat"
if errorlevel 1 goto finish

:try_launch
echo Trying to launch ImSwitch...
where python.exe >nul 2>&1
if errorlevel 1 goto setup
python.exe -m imswitch %*
if errorlevel 1 goto setup
set "exit_code=0"
goto finish

:setup
echo Launch failed. Setting up ImSwitch with Python 3.10...
rem WinGet's portable executable links may not be on this terminal's PATH yet.
set "PATH=%LOCALAPPDATA%\Microsoft\WinGet\Links;%ProgramFiles%\WinGet\Links;%USERPROFILE%\.local\bin;%PATH%"
where uv >nul 2>&1
if not errorlevel 1 goto install_dependencies
where winget.exe >nul 2>&1
if errorlevel 1 (
    echo Error: winget is required. Install Microsoft's App Installer and retry. >&2
    goto finish
)
winget install --id=astral-sh.uv -e
if errorlevel 1 goto finish
where uv >nul 2>&1
if errorlevel 1 (
    echo Error: uv is not on PATH. Open a new terminal and run this launcher again. >&2
    goto finish
)

:install_dependencies
uv venv --python 3.10
if errorlevel 1 goto finish
call ".venv\Scripts\activate.bat"
if errorlevel 1 goto finish
uv pip install --python "%CD%\.venv\Scripts\python.exe" -r requirements.lock
if errorlevel 1 goto finish
python.exe -m imswitch %*
set "exit_code=%ERRORLEVEL%"
goto finish

:invalid_project
echo Error: "%project_dir%" does not contain imswitch and requirements.lock. >&2

:finish
if defined project_pushed popd
if defined download_dir rmdir /s /q "%download_dir%"
endlocal & exit /b %exit_code%
