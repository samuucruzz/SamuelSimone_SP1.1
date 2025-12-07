# ESCRITO POR ALUMNO
# Parámetro para recibir la ruta del archivo con los usuarios
param(
    [string]$Archivo,
    [switch]$DryRun   # AÑADIDO: Modo simulación
)

# ============================================================
# BLOQUE DRYRUN - EJECUCIÓN SIMULADA
# ============================================================
if ($DryRun) {
    Write-Host "===============================================" -ForegroundColor Yellow
    Write-Host "         MODO DRY-RUN ACTIVADO (SIMULACIÓN)" -ForegroundColor Yellow
    Write-Host " Ninguna acción real será ejecutada en el sistema." -ForegroundColor Yellow
    Write-Host " Solo se mostrará lo que el script HARÍA." -ForegroundColor Yellow
    Write-Host "===============================================`n"

    # Comprobación de parámetro
    Write-Host "(DryRun) Se comprobaría si el archivo '$Archivo' existe."
    Write-Host "(DryRun) Si el archivo no existe, se mostraría un error y se detendría."

    # Lectura del archivo
    Write-Host "(DryRun) Se leerían todas las líneas del archivo para procesarlas." 

    Write-Host "`n=== Simulación del procesamiento de cada línea ==="

    Write-Host "(DryRun) Para cada línea del archivo:"
    Write-Host "   → Se validaría el formato: nombre:apellido1:apellido2:login"
    Write-Host "   → Se extraerían los datos y se comprobaría que el login no está vacío."
    Write-Host "   → Se comprobaría si el usuario existe en el sistema (Get-LocalUser)."

    # Usuario existente
    Write-Host "`n=== Si el usuario EXISTE ==="
    Write-Host "(DryRun) Se crearía una carpeta en: C:\Users\proyecto\<login>"
    Write-Host "(DryRun) Se buscarían todos los archivos de C:\Users\<login>"
    Write-Host "(DryRun) Se copiarían los archivos a la carpeta del proyecto replicando estructura."
    Write-Host "(DryRun) Se registraría en C:\bajas.log:"
    Write-Host "         - Fecha y hora"
    Write-Host "         - Login"
    Write-Host "         - Lista de archivos movidos"
    Write-Host "         - Total de ficheros movidos"

    Write-Host "(DryRun) Se eliminaría el usuario del sistema: Remove-LocalUser"
    Write-Host "(DryRun) Se eliminaría su carpeta personal: C:\Users\<login>"

    # Usuario NO existente
    Write-Host "`n=== Si el usuario NO EXISTE ==="
    Write-Host "(DryRun) Se registraría el error en C:\bajaserror.log con formato:"
    Write-Host "         fecha-hora-login-nombre-apellidos-ERROR:motivo"

    Write-Host "`n==============================================="
    Write-Host "          FIN DE SIMULACIÓN DRY-RUN"
    Write-Host "     No se realizó ninguna acción real."
    Write-Host "==============================================="

    exit
}


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
