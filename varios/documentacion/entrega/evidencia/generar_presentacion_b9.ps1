$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$Raiz = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")).Path
$Entrega = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Capturas = Join-Path $Entrega "capturas"
$Salida = Join-Path $Entrega "PRESENTACION_HABITA.pptx"
$Render = Join-Path $PSScriptRoot "render_presentacion"
New-Item -ItemType Directory -Path $Render -Force | Out-Null
if (Test-Path -LiteralPath $Salida) { Remove-Item -LiteralPath $Salida -Force }

function Color([string]$Hex) {
    $h = $Hex.TrimStart('#')
    $r = [Convert]::ToInt32($h.Substring(0,2),16)
    $g = [Convert]::ToInt32($h.Substring(2,2),16)
    $b = [Convert]::ToInt32($h.Substring(4,2),16)
    return $r + ($g * 256) + ($b * 65536)
}

$Verde = Color "#243B32"
$VerdeOscuro = Color "#182A23"
$Terracota = Color "#C96E4B"
$Oliva = Color "#83946A"
$Arena = Color "#E8D8C4"
$Crema = Color "#F7F2E8"
$Blanco = Color "#FFFDF8"
$Carbon = Color "#252525"
$Suave = Color "#5F665F"

function Fondo($Diapositiva, [int]$ColorFondo = $Crema) {
    $Diapositiva.FollowMasterBackground = 0
    $Diapositiva.Background.Fill.ForeColor.RGB = $ColorFondo
    $Diapositiva.Background.Fill.Solid()
}

function Texto($Diapositiva, [string]$Contenido, [double]$X, [double]$Y, [double]$W, [double]$H,
        [double]$Tamano = 20, [int]$ColorTexto = $Carbon, [bool]$Negrita = $false,
        [string]$Fuente = "Aptos", [int]$Alineacion = 1) {
    $forma = $Diapositiva.Shapes.AddTextbox(1, $X, $Y, $W, $H)
    $forma.TextFrame.MarginLeft = 0
    $forma.TextFrame.MarginRight = 0
    $forma.TextFrame.MarginTop = 0
    $forma.TextFrame.MarginBottom = 0
    $forma.TextFrame.WordWrap = -1
    $forma.TextFrame.TextRange.Text = $Contenido
    $forma.TextFrame.TextRange.Font.Name = $Fuente
    $forma.TextFrame.TextRange.Font.Size = $Tamano
    $forma.TextFrame.TextRange.Font.Bold = if ($Negrita) { -1 } else { 0 }
    $forma.TextFrame.TextRange.Font.Color.RGB = $ColorTexto
    $forma.TextFrame.TextRange.ParagraphFormat.Alignment = $Alineacion
    $forma.TextFrame.TextRange.ParagraphFormat.SpaceAfter = 5
    return $forma
}

function Titulo($Diapositiva, [string]$Contenido, [string]$Etiqueta = "HABITA") {
    [void](Texto $Diapositiva $Etiqueta 46 25 240 20 11 $Terracota $true "Aptos" 1)
    [void](Texto $Diapositiva $Contenido 46 48 870 42 29 $Verde $true "Georgia" 1)
}

function Pie($Diapositiva, [int]$Numero) {
    [void](Texto $Diapositiva "Proyecto académico · B9" 46 515 300 14 9 $Suave $false "Aptos" 1)
    [void](Texto $Diapositiva ([string]$Numero) 875 515 38 14 9 $Suave $false "Aptos" 3)
}

function Imagen-Ajustada($Diapositiva, [string]$Ruta, [double]$X, [double]$Y, [double]$W, [double]$H) {
    $imagen = [System.Drawing.Image]::FromFile($Ruta)
    try { $proporcion = $imagen.Width / [double]$imagen.Height } finally { $imagen.Dispose() }
    $destino = $W / $H
    if ($proporcion -gt $destino) {
        $ancho = $W
        $alto = $W / $proporcion
    } else {
        $alto = $H
        $ancho = $H * $proporcion
    }
    $izquierda = $X + (($W - $ancho) / 2)
    $arriba = $Y + (($H - $alto) / 2)
    $forma = $Diapositiva.Shapes.AddPicture($Ruta, 0, -1, $izquierda, $arriba, $ancho, $alto)
    $forma.Line.Visible = -1
    $forma.Line.ForeColor.RGB = $Arena
    $forma.Line.Weight = 0.75
    return $forma
}

