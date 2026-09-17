# Acuerdos para la versión JSP/JSPF



[Plan general](PLAN_IMPLEMENTACION.md) · [Delegación](PLAN_DELEGACION.md) · [SQL](../../sql/01-esquema.sql).

## 1. Organización

Organización MVC prevista: controlador/ recibe peticiones en JSP; WEB-INF/modelo/ contiene funciones de datos en JSPF; WEB-INF/vista/ presenta pantallas JSP. Los fragmentos comunes siguen en WEB-INF/jspf. Sin carpetas por rol ni clases Java propias.

Controlador valida HTTP, sesión y permisos, invoca modelo y pasa resultados a vista. Modelo no lee request/session ni escribe response/HTML; recibe datos explícitos y devuelve valores o listas, nunca ResultSet abierto. Vista no ejecuta SQL ni actualiza BD. Las funciones de cada entidad y sus argumentos se acuerdan antes de implementar el bloque.

Preferencia obligatoria: resolver con JSP/JSPF todo lo que pueda ejecutarse en servidor. Filtros, orden y paginación usan GET; cambios usan POST; validaciones y permisos son de servidor. Usar HTML5/CSS donde baste. JavaScript solo para el mínimo requerido por el parcial y las interacciones de navegador necesarias. No mover scripts a una JSP para presentarlos como lógica JSP: JavaScript incrustado sigue ejecutándose en el navegador. No crear AJAX ni validadores cliente adicionales sin una necesidad concreta acordada.

Modelo/vista no son accesibles directamente por navegador al quedar bajo WEB-INF. El controlador usa forward a la vista. Los roles se aplican a las acciones y datos, no a carpetas.

Crear carpetas no equivale a implementar MVC. La lógica y el Filter de servlet solicitado en el parcial siguen pendientes; no se considera seguridad.jspf un Filter.

Se conserva Tomcat instalado y driver PostgreSQL en WEB-INF/lib. Los datos de conexión están directamente en WEB-INF/jspf/conexion.jspf, sin archivos .properties. web.xml se mantiene en versión 3.1: Tomcat 8.5 lee la 4.0 como 3.1 e ignora sus funciones nuevas. No cambiar a Jakarta ni copiar versiones XML de capturas ajenas.

## 2. Funciones comunes de B0 (implementadas)

Controlador típico, en este orden:

~~~jsp
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
~~~

utilidades.jspf va **primero**: al incluirse fija UTF-8 en la petición, y eso solo funciona antes de leer cualquier parámetro.

| Fragmento | Función | Devuelve |
| --- | --- | --- |
| conexion.jspf | `abrirConexion()` | `Connection` con `currentSchema=inmobiliaria`. Lanza `SQLException` y `ClassNotFoundException` |
| utilidades.jspf | `generarClave(String)` | Hash `pbkdf2-sha256$120000$sal$hash` |
| | `verificarClave(String plana, String guardada)` | `boolean`, comparación en tiempo constante |
| | `escapar(Object)` | Texto seguro para HTML y atributos; `null` → `""` |
| | `obtenerToken(HttpSession)` / `campoToken(HttpSession)` | Token de sesión / `<input type="hidden" name="token">` |
| | `tokenValido(HttpServletRequest)` | `boolean`; usar en todo POST antes de modificar |
| | `limpiar(String)` | Texto sin espacios extremos; vacío → `null` |
| | `patronBusqueda(String)` | `%texto%` para `ILIKE`, con `%` y `_` escapados (movida desde usuario.jspf en B3) |
| | `urlImagen(ctx, ruta)` · `rutaImagenValida(String)` · `formatoArea(BigDecimal)` | Añadidas en B4: dirección de la foto (o el reemplazo), validación de enlace https o archivo de `img/`, y área sin decimales sobrantes |
| | `longitudValida(String, int, int)`, `esCorreo(String)`, `esTelefono(String)` | `boolean` |
| | `aEntero(String)` / `aImporte(String)` | `Integer` / `BigDecimal` con 2 decimales; `null` si no es válido |
| | `formatoPesos(BigDecimal)` | `$ 320.000.000` |
| | `ahora()`, `aFechaHora(String fecha, String hora)`, `formatoFecha(LocalDateTime)` | Zona America/Bogota; formato `dd/MM/yyyy HH:mm` |
| | `mensajeError(SQLException)` | Mensaje claro para 23505, 23503, 23001 y 23514 |
| | `carpetaArchivos(ServletContext)` | Carpeta privada de archivos subidos (se crea si falta) |
| | `valorFormulario(request, campo)` · `errorFormulario(request, campo)` · `invalido(request, campo)` | Para vistas (añadidas en B2): valor previo escapado de `valores`, mensaje escapado de `errores` y `" is-invalid"` si hay error |

No crear funciones con los mismos nombres en otros fragmentos: la página no compilaría.

