param(
    [string]$Archivo
)

# INICIO
Write-Host "=== SCRIPT DE CALIFICACION ===" -ForegroundColor Cyan
Write-Host "Nota: X/10" -ForegroundColor Yellow
Write-Host ""

# Variables para el resultado final
$puntosTotales = 0
$erroresEncontrados = @()

# PRUEBA 1: ¿El archivo de ejecución.bat existe?
Write-Host "PRUEBA 1: Verificando archivo SamuelSimone04.ps1..." -ForegroundColor Cyan
if (Test-Path "SamuelSimone04.ps1") {
    Write-Host "OK - Archivo existe" -ForegroundColor Green
    $puntosTotales += 1
} else {
    Write-Host "ERROR - Archivo no existe" -ForegroundColor Red
    $erroresEncontrados += "Prueba 1: SamuelSimone04.ps1 no existe"
}

# PRUEBA 2: ¿Existe bajas.log?
Write-Host ""
Write-Host "PRUEBA 2: Verificando bajas.log..." -ForegroundColor Cyan
if (Test-Path "C:\bajas.log") {
    Write-Host "OK - Archivo existe" -ForegroundColor Green
    $puntosTotales += 1
} else {
    Write-Host "ERROR - bajas.log no existe" -ForegroundColor Red
    $erroresEncontrados += "Prueba 2: bajas.log no existe"
}

# PRUEBA 3: ¿Existe bajaserror.log?
Write-Host ""
Write-Host "PRUEBA 3: Verificando bajaserror.log..." -ForegroundColor Cyan
if (Test-Path "C:\bajaserror.log") {
    Write-Host "OK - Archivo existe" -ForegroundColor Green
    $puntosTotales += 1
} else {
    Write-Host "ERROR - bajaserror.log no existe" -ForegroundColor Red
    $erroresEncontrados += "Prueba 3: bajaserror.log no existe"
}

# PRUEBA 4: ¿bajas.log tiene contenido?
Write-Host ""
Write-Host "PRUEBA 4: Verificando contenido de bajas.log..." -ForegroundColor Cyan
if (Test-Path "C:\bajas.log") {
    $contenido = Get-Content "C:\bajas.log" -ErrorAction SilentlyContinue
    if ($contenido -and $contenido.Count -gt 0) {
        Write-Host "OK - Archivo tiene contenido" -ForegroundColor Green
        $puntosTotales += 1
    } else {
        Write-Host "ERROR - Archivo vacío" -ForegroundColor Red
        $erroresEncontrados += "Prueba 4: bajas.log está vacío"
    }
} else {
    Write-Host "ERROR - bajas.log no existe" -ForegroundColor Red
    $erroresEncontrados += "Prueba 4: bajas.log no existe"
}

# PRUEBA 5: ¿bajaserror.log tiene contenido?
Write-Host ""
Write-Host "PRUEBA 5: Verificando contenido de bajaserror.log..." -ForegroundColor Cyan
if (Test-Path "C:\bajaserror.log") {
    $contenido = Get-Content "C:\bajaserror.log" -ErrorAction SilentlyContinue
    if ($contenido -and $contenido.Count -gt 0) {
        Write-Host "OK - Archivo tiene contenido" -ForegroundColor Green
        $puntosTotales += 1
    } else {
        Write-Host "ERROR - Archivo vacío" -ForegroundColor Red
        $erroresEncontrados += "Prueba 5: bajaserror.log está vacío"
    }
} else {
    Write-Host "ERROR - bajaserror.log no existe" -ForegroundColor Red
    $erroresEncontrados += "Prueba 5: bajaserror.log no existe"
}

# PRUEBA 6: ¿Se detectaron usuarios INEXISTENTES?
Write-Host ""
Write-Host "PRUEBA 6: Verificando detección de usuarios inexistentes..." -ForegroundColor Cyan
if (Test-Path "C:\bajaserror.log") {
    $contenido = Get-Content "C:\bajaserror.log"
    $tieneInexistente = $contenido | Where-Object { $_ -match "inexistente|no existe" }
    if ($tieneInexistente) {
        Write-Host "OK - Se detectaron usuarios inexistentes" -ForegroundColor Green
        $puntosTotales += 1
    } else {
        Write-Host "ERROR - No se detectaron usuarios inexistentes" -ForegroundColor Red
        $erroresEncontrados += "Prueba 6: No se registraron usuarios inexistentes"
    }
} else {
    Write-Host "ERROR - bajaserror.log no existe" -ForegroundColor Red
    $erroresEncontrados += "Prueba 6: bajaserror.log no existe"
}

# PRUEBA 7: ¿Se procesaron usuarios EXISTENTES?
Write-Host ""
Write-Host "PRUEBA 7: Verificando procesamiento de usuarios existentes..." -ForegroundColor Cyan
if (Test-Path "C:\bajas.log") {
    $contenido = Get-Content "C:\bajas.log" -ErrorAction SilentlyContinue
    if ($contenido -and $contenido.Count -gt 0) {
        Write-Host "OK - Se procesaron usuarios existentes" -ForegroundColor Green
        $puntosTotales += 1
    } else {
        Write-Host "ERROR - No se procesaron usuarios" -ForegroundColor Red
        $erroresEncontrados += "Prueba 7: bajas.log vacío"
    }
} else {
    Write-Host "ERROR - bajas.log no existe" -ForegroundColor Red
    $erroresEncontrados += "Prueba 7: bajas.log no existe"
}

