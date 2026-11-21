# P14b · WinServer-2025: exporta la configuración (texto) y copia los datos a TrueNAS por SMB.
# Uso (como Administrador): powershell -ExecutionPolicy Bypass -File copia-winserver.ps1 <contraseña SMB de asier en TrueNAS>
param([string]$Pw)
$R = '\\192.168.21.20\winserver'
$F = Get-Date -Format 'yyyy-MM-dd_HHmm'
$T = Join-Path $env:TEMP "copia-$F"; New-Item -ItemType Directory $T | Out-Null
$ini = Get-Date
# 1) Configuración exportada en texto (se puede leer y comparar)
Get-ComputerInfo -Property OsName,OsVersion,OsBuildNumber,CsName,TimeZone | Out-File "$T\sistema.txt"
Get-WindowsFeature | Where-Object Installed | Select-Object Name,DisplayName | Export-Csv "$T\roles-instalados.csv" -NoTypeInformation -Encoding UTF8
Get-NetIPConfiguration | Out-File "$T\red.txt"
Get-DnsClientServerAddress -AddressFamily IPv4 | Out-File -Append "$T\red.txt"
Get-LocalUser | Select-Object Name,Enabled,Description | Export-Csv "$T\usuarios.csv" -NoTypeInformation -Encoding UTF8
Get-LocalGroupMember Administradores | Select-Object Name | Export-Csv "$T\administradores.csv" -NoTypeInformation -Encoding UTF8
Get-SmbShare | Select-Object Name,Path,Description | Export-Csv "$T\recursos-compartidos.csv" -NoTypeInformation -Encoding UTF8
Get-WinUserLanguageList | Out-File "$T\idioma-teclado.txt"
secedit /export /cfg "$T\directivas-seguridad.inf" /areas SECURITYPOLICY | Out-Null
# 2) Copia a TrueNAS: la configuración + los datos de los usuarios (Documentos y Escritorio)
net use $R $Pw /user:asier /persistent:no | Out-Null
robocopy $T "$R\$F\configuracion" /E /R:1 /W:1 /NP /NFL /NDL /NJH /NJS | Out-Null
foreach ($u in 'Administrador','asier') {
  foreach ($d in 'Documents','Desktop') {
    if (Test-Path "C:\Users\$u\$d") { robocopy "C:\Users\$u\$d" "$R\$F\usuarios\$u\$d" /E /R:1 /W:1 /NP /NFL /NDL /NJH /NJS /XJ /XF desktop.ini | Out-Null }
  }
}
$n = (Get-ChildItem "$R\$F" -Recurse -File | Measure-Object -Sum Length)
"Copia $R\$F : $($n.Count) ficheros, $($n.Sum) bytes, $([int]((Get-Date)-$ini).TotalSeconds) s"
Get-ChildItem "$R\$F" -Recurse -File | ForEach-Object { $_.FullName.Replace("$R\$F\",'') + "  ($($_.Length) B)" }
net use $R /delete | Out-Null
Remove-Item $T -Recurse -Force
