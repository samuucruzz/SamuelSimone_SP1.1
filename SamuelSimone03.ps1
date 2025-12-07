# ESCRITO POR ALUMNO
# Parámetro para recibir la ruta del archivo con los usuarios
param(
    [string]$Archivo
)

# ESCRITO POR ALUMNO
# Mensaje de inicio del script
Write-Host "=== SCRIPT DE BACKUP DE USUARIOS ===" -ForegroundColor Cyan

# ESCRITO POR ALUMNO
# Comprobar si el archivo existe antes de continuar
if (!(Test-Path $Archivo)) {
    Write-Host "ERROR: El archivo '$Archivo' no existe" -ForegroundColor Red
    exit
}

# ESCRITO POR ALUMNO
# Leer todas las líneas del archivo
$lineas = Get-Content $Archivo

# ESCRITO POR ALUMNO
# Procesar cada línea del archivo
foreach ($linea in $lineas) {
    # AYUDA DE IA (validación de líneas vacías)
    # Saltar líneas que estén vacías
    if ([string]::IsNullOrWhiteSpace($linea)) {
        continue
    }
    
    # ESCRITO POR ALUMNO
    Write-Host ""
    Write-Host "Procesando: $linea" -ForegroundColor Yellow
    
    # ESCRITO POR ALUMNO
    # Separar la línea por ":" para obtener los datos
    $datos = $linea -split ":"
    
    # ESCRITO POR ALUMNO
    # Validar que la línea tenga exactamente 4 campos
    if ($datos.Count -ne 4) {
        Write-Host "ERROR: Formato incorrecto en la línea" -ForegroundColor Red
        continue
    }
    
    # ESCRITO POR ALUMNO
    # Extraer los datos de cada campo y quitar espacios
    $nombre = $datos[0].Trim()
    $apellido1 = $datos[1].Trim()
    $apellido2 = $datos[2].Trim()
    $login = $datos[3].Trim()
    
    # ESCRITO POR ALUMNO
    # Validar que el login no esté vacío
    if ([string]::IsNullOrWhiteSpace($login)) {
        Write-Host "ERROR: Login vacío" -ForegroundColor Red
        continue
    }
    
    # AYUDA DE IA (try-catch para verificar usuario)
    # Verificar si el usuario existe en el sistema
    try {
        $usuarioExiste = Get-LocalUser -Name $login -ErrorAction Stop
    } catch {
        $usuarioExiste = $null
    }
    
    # ESCRITO POR ALUMNO
    # Si el usuario existe, hacer el backup
    if ($usuarioExiste) {
        Write-Host "Usuario '$login' existe - Creando backup..." -ForegroundColor Green
        
        # ESCRITO POR ALUMNO
        # Crear carpeta de backup en C:\Users\proyecto
        $carpetaBackup = "C:\Users\proyecto\$login"
        if (!(Test-Path $carpetaBackup)) {
            New-Item -Path $carpetaBackup -ItemType Directory -Force | Out-Null
        }
        
        # ESCRITO POR ALUMNO
        # Definir la ruta del usuario
        $rutaUsuario = "C:\Users\$login"
        
        # ESCRITO POR ALUMNO
        # Si existe la carpeta del usuario, copiar sus archivos
        if (Test-Path $rutaUsuario) {
            # ESCRITO POR ALUMNO
            # Obtener todos los archivos del usuario (incluyendo ocultos)
            $archivos = Get-ChildItem -Path $rutaUsuario -Recurse -File -Force -ErrorAction SilentlyContinue
            $contador = 0
            $listaArchivos = @()
            
            # ESCRITO POR ALUMNO
            # Copiar cada archivo a la carpeta de backup
            foreach ($arch in $archivos) {
                try {
                    $contador++
                    
                    # AYUDA DE IA (Substring para ruta relativa)
                    # Calcular la ruta relativa del archivo
                    $rutaRelativa = $arch.FullName.Substring($rutaUsuario.Length + 1)
                    
                    # ESCRITO POR ALUMNO
                    # Calcular la ruta de destino
                    $destino = Join-Path $carpetaBackup $rutaRelativa
                    $carpetaDestino = Split-Path $destino -Parent
                    
                    # ESCRITO POR ALUMNO
                    # Crear la carpeta de destino si no existe
                    if (!(Test-Path $carpetaDestino)) {
                        New-Item -Path $carpetaDestino -ItemType Directory -Force | Out-Null
                    }
                    
                    # ESCRITO POR ALUMNO
                    # Copiar el archivo
                    Copy-Item -Path $arch.FullName -Destination $destino -Force
                    
                    # ESCRITO POR ALUMNO
                    # Guardar en la lista para el log
                    $listaArchivos += "${contador}:${rutaRelativa}"
                    
                    Write-Host "  Copiado: $rutaRelativa" -ForegroundColor Gray
                    
                } catch {
                    Write-Host "  Error con: $($arch.Name)" -ForegroundColor Red
                }
            }
            
            # ESCRITO POR ALUMNO
            # Registrar en bajas.log
            $fecha = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
            $logEntry = "$fecha-$login /home/proyecto/$login"
            Add-Content -Path "C:\bajas.log" -Value $logEntry
            
            # ESCRITO POR ALUMNO
            # Escribir la lista de archivos copiados
            foreach ($item in $listaArchivos) {
                Add-Content -Path "C:\bajas.log" -Value $item
            }
            
            # ESCRITO POR ALUMNO
            # Escribir el total de archivos
            Add-Content -Path "C:\bajas.log" -Value "Total de ficheros movidos: $contador"
            
            Write-Host "Total archivos copiados: $contador" -ForegroundColor Cyan
        }
        
        # ESCRITO POR ALUMNO
        # Eliminar el usuario del sistema
        try {
            Remove-LocalUser -Name $login -ErrorAction Stop
            Write-Host "Usuario '$login' eliminado" -ForegroundColor Green
        } catch {
            Write-Host "ERROR al eliminar usuario: $_" -ForegroundColor Red
        }
        
        # ESCRITO POR ALUMNO
        # Eliminar la carpeta del usuario
        try {
            Remove-Item -Path $rutaUsuario -Recurse -Force -ErrorAction Stop
            Write-Host "Carpeta del usuario eliminada" -ForegroundColor Green
        } catch {
            Write-Host "ADVERTENCIA: No se pudo eliminar la carpeta completamente" -ForegroundColor Yellow
        }
        
    } else {
        # ESCRITO POR ALUMNO
        # Si el usuario no existe, registrar el error
        Write-Host "Usuario '$login' NO existe" -ForegroundColor Red
        
        # ESCRITO POR ALUMNO
        # Escribir en bajaserror.log
        $fecha = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
        $motivoError = "login no existe en el sistema"
        $logError = "$fecha-$nombre-$apellido1-$apellido2-ERROR:$motivoError"
        Add-Content -Path "C:\bajaserror.log" -Value $logError
    }
}

# ESCRITO POR ALUMNO
# Mensajes de finalización
Write-Host ""
Write-Host "=== PROCESO COMPLETADO ===" -ForegroundColor Green
Write-Host "Fin" -ForegroundColor Cyan
