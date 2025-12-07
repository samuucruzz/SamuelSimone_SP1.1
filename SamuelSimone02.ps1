# ESCRITO POR ALUMNO
# Definición de parámetros para el script
param(
    [string]$G,      # Parámetro para crear grupos
    [string]$U,      # Parámetro para crear usuarios
    [string]$M,      # Parámetro para modificar usuarios
    [string]$AG,     # Parámetro para asignar usuarios a grupos
    [string]$LIST,   # Parámetro para listar objetos
    [switch]$S,      # Switch para tipo Security
    [switch]$D,      # Switch para tipo Distribution
    [string]$OU,     # Ruta de la Unidad Organizativa
    [string]$Estado, # Estado de la cuenta (Enabled/Disabled)
    [string]$Grupo,  # Nombre del grupo
    [string]$Filtro  # Filtro por OU
)

# ESCRITO POR ALUMNO
# Importar el módulo para trabajar con Active Directory
Import-Module ActiveDirectory

# ESCRITO POR ALUMNO
# Sistema de ayuda - Mostrar información si no se pasa ningún parámetro
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

# ============================================
# SECCIÓN: CREAR GRUPO
# ============================================
# ESCRITO POR ALUMNO
if ($G) {
    Write-Host "=== CREAR GRUPO ===" -ForegroundColor Cyan
    
    # Pedir el nombre del grupo al usuario
    $nombre = Read-Host "Nombre del grupo"
    
    # BLOQUE GENERADO POR IA (solo esta verificación)
    # Comprobar si el grupo ya existe
    $existe = Get-ADGroup -Filter "Name -eq '$nombre'" -ErrorAction SilentlyContinue
    if ($existe) {
        Write-Host "ERROR: El grupo ya existe" -ForegroundColor Red
        exit
    }
    
    # ESCRITO POR ALUMNO
    # Determinar el ámbito según el parámetro G, U o L
    $ambito = "Global"
    if ($G -eq "U") { $ambito = "Universal" }
    if ($G -eq "L") { $ambito = "DomainLocal" }
    
    # Determinar el tipo de grupo (Security o Distribution)
    $tipo = "Security"
    if ($D) { $tipo = "Distribution" }
    
    # Crear el grupo en Active Directory
    try {
        New-ADGroup -Name $nombre -GroupScope $ambito -GroupCategory $tipo
        Write-Host "Grupo creado: $nombre" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: No se pudo crear" -ForegroundColor Red
    }
}

# ============================================
# SECCIÓN: CREAR USUARIO
# ============================================
# ESCRITO POR ALUMNO
if ($U) {
    Write-Host "=== CREAR USUARIO ===" -ForegroundColor Cyan
    
    # BLOQUE GENERADO POR IA (solo esta verificación)
    # Verificar si el usuario ya existe
    $existe = Get-ADUser -Filter "SamAccountName -eq '$U'" -ErrorAction SilentlyContinue
    if ($existe) {
        Write-Host "ERROR: El usuario ya existe" -ForegroundColor Red
        exit
    }
    
    # ESCRITO POR ALUMNO
    # Generar contraseña aleatoria de 10 caracteres
    $chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    $pass = ""
    # Bucle para crear la contraseña caracter por caracter
    for ($i = 1; $i -le 10; $i++) {
        $pass += $chars[(Get-Random -Maximum $chars.Length)]
    }
    # Convertir a formato seguro para Active Directory
    $passSegura = ConvertTo-SecureString $pass -AsPlainText -Force
    
    # ESCRITO POR ALUMNO
    # Crear el usuario con o sin OU
    try {
        if ($OU) {
            # Si hay OU, crear el usuario en esa ubicación
            New-ADUser -Name $U -SamAccountName $U -AccountPassword $passSegura -Enabled $true -Path $OU
        } else {
            # Si no hay OU, crear en la ubicación por defecto
            New-ADUser -Name $U -SamAccountName $U -AccountPassword $passSegura -Enabled $true
        }
        Write-Host "Usuario creado: $U" -ForegroundColor Green
        Write-Host "Contraseña: $pass" -ForegroundColor Yellow
    } catch {
        Write-Host "ERROR: No se pudo crear" -ForegroundColor Red
    }
}

# ============================================
# SECCIÓN: MODIFICAR USUARIO
# ============================================
# ESCRITO POR ALUMNO
if ($M) {
    Write-Host "=== MODIFICAR USUARIO ===" -ForegroundColor Cyan
    
    # Preguntar qué usuario se quiere modificar
    $nombre = Read-Host "Nombre del usuario"
    
    # BLOQUE GENERADO POR IA (solo esta verificación)
    # Verificar que el usuario existe
    $existe = Get-ADUser -Filter "SamAccountName -eq '$nombre'" -ErrorAction SilentlyContinue
    if (!$existe) {
        Write-Host "ERROR: El usuario no existe" -ForegroundColor Red
        exit
    }
    
    # ESCRITO POR ALUMNO
    # Validar que la contraseña tenga al menos 8 caracteres
    if ($M.Length -lt 8) {
        Write-Host "ERROR: Mínimo 8 caracteres" -ForegroundColor Red
        exit
    }
    
    # AYUDA DE IA (regex patterns)
    # Validar complejidad de la contraseña
    $tieneMayuscula = $M -cmatch '[A-Z]'
    $tieneMinuscula = $M -cmatch '[a-z]'
    $tieneNumero = $M -match '\d'
    $tieneEspecial = $M -match '[^a-zA-Z0-9]'
    
    # ESCRITO POR ALUMNO
    # Comprobar que cumple los requisitos de complejidad
    if (!$tieneMayuscula -or !$tieneMinuscula -or !$tieneNumero) {
        Write-Host "ERROR: La contraseña debe incluir mayúscula, minúscula y número" -ForegroundColor Red
        exit
    }
    
    # ESCRITO POR ALUMNO
    # Cambiar la contraseña del usuario
    try {
        $passSegura = ConvertTo-SecureString $M -AsPlainText -Force
        Set-ADAccountPassword -Identity $nombre -NewPassword $passSegura -Reset
        Write-Host "Contraseña cambiada" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: No se pudo cambiar la contraseña" -ForegroundColor Red
    }
    
    # Cambiar el estado de la cuenta según el parámetro
    if ($Estado -eq "Enabled") {
        Enable-ADAccount -Identity $nombre
        Write-Host "Cuenta habilitada" -ForegroundColor Green
    }
    if ($Estado -eq "Disabled") {
        Disable-ADAccount -Identity $nombre
        Write-Host "Cuenta deshabilitada" -ForegroundColor Yellow
    }
}