Sin variables compartidas mutables entre peticiones dentro de declaraciones JSP. Incluir cada fragmento con declaraciones una sola vez por página; no incluir conexion/utilidades de nuevo desde cabecera u otros fragmentos.

JSP UTF-8. Incluir utilidades.jspf antes de leer parámetros. Claves nunca en el HTML, los logs ni el repositorio.

## 3. JDBC y configuración

conexion.jspf contiene url, usuario y contrasena como variables locales de abrirConexion(). La URL JDBC incluye currentSchema=inmobiliaria. Para una BD remota se ajustan allí los datos de conexión y los parámetros que requiera el proveedor; no se repiten en cada página.

El fragmento está excluido de Git por contener credenciales locales. En otro equipo se copia `WEB-INF/jspf/conexion.jspf.ejemplo` como `conexion.jspf` y se completa la contraseña. No recrear db.properties ni una clase de conexión.

PreparedStatement para valores. Nombre de esquema fijo/validado; no concatenar entradas de usuario en SQL. Cerrar conexión y resultados. Una transacción, una conexión: el que abre confirma/revierte. Registro, empresa/rol, cita y cierre son operaciones atómicas.

Conservar columnas contraseña_hash y baños. Se permiten alias contrasena_hash y banos en SELECT para facilitar su lectura. imagen_propiedad.ruta es TEXT; se guardan referencias de fotografías.

La configuración auxiliar de la versión retirada no está implementada. El nombre comercial y almacenamiento se definirán al desarrollar sus bloques; no existe el endpoint /estado.

## 4. Sesión y seguridad — B2

| Clave de sesión | Tipo |
| --- | --- |
| idUsuario | Integer |
| roles | Set<String> |
| tokenFormulario | String |
| nombreUsuario | String (nombre que muestra la cabecera; B2 lo guarda al iniciar sesión) |

Roles: ADMINISTRADOR, INMOBILIARIA, CLIENTE. El visitante es anónimo.

**Datos base ya cargados** (`sql/02-datos-base.sql`, del coordinador; se puede ejecutar varias veces sin duplicar):

| Dato | Valor |
| --- | --- |
| Roles | `1 = ADMINISTRADOR`, `2 = INMOBILIARIA`, `3 = CLIENTE`. Buscar siempre por nombre, nunca por número |
| Administrador inicial | `admin@habita.com` / `Admin123`, con perfil «Administrador Habita» y rol ADMINISTRADOR. Solo para desarrollo: cambiar antes de publicar |

No borrar ni modificar estas filas en pruebas. Orden de ejecución de scripts: `01-esquema.sql` → `02-datos-base.sql` → `03-datos-prueba.sql` (B8) → `04-consultas.sql` (B7). Usuario multirrol mantiene todos los permisos, con panel inicial admin > inmobiliaria > cliente.

### seguridad.jspf (B2, implementado)

Controlador privado, en este orden:

~~~jsp
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Arrays,java.util.HashSet" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/modelo/propiedad.jspf" %>
<%
    request.setAttribute("rolesPermitidos", new HashSet<String>(Arrays.asList("INMOBILIARIA")));
%>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    // idUsuarioSesion (Integer) y rolesUsuario (Set<String>) ya existen aquí.
%>
~~~

En cada petición, el fragmento vuelve a leer de la base si la cuenta está activa y qué roles tiene. Por eso desactivar una cuenta o quitarle un rol surte efecto de inmediato, aunque la sesión siga abierta. ADMINISTRADOR entra a todo lo privado aunque no esté en `rolesPermitidos`. Si falla, hace forward a `acceso_denegado.jsp` y `return;`. Si la cuenta ya no existe o está desactivada, invalida la sesión. Actualiza `roles` en la sesión para que el menú coincida.

Deja declaradas `idUsuarioSesion` y `rolesUsuario`: el controlador no debe volver a declararlas. No escribir HTML antes de incluirlo.

Todas las acciones y descargas privadas también lo incluyen. El controlador comprueba pertenencia del registro, con validaciones del modelo antes de modificar datos. Administrador con acceso total conforme al parcial; empresa solo sus propiedades/trámites y cliente los suyos.

Comprobar token en cada POST antes de modificar. Al ingresar se renueva el ID de sesión (`request.changeSessionId()`); al salir se invalida. Registro público solo CLIENTE.

### Funciones de B2 para otros bloques

Todas reciben la `Connection` de quien llama, para compartir transacción.

