@echo off
setlocal EnableDelayedExpansion
echo Spoofing MAC addresses...

:: Loop through all physical, enabled adapters
for /f "tokens=2 delims=," %%A in ('wmic nic where "PhysicalAdapter=True and NetEnabled=True" get Name /format:csv ^| findstr /R /C:"[^,]*,.*"') do (
    set "adapter=%%A"
    echo Found: !adapter!

    :: Search registry for the adapter name
    for /f "tokens=*" %%K in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}" /s /f "%%A" ^| findstr /I "HKEY"') do (
        set "regkey=%%K"
        echo Registry Key: !regkey!

        :: Generate a valid random MAC (starts with even number)
        set /a n1=(%random% %% 128) * 2
        set /a n2=%random% %% 256
        set /a n3=%random% %% 256
        set /a n4=%random% %% 256
        set /a n5=%random% %% 256
        set /a n6=%random% %% 256

        call :tohex !n1! h1
        call :tohex !n2! h2
        call :tohex !n3! h3
        call :tohex !n4! h4
        call :tohex !n5! h5
        call :tohex !n6! h6

        set "macspoof=!h1!!h2!!h3!!h4!!h5!!h6!"
        echo Spoofed MAC: !macspoof!

        reg add "!regkey!" /v NetworkAddress /d !macspoof! /f >nul 2>&1

        :: Disable and enable the adapter to apply change
        wmic path win32_networkadapter where "Name='!adapter!'" call disable >nul 2>&1
        timeout /t 1 >nul
        wmic path win32_networkadapter where "Name='!adapter!'" call enable >nul 2>&1
    )
)

exit /b

:tohex
setlocal
set /a val=%1
set "hex=0123456789ABCDEF"
set /a hi=val / 16
set /a lo=val %% 16
set "h1=!hex:~%hi%,1!"
set "h2=!hex:~%lo%,1!"
endlocal & set "%2=%h1%%h2%"
exit /b
