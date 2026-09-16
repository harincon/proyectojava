<#
    Genera los PDF de ejemplo de los documentos sembrados por B8.

    Las filas de documento_solicitud viven en PostgreSQL, pero los archivos se guardan en
    WEB-INF/archivos/, que está excluido de Git porque ahí van documentos privados.
    Este script vuelve a crearlos en cualquier equipo a partir de las rutas de la base.

    Uso:  powershell -ExecutionPolicy Bypass -File varios\herramientas\generar-pdf-ejemplo.ps1
          (opcional) -Base proyectojava -Usuario postgres -Carpeta "C:\ruta\WEB-INF\archivos"
    psql pide la contraseña de PostgreSQL. Ejecutarlo después de cargar sql/03-datos-prueba.sql.
#>
param(
    [string]$Base = "proyectojava",
    [string]$Usuario = "postgres",
    [string]$Servidor = "localhost",
    [string]$Carpeta = ""
)

$ErrorActionPreference = "Stop"
$raizProyecto = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ([string]::IsNullOrWhiteSpace($Carpeta)) {
    $Carpeta = Join-Path $raizProyecto "WEB-INF\archivos"
}

$psql = Get-ChildItem "C:\Program Files\PostgreSQL\*\bin\psql.exe" -ErrorAction SilentlyContinue |
        Sort-Object FullName -Descending | Select-Object -First 1
if (-not $psql) { throw "No se encontró psql.exe. Instala PostgreSQL o agrega su carpeta bin al PATH." }

# Crea un PDF de una página con el texto indicado, con su tabla xref correcta.
function New-PdfEjemplo {
    param([string]$Ruta, [string]$Titulo)

    $latin1 = [System.Text.Encoding]::GetEncoding(28591)
    # En un PDF, \ ( y ) dentro de un texto deben ir escapados.
    $tituloSeguro = $Titulo.Replace('\', '\\').Replace('(', '\(').Replace(')', '\)')
    $texto = "BT /F1 16 Tf 72 780 Td ($tituloSeguro) Tj ET`n" +
             "BT /F1 11 Tf 72 750 Td (Documento de ejemplo del proyecto acad$([char]0x00E9)mico Habita.) Tj ET`n" +
             "BT /F1 11 Tf 72 730 Td (No contiene datos personales reales.) Tj ET"

    $objetos = @(
        "<< /Type /Catalog /Pages 2 0 R >>",
        "<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
        "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>",
        "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>",
        "<< /Length $($latin1.GetByteCount($texto)) >>`nstream`n$texto`nendstream"
    )

    $documento = New-Object System.Text.StringBuilder
    [void]$documento.Append("%PDF-1.4`n")
    $posiciones = @()
    for ($i = 0; $i -lt $objetos.Count; $i++) {
        $posiciones += $latin1.GetByteCount($documento.ToString())
        [void]$documento.Append("$($i + 1) 0 obj`n$($objetos[$i])`nendobj`n")
    }
    $inicioXref = $latin1.GetByteCount($documento.ToString())
    [void]$documento.Append("xref`n0 $($objetos.Count + 1)`n0000000000 65535 f `n")
    foreach ($posicion in $posiciones) {
        [void]$documento.Append(("{0:d10} 00000 n `n" -f $posicion))
    }
    [void]$documento.Append("trailer`n<< /Size $($objetos.Count + 1) /Root 1 0 R >>`nstartxref`n$inicioXref`n%%EOF`n")

    $destino = Join-Path $Carpeta ($Ruta -replace '/', '\')
    New-Item -ItemType Directory -Force (Split-Path -Parent $destino) | Out-Null
    [System.IO.File]::WriteAllBytes($destino, $latin1.GetBytes($documento.ToString()))
}

# psql entrega UTF-8 y PowerShell lo lee igual, para conservar las tildes de los nombres.
$consulta = "SELECT ruta || '|' || nombre FROM inmobiliaria.documento_solicitud ORDER BY id_documento"
$env:PGCLIENTENCODING = "UTF8"
$codificacionAnterior = [Console]::OutputEncoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
try {
    $filas = & $psql.FullName -h $Servidor -U $Usuario -d $Base -qAt -c $consulta
} finally {
    [Console]::OutputEncoding = $codificacionAnterior
}
if ($LASTEXITCODE -ne 0) { throw "No fue posible consultar la base $Base." }

$creados = 0
foreach ($fila in $filas) {
    if ([string]::IsNullOrWhiteSpace($fila)) { continue }
    $partes = $fila.Split('|')
    New-PdfEjemplo -Ruta $partes[0] -Titulo $partes[1]
    $creados++
}
"PDF de ejemplo generados: $creados en $Carpeta"