| Modelo | Función | Devuelve |
| --- | --- | --- |
| usuario.jspf | `buscarUsuario(conexion, idUsuario)` | Map `idUsuario`, `correo`, `activo`, `nombres`, `apellidos`; `null` si no existe |
| | `crearUsuario(conexion, correo, hash)` | `int` id nuevo (23505 si el correo existe) |
| | `nombreCompleto(Map)` | Nombres y apellidos, o el correo si faltan |
| perfil.jspf | `buscarPerfil(conexion, idUsuario)` | Map `correo`, `nombres`, `apellidos`, `documento`, `telefono`, `direccion`, `foto` |
| usuario_rol.jspf | `rolesDeUsuario(conexion, idUsuario)` | `Set<String>` ordenado |
| | `asignarRol(conexion, idUsuario, "INMOBILIARIA")` | `true` si lo agregó; `false` si ya lo tenía. B3 lo usa dentro de su transacción de empresa |
| | `revocarRol(conexion, idUsuario, nombreRol)` | `true` si lo quitó |

Rutas de B2:

| Controlador | Acciones | Roles |
| --- | --- | --- |
| acceso.jsp | GET/POST `ingresar` · GET/POST `registro` · POST `salir` | Público |
| panel.jsp | Sin acción | Los tres |
| perfil.jsp | GET `ver` · POST `guardar` · POST `subir_foto` · GET `foto[&id_usuario=N]` (otra cuenta solo admin) | Los tres |
| usuario.jsp | GET `listar[&q&pagina]` · `nuevo` · `editar&id_usuario` · POST `crear` · `actualizar` · `cambiar_estado` | ADMINISTRADOR |
| usuario_rol.jsp | POST `asignar` · `revocar` (id_usuario, rol) | ADMINISTRADOR |
| rol.jsp | Sin acción | ADMINISTRADOR |

INMOBILIARIA no se asigna desde usuario_rol.jsp: el botón «Empresa» de la edición de usuario lleva a `inmobiliaria.jsp?accion=vincular&id_usuario=N` (B3). El administrador no puede desactivarse ni quitarse su propio rol, y ninguna cuenta queda sin roles.

### Empresas y catálogos (B3, implementado)

Funciones para B4 y los bloques siguientes. Reciben la `Connection` de quien llama. Los tres catálogos pueden incluirse en la misma página junto con los modelos de B2 (comprobado).

| Modelo | Función | Devuelve |
| --- | --- | --- |
| inmobiliaria.jspf | `buscarInmobiliariaPorUsuario(conexion, idUsuario)` | Map o `null`. Úsala para saber qué empresa publica: nunca aceptar `id_inmobiliaria` desde el formulario |
| | `buscarInmobiliaria(conexion, idInmobiliaria)` | Map `idInmobiliaria`, `idUsuario`, `nombre`, `identificacion`, `telefono`, `correoContacto`, `direccion`, `correoResponsable`, `responsable`, `activo` (cuenta responsable), `propiedades`; `null` si no existe |
| ciudad.jspf | `listarCiudades(conexion)` | `List<Map>` con `id`, `nombre` y `usos`, ordenada por nombre |
| tipo_propiedad.jspf | `listarTiposPropiedad(conexion)` | Igual: `id`, `nombre`, `usos` |
| caracteristica.jspf | `listarCaracteristicas(conexion)` | Igual: `id`, `nombre`, `usos` |

Rutas de B3:

| Controlador | Acciones | Roles |
| --- | --- | --- |
| inmobiliaria.jsp | GET `listar[&q&pagina]` · `vincular[&id_usuario]` · `editar&id_inmobiliaria` · POST `crear` · `actualizar&id_inmobiliaria` | ADMINISTRADOR |
| | GET `empresa` · POST `guardar_empresa` (sin acción, la inmobiliaria llega a `empresa`) | INMOBILIARIA |
| ciudad.jsp · tipo_propiedad.jsp · caracteristica.jsp | GET `listar` · `editar&id_<entidad>` · POST `crear` · `actualizar&id_<entidad>` · `eliminar&id_<entidad>` (campo `nombre`) | ADMINISTRADOR |

Reglas:
- **Vincular empresa:** una transacción con `asignarRol(…, "INMOBILIARIA")` y `crearInmobiliaria`. La cuenta debe estar activa y no tener empresa. Si algo falla, el rol también se revierte.
- **Datos de la empresa:** los cinco campos son obligatorios en la aplicación. La identificación se guarda en mayúsculas y el correo de contacto en minúsculas. La inmobiliaria edita su empresa pero no su identificación. El responsable no cambia y las empresas no se eliminan.
- **Catálogos:** nombres únicos sin distinguir mayúsculas. No se elimina lo que esté en uso. En características se bloquea en código, porque su relación con propiedades es ON DELETE CASCADE y borraría las asignaciones.
- **Búsqueda:** `patronBusqueda(texto)` pasó a utilidades.jspf; úsala con `ILIKE` en cualquier búsqueda.

### Publicaciones (B4, implementado)

