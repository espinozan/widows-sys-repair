#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Sistema Avanzado de Diagnóstico y Reparación para Windows
    
.DESCRIPTION
    Framework integral de análisis forense y reparación automatizada que implementa 
    patrones de observabilidad, estrategias de resiliencia y metodologías de 
    recuperación basadas en evidencia empírica.
    
.AUTHOR
    Nahuel Espinoza (espinozan)
    
.VERSION
    2.0.0 - Arquitectura Evolutiva
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Diagnostico", "Reparacion", "Completo", "Monitoreo")]
    [string]$Modo = "Completo",
    
    [Parameter(Mandatory=$false)]
    [switch]$GenerarReporte,
    
    [Parameter(Mandatory=$false)]
    [string]$RutaReporte = "$env:USERPROFILE\Desktop\DiagnosticoSistema_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"
)

# === ARQUITECTURA DE CONFIGURACIÓN ===
$ConfiguracionSistema = @{
    Logging = @{
        Nivel = "Detallado"
        RutaLogs = "$env:TEMP\SystemRepair_$(Get-Date -Format 'yyyyMMdd')"
    }
    Rendimiento = @{
        UmbralCPU = 80
        UmbralMemoria = 85
        UmbralDisco = 90
    }
    Seguridad = @{
        CrearPuntoRestauracion = $true
        ValidarIntegridad = $true
        AnalisisForense = $true
    }
}

# === SISTEMA DE LOGGING ESTRUCTURADO ===
class LoggerAvanzado {
    [string]$RutaArchivo
    [string]$Sesion
    
    LoggerAvanzado([string]$ruta) {
        $this.RutaArchivo = $ruta
        $this.Sesion = [guid]::NewGuid().ToString().Substring(0,8)
        $this.InicializarLogger()
    }
    
    [void]InicializarLogger() {
        if (!(Test-Path (Split-Path $this.RutaArchivo))) {
            New-Item -ItemType Directory -Path (Split-Path $this.RutaArchivo) -Force | Out-Null
        }
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Add-Content -Path $this.RutaArchivo -Value "=== SESIÓN INICIADA: $timestamp [ID: $($this.Sesion)] ==="
    }
    
    [void]Log([string]$nivel, [string]$mensaje, [hashtable]$contexto = @{}) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
        $contextoStr = if ($contexto.Count -gt 0) { " | Contexto: $($contexto | ConvertTo-Json -Compress)" } else { "" }
        $entrada = "[$timestamp] [$nivel] $mensaje$contextoStr"
        
        Add-Content -Path $this.RutaArchivo -Value $entrada
        
        $color = switch ($nivel) {
            "ERROR" { "Red" }
            "WARN" { "Yellow" }
            "SUCCESS" { "Green" }
            "INFO" { "Cyan" }
            default { "White" }
        }
        Write-Host $entrada -ForegroundColor $color
    }
    
    [void]Info([string]$mensaje, [hashtable]$contexto = @{}) { $this.Log("INFO", $mensaje, $contexto) }
    [void]Success([string]$mensaje, [hashtable]$contexto = @{}) { $this.Log("SUCCESS", $mensaje, $contexto) }
    [void]Warning([string]$mensaje, [hashtable]$contexto = @{}) { $this.Log("WARN", $mensaje, $contexto) }
    [void]Error([string]$mensaje, [hashtable]$contexto = @{}) { $this.Log("ERROR", $mensaje, $contexto) }
}

# === MOTOR DE DIAGNÓSTICO MULTIDIMENSIONAL ===
class DiagnosticoSistema {
    [LoggerAvanzado]$Logger
    [hashtable]$MetricasBaseline
    [hashtable]$EstadoSistema
    
    DiagnosticoSistema([LoggerAvanzado]$logger) {
        $this.Logger = $logger
        $this.MetricasBaseline = @{}
        $this.EstadoSistema = @{}
        $this.InicializarDiagnostico()
    }
    
    [void]InicializarDiagnostico() {
        $this.Logger.Info("Inicializando motor de diagnóstico multidimensional")
        $this.EstablecerBaseline()
        $this.AnalisisArquitectura()
    }
    
    [void]EstablecerBaseline() {
        $this.Logger.Info("Estableciendo métricas baseline del sistema")
        
        # Análisis de rendimiento base
        $cpu = Get-WmiObject -Class Win32_Processor | Measure-Object -Property LoadPercentage -Average
        $memoria = Get-WmiObject -Class Win32_OperatingSystem
        $discos = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
        
        $this.MetricasBaseline = @{
            CPU = @{
                Nucleos = (Get-WmiObject -Class Win32_Processor).NumberOfCores
                Utilizacion = $cpu.Average
                Velocidad = (Get-WmiObject -Class Win32_Processor).MaxClockSpeed
            }
            Memoria = @{
                Total = [math]::Round($memoria.TotalVisibleMemorySize / 1MB, 2)
                Disponible = [math]::Round($memoria.FreePhysicalMemory / 1MB, 2)
                PorcentajeUso = [math]::Round((($memoria.TotalVisibleMemorySize - $memoria.FreePhysicalMemory) / $memoria.TotalVisibleMemorySize) * 100, 2)
            }
            Almacenamiento = @{}
        }
        
        foreach ($disco in $discos) {
            $this.MetricasBaseline.Almacenamiento[$disco.DeviceID] = @{
                TamanoTotal = [math]::Round($disco.Size / 1GB, 2)
                EspacioLibre = [math]::Round($disco.FreeSpace / 1GB, 2)
                PorcentajeUso = [math]::Round((($disco.Size - $disco.FreeSpace) / $disco.Size) * 100, 2)
            }
        }
        
        $this.Logger.Success("Baseline establecido correctamente", $this.MetricasBaseline)
    }
    
