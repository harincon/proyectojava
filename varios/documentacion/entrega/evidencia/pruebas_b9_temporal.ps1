$ErrorActionPreference = "Stop"

$Base = "http://localhost:8080/proyectojava"
$Psql = "C:\Program Files\PostgreSQL\18\bin\psql.exe"
$Salida = Join-Path $PSScriptRoot "resultado_pruebas_b9.json"
$Marca = Get-Date -Format "yyyyMMddHHmmss"
$CorreoTemporal = "b9.recorrido.$Marca@habita.local"
$ClaveTemporal = "ClaveB9!2026"
$Matricula = "B9-$Marca"
$MatriculaInvalida = "B9-INV-$Marca"
$PdfValido = Join-Path $env:TEMP "habita-b9-valido-$Marca.pdf"
$PdfInvalido = Join-Path $env:TEMP "habita-b9-invalido-$Marca.pdf"
$PdfGrande = Join-Path $env:TEMP "habita-b9-grande-$Marca.pdf"
$Descarga = Join-Path $env:TEMP "habita-b9-descarga-$Marca.pdf"
$Resultados = New-Object System.Collections.ArrayList
$ArchivosServidor = New-Object System.Collections.ArrayList
$env:PGCLIENTENCODING = "UTF8"
$env:PGPASSWORD = "root"

function Sql([string]$Consulta) {
    $salidaSql = & $Psql -X -qAt -v ON_ERROR_STOP=1 -h localhost -U postgres -d proyectojava -c "SET search_path TO inmobiliaria; $Consulta" 2>&1
    if ($LASTEXITCODE -ne 0) { throw ($salidaSql -join "`n") }
    return (($salidaSql | ForEach-Object { $_.ToString() }) -join "`n").Trim()
}

function Agregar-Resultado([string]$Caso, [string]$Esperado, [string]$Obtenido, [bool]$Cumple, [string]$Detalle = "") {
    [void]$Resultados.Add([pscustomobject]@{
        caso = $Caso
        esperado = $Esperado
        obtenido = $Obtenido
        cumple = $Cumple
        detalle = $Detalle
    })
}

function Solicitar([string]$Metodo, [string]$Url, $Sesion, $Cuerpo = $null) {
    try {
        if ($Metodo -eq "POST") {
            $respuesta = Invoke-WebRequest -UseBasicParsing -Uri $Url -Method Post -WebSession $Sesion -Body $Cuerpo -ContentType "application/x-www-form-urlencoded" -TimeoutSec 60
        } else {
            $respuesta = Invoke-WebRequest -UseBasicParsing -Uri $Url -Method Get -WebSession $Sesion -TimeoutSec 60
        }
        return [pscustomobject]@{ Status = [int]$respuesta.StatusCode; Content = [string]$respuesta.Content; Url = [string]$respuesta.BaseResponse.ResponseUri }
    } catch [System.Net.WebException] {
        $respuestaError = $_.Exception.Response
        if ($null -eq $respuestaError) { throw }
        $lector = New-Object System.IO.StreamReader($respuestaError.GetResponseStream())
        try { $contenido = $lector.ReadToEnd() } finally { $lector.Dispose() }
        return [pscustomobject]@{ Status = [int]$respuestaError.StatusCode; Content = [string]$contenido; Url = [string]$respuestaError.ResponseUri }
    }
}

function Token-De($Sesion, [string]$Url) {
    $respuesta = Solicitar "GET" $Url $Sesion
    $coincidencia = [regex]::Match($respuesta.Content, 'name="token"\s+value="([^"]+)"')
    if (-not $coincidencia.Success) { throw "No se encontró token en $Url (HTTP $($respuesta.Status))." }
    return $coincidencia.Groups[1].Value
}

function Cookie-De($Sesion) {
    return (($Sesion.Cookies.GetCookies([uri]$Base) | ForEach-Object { "$($_.Name)=$($_.Value)" }) -join "; ")
}

function Iniciar-Sesion([string]$Correo, [string]$Clave) {
    $sesion = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $token = Token-De $sesion "$Base/controlador/acceso.jsp?accion=ingresar"
    $respuesta = Solicitar "POST" "$Base/controlador/acceso.jsp?accion=ingresar" $sesion @{
        token = $token; correo = $Correo; clave = $Clave
    }
    return [pscustomobject]@{ Sesion = $sesion; Respuesta = $respuesta }
}

