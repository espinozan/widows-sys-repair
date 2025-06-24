# windows-sys-repair
Sistema Avanzado de Diagnóstico y Reparación para Windows

Un sistema integral de diagnóstico, reparación y monitoreo de Windows, diseñado para técnicos avanzados y administradores de sistemas.

---

## 🚀 Características Avanzadas

### Arquitectura Orientada a Objetos
- **Clases Especializadas**:  
  - `LoggerAvanzado`  
  - `DiagnosticoSistema`  
  - `OrquestadorReparacion`  
  - `GeneradorReportes`
- **Separación de Responsabilidades**: Cada clase maneja una funcionalidad específica.  
- **Extensibilidad**: Fácil de mantener y extender con nuevas funcionalidades.

### Sistema de Logging Estructurado
- **Logging Contextual**: Cada operación se registra con metadatos (timestamp, usuario, contexto).  
- **Niveles de Severidad**: `INFO`, `SUCCESS`, `WARNING`, `ERROR`.  
- **Trazabilidad Completa**: Seguimiento detallado de todas las operaciones realizadas.

### Diagnóstico Multidimensional
- **Análisis de Baseline**: Establece métricas de referencia del sistema (CPU, memoria, I/O).  
- **Evaluación Forense**: Análisis profundo de registros e integridad de archivos.  
- **Puntuación de Salud**: Sistema de scoring automático (0–100 %) para evaluar estado general.

### Reparación Inteligente
- **Punto de Restauración Automático**: Backup del sistema antes de aplicar cambios.  
- **Análisis Multifásico**:  
  1. **Check**: Verifica consistencia del sistema.  
  2. **Scan**: Detecta errores y corrupciones.  
  3. **Restore**: Aplica correcciones con DISM y SFC.
- **Optimización de Servicios**: Configuración automática de servicios basada en mejores prácticas de Windows.

### Monitoreo en Tiempo Real
- **Monitoreo Continuo**: Supervisión de uso de CPU, memoria y procesos.  
- **Alertas Automáticas**: Notificaciones al superar umbrales críticos.  
- **Intervención Interactiva**: Control por teclado (`Q` o `Escape` para salir).

---

## 🎯 Modos de Operación

| Modo          | Descripción                                 |
|---------------|---------------------------------------------|
| **Diagnóstico** | Solo análisis sin aplicar cambios.        |
| **Reparación**  | Solo procesos de reparación activos.      |
| **Completo**    | Diagnóstico + Reparación integral.        |
| **Monitoreo**   | Supervisión continua del sistema.         |

---

## 📊 Reporte Ejecutivo HTML
- **Diseño Moderno**: Interfaz responsiva con gradientes y tipografía clara.  
- **Métricas Visuales**: Gráficos interactivos de salud y rendimiento.  
- **Análisis Detallado**: Resultados completos de cada fase del diagnóstico y reparación.  
- **Apertura Automática**: El reporte HTML se abre al finalizar la ejecución.

---

## 🛡️ Seguridad y Resiliencia
- **Validación de Privilegios**: Verificación de permisos administrativos antes de iniciar.  
- **Manejo de Errores**: Estructura `try/catch` exhaustiva en cada módulo.  
- **Validación de Requisitos**: Comprobación de PowerShell, espacio en disco y memoria libre.  
- **Confirmación de Usuario**: Solicita aprobación antes de ejecutar operaciones críticas.

---

## ✨ Características Únicas
- **Análisis de Programas Recientes**: Detección y desinstalación interactiva de software instalado en los últimos 7 días.  
- **Limpieza Inteligente**: Eliminación de archivos antiguos (> 7 días) basándose en políticas configurables.  
- **Actualización Automática**: Integración con `PSWindowsUpdate` para parcheo de sistema y drivers.  
- **Interfaz Colorizada**: Salida por consola con colores para mejor legibilidad.  
- **Resumen Ejecutivo**: Síntesis final de estado y acciones realizadas.

---

## 🎮 Uso del Script

```powershell
# Ejecutar diagnóstico completo con reporte
.\Repair-WindowsSystem.ps1 -Modo Completo -GenerarReporte

# Solo diagnóstico
.\Repair-WindowsSystem.ps1 -Modo Diagnostico

# Monitoreo continuo
.\Repair-WindowsSystem.ps1 -Modo Monitoreo