    [void]AnalisisArquitectura() {
        $this.Logger.Info("Ejecutando análisis arquitectónico profundo")
        
        # Análisis de servicios críticos
        $serviciosCriticos = @("wuauserv", "BITS", "CryptSvc", "msiserver", "TrustedInstaller")
        $estadoServicios = @{}
        
        foreach ($servicio in $serviciosCriticos) {
            $estado = Get-Service -Name $servicio -ErrorAction SilentlyContinue
            if ($estado) {
                $estadoServicios[$servicio] = @{
                    Estado = $estado.Status
                    TipoInicio = $estado.StartType
                    Saludable = ($estado.Status -eq "Running")
                }
            }
        }
        
        $this.EstadoSistema.Servicios = $estadoServicios
        
        # Análisis del registro
        $this.AnalisisRegistro()
        
        # Análisis de integridad de archivos
        $this.AnalisisIntegridad()
        
        $this.Logger.Success("Análisis arquitectónico completado")
    }
    
    [void]AnalisisRegistro() {
        $this.Logger.Info("Analizando integridad del registro del sistema")
        
        $clavesEsenciales = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
            "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion",
            "HKLM:\SYSTEM\CurrentControlSet\Services"
        )
        
        $estadoRegistro = @{}
        foreach ($clave in $clavesEsenciales) {
            try {
                $existe = Test-Path $clave
                $estadoRegistro[$clave] = @{
                    Existe = $existe
                    Accesible = $true
                }
                if ($existe) {
                    $items = Get-ChildItem $clave -ErrorAction SilentlyContinue
                    $estadoRegistro[$clave].NumeroElementos = $items.Count
                }
            }
            catch {
                $estadoRegistro[$clave] = @{
                    Existe = $false
                    Accesible = $false
                    Error = $_.Exception.Message
                }
            }
        }
        
        $this.EstadoSistema.Registro = $estadoRegistro
    }
    
    [void]AnalisisIntegridad() {
        $this.Logger.Info("Ejecutando análisis forense de integridad")
        
        # Verificar archivos críticos del sistema
        $archivosEsenciales = @(
            "$env:SystemRoot\System32\kernel32.dll",
            "$env:SystemRoot\System32\ntdll.dll",
            "$env:SystemRoot\System32\user32.dll",
            "$env:SystemRoot\System32\advapi32.dll"
        )
        
        $integridad = @{}
        foreach ($archivo in $archivosEsenciales) {
            $integridad[$archivo] = @{
                Existe = Test-Path $archivo
                Tamano = if (Test-Path $archivo) { (Get-Item $archivo).Length } else { 0 }
                Modificado = if (Test-Path $archivo) { (Get-Item $archivo).LastWriteTime } else { $null }
            }
        }
        
        $this.EstadoSistema.Integridad = $integridad
    }
    
    [hashtable]GenerarReporteDiagnostico() {
        return @{
            Timestamp = Get-Date
            MetricasBaseline = $this.MetricasBaseline
            EstadoSistema = $this.EstadoSistema
            ResumenSalud = $this.EvaluarSaludGlobal()
        }
    }
    
    [hashtable]EvaluarSaludGlobal() {
        $puntuacion = 100
        $problemas = @()
        
        # Evaluar CPU
        if ($this.MetricasBaseline.CPU.Utilizacion -gt $ConfiguracionSistema.Rendimiento.UmbralCPU) {
            $puntuacion -= 20
            $problemas += "CPU sobrecargada"
        }
        
        # Evaluar memoria
        if ($this.MetricasBaseline.Memoria.PorcentajeUso -gt $ConfiguracionSistema.Rendimiento.UmbralMemoria) {
            $puntuacion -= 15
            $problemas += "Memoria insuficiente"
        }
        
        # Evaluar discos
        foreach ($disco in $this.MetricasBaseline.Almacenamiento.GetEnumerator()) {
            if ($disco.Value.PorcentajeUso -gt $ConfiguracionSistema.Rendimiento.UmbralDisco) {
                $puntuacion -= 10
                $problemas += "Disco $($disco.Key) casi lleno"
            }
        }
        
        return @{
            PuntuacionSalud = [math]::Max(0, $puntuacion)
            Problemas = $problemas
            Estado = if ($puntuacion -ge 80) { "Excelente" } elseif ($puntuacion -ge 60) { "Bueno" } elseif ($puntuacion -ge 40) { "Regular" } else { "Crítico" }
        }
    }
}