function Curl-Multipart([string]$Url, $Sesion, [string]$Token, [string]$Nombre, [string]$Archivo, [string]$CuerpoSalida) {
    $cookie = Cookie-De $Sesion
    $resultado = & curl.exe -sS -L -o $CuerpoSalida -w "%{http_code}|%{url_effective}" -b $cookie `
        -F "token=$Token" -F "nombre=$Nombre" -F "archivo=@$Archivo;type=application/pdf" $Url
    if ($LASTEXITCODE -ne 0) { throw "curl falló al subir $Archivo" }
    return [string]$resultado
}

function Curl-Descarga([string]$Url, $Sesion, [string]$Destino) {
    $cookie = if ($null -eq $Sesion) { "" } else { Cookie-De $Sesion }
    $argumentos = @("-sS", "-o", $Destino, "-w", "%{http_code}|%{content_type}|%{size_download}")
    if ($cookie) { $argumentos += @("-b", $cookie) }
    $argumentos += $Url
    $resultado = & curl.exe @argumentos
    if ($LASTEXITCODE -ne 0) { throw "curl falló al descargar $Url" }
    return [string]$resultado
}

$Inicio = Get-Date
$MaxAuditoriaInicial = [int](Sql "SELECT COALESCE(max(id_auditoria), 0) FROM auditoria;")
$ConteosIniciales = Sql "SELECT (SELECT count(*) FROM usuario)||'|'||(SELECT count(*) FROM propiedad)||'|'||(SELECT count(*) FROM cita)||'|'||(SELECT count(*) FROM solicitud)||'|'||(SELECT count(*) FROM documento_solicitud)||'|'||(SELECT count(*) FROM favorito);"

try {
    [System.IO.File]::WriteAllText($PdfValido, "%PDF-1.4`n1 0 obj<</Type/Catalog>>endobj`ntrailer<</Root 1 0 R>>`n%%EOF", (New-Object System.Text.UTF8Encoding($false)))
    [System.IO.File]::WriteAllText($PdfInvalido, "Este archivo no tiene firma PDF.", (New-Object System.Text.UTF8Encoding($false)))
    $flujo = [System.IO.File]::Open($PdfGrande, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
    try {
        $prefijo = [System.Text.Encoding]::ASCII.GetBytes("%PDF-")
        $flujo.Write($prefijo, 0, $prefijo.Length)
        $flujo.SetLength(5242881)
    } finally { $flujo.Dispose() }

    # Registro y perfil del cliente temporal.
    $sesionCliente = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $token = Token-De $sesionCliente "$Base/controlador/acceso.jsp?accion=registro"
    $registro = Solicitar "POST" "$Base/controlador/acceso.jsp?accion=registro" $sesionCliente @{
        token = $token; nombres = "Prueba"; apellidos = "Recorrido B9"; correo = $CorreoTemporal
        clave = $ClaveTemporal; confirmar_clave = $ClaveTemporal
    }
    $idCliente = [int](Sql "SELECT id_usuario FROM usuario WHERE correo = '$CorreoTemporal';")
    Agregar-Resultado "Registro de cliente" "Cuenta y perfil CLIENTE creados" "HTTP $($registro.Status), usuario $idCliente" ($idCliente -gt 0)

    $loginCliente = Iniciar-Sesion $CorreoTemporal $ClaveTemporal
    $sesionCliente = $loginCliente.Sesion
    $perfil = Solicitar "GET" "$Base/controlador/perfil.jsp?accion=ver" $sesionCliente
    Agregar-Resultado "Ingreso del cliente" "Panel y perfil privados accesibles" "HTTP login $($loginCliente.Respuesta.Status), perfil $($perfil.Status)" ($perfil.Status -eq 200 -and $perfil.Content -match [regex]::Escape($CorreoTemporal))

    $token = Token-De $sesionCliente "$Base/controlador/perfil.jsp?accion=ver"
    $guardarPerfil = Solicitar "POST" "$Base/controlador/perfil.jsp?accion=guardar" $sesionCliente @{
        token = $token; nombres = "Prueba"; apellidos = "Recorrido B9"; documento = "B9$Marca"
        telefono = "+57 300 999 0000"; direccion = "Calle 9 # 9-09"
    }
    $perfilDb = Sql "SELECT documento||'|'||telefono||'|'||direccion FROM perfil WHERE id_usuario = $idCliente;"
    Agregar-Resultado "Actualización de perfil" "Datos persistidos" $perfilDb ($perfilDb -match "B9$Marca")

    # Publicación de la inmobiliaria y validación del servidor.
    $loginEmpresa = Iniciar-Sesion "camila.rojas@habita.local" "Clave123"
    $sesionEmpresa = $loginEmpresa.Sesion
    $tokenEmpresa = Token-De $sesionEmpresa "$Base/controlador/propiedad.jsp?accion=nueva"
    $propiedadBase = @{
        token = $tokenEmpresa; matricula = $Matricula; titulo = "Apartamento de prueba B9"
        descripcion = "Publicación temporal para el recorrido de integración B9."; direccion = "Carrera 27 # 45-10"
        operacion = "VENTA"; id_ciudad = "1"; id_tipo_propiedad = "2"; precio = "385000000"
        area = "92.50"; habitaciones = "3"; banos = "2"; caracteristica = @("1", "3", "5")
    }
    $invalida = @{} + $propiedadBase
    $invalida.matricula = $MatriculaInvalida
    $invalida.precio = "-1"
    $respuestaInvalida = Solicitar "POST" "$Base/controlador/propiedad.jsp?accion=crear" $sesionEmpresa $invalida
    $existeInvalida = [int](Sql "SELECT count(*) FROM propiedad WHERE matricula_inmobiliaria = '$MatriculaInvalida';")
    Agregar-Resultado "Validación de propiedad en servidor" "Rechazar precio negativo sin insertar" "HTTP $($respuestaInvalida.Status), filas $existeInvalida" ($existeInvalida -eq 0 -and $respuestaInvalida.Content -match "precio mayor")

    $crearPropiedad = Solicitar "POST" "$Base/controlador/propiedad.jsp?accion=crear" $sesionEmpresa $propiedadBase
    $idPropiedad = [int](Sql "SELECT id_propiedad FROM propiedad WHERE matricula_inmobiliaria = '$Matricula';")
    $propiedadDb = Sql "SELECT p.estado||'|'||p.activa||'|'||i.nombre||'|'||c.nombre FROM propiedad p JOIN inmobiliaria i USING(id_inmobiliaria) JOIN ciudad c USING(id_ciudad) WHERE p.id_propiedad=$idPropiedad;"
    Agregar-Resultado "Publicación de propiedad" "Activa, DISPONIBLE, empresa y ciudad correctas" "HTTP $($crearPropiedad.Status), $propiedadDb" ($propiedadDb -match "DISPONIBLE\|true\|.+Santandereana\|Bucaramanga")

    $catalogo = Solicitar "GET" "$Base/controlador/propiedad.jsp?accion=catalogo&q=$Matricula" $sesionCliente
    $detalle = Solicitar "GET" "$Base/controlador/propiedad.jsp?accion=detalle&id_propiedad=$idPropiedad" $sesionCliente
    Agregar-Resultado "Catálogo y detalle" "Publicación visible por búsqueda y detalle" "Catálogo $($catalogo.Status), detalle $($detalle.Status)" ($catalogo.Content -match $Matricula -and $detalle.Content -match $Matricula)

    # Token obligatorio y favorito sin duplicados.
    $favoritoSinToken = Solicitar "POST" "$Base/controlador/favorito.jsp?accion=agregar&id_propiedad=$idPropiedad" $sesionCliente @{}
    $favoritosTrasTokenMalo = [int](Sql "SELECT count(*) FROM favorito WHERE id_cliente=$idCliente AND id_propiedad=$idPropiedad;")
    Agregar-Resultado "Token en POST" "No cambia datos sin token válido" "Filas favorito: $favoritosTrasTokenMalo" ($favoritosTrasTokenMalo -eq 0)

    $tokenCliente = Token-De $sesionCliente "$Base/controlador/propiedad.jsp?accion=detalle&id_propiedad=$idPropiedad"
    $favorito1 = Solicitar "POST" "$Base/controlador/favorito.jsp?accion=agregar&id_propiedad=$idPropiedad" $sesionCliente @{ token = $tokenCliente }
    $favorito2 = Solicitar "POST" "$Base/controlador/favorito.jsp?accion=agregar&id_propiedad=$idPropiedad" $sesionCliente @{ token = $tokenCliente }
    $favoritos = [int](Sql "SELECT count(*) FROM favorito WHERE id_cliente=$idCliente AND id_propiedad=$idPropiedad;")
    $listadoFavoritos = Solicitar "GET" "$Base/controlador/favorito.jsp?accion=listar" $sesionCliente
    Agregar-Resultado "Favoritos sin duplicados" "Dos altas producen una sola relación y se lista" "Filas $favoritos" ($favoritos -eq 1 -and $listadoFavoritos.Content -match "Apartamento de prueba B9")

    # Cita pasada rechazada y cita futura válida.
    $fechaPasada = (Get-Date).AddDays(-1).ToString("yyyy-MM-dd")
    $tokenCliente = Token-De $sesionCliente "$Base/controlador/cita.jsp?accion=nueva&id_propiedad=$idPropiedad"
    $citaPasada = Solicitar "POST" "$Base/controlador/cita.jsp?accion=crear&id_propiedad=$idPropiedad" $sesionCliente @{
        token = $tokenCliente; fecha = $fechaPasada; hora = "10:00"
    }
    $citasPasadas = [int](Sql "SELECT count(*) FROM cita WHERE id_cliente=$idCliente AND id_propiedad=$idPropiedad AND fecha_hora < CURRENT_TIMESTAMP;")
    Agregar-Resultado "Fecha pasada de cita" "Rechazo en servidor" "Filas $citasPasadas" ($citasPasadas -eq 0 -and $citaPasada.Content -match "fecha y hora futuras")

    $fechaCita = (Get-Date).Date.AddDays(21).ToString("yyyy-MM-dd")
    $citaValida = Solicitar "POST" "$Base/controlador/cita.jsp?accion=crear&id_propiedad=$idPropiedad" $sesionCliente @{
        token = $tokenCliente; fecha = $fechaCita; hora = "11:00"
    }
    $idCita = [int](Sql "SELECT id_cita FROM cita WHERE id_cliente=$idCliente AND id_propiedad=$idPropiedad AND fecha_hora='$fechaCita 11:00';")
    Agregar-Resultado "Agendamiento de cita" "Cita futura PENDIENTE" (Sql "SELECT id_cita||'|'||estado FROM cita WHERE id_cita=$idCita;") ($idCita -gt 0)

    # Carrera: dos clientes intentan el mismo horario sobre la misma propiedad.
    $loginDaniela = Iniciar-Sesion "daniela.moreno@habita.local" "Clave123"
    $loginCarlos = Iniciar-Sesion "carlos.ruiz@habita.local" "Clave123"
    $sesionDaniela = $loginDaniela.Sesion
    $sesionCarlos = $loginCarlos.Sesion
    $tokenDaniela = Token-De $sesionDaniela "$Base/controlador/cita.jsp?accion=nueva&id_propiedad=$idPropiedad"
    $tokenCarlos = Token-De $sesionCarlos "$Base/controlador/cita.jsp?accion=nueva&id_propiedad=$idPropiedad"
    $cookieDaniela = Cookie-De $sesionDaniela
    $cookieCarlos = Cookie-De $sesionCarlos
    $fechaCruce = (Get-Date).Date.AddDays(22).ToString("yyyy-MM-dd")
    $salidaCruce1 = Join-Path $env:TEMP "habita-b9-cruce1-$Marca.html"
    $salidaCruce2 = Join-Path $env:TEMP "habita-b9-cruce2-$Marca.html"
    $urlCita = "$Base/controlador/cita.jsp?accion=crear&id_propiedad=$idPropiedad"
    $trabajo1 = Start-Job -ScriptBlock {
        param($u,$c,$t,$f,$o)
        & curl.exe -sS -L -o $o -w "%{http_code}" -b $c --data-urlencode "token=$t" --data-urlencode "fecha=$f" --data-urlencode "hora=15:00" $u
    } -ArgumentList $urlCita,$cookieDaniela,$tokenDaniela,$fechaCruce,$salidaCruce1
    $trabajo2 = Start-Job -ScriptBlock {
        param($u,$c,$t,$f,$o)
        & curl.exe -sS -L -o $o -w "%{http_code}" -b $c --data-urlencode "token=$t" --data-urlencode "fecha=$f" --data-urlencode "hora=15:00" $u
    } -ArgumentList $urlCita,$cookieCarlos,$tokenCarlos,$fechaCruce,$salidaCruce2
    Wait-Job $trabajo1,$trabajo2 | Out-Null
    $httpCruce1 = (Receive-Job $trabajo1 | Out-String).Trim()
    $httpCruce2 = (Receive-Job $trabajo2 | Out-String).Trim()
    Remove-Job $trabajo1,$trabajo2 -Force
    $cantidadCruce = [int](Sql "SELECT count(*) FROM cita WHERE id_propiedad=$idPropiedad AND fecha_hora='$fechaCruce 15:00' AND estado IN ('PENDIENTE','CONFIRMADA');")
    $ganadorCruce = Sql "SELECT u.correo FROM cita c JOIN usuario u ON u.id_usuario=c.id_cliente WHERE c.id_propiedad=$idPropiedad AND c.fecha_hora='$fechaCruce 15:00';"
    $contenidoCruce = ((Get-Content -Raw $salidaCruce1) + (Get-Content -Raw $salidaCruce2))
    Agregar-Resultado "Concurrencia de citas" "Una sola cita activa; la otra informa horario reservado" "Activas $cantidadCruce, ganador $ganadorCruce, HTTP $httpCruce1/$httpCruce2" ($cantidadCruce -eq 1 -and $contenidoCruce -match "horario ya est.+reservado")

    # Permisos sobre cita ajena y confirmación por la empresa propietaria.
    $tokenDaniela = Token-De $sesionDaniela "$Base/controlador/cita.jsp?accion=mis_citas"
    $cancelarAjena = Solicitar "POST" "$Base/controlador/cita.jsp?accion=cancelar&id_cita=$idCita" $sesionDaniela @{ token = $tokenDaniela }
    Agregar-Resultado "Cita ajena por URL" "403 y estado intacto" "HTTP $($cancelarAjena.Status), estado $(Sql "SELECT estado FROM cita WHERE id_cita=$idCita;")" ($cancelarAjena.Status -eq 403 -and (Sql "SELECT estado FROM cita WHERE id_cita=$idCita;") -eq "PENDIENTE")

    $tokenEmpresa = Token-De $sesionEmpresa "$Base/controlador/cita.jsp?accion=recibidas"
    $confirmarCita = Solicitar "POST" "$Base/controlador/cita.jsp?accion=confirmar&id_cita=$idCita" $sesionEmpresa @{ token = $tokenEmpresa }
    $estadoCita = Sql "SELECT estado FROM cita WHERE id_cita=$idCita;"
    Agregar-Resultado "Confirmación de cita" "Empresa dueña cambia a CONFIRMADA" $estadoCita ($estadoCita -eq "CONFIRMADA")

    # Solicitud, duplicado y documentos.
    $tokenCliente = Token-De $sesionCliente "$Base/controlador/solicitud.jsp?accion=nueva&id_propiedad=$idPropiedad"
    $crearSolicitud = Solicitar "POST" "$Base/controlador/solicitud.jsp?accion=crear&id_propiedad=$idPropiedad" $sesionCliente @{
        token = $tokenCliente; observacion = "Solicitud temporal del recorrido B9."
    }
    $idSolicitud = [int](Sql "SELECT id_solicitud FROM solicitud WHERE id_cliente=$idCliente AND id_propiedad=$idPropiedad;")
    Agregar-Resultado "Radicación de solicitud" "Solicitud PENDIENTE" (Sql "SELECT id_solicitud||'|'||estado FROM solicitud WHERE id_solicitud=$idSolicitud;") ($idSolicitud -gt 0)

    $duplicada = Solicitar "POST" "$Base/controlador/solicitud.jsp?accion=crear&id_propiedad=$idPropiedad" $sesionCliente @{
        token = $tokenCliente; observacion = "Duplicada"
    }
    $cantidadSolicitudes = [int](Sql "SELECT count(*) FROM solicitud WHERE id_cliente=$idCliente AND id_propiedad=$idPropiedad;")
    Agregar-Resultado "Solicitud abierta duplicada" "Se conserva una sola" "Filas $cantidadSolicitudes" ($cantidadSolicitudes -eq 1 -and $duplicada.Content -match "solicitud abierta")

    $tokenCliente = Token-De $sesionCliente "$Base/controlador/solicitud.jsp?accion=detalle&id_solicitud=$idSolicitud"
    $cuerpoInvalido = Join-Path $env:TEMP "habita-b9-pdf-invalido-$Marca.html"
    $subidaInvalida = Curl-Multipart "$Base/controlador/documento_solicitud.jsp?accion=subir&id_solicitud=$idSolicitud" $sesionCliente $tokenCliente "No PDF" $PdfInvalido $cuerpoInvalido
    $docsTrasInvalido = [int](Sql "SELECT count(*) FROM documento_solicitud WHERE id_solicitud=$idSolicitud;")
    Agregar-Resultado "Firma %PDF-" "Rechaza contenido sin firma aunque use .pdf" "Documentos $docsTrasInvalido" ($docsTrasInvalido -eq 0 -and (Get-Content -Raw $cuerpoInvalido) -match "PDF v")

    $cuerpoGrande = Join-Path $env:TEMP "habita-b9-pdf-grande-$Marca.html"
    $subidaGrande = Curl-Multipart "$Base/controlador/documento_solicitud.jsp?accion=subir&id_solicitud=$idSolicitud" $sesionCliente $tokenCliente "PDF grande" $PdfGrande $cuerpoGrande
    $docsTrasGrande = [int](Sql "SELECT count(*) FROM documento_solicitud WHERE id_solicitud=$idSolicitud;")
    Agregar-Resultado "Límite PDF 5 MB" "Rechaza 5 MB + 1 byte" "Documentos $docsTrasGrande" ($docsTrasGrande -eq 0 -and (Get-Content -Raw $cuerpoGrande) -match "5 MB")

    $cuerpoValido = Join-Path $env:TEMP "habita-b9-pdf-valido-$Marca.html"
    $subidaValida = Curl-Multipart "$Base/controlador/documento_solicitud.jsp?accion=subir&id_solicitud=$idSolicitud" $sesionCliente $tokenCliente "Cédula B9" $PdfValido $cuerpoValido
    $documentoDatos = Sql "SELECT id_documento||'|'||ruta FROM documento_solicitud WHERE id_solicitud=$idSolicitud;"
    $partesDocumento = $documentoDatos -split '\|',2
    $idDocumento = [int]$partesDocumento[0]
    $rutaDocumento = $partesDocumento[1]
    [void]$ArchivosServidor.Add($rutaDocumento)
    Agregar-Resultado "Subida PDF válida" "Registro y archivo privado creados" $documentoDatos ($idDocumento -gt 0)

    # Descarga privada para dueño, empresa, admin y usuarios ajenos.
    $loginAdmin = Iniciar-Sesion "admin@habita.com" "Admin123"
    $sesionAdmin = $loginAdmin.Sesion
    $loginAjeno = Iniciar-Sesion "andres.gomez@habita.local" "Clave123"
    $sesionAjeno = $loginAjeno.Sesion
    $urlDescarga = "$Base/controlador/documento_solicitud.jsp?accion=descargar&id_documento=$idDocumento"
    $descargaCliente = Curl-Descarga $urlDescarga $sesionCliente $Descarga
    $firmaDescarga = [System.Text.Encoding]::ASCII.GetString([System.IO.File]::ReadAllBytes($Descarga),0,5)
    $descargaEmpresa = Curl-Descarga $urlDescarga $sesionEmpresa (Join-Path $env:TEMP "habita-b9-empresa-$Marca.pdf")
    $descargaAdmin = Curl-Descarga $urlDescarga $sesionAdmin (Join-Path $env:TEMP "habita-b9-admin-$Marca.pdf")
    $descargaClienteAjeno = Curl-Descarga $urlDescarga $sesionDaniela (Join-Path $env:TEMP "habita-b9-ajeno-cliente-$Marca.html")
    $descargaEmpresaAjena = Curl-Descarga $urlDescarga $sesionAjeno (Join-Path $env:TEMP "habita-b9-ajeno-empresa-$Marca.html")
    $directaPrivada = Curl-Descarga "$Base/WEB-INF/archivos/$rutaDocumento" $null (Join-Path $env:TEMP "habita-b9-directa-$Marca.html")
    Agregar-Resultado "Documento privado: autorizados" "Cliente dueño, empresa dueña y admin descargan PDF" "$descargaCliente / $descargaEmpresa / $descargaAdmin, firma $firmaDescarga" ($descargaCliente -match '^200\|application/pdf' -and $descargaEmpresa -match '^200\|application/pdf' -and $descargaAdmin -match '^200\|application/pdf' -and $firmaDescarga -eq "%PDF-")
    Agregar-Resultado "Documento privado: ajenos" "Cliente y empresa ajenos reciben 403" "$descargaClienteAjeno / $descargaEmpresaAjena" ($descargaClienteAjeno -match '^403\|' -and $descargaEmpresaAjena -match '^403\|')
    Agregar-Resultado "Documento privado: ruta física" "WEB-INF no es servible por HTTP" $directaPrivada ($directaPrivada -match '^404\|')

    # Acceso por URL con id ajeno.
    $editarAjena = Solicitar "GET" "$Base/controlador/propiedad.jsp?accion=editar&id_propiedad=$idPropiedad" $sesionAjeno
    $detalleSolicitudAjena = Solicitar "GET" "$Base/controlador/solicitud.jsp?accion=detalle&id_solicitud=$idSolicitud" $sesionAjeno
    $auditoriaCliente = Solicitar "GET" "$Base/controlador/auditoria.jsp?accion=listar" $sesionCliente
    Agregar-Resultado "Propiedad ajena por URL" "403 a inmobiliaria que no es dueña" "HTTP $($editarAjena.Status)" ($editarAjena.Status -eq 403)
    Agregar-Resultado "Solicitud ajena por URL" "403 a inmobiliaria que no es dueña" "HTTP $($detalleSolicitudAjena.Status)" ($detalleSolicitudAjena.Status -eq 403)
    Agregar-Resultado "Auditoría por URL con CLIENTE" "Respuesta 403 de acceso denegado" "HTTP $($auditoriaCliente.Status)" ($auditoriaCliente.Status -eq 403) "La protección se hace con seguridad.jspf; el requisito explícito de Filter sigue pendiente."

    # Revisión del documento y solicitud por la empresa dueña.
    $tokenEmpresa = Token-De $sesionEmpresa "$Base/controlador/solicitud.jsp?accion=detalle&id_solicitud=$idSolicitud"
    $revisarDocumento = Solicitar "POST" "$Base/controlador/documento_solicitud.jsp?accion=revisar&id_documento=$idDocumento" $sesionEmpresa @{
        token = $tokenEmpresa; estado = "APROBADO"; observacion = "Documento verificado en recorrido B9."
    }
    $estadoDocumento = Sql "SELECT estado FROM documento_solicitud WHERE id_documento=$idDocumento;"
    Agregar-Resultado "Revisión de documento" "Documento APROBADO por empresa dueña" $estadoDocumento ($estadoDocumento -eq "APROBADO")

    $tokenEmpresa = Token-De $sesionEmpresa "$Base/controlador/solicitud.jsp?accion=detalle&id_solicitud=$idSolicitud"
    $aprobarSolicitud = Solicitar "POST" "$Base/controlador/solicitud.jsp?accion=revisar&id_solicitud=$idSolicitud" $sesionEmpresa @{
        token = $tokenEmpresa; estado = "APROBADA"; observacion = "Aprobada para prueba de cierre B9."
    }
    $estadoSolicitud = Sql "SELECT estado FROM solicitud WHERE id_solicitud=$idSolicitud;"
    Agregar-Resultado "Aprobación de solicitud" "Solicitud APROBADA" $estadoSolicitud ($estadoSolicitud -eq "APROBADA")

    # Carrera: dos cierres de la misma solicitud.
    $tokenEmpresa = Token-De $sesionEmpresa "$Base/controlador/solicitud.jsp?accion=detalle&id_solicitud=$idSolicitud"
    $cookieEmpresa = Cookie-De $sesionEmpresa
    $urlFinalizar = "$Base/controlador/solicitud.jsp?accion=finalizar&id_solicitud=$idSolicitud"
    $salidaCierre1 = Join-Path $env:TEMP "habita-b9-cierre1-$Marca.html"
    $salidaCierre2 = Join-Path $env:TEMP "habita-b9-cierre2-$Marca.html"
    $cierre1 = Start-Job -ScriptBlock {
        param($u,$c,$t,$o)
        & curl.exe -sS -L -o $o -w "%{http_code}" -b $c --data-urlencode "token=$t" $u
    } -ArgumentList $urlFinalizar,$cookieEmpresa,$tokenEmpresa,$salidaCierre1
    $cierre2 = Start-Job -ScriptBlock {
        param($u,$c,$t,$o)
        & curl.exe -sS -L -o $o -w "%{http_code}" -b $c --data-urlencode "token=$t" $u
    } -ArgumentList $urlFinalizar,$cookieEmpresa,$tokenEmpresa,$salidaCierre2
    Wait-Job $cierre1,$cierre2 | Out-Null
    $httpCierre1 = (Receive-Job $cierre1 | Out-String).Trim()
    $httpCierre2 = (Receive-Job $cierre2 | Out-String).Trim()
    Remove-Job $cierre1,$cierre2 -Force
    $cierreDb = Sql "SELECT s.estado||'|'||p.estado FROM solicitud s JOIN propiedad p USING(id_propiedad) WHERE s.id_solicitud=$idSolicitud;"
    $eventosCierre = [int](Sql "SELECT count(*) FROM auditoria WHERE id_auditoria>$MaxAuditoriaInicial AND accion LIKE 'SOLICITUD_FINALIZADA%solicitud $idSolicitud%';")
    $contenidoCierre = ((Get-Content -Raw $salidaCierre1) + (Get-Content -Raw $salidaCierre2))
    Agregar-Resultado "Concurrencia de cierre" "Un cierre efectivo: solicitud FINALIZADA, propiedad VENDIDA y un evento" "$cierreDb, eventos $eventosCierre, HTTP $httpCierre1/$httpCierre2" ($cierreDb -eq "FINALIZADA|VENDIDA" -and $eventosCierre -eq 1 -and $contenidoCierre -match "Solo se finaliza")

    # Reportes y auditoría por rol.
    $reporteEmpresa = Solicitar "GET" "$Base/controlador/reporte.jsp?accion=empresa" $sesionEmpresa
    $reporteAdmin = Solicitar "GET" "$Base/controlador/reporte.jsp?accion=general" $sesionAdmin
    $auditoriaAdmin = Solicitar "GET" "$Base/controlador/auditoria.jsp?accion=listar&q=B9" $sesionAdmin
    Agregar-Resultado "Reporte de inmobiliaria" "200, filtrado por empresa, con tablas y totales" "HTTP $($reporteEmpresa.Status)" ($reporteEmpresa.Status -eq 200 -and $reporteEmpresa.Content -match "Santandereana" -and $reporteEmpresa.Content -match "tabla-habita")
    Agregar-Resultado "Reportes de administrador" "200 con los cuatro consolidados" "HTTP $($reporteAdmin.Status)" ($reporteAdmin.Status -eq 200 -and $reporteAdmin.Content -match "Propiedades por ciudad" -and $reporteAdmin.Content -match "Citas por estado" -and $reporteAdmin.Content -match "Solicitudes por inmobiliaria" -and $reporteAdmin.Content -match "arriendos finalizados")
    Agregar-Resultado "Auditoría y filtro" "ADMIN ve eventos B9; CLIENTE no entra" "HTTP admin $($auditoriaAdmin.Status), cliente $($auditoriaCliente.Status)" ($auditoriaAdmin.Content -match "B9" -and $auditoriaCliente.Status -eq 403)

    $EventosGenerados = Sql "SELECT id_auditoria||'|'||COALESCE(id_usuario::text,'')||'|'||accion FROM auditoria WHERE id_auditoria>$MaxAuditoriaInicial ORDER BY id_auditoria;"
    $ResumenPrueba = [pscustomobject]@{
        inicio = $Inicio.ToString("o")
        fin = (Get-Date).ToString("o")
        marca = $Marca
        datos_temporales = [pscustomobject]@{ correo = $CorreoTemporal; matricula = $Matricula; id_usuario = $idCliente; id_propiedad = $idPropiedad; id_cita = $idCita; id_solicitud = $idSolicitud; id_documento = $idDocumento }
        conteos_iniciales = $ConteosIniciales
        auditoria_inicial_max = $MaxAuditoriaInicial
        eventos_generados = $EventosGenerados -split "`n"
        resultados = $Resultados
    }
    [System.IO.File]::WriteAllText($Salida, ($ResumenPrueba | ConvertTo-Json -Depth 8), (New-Object System.Text.UTF8Encoding($false)))
}
finally {
    # La evidencia conserva el resultado, pero la base y el almacenamiento vuelven al punto de partida.
    try {
        if ($null -ne $idPropiedad -and $idPropiedad -gt 0) {
            $rutas = Sql "SELECT ruta FROM documento_solicitud d JOIN solicitud s USING(id_solicitud) WHERE s.id_propiedad=$idPropiedad;"
            if ($rutas) { foreach ($ruta in ($rutas -split "`n")) { if ($ruta) { [void]$ArchivosServidor.Add($ruta) } } }
        }
    } catch { }
    foreach ($ruta in ($ArchivosServidor | Select-Object -Unique)) {
        $archivoServidor = Join-Path (Join-Path (Split-Path $PSScriptRoot -Parent | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent) "WEB-INF\archivos") $ruta
        if (Test-Path -LiteralPath $archivoServidor) { Remove-Item -LiteralPath $archivoServidor -Force -ErrorAction SilentlyContinue }
    }
    try {
        if ($null -ne $idPropiedad -and $idPropiedad -gt 0) {
            [void](Sql "BEGIN; DELETE FROM auditoria WHERE id_auditoria>$MaxAuditoriaInicial; DELETE FROM documento_solicitud WHERE id_solicitud IN (SELECT id_solicitud FROM solicitud WHERE id_propiedad=$idPropiedad); DELETE FROM solicitud WHERE id_propiedad=$idPropiedad; DELETE FROM cita WHERE id_propiedad=$idPropiedad; DELETE FROM favorito WHERE id_propiedad=$idPropiedad; DELETE FROM propiedad_caracteristica WHERE id_propiedad=$idPropiedad; DELETE FROM imagen_propiedad WHERE id_propiedad=$idPropiedad; DELETE FROM propiedad WHERE id_propiedad=$idPropiedad; DELETE FROM usuario_rol WHERE id_usuario=$idCliente; DELETE FROM perfil WHERE id_usuario=$idCliente; DELETE FROM usuario WHERE id_usuario=$idCliente; COMMIT;")
        } elseif ($null -ne $idCliente -and $idCliente -gt 0) {
            [void](Sql "BEGIN; DELETE FROM auditoria WHERE id_auditoria>$MaxAuditoriaInicial; DELETE FROM usuario_rol WHERE id_usuario=$idCliente; DELETE FROM perfil WHERE id_usuario=$idCliente; DELETE FROM usuario WHERE id_usuario=$idCliente; COMMIT;")
        }
    } catch {
        Write-Error "Falló la limpieza SQL: $($_.Exception.Message)"
    }
    Get-ChildItem -Path $env:TEMP -Filter "habita-b9-*-$Marca.*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
}

$ConteosFinales = Sql "SELECT (SELECT count(*) FROM usuario)||'|'||(SELECT count(*) FROM propiedad)||'|'||(SELECT count(*) FROM cita)||'|'||(SELECT count(*) FROM solicitud)||'|'||(SELECT count(*) FROM documento_solicitud)||'|'||(SELECT count(*) FROM favorito);"
$ResultadoFinal = Get-Content -Raw -Encoding UTF8 $Salida | ConvertFrom-Json
$ResultadoFinal | Add-Member -NotePropertyName conteos_finales -NotePropertyValue $ConteosFinales
$ResultadoFinal | Add-Member -NotePropertyName limpieza_correcta -NotePropertyValue ($ConteosFinales -eq $ConteosIniciales)
[System.IO.File]::WriteAllText($Salida, ($ResultadoFinal | ConvertTo-Json -Depth 8), (New-Object System.Text.UTF8Encoding($false)))
$ResultadoFinal | ConvertTo-Json -Depth 8