| Modelo | Función | Devuelve |
| --- | --- | --- |
| propiedad.jspf | `buscarPropiedad(conexion, idPropiedad)` | Map con `idPropiedad`, `matricula`, `titulo`, `descripcion`, `direccion`, `precio`, `area`, `habitaciones`, `banos`, `operacion`, `estado`, `activa`, `destacada`, ciudad, tipo, empresa (`idInmobiliaria`, `inmobiliaria`, `telefonoEmpresa`, `correoContacto`, `idResponsable`) y `foto`; `null` si no existe |
| | `listarPropiedades(conexion, filtros, orden, limite, desplazamiento)` · `contarPropiedades(conexion, filtros)` | Filtros opcionales en un Map: `publicas`, `idCiudad`, `idTipoPropiedad`, `operacion`, `estado`, `precioMinimo`, `precioMaximo`, `texto`, `idInmobiliaria`, `destacada` y `caracteristicas` (List de ids: las exige todas) |
| | `actualizarDisponibilidad(conexion, idPropiedad, estado)` | **Para B6:** cambia el estado comercial dentro de su transacción de cierre |
| imagen_propiedad.jspf | `listarImagenes(conexion, idPropiedad)` | `List<Map>` con `idImagen` y `ruta`, en orden; la primera es la del catálogo |
| propiedad_caracteristica.jspf | `caracteristicasDePropiedad(conexion, idPropiedad)` · `idsCaracteristicas(…)` | Lista con `id`/`nombre` · `Set<Integer>` |

Rutas de B4:

| Controlador | Acciones | Roles |
| --- | --- | --- |
| inicio.jsp | Sin acción (index.jsp reenvía aquí) | Público |
| propiedad.jsp | GET `catalogo[&ciudad&tipo&operacion&precio_min&precio_max&caracteristica(varias)&q&orden&pagina]` · `detalle&id_propiedad` | Público |
| | GET `gestionar[&q&pagina]` · `nueva` · `editar&id_propiedad` · POST `crear` · `actualizar&id_propiedad` · `cambiar_activa&id_propiedad` | INMOBILIARIA dueña o ADMINISTRADOR |
| imagen_propiedad.jsp | POST `agregar&id_propiedad` (campo `ruta`) · `eliminar&id_propiedad&id_imagen` | INMOBILIARIA dueña o ADMINISTRADOR |

Reglas:
- **Pertenencia:** la empresa se toma de `buscarInmobiliariaPorUsuario`, nunca del formulario. Con una propiedad ajena se responde 403. El administrador entra a todas y es el único que elige empresa al publicar y que marca «destacada».
- **Visibilidad:** el catálogo muestra solo propiedades `activa` y `DISPONIBLE`. `activa` es baja lógica y se cambia aquí; el estado comercial lo cierra B6. Una publicación retirada solo la ven su empresa y el administrador.
- **Contacto:** el teléfono y el correo de la empresa se muestran solo con sesión iniciada.
- **Fotografías:** `ruta` admite un enlace `https://` o un archivo del proyecto bajo `img/` (jpg, png, svg o webp), validado con `rutaImagenValida`; hasta 8 por propiedad. Las vistas las muestran con `urlImagen(ctx, ruta)`, que usa `img/sin_foto.svg` cuando no hay.
- **Botones hacia B5 y B6** (rutas acordadas, visibles para CLIENTE en el detalle de una propiedad disponible): `cita.jsp?accion=nueva&id_propiedad=N`, `solicitud.jsp?accion=nueva&id_propiedad=N` y POST `favorito.jsp?accion=agregar&id_propiedad=N` con token.

### Favoritos y citas (B5, implementado)

| Modelo | Función | Devuelve |
| --- | --- | --- |
| favorito.jspf | `agregarFavorito(conexion, idCliente, idPropiedad)` · `quitarFavorito(…)` · `listarFavoritos(conexion, idCliente)` | `boolean` · `boolean` · `List<Map>` con las claves de las tarjetas del catálogo |
| cita.jspf | `buscarCita(conexion, idCita)` · `bloquearCita(…)` | Map con la cita, su propiedad, la empresa y el cliente |
| | `listarCitasCliente(conexion, idCliente)` · `listarCitasInmobiliaria(conexion, idInmobiliaria)` | `List<Map>`; con `null` como empresa, el administrador ve todas |
| | `crearCita(…)` · `cambiarEstadoCita(conexion, idCita, estado)` | `int` · `boolean` |

| Controlador | Acciones | Roles |
| --- | --- | --- |
| favorito.jsp | GET `listar` · POST `agregar&id_propiedad` · `quitar&id_propiedad` | CLIENTE |
| cita.jsp | GET `nueva&id_propiedad` · POST `crear&id_propiedad` (campos `fecha` y `hora`) · GET `mis_citas` · POST `cancelar&id_cita` | CLIENTE |
| | GET `recibidas` · POST `confirmar&id_cita` · `rechazar&id_cita` · `realizar&id_cita` | INMOBILIARIA dueña o ADMINISTRADOR |