# ============================================
# SECCIÓN: ASIGNAR USUARIO A GRUPO
# ============================================
# ESCRITO POR ALUMNO
if ($AG) {
    Write-Host "=== ASIGNAR A GRUPO ===" -ForegroundColor Cyan
    
    # BLOQUE GENERADO POR IA (solo las verificaciones)
    # Verificar que el usuario existe
    $usuarioExiste = Get-ADUser -Filter "SamAccountName -eq '$AG'" -ErrorAction SilentlyContinue
    if (!$usuarioExiste) {
        Write-Host "ERROR: El usuario no existe" -ForegroundColor Red
        exit
    }
    
    # Verificar que el grupo existe
    $grupoExiste = Get-ADGroup -Filter "Name -eq '$Grupo'" -ErrorAction SilentlyContinue
    if (!$grupoExiste) {
        Write-Host "ERROR: El grupo no existe" -ForegroundColor Red
        exit
    }
    
    # ESCRITO POR ALUMNO
    # Asignar el usuario al grupo
    try {
        Add-ADGroupMember -Identity $Grupo -Members $AG
        Write-Host "Usuario asignado al grupo" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: No se pudo asignar" -ForegroundColor Red
    }
}

# ============================================
# SECCIÓN: LISTAR OBJETOS
# ============================================
# ESCRITO POR ALUMNO
if ($LIST) {
    Write-Host "=== LISTADO ===" -ForegroundColor Cyan
    
    # LISTAR USUARIOS
    if ($LIST -eq "Usuarios") {
        Write-Host "--- USUARIOS ---" -ForegroundColor Green
        
        # Aplicar filtro por OU si existe
        if ($Filtro) {
            Write-Host "Filtrando por OU: $Filtro" -ForegroundColor Yellow
            $usuarios = Get-ADUser -Filter * -SearchBase $Filtro -Properties Name, SamAccountName
        } else {
            $usuarios = Get-ADUser -Filter * -Properties Name, SamAccountName
        }
        
        # Mostrar todos los usuarios encontrados
        if ($usuarios.Count -gt 0) {
            # AYUDA DE IA (uso de ForEach-Object con pipeline)
            $usuarios | ForEach-Object {
                Write-Host "  - $($_.SamAccountName) - $($_.Name)"
            }
        } else {
            Write-Host "  No se encontraron usuarios" -ForegroundColor Yellow
        }
        Write-Host "Total: $($usuarios.Count)" -ForegroundColor Cyan
    }
    
    # LISTAR GRUPOS
    # ESCRITO POR ALUMNO
    if ($LIST -eq "Grupos") {
        Write-Host "--- GRUPOS ---" -ForegroundColor Green
        
        # Aplicar filtro si se especificó
        if ($Filtro) {
            Write-Host "Filtrando por OU: $Filtro" -ForegroundColor Yellow
            $grupos = Get-ADGroup -Filter * -SearchBase $Filtro
        } else {
            $grupos = Get-ADGroup -Filter *
        }
        
        # Mostrar los grupos
        if ($grupos.Count -gt 0) {
            # AYUDA DE IA (ForEach-Object)
            $grupos | ForEach-Object {
                Write-Host "  - $($_.Name)"
            }
        } else {
            Write-Host "  No se encontraron grupos" -ForegroundColor Yellow
        }
        Write-Host "Total: $($grupos.Count)" -ForegroundColor Cyan
    }
    
    # LISTAR AMBOS (USUARIOS Y GRUPOS)
    # ESCRITO POR ALUMNO
    if ($LIST -eq "Ambos") {
        # Obtener usuarios y grupos con o sin filtro
        if ($Filtro) {
            Write-Host "Filtrando por OU: $Filtro" -ForegroundColor Yellow
            $usuarios = Get-ADUser -Filter * -SearchBase $Filtro -Properties Name, SamAccountName
            $grupos = Get-ADGroup -Filter * -SearchBase $Filtro
        } else {
            $usuarios = Get-ADUser -Filter * -Properties Name, SamAccountName
            $grupos = Get-ADGroup -Filter *
        }
        
        # Mostrar usuarios
        Write-Host "--- USUARIOS ---" -ForegroundColor Green
        if ($usuarios.Count -gt 0) {
            $usuarios | ForEach-Object {
                Write-Host "  - $($_.SamAccountName) - $($_.Name)"
            }
        }
        
        # Mostrar grupos
        Write-Host ""
        Write-Host "--- GRUPOS ---" -ForegroundColor Green
        if ($grupos.Count -gt 0) {
            $grupos | ForEach-Object {
                Write-Host "  - $($_.Name)"
            }
        }
    }
}

# ESCRITO POR ALUMNO
# Mensaje de finalización del script
Write-Host ""
Write-Host "Fin" -ForegroundColor Cyan
