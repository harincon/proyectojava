param([switch]$SoloAuditoriaAdmin)
$ErrorActionPreference = "Stop"

$Base = "http://localhost:8080/proyectojava"
$Edge = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$Puerto = 9327
$Perfil = Join-Path $env:TEMP ("habita-b9-edge-" + [guid]::NewGuid().ToString("N"))
$CarpetaCapturas = Join-Path (Split-Path $PSScriptRoot -Parent) "capturas"
$Salida = Join-Path $PSScriptRoot "resultado_responsive_b9.json"
New-Item -ItemType Directory -Path $CarpetaCapturas -Force | Out-Null
New-Item -ItemType Directory -Path $Perfil -Force | Out-Null

$Proceso = Start-Process -FilePath $Edge -ArgumentList @(
    "--headless=new",
    "--remote-debugging-port=$Puerto",
    "--remote-allow-origins=*",
    "--user-data-dir=$Perfil",
    "--no-first-run",
    "--disable-gpu",
    "--hide-scrollbars",
    "about:blank"
) -WindowStyle Hidden -PassThru

$WebSocket = $null
$Resultados = New-Object System.Collections.ArrayList
$script:IdCdp = 0

function Invocar-Cdp([string]$Metodo, $Parametros = @{}) {
    $script:IdCdp++
    $id = $script:IdCdp
    $mensaje = @{ id = $id; method = $Metodo; params = $Parametros } | ConvertTo-Json -Compress -Depth 20
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($mensaje)
    $segmento = New-Object System.ArraySegment[byte] -ArgumentList @(,$bytes)
    $WebSocket.SendAsync($segmento, [System.Net.WebSockets.WebSocketMessageType]::Text, $true,
        [System.Threading.CancellationToken]::None).GetAwaiter().GetResult()
    while ($true) {
        $buffer = New-Object byte[] 1048576
        $segmentoRespuesta = New-Object System.ArraySegment[byte] -ArgumentList @(,$buffer)
        $memoria = New-Object System.IO.MemoryStream
        try {
            do {
                $recibido = $WebSocket.ReceiveAsync($segmentoRespuesta,
                    [System.Threading.CancellationToken]::None).GetAwaiter().GetResult()
                if ($recibido.MessageType -eq [System.Net.WebSockets.WebSocketMessageType]::Close) {
                    throw "DevTools cerró la conexión."
                }
                $memoria.Write($buffer, 0, $recibido.Count)
            } while (-not $recibido.EndOfMessage)
            $texto = [System.Text.Encoding]::UTF8.GetString($memoria.ToArray())
        } finally { $memoria.Dispose() }
        $respuesta = $texto | ConvertFrom-Json
        if ($respuesta.id -eq $id) {
            if ($null -ne $respuesta.error) { throw ($respuesta.error | ConvertTo-Json -Compress) }
            return $respuesta.result
        }
    }
}

function Esperar-Documento([int]$Segundos = 25) {
    $limite = (Get-Date).AddSeconds($Segundos)
    do {
        Start-Sleep -Milliseconds 200
        $estado = Invocar-Cdp "Runtime.evaluate" @{ expression = "document.readyState"; returnByValue = $true }
        if ($estado.result.value -eq "complete") { return }
    } while ((Get-Date) -lt $limite)
    throw "La página no terminó de cargar."
}

function Navegar([string]$Ruta) {
    [void](Invocar-Cdp "Page.navigate" @{ url = "$Base$Ruta" })
    Esperar-Documento
    Start-Sleep -Milliseconds 700
}

function Fijar-Tamano([int]$Ancho, [int]$Alto) {
    [void](Invocar-Cdp "Emulation.setDeviceMetricsOverride" @{
        width = $Ancho; height = $Alto; deviceScaleFactor = 1; mobile = ($Ancho -lt 600)
        screenWidth = $Ancho; screenHeight = $Alto
    })
}