Reglas: se agenda solo sobre propiedades activas y `DISPONIBLE`, en fecha futura. Además del índice `uq_cita_horario`, se comprueba que ni el cliente ni la empresa tengan otra cita activa a esa hora; el 23505 se traduce a «Ese horario ya está reservado». Orden de bloqueo: **propiedad → participantes**. Transiciones: el cliente cancela PENDIENTE o CONFIRMADA; la empresa confirma una PENDIENTE, rechaza PENDIENTE o CONFIRMADA y marca REALIZADA solo una CONFIRMADA ya pasada. Las acciones de estado van por POST con token; por GET responden 405.

### Solicitudes y documentos (B6, implementado)

| Modelo | Función | Devuelve |
| --- | --- | --- |
| solicitud.jspf | `buscarSolicitud` · `bloquearSolicitud` · `bloquearPropiedadSolicitud` | Map de la solicitud con propiedad, empresa y cliente |
| | `existeSolicitudAbierta(conexion, idCliente, idPropiedad)` · `crearSolicitud(…)` | `boolean` · `int` |
| | `listarSolicitudesCliente` · `listarSolicitudesInmobiliaria(conexion, idInmobiliaria)` | `List<Map>`; `null` como empresa lista todas |
| | `cambiarEstadoSolicitud(conexion, id, estado, observacion)` · `rechazarOtrasSolicitudesAbiertas(conexion, idPropiedad, idFinalizada)` | `boolean` · `int` |
| documento_solicitud.jspf | `listarDocumentosSolicitud` · `buscarDocumentoSolicitud` · `bloquearDocumentoSolicitud` · `crearDocumentoSolicitud` · `revisarDocumentoSolicitud` | Documentos del trámite y su revisión |

| Controlador | Acciones | Roles |
| --- | --- | --- |
| solicitud.jsp | GET `nueva&id_propiedad` · POST `crear&id_propiedad` (campo `observacion`) · GET `mis_solicitudes` · `detalle&id_solicitud` | CLIENTE dueño |
| | GET `recibidas` · POST `revisar&id_solicitud` (`estado` APROBADA o RECHAZADA y `observacion`) · `finalizar&id_solicitud` | INMOBILIARIA dueña o ADMINISTRADOR |
| documento_solicitud.jsp | POST `subir&id_solicitud` (multipart: `nombre` y `archivo`) | CLIENTE dueño |
| | POST `revisar&id_documento` (`estado` APROBADO o RECHAZADO y `observacion`) | INMOBILIARIA dueña o ADMINISTRADOR |
| | GET `descargar&id_documento` | Cliente dueño, empresa propietaria o ADMINISTRADOR |

Reglas:
- **Radicación:** solo sobre propiedades activas y `DISPONIBLE`, y sin otra solicitud abierta (PENDIENTE o APROBADA) del mismo cliente sobre esa propiedad.
- **Revisión:** aprobar exige que la solicitud esté PENDIENTE y la propiedad siga disponible; rechazar admite PENDIENTE o APROBADA. Siempre con observación.
- **Cierre:** una sola transacción que bloquea **propiedad → solicitud**, marca FINALIZADA, llama a `actualizarDisponibilidad` (VENDIDA o ARRENDADA según la operación) y deja las demás solicitudes abiertas como RECHAZADA con la observación «La propiedad fue cerrada en otra solicitud». Solo se finaliza una solicitud APROBADA sobre una propiedad DISPONIBLE.
- **Documentos:** PDF de hasta 5 MB, comprobados por la firma `%PDF-`, guardados con nombre generado en `carpetaArchivos(application)/solicitudes/`. La descarga pasa siempre por el controlador. `documento_solicitud.jsp` está registrado con `multipart-config` en web.xml (5 MB por archivo, 6 MB por petición).

### Reportes y auditoría (B7, implementado e integrado)

| Modelo | Función | Devuelve |
| --- | --- | --- |
| reporte.jspf | `listarReportePropiedades` · `listarReporteCitas` · `listarReporteSolicitudes` · `listarReporteFinalizadas` `(conexion, idInmobiliaria)` | `List<Map>`; con `null` como empresa, el consolidado |
| auditoria.jspf | `registrarEvento(conexion, idUsuario, accion)` | Inserta el evento; `idUsuario` puede ser `null`; `accion` de 1 a 255 caracteres |
| | `listarAuditoria` · `contarAuditoria` `(conexion, usuario, texto, desde, hastaExclusiva, …)` | Consulta con filtros y paginación |

| Controlador | Acciones | Roles |
| --- | --- | --- |
| reporte.jsp | GET `general` | ADMINISTRADOR |
| | GET `empresa` (la empresa sale de la sesión) | INMOBILIARIA |
| auditoria.jsp | GET `listar[&usuario&q&desde&hasta&pagina]` (solo lectura) | ADMINISTRADOR |

