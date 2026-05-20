@echo off&mode 80,25&title AnyDesk ID Changer
IF not "%1"=="am_admin" (powershell start -verb runas '%0' am_admin & exit /B)
IF not exist "C:\Program Files (x86)\AnyDesk\AnyDesk.exe" echo [-] Anydesk is not installed&timeout /t 99999 /nobreak>NUL
IF not exist "C:\ProgramData\AnyDesk\service.conf" echo [-] Open AnyDesk and try again&timeout /t 99999 /nobreak>NUL
IF not exist "C:\ProgramData\AnyDesk\system.conf" echo [-] Open AnyDesk and try again&timeout /t 99999 /nobreak>NUL
tasklist /fi "ImageName eq AnyDesk.exe" /FO csv 2>NUL | find /I "AnyDesk.exe">NUL 2>&1
IF "%ERRORLEVEL%"=="0" taskkill /F /T /IM AnyDesk.exe>NUL 2>&1
echo [*] Terminating AnyDesk
<"C:\ProgramData\AnyDesk\system.conf" find "ad.anynet.id=">"%temp%anydesk.txt"
echo [*] Setting variables
for /F "delims=" %%x in ("%temp%anydesk.txt") do set anydesk=%%x
set /P anycode=<%anydesk%
powershell -Command "(gc C:\ProgramData\AnyDesk\system.conf) -replace '%anycode%', '' | Out-File -encoding ASCII C:\ProgramData\AnyDesk\system.conf"
echo [*] Removing Old Code
taskkill /F /T /IM AnyDesk.exe>NUL 2>&1
del /F /Q "C:\ProgramData\AnyDesk\system.conf">NUL 2>&1
del /F /Q "C:\ProgramData\AnyDesk\service.conf">NUL 2>&1
del /F /Q "%anydesk%">NUL 2>&1
echo [*] Cleaning Junk
set "ANYDESK_USER_DATA=%APPDATA%\AnyDesk"
if exist "%ANYDESK_USER_DATA%" (
    echo [*] Cleaning user data folder: %ANYDESK_USER_DATA%
    for /f "delims=" %%i in ('dir /b /a "%ANYDESK_USER_DATA%" 2^>nul') do (
        if /i not "%%i"=="user.conf" (
            if /i not "%%i"=="thumbnails" (
                rd /s /q "%ANYDESK_USER_DATA%\%%i" 2>nul
                del /f /q "%ANYDESK_USER_DATA%\%%i" 2>nul
            )
        )
    )
    echo [*] Preserved: user.conf and thumbnails folder
) else (
    echo [-] %ANYDESK_USER_DATA% not found
)
echo [+] Succesfully changed AnyDesk ID&start C:\"Program Files (x86)"\AnyDesk\AnyDesk.exe&timeout /t 10 /nobreak>NUL&exit /B