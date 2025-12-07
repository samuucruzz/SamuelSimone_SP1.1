param(
    [string]$Archivo
)

# INICIO
Write-Host "=== SCRIPT DE BACKUP DE USUARIOS ===" -ForegroundColor Cyan

# Verificar si existe el archivo
if (!(Test-Path $Archivo)) {
    Write-Host "ERROR: El archivo '$Archivo' no existe" -ForegroundColor Red
    exit
}

# Leer archivo línea por línea
$lineas = Get-Content $Archivo

foreach ($linea in $lineas) {
    # Saltar líneas vacías
    if ([string]::IsNullOrWhiteSpace($linea)) {
        continue
    }
    
    Write-Host ""
    Write-Host "Procesando: $linea" -ForegroundColor Yellow
    
    # Separar datos por ":"
    $datos = $linea -split ":"
    
    # Validar que tenga 4 campos
    if ($datos.Count -ne 4) {
        Write-Host "ERROR: Formato incorrecto en la línea" -ForegroundColor Red
        continue
    }
    
    $nombre = $datos[0].Trim()
    $apellido1 = $datos[1].Trim()
    $apellido2 = $datos[2].Trim()
    $login = $datos[3].Trim()
    
    # Validar que el login no esté vacío
    if ([string]::IsNullOrWhiteSpace($login)) {
        Write-Host "ERROR: Login vacío" -ForegroundColor Red
        continue
    }
    
    # Verificar si el usuario existe
    try {
        $usuarioExiste = Get-LocalUser -Name $login -ErrorAction Stop
    } catch {
        $usuarioExiste = $null
    }
    
    if ($usuarioExiste) {
        Write-Host "Usuario '$login' existe - Creando backup..." -ForegroundColor Green
        
        # Crear carpeta backup en C:\Users\proyecto
        $carpetaBackup = "C:\Users\proyecto\$login"
        if (!(Test-Path $carpetaBackup)) {
            New-Item -Path $carpetaBackup -ItemType Directory -Force | Out-Null
        }
        
        # Ruta del usuario a respaldar
        $rutaUsuario = "C:\Users\$login"
        
        if (Test-Path $rutaUsuario) {
            # Obtener todos los archivos
            $archivos = Get-ChildItem -Path $rutaUsuario -Recurse -File -Force -ErrorAction SilentlyContinue
            $contador = 0
            $listaArchivos = @()
            
            foreach ($arch in $archivos) {
                try {
                    $contador++
                    
                    # Calcular ruta relativa
                    $rutaRelativa = $arch.FullName.Substring($rutaUsuario.Length + 1)
                    
                    # Ruta destino
                    $destino = Join-Path $carpetaBackup $rutaRelativa
                    $carpetaDestino = Split-Path $destino -Parent
                    
                    # Crear carpeta destino si no existe
                    if (!(Test-Path $carpetaDestino)) {
                        New-Item -Path $carpetaDestino -ItemType Directory -Force | Out-Null
                    }
                    
                    # Copiar archivo
                    Copy-Item -Path $arch.FullName -Destination $destino -Force
                    
                    # Añadir a lista para log
                    $listaArchivos += "${contador}:${rutaRelativa}"
                    
                    Write-Host "  Copiado: $rutaRelativa" -ForegroundColor Gray
                    
                } catch {
                    Write-Host "  Error con: $($arch.Name)" -ForegroundColor Red
                }
            }
            
            # Registrar en bajas.log
            $fecha = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
            $logEntry = "$fecha-$login /home/proyecto/$login"
            Add-Content -Path "C:\bajas.log" -Value $logEntry
            
            # Escribir lista de archivos
            foreach ($item in $listaArchivos) {
                Add-Content -Path "C:\bajas.log" -Value $item
            }
            
            # Escribir total
            Add-Content -Path "C:\bajas.log" -Value "Total de ficheros movidos: $contador"
            
            Write-Host "Total archivos copiados: $contador" -ForegroundColor Cyan
        }
        
        # Eliminar usuario
        try {
            Remove-LocalUser -Name $login -ErrorAction Stop
            Write-Host "Usuario '$login' eliminado" -ForegroundColor Green
        } catch {
            Write-Host "ERROR al eliminar usuario: $_" -ForegroundColor Red
        }
        
        # Eliminar carpeta del usuario
        try {
            Remove-Item -Path $rutaUsuario -Recurse -Force -ErrorAction Stop
            Write-Host "Carpeta del usuario eliminada" -ForegroundColor Green
        } catch {
            Write-Host "ADVERTENCIA: No se pudo eliminar la carpeta completamente" -ForegroundColor Yellow
        }
        
    } else {
        Write-Host "Usuario '$login' NO existe" -ForegroundColor Red
        
        # Escribir en bajaserror.log
        $fecha = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
        $motivoError = "login no existe en el sistema"
        $logError = "$fecha-$nombre-$apellido1-$apellido2-ERROR:$motivoError"
        Add-Content -Path "C:\bajaserror.log" -Value $logError
    }
}

Write-Host ""
Write-Host "=== PROCESO COMPLETADO ===" -ForegroundColor Green
Write-Host "Fin" -ForegroundColor Cyan