# === ORQUESTADOR DE REPARACIONES ===
class OrquestadorReparacion {
    [LoggerAvanzado]$Logger
    [DiagnosticoSistema]$Diagnostico
    [hashtable]$HistorialEjecuciones
    
    OrquestadorReparacion([LoggerAvanzado]$logger, [DiagnosticoSistema]$diagnostico) {
        $this.Logger = $logger
        $this.Diagnostico = $diagnostico
        $this.HistorialEjecuciones = @{}
    }
    
    [hashtable]EjecutarReparacionIntegral() {
        $this.Logger.Info("Iniciando orquestación de reparación integral")
        
        $resultados = @{
            PuntoRestauracion = $this.CrearPuntoRestauracion()
            SFC = $this.EjecutarSFC()
            DISM = $this.EjecutarDISM()
            ChkDsk = $this.EjecutarChkDsk()
            LimpiezaSistema = $this.LimpiezaAvanzada()
            OptimizacionServicios = $this.OptimizarServicios()
            ActualizacionSistema = $this.ActualizarSistema()
        }
        
        $this.Logger.Success("Orquestación de reparación completada")
        return $resultados
    }
    
    [hashtable]CrearPuntoRestauracion() {
        $this.Logger.Info("Creando punto de restauración del sistema")
        
        try {
            # Verificar si la restauración del sistema está habilitada
            $restoreEnabled = Get-ComputerRestorePoint -ErrorAction SilentlyContinue
            
            if (-not $restoreEnabled -and (Get-Service -Name VSS).Status -eq "Running") {
                Enable-ComputerRestore -Drive "$env:SystemDrive"
            }
            
            $descripcion = "PreReparacion_Sistema_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Checkpoint-Computer -Description $descripcion -RestorePointType "MODIFY_SETTINGS"
            
            $this.Logger.Success("Punto de restauración creado", @{ Descripcion = $descripcion })
            return @{ Exito = $true; Descripcion = $descripcion }
        }
        catch {
            $this.Logger.Error("Error al crear punto de restauración", @{ Error = $_.Exception.Message })
            return @{ Exito = $false; Error = $_.Exception.Message }
        }
    }
    
    [hashtable]EjecutarSFC() {
        $this.Logger.Info("Ejecutando System File Checker con análisis forense")
        
        try {
            $proceso = Start-Process -FilePath "sfc" -ArgumentList "/scannow" -Wait -PassThru -NoNewWindow -RedirectStandardOutput "$env:TEMP\sfc_output.txt"
            $salida = Get-Content "$env:TEMP\sfc_output.txt" -Raw
            
            $resultado = @{
                Exito = ($proceso.ExitCode -eq 0)
                CodigoSalida = $proceso.ExitCode
                Salida = $salida
                ArchivosReparados = $this.ParsearSalidaSFC($salida)
            }
            
            if ($resultado.Exito) {
                $this.Logger.Success("SFC completado exitosamente", @{ ArchivosReparados = $resultado.ArchivosReparados.Count })
            } else {
                $this.Logger.Warning("SFC completado con advertencias", @{ CodigoSalida = $proceso.ExitCode })
            }
            
            return $resultado
        }
        catch {
            $this.Logger.Error("Error ejecutando SFC", @{ Error = $_.Exception.Message })
            return @{ Exito = $false; Error = $_.Exception.Message }
        }
        finally {
            Remove-Item "$env:TEMP\sfc_output.txt" -ErrorAction SilentlyContinue
        }
    }
    
    [array]ParsearSalidaSFC([string]$salida) {
        $archivosReparados = @()
        $lineas = $salida -split "`n"
        
        foreach ($linea in $lineas) {
            if ($linea -match "Windows Resource Protection found corrupt files and successfully repaired them") {
                # Parsear archivos específicos si están listados
                $archivosReparados += "Archivos corruptos reparados"
            }
        }
        
        return $archivosReparados
    }
    
    [hashtable]EjecutarDISM() {
        $this.Logger.Info("Ejecutando DISM con análisis multifásico")
        
        $fases = @("CheckHealth", "ScanHealth", "RestoreHealth")
        $resultados = @{}
        
        foreach ($fase in $fases) {
            $this.Logger.Info("Ejecutando DISM fase: $fase")
            
            try {
                $argumentos = "/Online /Cleanup-Image /$fase"
                $proceso = Start-Process -FilePath "DISM" -ArgumentList $argumentos -Wait -PassThru -NoNewWindow -RedirectStandardOutput "$env:TEMP\dism_$fase.txt"
                $salida = Get-Content "$env:TEMP\dism_$fase.txt" -Raw
                
                $resultados[$fase] = @{
                    Exito = ($proceso.ExitCode -eq 0)
                    CodigoSalida = $proceso.ExitCode
                    Salida = $salida
                }
                
                if ($resultados[$fase].Exito) {
                    $this.Logger.Success("DISM $fase completado exitosamente")
                } else {
                    $this.Logger.Warning("DISM $fase completado con advertencias", @{ CodigoSalida = $proceso.ExitCode })
                }
            }
            catch {
                $this.Logger.Error("Error ejecutando DISM $fase", @{ Error = $_.Exception.Message })
                $resultados[$fase] = @{ Exito = $false; Error = $_.Exception.Message }
            }
            finally {
                Remove-Item "$env:TEMP\dism_$fase.txt" -ErrorAction SilentlyContinue
            }
        }
        
        return $resultados
    }
    