**Eventos registrados.** Formato: `EVENTO · detalle`, con el autor en `id_usuario`.

| Controlador | Eventos |
| --- | --- |
| acceso.jsp | `INGRESO`, `INGRESO_FALLIDO` (con la cuenta si existe, o sin usuario), `INGRESO_BLOQUEO` (inicio de un bloqueo), `INGRESO_BLOQUEADO` (intento durante el bloqueo), `CIERRE_SESION`, `REGISTRO` |
| usuario.jsp · usuario_rol.jsp | `USUARIO_CREADO`, `USUARIO_ACTUALIZADO` (indica si cambió la clave), `USUARIO_ACTIVADO`, `USUARIO_DESACTIVADO`, `ROL_ASIGNADO`, `ROL_REVOCADO` |
| inmobiliaria.jsp | `EMPRESA_VINCULADA`, `EMPRESA_ACTUALIZADA` |
| propiedad.jsp | `PROPIEDAD_PUBLICADA`, `PROPIEDAD_EDITADA`, `PROPIEDAD_RETIRADA`, `PROPIEDAD_REACTIVADA` |
| cita.jsp | `CITA_SOLICITADA`, `CITA_CONFIRMADA`, `CITA_RECHAZADA`, `CITA_REALIZADA`, `CITA_CANCELADA` |
| solicitud.jsp · documento_solicitud.jsp | `SOLICITUD_RADICADA`, `SOLICITUD_APROBADA`, `SOLICITUD_RECHAZADA`, `SOLICITUD_FINALIZADA`, `DOCUMENTO_SUBIDO`, `DOCUMENTO_APROBADO`, `DOCUMENTO_RECHAZADO` |

Reglas:
- **Momento del registro:** el evento se registra con la misma `Connection`, después del cambio y antes del `commit`. Si la operación se revierte, el evento también; las acciones rechazadas no dejan evento.
- **Cierre de sesión:** nunca se bloquea por un fallo de auditoría.
- **Bloqueo de ingreso:** tras 5 intentos fallidos seguidos para un mismo correo, el ingreso queda bloqueado 5 minutos desde el quinto intento; durante ese tiempo tampoco entra la clave correcta. El conteo vuelve a cero con un ingreso correcto o al empezar un bloqueo, y los intentos hechos durante el bloqueo no lo alargan. Se aplica al correo escrito, exista o no la cuenta, para no revelar qué cuentas existen. Se calcula con los eventos de auditoría mediante `segundosBloqueoIngreso` e `intentosFallidosSeguidos` (auditoria.jspf); los límites son constantes en acceso.jsp.
- **Integridad:** la auditoría no se edita ni se borra desde la aplicación. Como `auditoria.id_usuario` es ON DELETE RESTRICT, una cuenta con eventos no se puede borrar; la aplicación solo desactiva cuentas.
- **Operaciones nuevas:** toda operación que modifique datos debe registrar su evento con esta misma forma.

## 5. Rutas y parámetros

Los enlaces y formularios apuntan a /controlador/<entidad>.jsp, nunca directamente a las vistas. Usar el contexto de aplicación. Los modelos se incluyen estáticamente en el controlador; las vistas reciben los resultados mediante atributos de petición y forward.

Ejemplo implementado: GET /controlador/propiedad.jsp?accion=detalle&id_propiedad=5 → modelo/propiedad.jspf → vista/propiedad.jsp.

GET consulta; POST modifica. Cada controlador publica sus acciones, parámetros, roles y atributos para la vista. Tras un POST correcto redirige a una acción GET. Los identificadores de cliente/empresa no se aceptan sin contrastarlos con la sesión y pertenencia.

La propiedad de archivos está en PLAN_DELEGACION.md. No crear rutas por rol ni modelos/consultas duplicados para admin y cliente. Filtrar los datos y habilitar acciones según permisos.

## 6. Mensajes y presentación

Errores por campo en atributo de petición `errores` (Map<String,String>); la clave `general` se muestra como aviso rojo en la cabecera. Valores previos en `valores` (Map<String,String>). Tras una redirección: sesión `mensaje` (aviso verde) o `mensajeError` (aviso rojo), String; la cabecera los muestra una vez y los borra. B1 presenta; el controlador escribe.

Escapar textos procedentes de usuario/BD antes de HTML. Traducir duplicados 23505, FK 23503, RESTRICT 23001 y CHECK 23514 a mensajes claros. No exponer trazas SQL ni claves.

### Presentación (B1, implementado)

Diseño vigente: **Habita**, «Encuentra tu próximo espacio» y paleta Figma: verde bosque `#243B32`, terracota `#C96E4B`, oliva `#83946A`, arena `#E8D8C4`, crema `#F7F2E8` y carbón `#252525`. Bootstrap 5.3.3 y Bootstrap Icons 1.11.3 están guardados en local (`css/`, `js/`): no usar CDN. Los recursos de marca y las fotografías seleccionadas están en `img/habita/`. El código React, TypeScript y Tailwind de Figma no se incorpora; se adapta a JSP/JSPF, HTML, CSS y Bootstrap local. Muestra de componentes en `controlador/prueba_diseno.jsp` (solo en el propio equipo).

