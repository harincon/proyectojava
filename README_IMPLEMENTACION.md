# Registro de implementación

## Estado actual

La base de datos está creada en PostgreSQL. La estructura anterior de B0 basada en clases Java propias se retiró por instrucción del estudiante el 14 de septiembre de 2026.

| Elemento | Estado |
| --- | --- |
| SQL y BD | Conservados: 16 tablas y 18 FK |
| Últimos campos | contraseña_hash, baños e imagen_propiedad.ruta TEXT |
| Driver PostgreSQL | Conservado en WEB-INF/lib |
| Conexión local | Centralizada en WEB-INF/jspf/conexion.jspf; función abrirConexion() comprobada por JDBC |
| Fuentes y compilados de B0 | Retirados, incluida la prueba Java y su script de compilación |
| web.xml | Conserva configuración de sesión y restricciones del material auxiliar; se retiró la referencia al filtro eliminado |
| Plan, contratos y plano | Actualizados para páginas JSP y fragmentos JSPF |
| Nueva base B0 | Terminada en JSP/JSPF y verificada en Tomcat (ver abajo) |

La comprobación técnica /estado y los contratos de base-B0-v1 ya no están disponibles. Las pruebas anteriores de esa versión no certifican la futura base JSP.

## Próximo paso

Delegar B2 y B8 cuando se autoricen.

## B1 — 15 de septiembre de 2026

Diseño aprobado por el estudiante: nombre **Habita**, lema «Encuentra tu próximo espacio» y **paleta A** (azul y turquesa), cercana a la plantilla de Figma.

| Archivo | Contenido |
| --- | --- |
| css/bootstrap.min.css, js/bootstrap.bundle.min.js | Bootstrap 5.3.3 en local |
| css/bootstrap-icons.min.css, css/fonts/ | Bootstrap Icons 1.11.3 en local |
| css/estilos.css | Paleta, botones, menú lateral, tarjetas, tablas, estados, lista vacía y pies |
| img/logo.svg, img/sin_foto.svg | Logo y reemplazo de propiedad sin foto |
| WEB-INF/jspf/cabecera.jspf | Encabezado, menú público, menú lateral por roles, cierre de sesión por POST y avisos |
| WEB-INF/jspf/pie.jspf | Pie público o interno y JavaScript de Bootstrap |
| WEB-INF/vista/acceso_denegado.jsp, error.jsp | Páginas 403, 404 y 500, registradas en web.xml |
| controlador/prueba_diseno.jsp | Muestra de componentes; solo en el propio equipo |

Verificado en Tomcat (22 comprobaciones): recursos locales servidos, menú público, menú de panel con varios roles y opción activa, nombre escapado, aviso de un solo uso, páginas 403 y 404 propias. Capturas revisadas a 1366, 768 y 390 px.

Corregido durante la prueba: los `.jspf` se leían en ISO-8859-1 y dañaban las tildes (también los mensajes de utilidades.jspf de B0); web.xml ahora aplica UTF-8 a `*.jspf`. Detectado y documentado: las JSP de Tomcat 8.5 no aceptan lambdas, y `trim-directive-whitespaces` borra espacios entre expresiones.

## B0 — 15 de septiembre de 2026

Base común en JSP/JSPF sobre Tomcat 8.5.96, con web.xml 3.1.

| Archivo | Contenido |
| --- | --- |
| WEB-INF/jspf/utilidades.jspf | UTF-8, hash PBKDF2, escape, token, validaciones, pesos, fechas, errores SQL y carpeta de archivos |
| WEB-INF/jspf/conexion.jspf.ejemplo | Plantilla de conexión sin contraseña, versionada en Git |
| controlador/prueba_conexion.jsp | Diagnóstico de conexión y utilidades; solo responde en el propio equipo |
| controlador/prueba_subida.jsp | Diagnóstico de subida multipart; solo en el propio equipo |
| WEB-INF/web.xml | `rutaArchivos` y registro multipart de la prueba de subida |

Verificado por HTTP en Tomcat: conexión a PostgreSQL 18.6, esquema con 16 tablas, columnas con ñ, hash (confirmado también con .NET), escape, validaciones, fechas, token aceptado y rechazado, texto POST con ñ intacto, y subida de archivos (nombre con ñ, 3 MB aceptado, 12 MB rechazado con mensaje, token falso rechazado, sin archivos residuales). La base de datos no se modificó.

Pendiente para B9: retirar o proteger las dos páginas de prueba antes de publicar.

Se retiraron los dos archivos de propiedades y su carpeta config. conexion.jspf conserva los datos de conexión, fija currentSchema=inmobiliaria y está excluido de Git por contener credenciales. La prueba ejecutó su función por JDBC y confirmó 16 tablas; no fue una prueba HTTP de JSP en Tomcat.

Se trasladó el PDF Figma a varios/referencias/ y se usa index.jsp como entrada temporal. Por la última instrucción del estudiante, se retiraron las carpetas vacías por rol y se crearon controlador/, WEB-INF/modelo/ y WEB-INF/vista/. Se conservan recursos y fragmentos comunes. Esta modificación solo organiza carpetas y documentación; no implementa lógica.

La auditoría se aplaza a B7, después de los módulos principales. La revisión global y las evidencias se preparan al final; durante el desarrollo solo se comprueba el cambio y se registra un resumen breve por bloque.

Se incorporó a los planes y contratos la preferencia por JSP/JSPF para todo lo viable en servidor, con JavaScript mínimo. Este ajuste solo documenta la decisión; no implementa funciones nuevas.

La limpieza no implementó login, seguridad.jspf, propiedades ni los demás módulos.

La estructura actual separa modelo, vista y controlador manteniendo JSP/JSPF. La implementación de esa separación y el requisito Filter están pendientes; esta organización no los da por terminados.

Se probó un filtro de servlet en una clase Java (AccesoFilter). Por decisión del estudiante se retiraron su código, sus compilados y su registro en web.xml, para mantener la forma del simulacro: la seguridad se hará con seguridad.jspf incluido en cada controlador privado. Se conservó en web.xml la opción trim-directive-whitespaces, que también usa el simulacro.

[Plan de delegación](varios/planificacion/PLAN_DELEGACION.md) · [Acuerdos](varios/planificacion/CONTRATOS.md) · [SQL](sql/01-esquema.sql).