    [hashtable]EjecutarChkDsk() {
        $this.Logger.Info("Programando verificación de disco para el próximo reinicio")
        
        try {
            # ChkDsk requiere reinicio para unidades del sistema
            $resultado = & chkdsk $env:SystemDrive /f /r /x
            
            $this.Logger.Success("ChkDsk programado correctamente")
            return @{ 
                Exito = $true
                Mensaje = "ChkDsk programado para ejecutarse en el próximo reinicio"
                RequiereReinicio = $true
            }
        }
        catch {
            $this.Logger.Error("Error programando ChkDsk", @{ Error = $_.Exception.Message })
            return @{ Exito = $false; Error = $_.Exception.Message }
        }
    }
    
    [hashtable]LimpiezaAvanzada() {
        $this.Logger.Info("Ejecutando limpieza avanzada del sistema")
        
        $directoriosLimpieza = @(
            @{ Ruta = "$env:TEMP"; Descripcion = "Archivos temporales del usuario" },
            @{ Ruta = "$env:SystemRoot\Temp"; Descripcion = "Archivos temporales del sistema" },
            @{ Ruta = "$env:SystemRoot\SoftwareDistribution\Download"; Descripcion = "Cache de Windows Update" },
            @{ Ruta = "$env:SystemRoot\Logs"; Descripcion = "Logs antiguos del sistema" }
        )
        
        $resultados = @{}
        $espacioLiberado = 0
        
        foreach ($directorio in $directoriosLimpieza) {
            try {
                if (Test-Path $directorio.Ruta) {
                    $tamanioAntes = (Get-ChildItem $directorio.Ruta -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB
                    
                    Get-ChildItem $directorio.Ruta -Recurse -ErrorAction SilentlyContinue | 
                        Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } | 
                        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                    
                    $tamanioDespues = (Get-ChildItem $directorio.Ruta -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB
                    $liberado = $tamanioAntes - $tamanioDespues
                    $espacioLiberado += $liberado
                    
                    $resultados[$directorio.Descripcion] = @{
                        Exito = $true
                        EspacioLiberado = [math]::Round($liberado, 2)
                    }
                    
                    $this.Logger.Success("Limpieza completada: $($directorio.Descripcion)", @{ EspacioLiberado = "$([math]::Round($liberado, 2)) MB" })
                }
            }
            catch {
                $resultados[$directorio.Descripcion] = @{
                    Exito = $false
                    Error = $_.Exception.Message
                }
                $this.Logger.Warning("Error en limpieza: $($directorio.Descripcion)", @{ Error = $_.Exception.Message })
            }
        }
        
        $this.Logger.Success("Limpieza avanzada completada", @{ EspacioTotalLiberado = "$([math]::Round($espacioLiberado, 2)) MB" })
        return @{ Resultados = $resultados; EspacioTotalLiberado = $espacioLiberado }
    }
    
    [hashtable]OptimizarServicios() {
        $this.Logger.Info("Optimizando configuración de servicios")
        
        $serviciosOptimizar = @{
            "wuauserv" = @{ Estado = "Running"; Inicio = "Automatic" }
            "BITS" = @{ Estado = "Running"; Inicio = "Automatic" }
            "CryptSvc" = @{ Estado = "Running"; Inicio = "Automatic" }
            "msiserver" = @{ Estado = "Stopped"; Inicio = "Manual" }
            "Spooler" = @{ Estado = "Running"; Inicio = "Automatic" }
        }
        
        $resultados = @{}
        
        foreach ($servicio in $serviciosOptimizar.GetEnumerator()) {
            try {
                $servicioObj = Get-Service -Name $servicio.Key -ErrorAction SilentlyContinue
                
                if ($servicioObj) {
                    $estadoAnterior = $servicioObj.Status
                    $inicioAnterior = $servicioObj.StartType
                    
                    # Configurar tipo de inicio
                    Set-Service -Name $servicio.Key -StartupType $servicio.Value.Inicio
                    
                    # Configurar estado
                    if ($servicio.Value.Estado -eq "Running" -and $servicioObj.Status -ne "Running") {
                        Start-Service -Name $servicio.Key
                    }
                    elseif ($servicio.Value.Estado -eq "Stopped" -and $servicioObj.Status -eq "Running") {
                        Stop-Service -Name $servicio.Key -Force
                    }
                    
                    $resultados[$servicio.Key] = @{
                        Exito = $true
                        EstadoAnterior = $estadoAnterior
                        EstadoNuevo = $servicio.Value.Estado
                        InicioAnterior = $inicioAnterior
                        InicioNuevo = $servicio.Value.Inicio
                    }
                    
                    $this.Logger.Success("Servicio optimizado: $($servicio.Key)")
                }
            }
            catch {
                $resultados[$servicio.Key] = @{
                    Exito = $false
                    Error = $_.Exception.Message
                }
                $this.Logger.Warning("Error optimizando servicio: $($servicio.Key)", @{ Error = $_.Exception.Message })
            }
        }
        
        return $resultados
    }
    
    [hashtable]ActualizarSistema() {
        $this.Logger.Info("Iniciando actualización del sistema")
        
        try {
            # Verificar módulo PSWindowsUpdate
            if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
                $this.Logger.Info("Instalando módulo PSWindowsUpdate")
                Install-Module -Name PSWindowsUpdate -Force -AllowClobber
            }
            
            Import-Module PSWindowsUpdate -Force
            
            # Buscar actualizaciones
            $actualizaciones = Get-WUList -MicrosoftUpdate
            
            if ($actualizaciones.Count -gt 0) {
                $this.Logger.Info("Encontradas $($actualizaciones.Count) actualizaciones disponibles")
                
                # Instalar actualizaciones críticas
                $resultadoInstalacion = Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot:$false
                
                return @{
                    Exito = $true
                    ActualizacionesEncontradas = $actualizaciones.Count
                    ActualizacionesInstaladas = $resultadoInstalacion.Count
                    RequiereReinicio = ($resultadoInstalacion | Where-Object { $_.RebootRequired }).Count -gt 0
                }
            }
            else {
                $this.Logger.Success("Sistema actualizado - No hay actualizaciones pendientes")
                return @{
                    Exito = $true
                    ActualizacionesEncontradas = 0
                    ActualizacionesInstaladas = 0
                    RequiereReinicio = $false
                }
            }
        }
        catch {
            $this.Logger.Error("Error durante actualización del sistema", @{ Error = $_.Exception.Message })
            return @{
                Exito = $false
                Error = $_.Exception.Message
            }
        }
    }
}