Toda vista empieza así:

~~~jsp
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Mis citas";
    String menuActivo = "citas";
    boolean vistaPanel = true;   // true: panel con menú lateral · false: página pública
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
  ... contenido ...
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
~~~

La cabecera declara `ctx`, `haySesion`, `rolesSesion` y `nombreSesion`: la vista puede usarlos pero no volver a declararlos. En páginas públicas el contenido va dentro de `<div class="container py-4">`; en el panel ya tiene márgenes.

| Componente | Clases |
| --- | --- |
| Botón principal / marca / secundario | `btn btn-primary` (terracota) · `btn btn-marca` (verde bosque) · `btn btn-outline-primary` |
| Título de página | `h1.h3.titulo-pagina` |
| Tarjeta de propiedad | `card tarjeta-propiedad`, imagen `img.foto` (usar `img/sin_foto.svg` si no hay foto), precio `.precio`, datos `.datos`. Rejilla `row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4` |
| Tabla de administración | `table tabla-habita` dentro de `.table-responsive`; celda de botones `td.acciones` |
| Estado | `<span class="estado estado-<%= estado %>"><%= estado %></span>` con el valor exacto del SQL, más `ACTIVA`/`INACTIVA` |
| Campo con error | `is-invalid` en el campo y `<div class="invalid-feedback">` debajo |
| Lista vacía | `<div class="vacio"><i class="bi bi-..."></i> Texto</div>` |
| Portada y buscador | `section.portada` y `form.buscador-rapido` |

Destinos del menú: cada dueño implementa la acción indicada (o pide al coordinador cambiar el enlace).

| Menú | Enlace | menuActivo |
| --- | --- | --- |
| Inicio · Catálogo | raíz `/` · `propiedad.jsp?accion=catalogo` | `inicio` · `catalogo` |
| Iniciar sesión · Registrarse · Cerrar sesión (POST con token) | `acceso.jsp?accion=ingresar` · `accion=registro` · `accion=salir` | — |
| Mi panel · Mi perfil | `panel.jsp` · `perfil.jsp?accion=ver` | `panel` · `perfil` |
| Admin: Usuarios · Inmobiliarias · Catálogos · Reportes · Auditoría | `usuario.jsp?accion=listar` · `inmobiliaria.jsp?accion=listar` · `ciudad.jsp?accion=listar` · `reporte.jsp?accion=general` · `auditoria.jsp?accion=listar` | `usuarios` · `inmobiliarias` · `catalogos` · `reportes` · `auditoria` |
| Inmobiliaria: Mi empresa · Mis propiedades · Citas recibidas · Solicitudes recibidas · Reportes | `inmobiliaria.jsp?accion=empresa` · `propiedad.jsp?accion=gestionar` · `cita.jsp?accion=recibidas` · `solicitud.jsp?accion=recibidas` · `reporte.jsp?accion=empresa` | `empresa` · `propiedades` · `citas_recibidas` · `solicitudes_recibidas` · `reportes_empresa` |
| Cliente: Favoritos · Mis citas · Mis solicitudes | `favorito.jsp?accion=listar` · `cita.jsp?accion=mis_citas` · `solicitud.jsp?accion=mis_solicitudes` | `favoritos` · `citas` · `solicitudes` |

Páginas de error: `WEB-INF/vista/acceso_denegado.jsp` (403) y `WEB-INF/vista/error.jsp` (404 y 500), registradas en web.xml. seguridad.jspf llega a acceso denegado con `forward` a esa vista, porque WEB-INF no es accesible por redirección.

No crear menu.jspf ni mensajes.jspf separados. Las peticiones de estilos comunes se entregan a B1, sin crear carpetas de CSS por bloque.

### Detalles de JSP comprobados en este Tomcat

- Las JSP compilan con nivel **Java 7**: no usar lambdas ni referencias a métodos (una lambda da error 500).
- `trim-directive-whitespaces` borra el espacio que queda solo entre dos `<%= %>`. Escribir el espacio dentro de la expresión (`<%= a + " " + b %>`) o separar con una clase como `me-1`.
- Los `.jspf` se leen en UTF-8 porque web.xml los incluye en la regla de codificación; al crear otra extensión, agregarla allí.

## 7. Claves, archivos y fechas

Formato de hash: pbkdf2-sha256$120000$salBase64$hashBase64, PBKDF2WithHmacSHA256 con sal aleatoria de 16 bytes y salida de 256 bits. Verificado también con una implementación independiente (.NET).

