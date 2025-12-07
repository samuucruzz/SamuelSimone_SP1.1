param(
    [string]$G,
    [string]$U,
    [string]$M,
    [string]$AG,
    [string]$LIST,
    [switch]$S,
    [switch]$D,
    [string]$OU,
    [string]$Estado,
    [string]$Grupo,
    [string]$Filtro
)

# Importar módulo de Active Directory
Import-Module ActiveDirectory

# Si no hay parámetros, mostrar ayuda
if (!$G -and !$U -and !$M -and !$AG -and !$LIST) {
    Write-Host "=== AYUDA ===" -ForegroundColor Cyan
    Write-Host "Uso: .\nombre02.ps1 -Accion valor1 valor2"
    Write-Host ""
    Write-Host "Acciones:"
    Write-Host "  -G    Crear grupo"
    Write-Host "        -G [G/U/L] -S/-D"
    Write-Host ""
    Write-Host "  -U    Crear usuario"
    Write-Host "        -U [nombre] (opcional: -OU [ruta])"
    Write-Host ""
    Write-Host "  -M    Modificar usuario"
    Write-Host "        -M [contraseña] -Estado [Enabled/Disabled]"
    Write-Host ""
    Write-Host "  -AG   Asignar usuario a grupo"
    Write-Host "        -AG [usuario] -Grupo [nombre]"
    Write-Host ""
    Write-Host "  -LIST Listar Usuarios / Grupos / Ambos"
    Write-Host "        Ejemplo: .\script.ps1 -LIST Grupos"
    exit
}

# CREAR GRUPO
if ($G) {
    Write-Host "=== CREAR GRUPO ===" -ForegroundColor Cyan
    $nombre = Read-Host "Nombre del grupo"
    
    $existe = Get-ADGroup -Filter "Name -eq '$nombre'" -ErrorAction SilentlyContinue
    if ($existe) {
        Write-Host "ERROR: El grupo ya existe" -ForegroundColor Red
        exit
    }
    
    $ambito = "Global"
    if ($G -eq "U") { $ambito = "Universal" }
    if ($G -eq "L") { $ambito = "DomainLocal" }
    
    $tipo = "Security"
    if ($D) { $tipo = "Distribution" }
    
    try {
        New-ADGroup -Name $nombre -GroupScope $ambito -GroupCategory $tipo
        Write-Host "Grupo creado: $nombre" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: No se pudo crear" -ForegroundColor Red
    }
}

# CREAR USUARIO
if ($U) {
    Write-Host "=== CREAR USUARIO ===" -ForegroundColor Cyan
    
    $existe = Get-ADUser -Filter "SamAccountName -eq '$U'" -ErrorAction SilentlyContinue
    if ($existe) {
        Write-Host "ERROR: El usuario ya existe" -ForegroundColor Red
        exit
    }
    
    $chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    $pass = ""
    for ($i = 1; $i -le 10; $i++) {
        $pass += $chars[(Get-Random -Maximum $chars.Length)]
    }
    $passSegura = ConvertTo-SecureString $pass -AsPlainText -Force
    
    try {
        if ($OU) {
            New-ADUser -Name $U -SamAccountName $U -AccountPassword $passSegura -Enabled $true -Path $OU
        } else {
            New-ADUser -Name $U -SamAccountName $U -AccountPassword $passSegura -Enabled $true
        }
        Write-Host "Usuario creado: $U" -ForegroundColor Green
        Write-Host "Contraseña: $pass" -ForegroundColor Yellow
    } catch {
        Write-Host "ERROR: No se pudo crear" -ForegroundColor Red
    }
}

# MODIFICAR USUARIO
if ($M) {
    Write-Host "=== MODIFICAR USUARIO ===" -ForegroundColor Cyan
    $nombre = Read-Host "Nombre del usuario"
    
    $existe = Get-ADUser -Filter "SamAccountName -eq '$nombre'" -ErrorAction SilentlyContinue
    if (!$existe) {
        Write-Host "ERROR: El usuario no existe" -ForegroundColor Red
        exit
    }
    
    if ($M.Length -lt 8) {
        Write-Host "ERROR: Mínimo 8 caracteres" -ForegroundColor Red
        exit
    }
    
    $tieneMayuscula = $M -cmatch '[A-Z]'
    $tieneMinuscula = $M -cmatch '[a-z]'
    $tieneNumero = $M -match '\d'
    $tieneEspecial = $M -match '[^a-zA-Z0-9]'
    
    if (!$tieneMayuscula -or !$tieneMinuscula -or !$tieneNumero) {
        Write-Host "ERROR: La contraseña debe incluir mayúscula, minúscula y número" -ForegroundColor Red
        exit
    }
    
    try {
        $passSegura = ConvertTo-SecureString $M -AsPlainText -Force
        Set-ADAccountPassword -Identity $nombre -NewPassword $passSegura -Reset
        Write-Host "Contraseña cambiada" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: No se pudo cambiar la contraseña" -ForegroundColor Red
    }
    
    if ($Estado -eq "Enabled") {
        Enable-ADAccount -Identity $nombre
        Write-Host "Cuenta habilitada" -ForegroundColor Green
    }
    if ($Estado -eq "Disabled") {
        Disable-ADAccount -Identity $nombre
        Write-Host "Cuenta deshabilitada" -ForegroundColor Yellow
    }
}