function Capturar([string]$Nombre, [string]$Ruta, [int]$Ancho, [int]$Alto, [string]$Rol) {
    Fijar-Tamano $Ancho $Alto
    Navegar $Ruta
    $estado = Invocar-Cdp "Runtime.evaluate" @{
        expression = "JSON.stringify({url:location.href,titulo:document.title,ancho:innerWidth,alto:innerHeight,scrollWidth:document.documentElement.scrollWidth,scrollHeight:document.documentElement.scrollHeight})"
        returnByValue = $true
    }
    $medidas = $estado.result.value | ConvertFrom-Json
    $captura = Invocar-Cdp "Page.captureScreenshot" @{ format = "png"; fromSurface = $true; captureBeyondViewport = $false }
    $rutaCaptura = Join-Path $CarpetaCapturas ("$Nombre.png")
    [System.IO.File]::WriteAllBytes($rutaCaptura, [Convert]::FromBase64String($captura.data))
    [void]$Resultados.Add([pscustomobject]@{
        archivo = (Split-Path $rutaCaptura -Leaf); rol = $Rol; ruta = $Ruta
        ancho = [int]$medidas.ancho; alto = [int]$medidas.alto
        scroll_width = [int]$medidas.scrollWidth; scroll_height = [int]$medidas.scrollHeight
        sin_desbordamiento_horizontal = ([int]$medidas.scrollWidth -le [int]$medidas.ancho)
        titulo = [string]$medidas.titulo; url_final = [string]$medidas.url
    })
}

