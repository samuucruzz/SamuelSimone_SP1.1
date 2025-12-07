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
    [string]$Filtro, # Filtro por OU
    [switch]$DryRun  # AÑADIDO – Modo de ejecución simulada
)

# ============================================================
# BLOQUE DRYRUN - EJECUCIÓN SIMULADA
# ============================================================
if ($DryRun) {
    Write-Host "===============================================" -ForegroundColor Yellow
    Write-Host "      MODO DRY-RUN ACTIVADO (SIMULACIÓN)" -ForegroundColor Yellow
    Write-Host " Ninguna acción real de Active Directory será ejecutada." -ForegroundColor Yellow
    Write-Host "===============================================`n" -ForegroundColor Yellow

    # -------------------------------------------
    # SIN ACCIÓN
    # -------------------------------------------
    if (!$G -and !$U -and !$M -and !$AG -and !$LIST) {
        Write-Host "(DryRun) No se especificó ninguna acción."
        Write-Host "(DryRun) Se mostraría la ayuda del script."
        Write-Host "(DryRun) Se explicarían los parámetros disponibles."
        exit
    }

    # -------------------------------------------
    # ACCIÓN: CREAR GRUPO (-G)
    # -------------------------------------------
    if ($G) {
        Write-Host "=== DRYRUN: CREAR GRUPO ==="
        Write-Host "(DryRun) Se crearía un grupo nuevo."
        Write-Host "(DryRun) Parámetro 1 (Ámbito): $G  → Global / Universal / Local"
        Write-Host "(DryRun) Parámetro 2 (Tipo):  $(if($S){'Security'}elseif($D){'Distribution'}else{'Security por defecto'})"
        Write-Host "(DryRun) Se pediría al usuario el nombre del grupo mediante Read-Host."
        Write-Host "(DryRun) Se comprobaría si el grupo YA existe antes de crearlo."
        Write-Host "(DryRun) Si no existe, se ejecutaría New-ADGroup con los parámetros definidos."
        Write-Host ""
    }

    # -------------------------------------------
    # ACCIÓN: CREAR USUARIO (-U)
    # -------------------------------------------
    if ($U) {
        Write-Host "=== DRYRUN: CREAR USUARIO ==="
        Write-Host "(DryRun) Se crearía un usuario con SamAccountName '$U'."
        Write-Host "(DryRun) Parámetro 2 (Nombre del usuario): $U"
        Write-Host "(DryRun) Parámetro 3 (OU): $(if($OU){$OU}else{'No especificada'})"
        Write-Host "(DryRun) Se comprobaría si el usuario YA existe."
        Write-Host "(DryRun) Se generaría una contraseña aleatoria de 10 caracteres."
        Write-Host "(DryRun) Se convertiría la contraseña a SecureString."
        Write-Host "(DryRun) Se ejecutaría New-ADUser en la OU indicada (o por defecto)."
        Write-Host ""
    }

    # -------------------------------------------
    # ACCIÓN: MODIFICAR USUARIO (-M)
    # -------------------------------------------
    if ($M) {
        Write-Host "=== DRYRUN: MODIFICAR USUARIO ==="
        Write-Host "(DryRun) Se modificaría el usuario indicado por Read-Host."
        Write-Host "(DryRun) Nueva contraseña propuesta: $M"
        Write-Host "(DryRun) Se comprobaría si el usuario existe en AD."
        Write-Host "(DryRun) Se validaría que la contraseña:"
        Write-Host "          - Tiene mínimo 8 caracteres"
        Write-Host "          - Contiene mayúsculas"
        Write-Host "          - Contiene minúsculas"
        Write-Host "          - Contiene números"
        Write-Host "(DryRun) Si la contraseña es válida → se cambiaría con Set-ADAccountPassword."
        Write-Host "(DryRun) También se aplicaría el estado de la cuenta (Enabled/Disabled)."
        Write-Host ""
    }

    # -------------------------------------------
    # ACCIÓN: ASIGNAR USUARIO A GRUPO (-AG)
    # -------------------------------------------
    if ($AG) {
        Write-Host "=== DRYRUN: ASIGNAR USUARIO A GRUPO ==="
        Write-Host "(DryRun) Usuario a asignar: $AG"
        Write-Host "(DryRun) Grupo destino: $Grupo"
        Write-Host "(DryRun) Se comprobaría si el usuario existe."
        Write-Host "(DryRun) Se comprobaría si el grupo existe."
        Write-Host "(DryRun) Si ambos existen → se ejecutaría Add-ADGroupMember."
        Write-Host ""
    }

    # -------------------------------------------
    # ACCIÓN: LISTAR OBJETOS (-LIST)
    # -------------------------------------------
    if ($LIST) {
        Write-Host "=== DRYRUN: LISTAR OBJETOS ==="
        Write-Host "(DryRun) Acción solicitada: $LIST"
        Write-Host "(DryRun) Parámetro 3 (Filtro OU): $(if($Filtro){$Filtro}else{'Sin filtro'})"

        switch ($LIST) {
            "Usuarios" {
                Write-Host "(DryRun) Se listarían todos los usuarios del dominio."
                Write-Host "(DryRun) Si hay filtro OU → se limitaría la búsqueda a esa unidad."
            }
            "Grupos" {
                Write-Host "(DryRun) Se listarían todos los grupos del dominio."
                Write-Host "(DryRun) Si hay filtro OU → se limitaría la búsqueda."
            }
            "Ambos" {
                Write-Host "(DryRun) Se listarían usuarios Y grupos."
                Write-Host "(DryRun) Si hay filtro OU → se limitaría la búsqueda."
            }
            default {
                Write-Host "(DryRun) Valor de LIST no reconocido."
            }
        }

        Write-Host "(DryRun) Los resultados se mostrarían formateados en pantalla."
        Write-Host ""
    }

    Write-Host "==============================================="
    Write-Host "       FIN DE SIMULACIÓN DRYRUN"
    Write-Host " No se aplicó ningún cambio en Active Directory."
    Write-Host "==============================================="
    exit
}


# ============================================================
# A PARTIR DE AQUÍ EL SCRIPT SIN DryRun
# ============================================================

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
    for ($i = 1; $i -le 10; $i++) {
        $pass += $chars[(Get-Random -Maximum $chars.Length)]
    }
    $passSegura = ConvertTo-SecureString $pass -AsPlainText -Force
    
    # ESCRITO POR ALUMNO
    # Crear el usuario con o sin OU
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

# ============================================
# SECCIÓN: MODIFICAR USUARIO
# ============================================
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

    # Validaciones con ayuda de IA
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

# ============================================
# SECCIÓN: ASIGNAR USUARIO A GRUPO
# ============================================
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

# ============================================
# SECCIÓN: LISTAR OBJETOS
# ============================================
if ($LIST) {
    Write-Host "=== LISTADO ===" -ForegroundColor Cyan
    ...
}

Write-Host ""
Write-Host "Fin" -ForegroundColor Cyan