# ASIGNAR A GRUPO
if ($AG) {
    Write-Host "=== ASIGNAR A GRUPO ===" -ForegroundColor Cyan
    
    $usuarioExiste = Get-ADUser -Filter "SamAccountName -eq '$AG'" -ErrorAction SilentlyContinue
    if (!$usuarioExiste) {
        Write-Host "ERROR: El usuario no existe" -ForegroundColor Red
        exit
    }
    
    $grupoExiste = Get-ADGroup -Filter "Name -eq '$Grupo'" -ErrorAction SilentlyContinue
    if (!$grupoExiste) {
        Write-Host "ERROR: El grupo no existe" -ForegroundColor Red
        exit
    }
    
    try {
        Add-ADGroupMember -Identity $Grupo -Members $AG
        Write-Host "Usuario asignado al grupo" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: No se pudo asignar" -ForegroundColor Red
    }
}

# LISTAR
if ($LIST) {
    Write-Host "=== LISTADO ===" -ForegroundColor Cyan
    
    if ($LIST -eq "Usuarios") {
        Write-Host "--- USUARIOS ---" -ForegroundColor Green
        
        if ($Filtro) {
            Write-Host "Filtrando por OU: $Filtro" -ForegroundColor Yellow
            $usuarios = Get-ADUser -Filter * -SearchBase $Filtro -Properties Name, SamAccountName
        } else {
            $usuarios = Get-ADUser -Filter * -Properties Name, SamAccountName
        }
        
        if ($usuarios.Count -gt 0) {
            $usuarios | ForEach-Object {
                Write-Host "  - $($_.SamAccountName) - $($_.Name)"
            }
        } else {
            Write-Host "  No se encontraron usuarios" -ForegroundColor Yellow
        }
        Write-Host "Total: $($usuarios.Count)" -ForegroundColor Cyan
    }
    
    if ($LIST -eq "Grupos") {
        Write-Host "--- GRUPOS ---" -ForegroundColor Green
        
        if ($Filtro) {
            Write-Host "Filtrando por OU: $Filtro" -ForegroundColor Yellow
            $grupos = Get-ADGroup -Filter * -SearchBase $Filtro
        } else {
            $grupos = Get-ADGroup -Filter *
        }
        
        if ($grupos.Count -gt 0) {
            $grupos | ForEach-Object {
                Write-Host "  - $($_.Name)"
            }
        } else {
            Write-Host "  No se encontraron grupos" -ForegroundColor Yellow
        }
        Write-Host "Total: $($grupos.Count)" -ForegroundColor Cyan
    }
    
    if ($LIST -eq "Ambos") {
        if ($Filtro) {
            Write-Host "Filtrando por OU: $Filtro" -ForegroundColor Yellow
            $usuarios = Get-ADUser -Filter * -SearchBase $Filtro -Properties Name, SamAccountName
            $grupos = Get-ADGroup -Filter * -SearchBase $Filtro
        } else {
            $usuarios = Get-ADUser -Filter * -Properties Name, SamAccountName
            $grupos = Get-ADGroup -Filter *
        }
        
        Write-Host "--- USUARIOS ---" -ForegroundColor Green
        if ($usuarios.Count -gt 0) {
            $usuarios | ForEach-Object {
                Write-Host "  - $($_.SamAccountName) - $($_.Name)"
            }
        }
        
        Write-Host ""
        Write-Host "--- GRUPOS ---" -ForegroundColor Green
        if ($grupos.Count -gt 0) {
            $grupos | ForEach-Object {
                Write-Host "  - $($_.Name)"
            }
        }
    }
}

Write-Host ""
Write-Host "Fin" -ForegroundColor Cyan
