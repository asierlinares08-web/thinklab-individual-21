@echo off
rem P14b · copia de las carpetas del usuario a TrueNAS (SMB). Uso: copia-win.bat <recurso> <contraseña SMB>
set R=\\192.168.21.20\%1
net use %R% %2 /user:asier /persistent:no >nul || (echo ERROR: no conecta con %R% & exit /b 1)
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HHmm"') do set F=%%i
echo [%time%] Inicio copia de %USERPROFILE% en %R%\%F%
for %%d in (Desktop Documents Pictures) do robocopy "%USERPROFILE%\%%d" "%R%\%F%\%%d" /E /R:1 /W:1 /NP /NDL /NFL /XJ /XF desktop.ini | findstr /R /C:"Dirs :" /C:"Files :" /C:"Bytes :" /C:"Times :" /C:"Origen" /C:"Source"
echo [%time%] Fin
dir /s /-c "%R%\%F%" | findstr /C:"archivos" /C:"File(s)"
net use %R% /delete >nul