# === GENERADOR DE REPORTES EJECUTIVOS ===
class GeneradorReportes {
    [LoggerAvanzado]$Logger
    
    GeneradorReportes([LoggerAvanzado]$logger) {
        $this.Logger = $logger
    }
    
    [void]GenerarReporteHTML([hashtable]$diagnostico, [hashtable]$reparaciones, [string]$rutaArchivo) {
        $this.Logger.Info("Generando reporte ejecutivo HTML")
        
        $html = $this.CrearPlantillaHTML($diagnostico, $reparaciones)
        
        try {
            $html | Out-File -FilePath $rutaArchivo -Encoding UTF8
            $this.Logger.Success("Reporte generado exitosamente", @{ Ruta = $rutaArchivo })
        }
        catch {
            $this.Logger.Error("Error generando reporte", @{ Error = $_.Exception.Message })
        }
    }
    
    [string]CrearPlantillaHTML([hashtable]$diagnostico, [hashtable]$reparaciones) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $saludGlobal = $diagnostico.ResumenSalud
        
        return @"
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reporte de Diagnóstico y Reparación del Sistema</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
        .container { max-width: 1200px; margin: 0 auto; background: white; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.3); overflow: hidden; }
        .header { background: linear-gradient(135deg, #2c3e50 0%, #3498db 100%); color: white; padding: 30px; text-align: center; }
        .header h1 { margin: 0; font-size: 2.5em; font-weight: 300; }
        .header p { margin: 10px 0 0 0; opacity: 0.9; }
        .content { padding: 30px; }
        .section { margin-bottom: 30px; padding: 20px; border-radius: 10px; background: #f8f9fa; border-left: 5px solid #3498db; }
        .section h2 { color: #2c3e50; margin-top: 0; font-size: 1.5em; }
        .metric-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin: 20px 0; }
        .metric-card { background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .metric-card h3 { margin: 0 0 10px 0; color: #2c3e50; font-size: 1.1em; }
        .metric-value { font-size: 2em; font-weight: bold; color: #3498db; }
        .health-score { text-align: center; margin: 20px 0; }
        .health-score .score { font-size: 4em; font-weight: bold; margin: 10px 0; }
        .health-excellent { color: #27ae60; }
        .health-good { color: #f39c12; }
        .health-regular { color: #e67e22; }
        .health-critical { color: #e74c3c; }
        .problems-list { background: #fff3cd; border: 1px solid #ffeaa7; border-radius: 5px; padding: 15px; margin: 10px 0; }
        .problems-list h4 { margin: 0 0 10px 0; color: #856404; }
        .problems-list ul { margin: 0; padding-left: 20px; }
        .repair-status { display: flex; align-items: center; margin: 10px 0; }
        .repair-status .status-icon { width: 20px; height: 20px; border-radius: 50%; margin-right: 10px; }
        .status-success { background: #27ae60; }
        .status-warning { background: #f39c12; }
        .status-error { background: #e74c3c; }
        .footer { background: #2c3e50; color: white; padding: 20px; text-align: center; }
        .progress-bar { width: 100%; height: 20px; background: #ecf0f1; border-radius: 10px; overflow: hidden; margin: 10px 0; }
        .progress-fill { height: 100%; background: linear-gradient(90deg, #3498db, #2ecc71); transition: width 0.3s ease; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔧 Sistema de Diagnóstico Avanzado</h1>
            <p>Reporte Ejecutivo - $timestamp</p>
        </div>
        
        <div class="content">
            <div class="section">
                <h2>📊 Resumen de Salud del Sistema</h2>
                <div class="health-score">
                    <div class="score health-$($saludGlobal.Estado.ToLower())">$($saludGlobal.PuntuacionSalud)%</div>
                    <h3>Estado: $($saludGlobal.Estado)</h3>
                </div>
                $(if ($saludGlobal.Problemas.Count -gt 0) {
                    "<div class='problems-list'><h4>⚠️ Problemas Detectados:</h4><ul>"
                    foreach ($problema in $saludGlobal.Problemas) {
                        "<li>$problema</li>"
                    }
                    "</ul></div>"
                })
            </div>
            
            <div class="section">
                <h2>💻 Métricas del Sistema</h2>
                <div class="metric-grid">
                    <div class="metric-card">
                        <h3>Procesador</h3>
                        <div class="metric-value">$($diagnostico.MetricasBaseline.CPU.Utilizacion)%</div>
                        <p>$($diagnostico.MetricasBaseline.CPU.Nucleos) núcleos - $($diagnostico.MetricasBaseline.CPU.Velocidad) MHz</p>
                    </div>
                    <div class="metric-card">
                        <h3>Memoria RAM</h3>
                        <div class="metric-value">$($diagnostico.MetricasBaseline.Memoria.PorcentajeUso)%</div>
                        <p>$($diagnostico.MetricasBaseline.Memoria.Disponible) GB disponible de $($diagnostico.MetricasBaseline.Memoria.Total) GB</p>
                    </div>
                    $(foreach ($disco in $diagnostico.MetricasBaseline.Almacenamiento.GetEnumerator()) {
                        "<div class='metric-card'><h3>Disco $($disco.Key)</h3><div class='metric-value'>$($disco.Value.PorcentajeUso)%</div><p>$($disco.Value.EspacioLibre) GB libres de $($disco.Value.TamanoTotal) GB</p></div>"
                    })
                </div>
            </div>
            
            $(if ($reparaciones) {
                "<div class='section'><h2>🔧 Resultados de Reparación</h2>"
                foreach ($reparacion in $reparaciones.GetEnumerator()) {
                    $iconoEstado = if ($reparacion.Value.Exito) { "status-success" } elseif ($reparacion.Value.ContainsKey('CodigoSalida')) { "status-warning" } else { "status-error" }
                    "<div class='repair-status'><div class='status-icon $iconoEstado'></div><strong>$($reparacion.Key):</strong> $(if ($reparacion.Value.Exito) { 'Completado exitosamente' } else { 'Completado con advertencias' })</div>"
                }
                "</div>"
            })
        </div>
        
        <div class="footer">
            <p>🚀 Sistema de Ingeniería Diagnóstica Avanzada | Reporte generado automáticamente</p>
        </div>
    </div>
</body>
</html>
"@
    }
}

# === MOTOR PRINCIPAL DE EJECUCIÓN ===
function Initialize-SystemRepair {
    param(
        [string]$ModoEjecucion = $Modo,
        [bool]$GenerarInforme = $GenerarReporte,
        [string]$RutaInforme = $RutaReporte
    )
    
    # Inicializar componentes del sistema
    $logger = [LoggerAvanzado]::new("$($ConfiguracionSistema.Logging.RutaLogs)\SystemRepair.log")
    $logger.Info("🚀 Iniciando Sistema Avanzado de Diagnóstico y Reparación")
    $logger.Info("Modo de ejecución: $ModoEjecucion")
    
    try {
        # Verificar privilegios administrativos
        if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
            throw "Este script requiere privilegios de administrador para funcionar correctamente."
        }
        
        # Inicializar motor de diagnóstico
        $diagnostico = [DiagnosticoSistema]::new($logger)
        $reporteDiagnostico = $diagnostico.GenerarReporteDiagnostico()
        
        $resultadosReparacion = $null
        
        # Ejecutar según el modo seleccionado
        switch ($ModoEjecucion.ToLower()) {
            "diagnostico" {
                $logger.Info("Ejecutando únicamente diagnóstico del sistema")
                # Solo diagnóstico, no reparación
            }
            
            "reparacion" {
                $logger.Info("Ejecutando únicamente procesos de reparación")
                $orquestador = [OrquestadorReparacion]::new($logger, $diagnostico)
                $resultadosReparacion = $orquestador.EjecutarReparacionIntegral()
            }
            
            "completo" {
                $logger.Info("Ejecutando diagnóstico completo y reparación integral")
                $orquestador = [OrquestadorReparacion]::new($logger, $diagnostico)
                $resultadosReparacion = $orquestador.EjecutarReparacionIntegral()
            }
            
            "monitoreo" {
                $logger.Info("Ejecutando monitoreo continuo del sistema")
                Start-SystemMonitoring -Logger $logger -Diagnostico $diagnostico
            }
        }
        
        # Generar reporte si es solicitado
        if ($GenerarInforme) {
            $generadorReportes = [GeneradorReportes]::new($logger)
            $generadorReportes.GenerarReporteHTML($reporteDiagnostico, $resultadosReparacion, $RutaInforme)
            
            # Abrir reporte automáticamente
            if (Test-Path $RutaInforme) {
                $logger.Info("Abriendo reporte generado")
                Start-Process $RutaInforme
            }
        }
        
        # Mostrar resumen final
        Show-ExecutionSummary -Diagnostico $reporteDiagnostico -Reparaciones $resultadosReparacion -Logger $logger
        
        $logger.Success("✅ Sistema Avanzado de Diagnóstico y Reparación completado exitosamente")
        
    }
    catch {
        $logger.Error("💥 Error crítico durante la ejecución", @{ 
            Error = $_.Exception.Message
            Linea = $_.InvocationInfo.ScriptLineNumber
            Comando = $_.InvocationInfo.Line.Trim()
        })
        
        Write-Host "`n❌ EJECUCIÓN TERMINADA CON ERRORES" -ForegroundColor Red
        Write-Host "Consulte el archivo de log para más información: $($ConfiguracionSistema.Logging.RutaLogs)\SystemRepair.log" -ForegroundColor Yellow
        exit 1
    }
}

# === FUNCIÓN DE MONITOREO CONTINUO ===
function Start-SystemMonitoring {
    param(
        [LoggerAvanzado]$Logger,
        [DiagnosticoSistema]$Diagnostico
    )
    
    $Logger.Info("Iniciando monitoreo continuo del sistema")
    
    $intervalos = 30  # segundos
    $contadorCiclos = 0
    
    try {
        while ($true) {
            $contadorCiclos++
            $Logger.Info("Ciclo de monitoreo #$contadorCiclos")
            
            # Recopilar métricas actuales
            $cpu = Get-WmiObject -Class Win32_Processor | Measure-Object -Property LoadPercentage -Average
            $memoria = Get-WmiObject -Class Win32_OperatingSystem
            $procesosProblemáticos = Get-Process | Where-Object { $_.CPU -gt 50 } | Select-Object -First 3
            
            # Evaluar thresholds críticos
            if ($cpu.Average -gt 90) {
                $Logger.Warning("🔥 CPU sobrecargada detectada", @{ Utilizacion = "$($cpu.Average)%" })
            }
            
            $memoriaUsada = (($memoria.TotalVisibleMemorySize - $memoria.FreePhysicalMemory) / $memoria.TotalVisibleMemorySize) * 100
            if ($memoriaUsada -gt 95) {
                $Logger.Warning("💾 Memoria crítica detectada", @{ Utilizacion = "$([math]::Round($memoriaUsada, 2))%" })
            }
            
            # Mostrar estado en consola
            Write-Host "`n📊 MONITOREO SISTEMA - Ciclo #$contadorCiclos" -ForegroundColor Cyan
            Write-Host "CPU: $($cpu.Average)% | RAM: $([math]::Round($memoriaUsada, 2))%" -ForegroundColor White
            
            if ($procesosProblemáticos) {
                Write-Host "`n⚠️  PROCESOS DE ALTO CONSUMO:" -ForegroundColor Yellow
                $procesosProblemáticos | ForEach-Object { 
                    Write-Host "   $($_.Name) - CPU: $($_.CPU)" -ForegroundColor Yellow 
                }
            }
            
            # Palear por input del usuario para salir
            if ([Console]::KeyAvailable) {
                $key = [Console]::ReadKey($true)
                if ($key.Key -eq 'Q' -or $key.Key -eq 'Escape') {
                    $Logger.Info("Monitoreo detenido por el usuario")
                    break
                }
            }
            
            Start-Sleep -Seconds $intervalos
        }
    }
    catch {
        $Logger.Error("Error durante monitoreo continuo", @{ Error = $_.Exception.Message })
    }
}

# === FUNCIÓN DE RESUMEN EJECUTIVO ===
function Show-ExecutionSummary {
    param(
        [hashtable]$Diagnostico,
        [hashtable]$Reparaciones,
        [LoggerAvanzado]$Logger
    )
    
    Write-Host "`n" + "="*80 -ForegroundColor Cyan
    Write-Host "📋 RESUMEN EJECUTIVO DEL SISTEMA" -ForegroundColor Cyan
    Write-Host "="*80 -ForegroundColor Cyan
    
    # Mostrar salud del sistema
    $salud = $Diagnostico.ResumenSalud
    $colorSalud = switch ($salud.Estado) {
        "Excelente" { "Green" }
        "Bueno" { "Yellow" }
        "Regular" { "DarkYellow" }
        "Crítico" { "Red" }
    }
    
    Write-Host "`n🏥 SALUD DEL SISTEMA: " -NoNewline
    Write-Host "$($salud.Estado) ($($salud.PuntuacionSalud)%)" -ForegroundColor $colorSalud
    
    # Mostrar métricas clave
    Write-Host "`n💻 MÉTRICAS CLAVE:" -ForegroundColor White
    Write-Host "   CPU: $($Diagnostico.MetricasBaseline.CPU.Utilizacion)% de uso" -ForegroundColor Gray
    Write-Host "   RAM: $($Diagnostico.MetricasBaseline.Memoria.PorcentajeUso)% de uso ($($Diagnostico.MetricasBaseline.Memoria.Disponible) GB disponible)" -ForegroundColor Gray
    
    foreach ($disco in $Diagnostico.MetricasBaseline.Almacenamiento.GetEnumerator()) {
        Write-Host "   Disco $($disco.Key): $($disco.Value.PorcentajeUso)% de uso ($($disco.Value.EspacioLibre) GB libres)" -ForegroundColor Gray
    }
    
    # Mostrar problemas si existen
    if ($salud.Problemas.Count -gt 0) {
        Write-Host "`n⚠️  PROBLEMAS DETECTADOS:" -ForegroundColor Yellow
        foreach ($problema in $salud.Problemas) {
            Write-Host "   • $problema" -ForegroundColor Yellow
        }
    }
    
    # Mostrar resultados de reparación si existen
    if ($Reparaciones) {
        Write-Host "`n🔧 RESULTADOS DE REPARACIÓN:" -ForegroundColor White
        foreach ($reparacion in $Reparaciones.GetEnumerator()) {
            $estado = if ($reparacion.Value.Exito) { "✅" } else { "⚠️" }
            $color = if ($reparacion.Value.Exito) { "Green" } else { "Yellow" }
            Write-Host "   $estado $($reparacion.Key)" -ForegroundColor $color
        }
        
        # Verificar si se requiere reinicio
        $requiereReinicio = $Reparaciones.Values | Where-Object { $_.RequiereReinicio -eq $true }
        if ($requiereReinicio) {
            Write-Host "`n🔄 REINICIO REQUERIDO para completar algunas reparaciones" -ForegroundColor Magenta
        }
    }
    
    Write-Host "`n" + "="*80 -ForegroundColor Cyan
    Write-Host "Presione cualquier tecla para continuar..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# === FUNCIÓN DE VALIDACIÓN DE ENTORNO ===
function Test-SystemRequirements {
    $requisitos = @{
        PowerShellVersion = @{ Minimo = 5.1; Actual = $PSVersionTable.PSVersion }
        EspacioDisco = @{ Minimo = 1GB; Actual = (Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq $env:SystemDrive }).FreeSpace }
        MemoriaRAM = @{ Minimo = 2GB; Actual = (Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory }
    }
    
    $cumpleRequisitos = $true
    
    foreach ($requisito in $requisitos.GetEnumerator()) {
        $cumple = $requisito.Value.Actual -ge $requisito.Value.Minimo
        if (-not $cumple) {
            Write-Warning "Requisito no cumplido: $($requisito.Key)"
            $cumpleRequisitos = $false
        }
    }
    
    return $cumpleRequisitos
}

# === PUNTO DE ENTRADA PRINCIPAL ===
Write-Host @"

🚀 ===================================================================
   SISTEMA AVANZADO DE DIAGNÓSTICO Y REPARACIÓN WINDOWS v2.0
   Framework de Ingeniería Forense y Recuperación Automatizada
===================================================================

"@ -ForegroundColor Cyan

# Validar requisitos del sistema
if (-not (Test-SystemRequirements)) {
    Write-Error "El sistema no cumple con los requisitos mínimos para ejecutar este script."
    exit 1
}

# Mostrar información de ejecución
Write-Host "📋 Configuración de Ejecución:" -ForegroundColor White
Write-Host "   • Modo: $Modo" -ForegroundColor Gray
Write-Host "   • Generar Reporte: $GenerarReporte" -ForegroundColor Gray
if ($GenerarReporte) {
    Write-Host "   • Ruta del Reporte: $RutaReporte" -ForegroundColor Gray
}
Write-Host ""

# Confirmar ejecución
$confirmacion = Read-Host "¿Desea continuar con la ejecución? (S/N)"
if ($confirmacion -notmatch '^[SsYy]') {
    Write-Host "Ejecución cancelada por el usuario." -ForegroundColor Yellow
    exit 0
}

# Ejecutar sistema principal
Initialize-SystemRepair -ModoEjecucion $Modo -GenerarInforme $GenerarReporte -RutaInforme $RutaReporte