function Ingresar([string]$Correo, [string]$Clave) {
    Navegar "/controlador/acceso.jsp?accion=ingresar"
    $correoJs = $Correo.Replace("\", "\\").Replace("'", "\'")
    $claveJs = $Clave.Replace("\", "\\").Replace("'", "\'")
    $envio = Invocar-Cdp "Runtime.evaluate" @{
        expression = "(function(){var correo=document.querySelector('#correo'),clave=document.querySelector('#clave'),formulario=document.querySelector('form');if(!correo||!clave||!formulario){return false;}correo.value='$correoJs';clave.value='$claveJs';formulario.submit();return true;})()"
        returnByValue = $true
    }
    if ($envio.result.value -ne $true) { throw "No apareció el formulario de ingreso para $Correo." }
    Esperar-Documento
    Start-Sleep -Milliseconds 700
    $ubicacion = Invocar-Cdp "Runtime.evaluate" @{ expression = "location.href"; returnByValue = $true }
    if ($ubicacion.result.value -notmatch "/controlador/panel.jsp") {
        throw "No se pudo iniciar sesión con $Correo. URL: $($ubicacion.result.value)"
    }
}

function Salir {
    $envio = Invocar-Cdp "Runtime.evaluate" @{
        expression = '(function(){var formulario=document.querySelector("form[action*=''accion=salir'']");if(!formulario){return false;}formulario.submit();return true;})()'
        returnByValue = $true
    }
    if ($envio.result.value -ne $true) { throw "No apareció el formulario de cierre de sesión." }
    Esperar-Documento
    Start-Sleep -Milliseconds 500
}

try {
    $version = $null
    $limite = (Get-Date).AddSeconds(20)
    do {
        try { $version = Invoke-RestMethod -UseBasicParsing -Uri "http://127.0.0.1:$Puerto/json/version" -TimeoutSec 2 } catch { Start-Sleep -Milliseconds 300 }
    } while ($null -eq $version -and (Get-Date) -lt $limite)
    if ($null -eq $version) { throw "Edge no expuso DevTools en el puerto $Puerto." }

    $pestanas = Invoke-RestMethod -UseBasicParsing -Uri "http://127.0.0.1:$Puerto/json/list" -TimeoutSec 5
    $pestana = $pestanas | Where-Object { $_.type -eq "page" } | Select-Object -First 1
    $WebSocket = New-Object System.Net.WebSockets.ClientWebSocket
    $WebSocket.ConnectAsync([uri]$pestana.webSocketDebuggerUrl,
        [System.Threading.CancellationToken]::None).GetAwaiter().GetResult()
    [void](Invocar-Cdp "Page.enable")
    [void](Invocar-Cdp "Runtime.enable")

    if ($SoloAuditoriaAdmin) {
        Ingresar "admin@habita.com" "Admin123"
        Capturar "17-auditoria-admin" "/controlador/auditoria.jsp?accion=listar" 1366 900 "Administrador"
        $SalidaSolo = Join-Path $PSScriptRoot "resultado_auditoria_b9.json"
        [System.IO.File]::WriteAllText($SalidaSolo, ($Resultados | ConvertTo-Json -Depth 6), (New-Object System.Text.UTF8Encoding($false)))
    } else {
        Capturar "01-inicio-1366" "/" 1366 900 "Público"
        Capturar "02-catalogo-1366" "/controlador/propiedad.jsp?accion=catalogo" 1366 900 "Público"
        Capturar "03-catalogo-768" "/controlador/propiedad.jsp?accion=catalogo" 768 1024 "Público"
        Capturar "04-catalogo-390" "/controlador/propiedad.jsp?accion=catalogo" 390 844 "Público"
        Capturar "05-detalle-propiedad" "/controlador/propiedad.jsp?accion=detalle&id_propiedad=1" 1366 900 "Público"
        Capturar "06-ingreso-768" "/controlador/acceso.jsp?accion=ingresar" 768 1024 "Público"

        Ingresar "daniela.moreno@habita.local" "Clave123"
        Capturar "07-panel-cliente" "/controlador/panel.jsp" 1366 900 "Cliente"
        Capturar "08-favoritos-cliente" "/controlador/favorito.jsp?accion=listar" 1366 900 "Cliente"
        Capturar "09-citas-cliente" "/controlador/cita.jsp?accion=mis_citas" 1366 900 "Cliente"
        Capturar "10-solicitudes-cliente" "/controlador/solicitud.jsp?accion=mis_solicitudes" 1366 900 "Cliente"
        Salir

        Ingresar "camila.rojas@habita.local" "Clave123"
        Capturar "11-propiedades-inmobiliaria" "/controlador/propiedad.jsp?accion=gestionar" 1366 900 "Inmobiliaria"
        Capturar "12-citas-inmobiliaria" "/controlador/cita.jsp?accion=recibidas" 1366 900 "Inmobiliaria"
        Capturar "13-solicitudes-inmobiliaria" "/controlador/solicitud.jsp?accion=recibidas" 1366 900 "Inmobiliaria"
        Capturar "14-reportes-inmobiliaria" "/controlador/reporte.jsp?accion=empresa" 1366 900 "Inmobiliaria"
        Salir

        Ingresar "admin@habita.com" "Admin123"
        Capturar "15-usuarios-admin" "/controlador/usuario.jsp?accion=listar" 1366 900 "Administrador"
        Capturar "16-reportes-admin" "/controlador/reporte.jsp?accion=general" 1366 900 "Administrador"
        Capturar "17-auditoria-admin" "/controlador/auditoria.jsp?accion=listar" 1366 900 "Administrador"

        [System.IO.File]::WriteAllText($Salida, ($Resultados | ConvertTo-Json -Depth 6), (New-Object System.Text.UTF8Encoding($false)))
    }
    $Resultados | Format-Table archivo,rol,ancho,alto,scroll_width,sin_desbordamiento_horizontal -AutoSize | Out-String
}
finally {
    if ($null -ne $WebSocket) {
        try { $WebSocket.Dispose() } catch { }
    }
    if ($null -ne $Proceso -and -not $Proceso.HasExited) {
        Stop-Process -Id $Proceso.Id -Force -ErrorAction SilentlyContinue
    }
    Start-Sleep -Milliseconds 500
    $perfilResuelto = [System.IO.Path]::GetFullPath($Perfil)
    $tempResuelto = [System.IO.Path]::GetFullPath($env:TEMP)
    if ($perfilResuelto.StartsWith($tempResuelto, [System.StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $perfilResuelto)) {
        Remove-Item -LiteralPath $perfilResuelto -Recurse -Force -ErrorAction SilentlyContinue
    }
}