B8 obtiene un hash válido de `Clave123` en `controlador/prueba_conexion.jsp` (fila «Clave PBKDF2»). Puede usarlo en los usuarios de prueba: cada recarga genera otro distinto y todos son válidos.

Fotos de propiedades mediante enlaces HTTPS validados; demostrar acceso de visitante y tipo de visualización. No descargar URLs arbitrarias desde el servidor. Documento privado mediante carga PDF y foto de perfil JPG/PNG; límites se acuerdan antes de implementar.

Subida de archivos (verificada por B0 con `controlador/prueba_subida.jsp`). En Tomcat 8.5 una JSP solo recibe archivos si se registra en web.xml con `<multipart-config>`:

~~~xml
<servlet>
    <servlet-name>documentoSolicitud</servlet-name>
    <jsp-file>/controlador/documento_solicitud.jsp</jsp-file>
    <multipart-config>
        <max-file-size>10485760</max-file-size>
        <max-request-size>11534336</max-request-size>
    </multipart-config>
</servlet>
<servlet-mapping>
    <servlet-name>documentoSolicitud</servlet-name>
    <url-pattern>/controlador/documento_solicitud.jsp</url-pattern>
</servlet-mapping>
~~~

Ya registrados: `pruebaSubida` y `perfil` (foto JPG/PNG, 2 MB; el tipo se comprueba por los primeros bytes, no por el nombre). B6 pide el suyo al coordinador; no edita web.xml. En la JSP: `Part archivo = request.getPart("archivo")` dentro de `try/catch (IllegalStateException)`, que indica archivo demasiado grande. El token del formulario se lee con `tokenValido` como siempre. Comprobado: nombres con ñ, archivos de 3 MB y rechazo claro por encima del límite.

Los archivos se guardan con nombre generado en `carpetaArchivos(application)`. La ruta se configura en el `context-param rutaArchivos` de web.xml; vacío = `WEB-INF/archivos`, que no es accesible por URL y está excluida de Git. La descarga pasa siempre por un controlador autorizado.

Fechas interpretadas en America/Bogota, importes COP con BigDecimal, baños enteros. No inventar cantidad de estacionamientos ni fecha de registro.

## 8. Operaciones que cruzan bloques

B3 posee la vinculación empresa/cuenta y asignación inicial del rol INMOBILIARIA. B2 posee la gestión general de roles y enlaza hacia el controlador de inmobiliaria cuando se necesite empresa. Las funciones de modelo que deban compartir transacción reciben la misma Connection.

B6 dirige la finalización desde su controlador: el modelo verifica/bloquea solicitud e inmueble y realiza los cambios en una transacción. B4 entrega una función de modelo para actualizar disponibilidad con la conexión recibida; B6 la usa sin editar archivos ajenos ni duplicar reglas.

B5 comprueba cruces de cliente y responsable además del índice propiedad/horario. Antes de publicar esas acciones, el coordinador acuerda una estrategia de bloqueos con orden consistente que cubra recursos compartidos; no basta consultar disponibilidad y luego insertar.

Para operaciones sobre un inmueble, coordinar propiedad → solicitud → cita y validar también bajas y cierre frente a nuevas reservas. Si hacen falta bloqueos de usuario/empresa para cruces entre inmuebles, fijar su orden común antes de implementar B5/B6.

La auditoría se implementó al final, en B7 (WEB-INF/modelo/auditoria.jspf, su controlador y su vista). Después, el coordinador incorporó las llamadas de registro en los controladores de B2 a B6 (ver «Reportes y auditoría» en la sección 4). Los eventos empiezan desde esa integración: no se inventaron eventos anteriores.

## 9. Estados exactos

| Dato | Valores |
| --- | --- |
| Operación | VENTA, ARRIENDO |
| Propiedad | DISPONIBLE, VENDIDA, ARRENDADA |
| Cita | PENDIENTE, CONFIRMADA, REALIZADA, CANCELADA, RECHAZADA |
| Solicitud | PENDIENTE, APROBADA, RECHAZADA, FINALIZADA |
| Documento | PENDIENTE, APROBADO, RECHAZADO |

propiedad.activa es independiente del estado comercial. No borrar historia para liberar citas. Las transiciones y el tratamiento de otras solicitudes al cerrar se documentan antes de automatizarlas.

## 10. Estado de los acuerdos

No utilizar los antiguos nombres Conexion.obtener, AuditoriaDAO, Textos.escapar, Mensajes ni Sesion: esas clases fueron retiradas. No reemplazarlas con nuevas clases equivalentes.

B0 a B8 están terminados e integrados, incluida la auditoría en las operaciones. Falta B9 (integración final, evidencias y sustentación). Se comprueba cada cambio de forma breve y se deja la revisión global para B9. La auditoría no bloquea el avance de otros módulos. Cada cambio de contrato se solicita al coordinador y se incorpora antes de que lo consuma otro bloque.