function Nueva-Diapositiva($Presentacion, [int]$Numero, [string]$TituloTexto, [string]$Etiqueta = "HABITA") {
    $d = $Presentacion.Slides.Add($Numero, 12)
    Fondo $d
    Titulo $d $TituloTexto $Etiqueta
    Pie $d $Numero
    return $d
}

$PowerPoint = New-Object -ComObject PowerPoint.Application
$Presentacion = $null
try {
    $Presentacion = $PowerPoint.Presentations.Add(0)
    $Presentacion.PageSetup.SlideWidth = 960
    $Presentacion.PageSetup.SlideHeight = 540

    # 1. Portada
    $d = $Presentacion.Slides.Add(1, 12)
    Fondo $d $VerdeOscuro
    [void](Imagen-Ajustada $d (Join-Path $Capturas "01-inicio-1366.png") 500 0 460 540)
    [void](Texto $d "HABITA" 55 70 360 24 13 $Terracota $true "Aptos" 1)
    [void](Texto $d "Gestión web para una inmobiliaria" 55 112 400 155 38 $Blanco $true "Georgia" 1)
    [void](Texto $d "JSP · JSPF · JDBC · PostgreSQL · Tomcat 8.5" 55 305 395 60 18 $Arena $false "Aptos" 1)
    [void](Texto $d "Integración, pruebas y documentación final" 55 395 395 55 20 $Blanco $false "Aptos" 1)
    [void](Texto $d "16 de septiembre de 2026" 55 490 260 18 11 $Arena $false "Aptos" 1)

    # 2. Contexto
    $d = Nueva-Diapositiva $Presentacion 2 "Alcance del proyecto" "PRESENTACIÓN"
    [void](Texto $d "Habita permite publicar, buscar y tramitar propiedades con permisos diferenciados." 46 112 400 74 24 $Carbon $true "Georgia" 1)
    [void](Texto $d "• Catálogo público con filtros y detalle`n• Registro, sesión y perfiles`n• Propiedades, favoritos y citas`n• Solicitudes con documentos privados`n• Reportes y auditoría" 46 205 390 205 20 $Carbon $false "Aptos" 1)
    [void](Imagen-Ajustada $d (Join-Path $Capturas "05-detalle-propiedad.png") 480 105 430 355)

    # 3. Roles
    $d = Nueva-Diapositiva $Presentacion 3 "Roles y control de acceso" "REQUISITOS"
    [void](Texto $d "Visitante" 46 118 190 28 21 $Verde $true "Georgia" 1)
    [void](Texto $d "Inicio, catálogo y detalle público." 46 150 190 55 16 $Carbon $false "Aptos" 1)
    [void](Texto $d "Cliente" 46 225 190 28 21 $Verde $true "Georgia" 1)
    [void](Texto $d "Favoritos, citas, solicitudes, documentos y perfil." 46 257 190 72 16 $Carbon $false "Aptos" 1)
    [void](Texto $d "Inmobiliaria" 255 118 190 28 21 $Verde $true "Georgia" 1)
    [void](Texto $d "Empresa, propiedades, revisiones y reportes propios." 255 150 190 72 16 $Carbon $false "Aptos" 1)
    [void](Texto $d "Administrador" 255 245 190 28 21 $Verde $true "Georgia" 1)
    [void](Texto $d "Usuarios, roles, catálogos, reportes generales y auditoría." 255 277 190 72 16 $Carbon $false "Aptos" 1)
    [void](Imagen-Ajustada $d (Join-Path $Capturas "07-panel-cliente.png") 475 110 435 330)
    [void](Texto $d "La interfaz oculta opciones por rol y el servidor vuelve a validar sesión, rol y pertenencia." 475 456 435 45 14 $Suave $false "Aptos" 1)

    # 4. Datos
    $d = Nueva-Diapositiva $Presentacion 4 "Modelo de datos normalizado" "BASE DE DATOS"
    [void](Imagen-Ajustada $d (Join-Path $Raiz "varios\documentacion\base-datos\bdjava (2).png") 46 105 645 385)
    [void](Texto $d "16 tablas" 720 118 190 38 28 $Terracota $true "Georgia" 1)
    [void](Texto $d "1:1`nusuario y perfil`n`n1:N`ninmobiliaria y propiedad`npropiedad e imagen`n`nN:M`nusuario y rol`npropiedad y característica" 720 175 190 260 17 $Carbon $false "Aptos" 1)
    [void](Texto $d "3FN separa credenciales, datos personales, catálogos y operación." 720 420 190 55 13 $Suave $false "Aptos" 1)

    # 5. Arquitectura
    $d = Nueva-Diapositiva $Presentacion 5 "Arquitectura JSP y JSPF" "ARQUITECTURA"
    [void](Texto $d "Navegador" 55 140 190 34 22 $Terracota $true "Georgia" 2)
    [void](Texto $d "formularios GET y POST`nsesión y token" 55 190 190 60 17 $Carbon $false "Aptos" 2)
    [void](Texto $d "Controlador JSP" 275 140 200 34 22 $Verde $true "Georgia" 2)
    [void](Texto $d "valida, autoriza y coordina`nredirige después del POST" 275 190 200 60 17 $Carbon $false "Aptos" 2)
    [void](Texto $d "Modelo JSPF" 525 140 185 34 22 $Oliva $true "Georgia" 2)
    [void](Texto $d "PreparedStatement`nconsultas y transacciones" 525 190 185 60 17 $Carbon $false "Aptos" 2)
    [void](Texto $d "PostgreSQL" 750 140 170 34 22 $Terracota $true "Georgia" 2)
    [void](Texto $d "esquema inmobiliaria`nrestricciones y bloqueos" 750 190 170 60 17 $Carbon $false "Aptos" 2)
    [void](Texto $d "WEB-INF/vista" 120 320 220 34 23 $Verde $true "Georgia" 2)
    [void](Texto $d "HTML escapado, Bootstrap local y CSS Habita" 120 366 220 65 17 $Carbon $false "Aptos" 2)
    [void](Texto $d "WEB-INF/jspf" 390 320 220 34 23 $Verde $true "Georgia" 2)
    [void](Texto $d "conexión, utilidades, cabecera, pie y seguridad" 390 366 220 65 17 $Carbon $false "Aptos" 2)
    [void](Texto $d "WEB-INF/lib" 660 320 180 34 23 $Verde $true "Georgia" 2)
    [void](Texto $d "Driver JDBC de PostgreSQL" 660 366 180 65 17 $Carbon $false "Aptos" 2)
    [void](Texto $d "La aplicación no define clases Java propias." 46 470 860 30 16 $Suave $true "Aptos" 2)

    # 6. Cliente
    $d = Nueva-Diapositiva $Presentacion 6 "Recorrido del cliente" "MÓDULOS"
    [void](Imagen-Ajustada $d (Join-Path $Capturas "08-favoritos-cliente.png") 46 112 410 260)
    [void](Imagen-Ajustada $d (Join-Path $Capturas "10-solicitudes-cliente.png") 500 112 410 260)
    [void](Texto $d "1. Busca y guarda favoritos`n2. Agenda una visita futura`n3. Radica una solicitud`n4. Adjunta PDF y consulta estados" 46 400 400 95 19 $Carbon $false "Aptos" 1)
    [void](Texto $d "El cliente solo puede consultar y cambiar registros propios." 500 410 410 62 20 $Verde $true "Georgia" 1)

    # 7. Inmobiliaria
    $d = Nueva-Diapositiva $Presentacion 7 "Operación de la inmobiliaria" "MÓDULOS"
    [void](Imagen-Ajustada $d (Join-Path $Capturas "11-propiedades-inmobiliaria.png") 46 110 420 275)
    [void](Imagen-Ajustada $d (Join-Path $Capturas "13-solicitudes-inmobiliaria.png") 490 110 420 275)
    [void](Texto $d "Publica y retira sus inmuebles. Atiende citas. Revisa documentos y solicitudes." 46 410 400 66 19 $Carbon $false "Aptos" 1)
    [void](Texto $d "El cierre cambia solicitud y propiedad dentro de una sola transacción." 490 410 420 66 20 $Verde $true "Georgia" 1)

    # 8. Admin
    $d = Nueva-Diapositiva $Presentacion 8 "Administración y trazabilidad" "MÓDULOS"
    [void](Imagen-Ajustada $d (Join-Path $Capturas "15-usuarios-admin.png") 46 110 420 285)
    [void](Imagen-Ajustada $d (Join-Path $Capturas "17-auditoria-admin.png") 490 110 420 285)
    [void](Texto $d "Usuarios y roles" 46 415 420 28 20 $Verde $true "Georgia" 1)
    [void](Texto $d "El administrador activa cuentas, asigna roles y administra catálogos." 46 448 420 48 16 $Carbon $false "Aptos" 1)
    [void](Texto $d "Auditoría" 490 415 420 28 20 $Verde $true "Georgia" 1)
    [void](Texto $d "Los filtros consultan eventos reales por usuario, texto y rango de fechas." 490 448 420 48 16 $Carbon $false "Aptos" 1)

    # 9. Seguridad
    $d = Nueva-Diapositiva $Presentacion 9 "Validaciones y seguridad" "COMPROBACIONES"
    [void](Texto $d "PBKDF2 con salt" 55 120 300 38 27 $Terracota $true "Georgia" 1)
    [void](Texto $d "Las contraseñas no se guardan en texto plano." 55 164 350 52 18 $Carbon $false "Aptos" 1)
    [void](Texto $d "Servidor y pertenencia" 55 250 350 38 27 $Verde $true "Georgia" 1)
    [void](Texto $d "PreparedStatement, token en POST, rol vigente y dueño del registro." 55 294 350 72 18 $Carbon $false "Aptos" 1)
    [void](Texto $d "Archivos privados" 55 402 300 38 27 $Oliva $true "Georgia" 1)
    [void](Texto $d "Firma %PDF-, límite de 5 MB y descarga por controlador." 55 446 350 52 18 $Carbon $false "Aptos" 1)
    [void](Texto $d "403" 515 135 150 60 46 $Terracota $true "Georgia" 2)
    [void](Texto $d "ID ajeno y rol no autorizado" 485 200 210 54 17 $Carbon $false "Aptos" 2)
    [void](Texto $d "1" 735 135 150 60 46 $Verde $true "Georgia" 2)
    [void](Texto $d "cita activa por inmueble y hora" 705 200 210 54 17 $Carbon $false "Aptos" 2)
    [void](Texto $d "5 MB" 515 315 150 60 42 $Oliva $true "Georgia" 2)
    [void](Texto $d "límite de documento" 485 380 210 48 17 $Carbon $false "Aptos" 2)
    [void](Texto $d "5 min" 735 315 150 60 42 $Terracota $true "Georgia" 2)
    [void](Texto $d "bloqueo tras cinco fallos" 705 380 210 48 17 $Carbon $false "Aptos" 2)

    # 10. Reportes
    $d = Nueva-Diapositiva $Presentacion 10 "Consultas y reportes" "SQL"
    [void](Imagen-Ajustada $d (Join-Path $Capturas "14-reportes-inmobiliaria.png") 46 108 415 270)
    [void](Imagen-Ajustada $d (Join-Path $Capturas "16-reportes-admin.png") 495 108 415 270)
    [void](Texto $d "sql/04-consultas.sql" 46 395 300 28 20 $Verde $true "Georgia" 1)
    [void](Texto $d "2 INNER JOIN de tres o más tablas`n1 N:M`n1 LEFT JOIN`n1 GROUP BY con HAVING" 46 428 330 76 13 $Carbon $false "Aptos" 1)
    [void](Texto $d "Filas devueltas" 520 405 240 28 20 $Verde $true "Georgia" 1)
    [void](Texto $d "20 · 15 · 15 · 30 · 5 · 4 · 4" 520 447 350 38 24 $Terracota $true "Aptos" 1)

    # 11. Responsive
    $d = Nueva-Diapositiva $Presentacion 11 "Diseño responsivo comprobado" "INTERFAZ"
    [void](Imagen-Ajustada $d (Join-Path $Capturas "04-catalogo-390.png") 55 105 190 350)
    [void](Imagen-Ajustada $d (Join-Path $Capturas "03-catalogo-768.png") 305 105 245 350)
    [void](Imagen-Ajustada $d (Join-Path $Capturas "02-catalogo-1366.png") 605 105 305 350)
    [void](Texto $d "390 px" 55 470 190 24 18 $Verde $true "Aptos" 2)
    [void](Texto $d "768 px" 305 470 245 24 18 $Verde $true "Aptos" 2)
    [void](Texto $d "1366 px" 605 470 305 24 18 $Verde $true "Aptos" 2)

    # 12. Pruebas
    $d = Nueva-Diapositiva $Presentacion 12 "Resultado de integración" "B9"
    [void](Texto $d "30/30" 55 135 300 90 64 $Terracota $true "Georgia" 1)
    [void](Texto $d "casos aprobados" 55 225 300 36 24 $Verde $true "Aptos" 1)
    [void](Texto $d "Concurrencia" 430 120 220 32 24 $Verde $true "Georgia" 1)
    [void](Texto $d "Una cita activa en el mismo horario.`nUn cierre efectivo para la misma solicitud." 430 162 430 76 18 $Carbon $false "Aptos" 1)
    [void](Texto $d "Documentos" 430 270 220 32 24 $Verde $true "Georgia" 1)
    [void](Texto $d "Autorizados: 200 application/pdf.`nAjenos: 403. Ruta WEB-INF: 404." 430 312 430 72 18 $Carbon $false "Aptos" 1)
    [void](Texto $d "Limpieza" 430 395 220 32 24 $Verde $true "Georgia" 1)
    [void](Texto $d "Los conteos volvieron a 21 · 20 · 15 · 15 · 20 · 10." 430 438 430 38 18 $Carbon $false "Aptos" 1)

    # 13. Scrum
    $d = Nueva-Diapositiva $Presentacion 13 "Scrum: planificación y evidencia" "PROCESO"
    [void](Texto $d "Plan previsto" 55 120 260 34 25 $Verde $true "Georgia" 1)
    [void](Texto $d "Sprint 1 · base y acceso`nSprint 2 · núcleo del negocio`nSprint 3 · operación y cierre" 55 170 330 120 20 $Carbon $false "Aptos" 1)
    [void](Texto $d "Evidencia disponible" 410 120 300 34 25 $Verde $true "Georgia" 1)
    [void](Texto $d "28 commits o merges`n14 al 16 de septiembre de 2026`nRama específica y merge de B8`nPlanificación y README por bloques" 410 170 430 135 20 $Carbon $false "Aptos" 1)
    [void](Texto $d "Brecha documentada" 55 350 300 34 25 $Terracota $true "Georgia" 1)
    [void](Texto $d "No hay actas suficientes de planning, review y retrospectiva para demostrar tres sprints reales de siete días. La entrega no inventa reuniones." 55 400 790 78 20 $Carbon $false "Aptos" 1)

    # 14. Ejecución
    $d = Nueva-Diapositiva $Presentacion 14 "Ejecución local" "DESPLIEGUE"
    [void](Texto $d "1" 55 120 40 40 30 $Terracota $true "Georgia" 2)
    [void](Texto $d "Crear `proyectojava` en PostgreSQL" 110 122 360 35 21 $Carbon $true "Aptos" 1)
    [void](Texto $d "2" 55 200 40 40 30 $Terracota $true "Georgia" 2)
    [void](Texto $d "Ejecutar 01, 02 y 03 en orden" 110 202 360 35 21 $Carbon $true "Aptos" 1)
    [void](Texto $d "3" 55 280 40 40 30 $Terracota $true "Georgia" 2)
    [void](Texto $d "Copiar conexion.jspf.ejemplo y completar la clave" 110 282 360 55 21 $Carbon $true "Aptos" 1)
    [void](Texto $d "4" 55 380 40 40 30 $Terracota $true "Georgia" 2)
    [void](Texto $d "Copiar a webapps, iniciar Tomcat y abrir localhost:8080" 110 382 360 60 21 $Carbon $true "Aptos" 1)
    [void](Imagen-Ajustada $d (Join-Path $Capturas "06-ingreso-768.png") 540 105 330 370)

    # 15. Pendientes
    $d = Nueva-Diapositiva $Presentacion 15 "Decisiones antes de publicar" "PENDIENTES"
    [void](Texto $d "Filter" 55 120 230 32 25 $Terracota $true "Georgia" 1)
    [void](Texto $d "El parcial lo exige. Hoy se usa seguridad.jspf en cada controlador privado." 55 158 350 70 17 $Carbon $false "Aptos" 1)
    [void](Texto $d "Credenciales" 55 270 230 32 25 $Terracota $true "Georgia" 1)
    [void](Texto $d "Cambiar Admin123 y mantener secretos fuera del repositorio." 55 308 350 62 17 $Carbon $false "Aptos" 1)
    [void](Texto $d "Diagnóstico" 55 410 230 32 25 $Terracota $true "Georgia" 1)
    [void](Texto $d "Retirar o limitar las tres páginas de prueba." 55 448 350 45 17 $Carbon $false "Aptos" 1)
    [void](Texto $d "Requisitos externos" 500 120 280 32 25 $Verde $true "Georgia" 1)
    [void](Texto $d "• Instancia PostgreSQL en línea`n• Despliegue web opcional`n• Evidencia mínima de JavaScript`n• Tablero y ceremonias Scrum reales" 500 170 350 150 20 $Carbon $false "Aptos" 1)
    [void](Texto $d "B9 propone la resolución. No aplica cambios sin decisión del coordinador o del profesor." 500 382 350 82 19 $Suave $true "Aptos" 1)

    # 16. Cierre
    $d = $Presentacion.Slides.Add(16, 12)
    Fondo $d $VerdeOscuro
    [void](Texto $d "HABITA" 55 70 300 24 13 $Terracota $true "Aptos" 1)
    [void](Texto $d "Guion de sustentación" 55 110 540 60 38 $Blanco $true "Georgia" 1)
    [void](Texto $d "1. Modelo y relaciones`n2. Arquitectura JSP/JSPF`n3. Recorrido por roles`n4. Transacciones y seguridad`n5. Reportes, pruebas y pendientes" 55 210 380 220 24 $Arena $false "Aptos" 1)
    [void](Imagen-Ajustada $d (Join-Path $Capturas "01-inicio-1366.png") 500 80 405 360)
    [void](Texto $d "Encuentra tu próximo espacio" 500 470 405 28 20 $Blanco $true "Georgia" 2)

    $Presentacion.SaveAs($Salida, 24)
    $Presentacion.Export($Render, "PNG", 1600, 900)
    "PPTX=$Salida"
    "DIAPOSITIVAS=$($Presentacion.Slides.Count)"
    "RENDER=$Render"
}
finally {
    if ($null -ne $Presentacion) {
        try { $Presentacion.Close() } catch { }
    }
    if ($null -ne $PowerPoint) {
        try { $PowerPoint.Quit() } catch { }
    }
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}