# PRUEBA 8: ¿Contiene "devdusar" o "fsmaosl1" en bajas.log?
Write-Host ""
Write-Host "PRUEBA 8: Verificando usuarios específicos en bajas.log..." -ForegroundColor Cyan
if (Test-Path "C:\bajas.log") {
    $contenido = Get-Content "C:\bajas.log"
    $tieneUsuarios = $contenido | Where-Object { $_ -match "jsuasol|damamoe" }
    if ($tieneUsuarios) {
        Write-Host "OK - Se encontraron usuarios procesados" -ForegroundColor Green
        $puntosTotales += 1
    } else {
        Write-Host "ERROR - No se encontraron los usuarios esperados" -ForegroundColor Red
        $erroresEncontrados += "Prueba 8: No se encontró devdusar o fsmaosl1"
    }
} else {
    Write-Host "ERROR - bajas.log no existe" -ForegroundColor Red
    $erroresEncontrados += "Prueba 8: bajas.log no existe"
}

# PRUEBA 9: ¿Tiene fecha, lista de archivos y total?
Write-Host ""
Write-Host "PRUEBA 9: Verificando formato de bajas.log..." -ForegroundColor Cyan
if (Test-Path "C:\bajas.log") {
    $contenido = Get-Content "C:\bajas.log"
    $tieneFecha = $contenido | Where-Object { $_ -match "\d{2}/\d{2}/\d{4}" }
    $tieneTotal = $contenido | Where-Object { $_ -match "Total" }
    $tieneArchivos = $contenido | Where-Object { $_ -match "^\d+:" }
    
    if ($tieneFecha -and $tieneTotal -and $tieneArchivos) {
        Write-Host "OK - Formato correcto (fecha, archivos, total)" -ForegroundColor Green
        $puntosTotales += 1
    } else {
        Write-Host "ERROR - Formato incorrecto" -ForegroundColor Red
        $erroresEncontrados += "Prueba 9: Falta fecha, lista de archivos o total"
    }
} else {
    Write-Host "ERROR - bajas.log no existe" -ForegroundColor Red
    $erroresEncontrados += "Prueba 9: bajas.log no existe"
}

# PRUEBA 10: ¿El archivo bajas.log tiene formato correcto?
Write-Host ""
Write-Host "PRUEBA 10: Verificando formato completo bajas.log..." -ForegroundColor Cyan
if (Test-Path "C:\bajas.log") {
    $contenido = Get-Content "C:\bajas.log"
    
    # Verificar que tenga al menos: fecha, un archivo numerado, y total
    $tieneFecha = $contenido | Where-Object { $_ -match "\d{2}/\d{2}/\d{4}" }
    $tieneArchivo = $contenido | Where-Object { $_ -match "^\d+:" }
    $tieneTotal = $contenido | Where-Object { $_ -match "Total de ficheros movidos: \d+" }
    
    if ($tieneFecha -and $tieneArchivo -and $tieneTotal) {
        Write-Host "OK - Formato completo correcto" -ForegroundColor Green
        $puntosTotales += 1
    } else {
        Write-Host "ERROR - Formato incompleto" -ForegroundColor Red
        Write-Host "  Tiene fecha: $($tieneFecha -ne $null)" -ForegroundColor Yellow
        Write-Host "  Tiene archivos: $($tieneArchivo -ne $null)" -ForegroundColor Yellow
        Write-Host "  Tiene total: $($tieneTotal -ne $null)" -ForegroundColor Yellow
        $erroresEncontrados += "Prueba 10: Formato de bajas.log incompleto"
    }
} else {
    Write-Host "ERROR - bajas.log no existe" -ForegroundColor Red
    $erroresEncontrados += "Prueba 10: bajas.log no existe"
}

# MOSTRAR RESULTADOS FINALES
Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "RESULTADO FINAL" -ForegroundColor Yellow
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Puntuación obtenida: $puntosTotales/10" -ForegroundColor $(if($puntosTotales -ge 5){"Green"}else{"Red"})
Write-Host ""

if ($erroresEncontrados.Count -gt 0) {
    Write-Host "ERRORES ENCONTRADOS:" -ForegroundColor Red
    foreach ($error in $erroresEncontrados) {
        Write-Host "  - $error" -ForegroundColor Red
    }
    Write-Host ""
}

Write-Host "Listado de errores y fallos:" -ForegroundColor Yellow
Write-Host "Total de pruebas completadas: 10" -ForegroundColor Cyan
Write-Host "Total de pruebas correctas: $puntosTotales" -ForegroundColor Green
Write-Host "Total de pruebas incorrectas: $($erroresEncontrados.Count)" -ForegroundColor Red
Write-Host ""
Write-Host "Fin del programa" -ForegroundColor Cyan