# Delegación — estructura MVC con JSP/JSPF

Revisión: 14 de septiembre de 2026. Organización por modelo, vista y controlador, no por roles. Solo se están preparando carpetas; no se autoriza implementar módulos con esta revisión. Mantener JSP/JSPF sin clases Java propias.

## Reglas comunes

- Leer [plan general](PLAN_IMPLEMENTACION.md), [acuerdos](CONTRATOS.md), [SQL](../../sql/01-esquema.sql) y [simulacro](../referencias/SIMULACRO_PARCIAL_PRACTICO_Aplicacion_Web_JSP_Restaurante.pdf).
- El [PDF de Figma](../referencias/Sin%20título.pdf) orienta lo visual con los ajustes del plan; no agregar campos o funciones solo por la plantilla.
- proyectojava/ ya es la raíz pública de Tomcat. No anidar otra carpeta web/.
- Un dueño por archivo mientras se trabaja. El coordinador integra; no sustituir todo el proyecto con la copia de otra IA.
- Priorizar JSP/JSPF frente a JavaScript: formularios GET/POST, filtros, paginación, validación y decisiones en servidor. B1 solo incorpora JavaScript indispensable para interacción del navegador y para el requisito del parcial; no añadir validaciones.js, AJAX ni lógica de negocio cliente por defecto.
- Cada bloque comprueba lo que cambia y entrega archivos, resultado y pendientes en un mensaje breve. El coordinador actualiza README_IMPLEMENTACION.md una vez por bloque.
- No crear informes, carpetas de evidencias ni auditorías por cada pequeño cambio. La revisión global y la evidencia final corresponden a B9; los registros Scrum se mantienen por sprint.
- No cambiar el SQL ni escribir en la BD compartida para hacer pruebas sin coordinación.
- La auditoría de accesos/cambios se incorpora al final, en B7, una vez terminados los módulos principales. No es dependencia de B0–B6.
- Las vistas no ejecutan SQL, el modelo no genera HTML y los controladores reciben las peticiones. El requisito Filter continúa pendiente, sin considerarlo resuelto por la estructura.

## Bloques y archivos exclusivos

M = WEB-INF/modelo; C = controlador; V = WEB-INF/vista. Los archivos de M usan .jspf, los de C y V usan .jsp. Los nombres de entidad de la tabla asignan tanto su modelo como su controlador al mismo dueño; se listan aparte las vistas.

| Bloque | Trabajo | Archivos exclusivos previstos |
| --- | --- | --- |
| B0 | Base común — **terminado** | WEB-INF/web.xml, WEB-INF/jspf/conexion.jspf, conexion.jspf.ejemplo y utilidades.jspf; controlador/prueba_conexion.jsp y prueba_subida.jsp |
| B1 | Diseño | css/, js/, img/; WEB-INF/jspf/cabecera.jspf y pie.jspf; V/acceso_denegado.jsp y error.jsp |
| B2 | Acceso, usuarios/roles y perfil | M y C: usuario, rol, usuario_rol, perfil. C/acceso.jsp y panel.jsp. V/login.jsp, registro.jsp, panel.jsp, perfil.jsp, usuarios.jsp, formulario_usuario.jsp y roles.jsp. WEB-INF/jspf/seguridad.jspf |
| B3 | Empresas y catálogos | M y C: inmobiliaria, ciudad, tipo_propiedad, caracteristica. V/inmobiliarias.jsp, formulario_inmobiliaria.jsp y catalogos.jsp |
| B4 | Inicio y publicaciones | M y C: propiedad, imagen_propiedad, propiedad_caracteristica. index.jsp, C/inicio.jsp. V/inicio.jsp, catalogo.jsp, propiedad.jsp, propiedades.jsp y formulario_propiedad.jsp |
| B5 | Favoritos y citas | M y C: favorito, cita. V/favoritos.jsp, citas.jsp y formulario_cita.jsp |
| B6 | Solicitudes/documentos | M y C: solicitud, documento_solicitud. V/solicitudes.jsp, formulario_solicitud.jsp y solicitud.jsp |
| B7 | Reportes y auditoría final | M y C: reporte, auditoria. V/reportes.jsp y auditoria.jsp; sql/03-consultas.sql |
| B8 | Datos y documentación BD | sql/02-datos-prueba.sql; varios/documentacion/base-datos/ |
| B9 | Integración y cierre | Documentación, pruebas finales, Scrum y README mediante el coordinador |

Cabecera reúne menú y avisos; no crear fragmentos visuales adicionales por cada rol. Auditoría se implementa en B7; el coordinador integra las llamadas en operaciones ya terminadas, sin edición simultánea de esos archivos.

Cada bloque desarrolla su modelo, controlador y vistas cuando se autorice. No crear páginas vacías por completar el árbol. Las vistas se reutilizan según los permisos y los datos que suministra el controlador.

## Orden para delegar

| Momento | Encargos | Requiere |
| --- | --- | --- |
| 1 | B0 — terminado | Verificado en Tomcat 8.5.96 |
| 2 | B1, B2 y B8 en paralelo | B0 integrado; B2 espera componentes B1 para su cierre visual |
| 3 | B3 | Acceso de B2; coordinar empresa y rol antes de aceptar ambos |
| 4 | B4 | B1, B2 y B3 integrados |
| 5 | B5 y B6 en paralelo | B4 completo |
| 6 | B7 y cierre B8 | Módulos principales implementados |
| 7 | B9 y correcciones por dueño | Entregas integradas |

B8 usa el formato de claves que entrega B0. B9 acompaña la integración con comprobaciones breves; no exige una auditoría completa para avanzar de un bloque a otro.

## Qué debe entregar cada bloque

**B0:** conexión y utilidades compartidas sencillas, UTF-8, hash con sal, escape y token de formularios. Prueba de conexión en JSP. Carga de archivos solo se verifica en lo necesario para habilitar perfil/documentos; no implementar sus módulos ni auditoría.

**B1:** apariencia aprobada de Figma, componentes reutilizables, tamaños adaptables, formularios/errores legibles. Cabecera pública con registro/login y privada con roles/logout. Pie interno breve. No crear blog, chat ni enlaces vacíos.

**B2:** registro transaccional usuario/perfil/CLIENTE; login/logout, permisos actuales, activación y varios roles. Perfil con documento y foto. seguridad.jspf se incluye en el controlador antes de invocar el modelo o mostrar una vista. Comprobar también pertenencia y duplicados. B3 completa empresa/rol.

**B3:** empresa con responsable único, identificación empresarial, contacto y dirección. Ciudades/tipos/características administrables y errores claros por duplicados/referencias. El controlador de inmobiliaria solicita al modelo la vinculación de empresa y rol en una transacción; B2 enlaza hacia esa acción.

**B4:** inicio, destacados, catálogo y detalle; filtros ciudad/tipo/operación/precio/características, limpiar y paginar. Formulario completo con matrícula, dirección, características y enlaces de imágenes. Baja lógica, permisos de dueño y contacto restringido al visitante. Verificar si el enlace de Drive muestra visor o imagen. B4 pone botones hacia B5/B6 usando las rutas acordadas.

**B5:** favoritos sin duplicados; citas futuras, cancelar, confirmar, rechazar y realizar. Comprobar cruces de propiedad, cliente y responsable; coordinar concurrencia con B6. No documentos ni observaciones de solicitud dentro de citas.

**B6:** radicación y documentos PDF privados, consulta de estados, revisión/aprobación/rechazo y observaciones. El controlador de documento_solicitud permite descarga solo a cliente dueño, empresa propietaria y administrador. Finalización en una sola transacción cambia solicitud e inmueble y no permite cierres duplicados. Sin pagos ni facturación.

**B7:** reportes de propiedades por ciudad/estado, citas por estado, solicitudes por empresa y ventas/arriendos finalizados. Cinco consultas mínimas: dos INNER JOIN de tres o más tablas, N:M, LEFT JOIN y GROUP BY/HAVING. Al terminar los módulos, incorporar auditoría y su consulta admin.

Para auditoría, el coordinador reserva temporalmente los archivos de acciones ya terminados, añade los puntos de registro y devuelve su propiedad. Las IA no editan esos archivos a la vez. No se inventan eventos previos: los eventos reales comienzan al incorporar la función y los recorridos se comprueban nuevamente al final.

**B8:** mínimo diez registros por tabla principal, roles/tipos reales y claves compatibles. MER, relacional, diccionario y 3FN conforme al SQL; conservar la imagen aportada y actualizar solo lo acordado. No recrear esquemas anteriores.

**B9:** recorrido completo y pruebas unitarias/funcionales exigidas, permisos, concurrencia, JDBC local/remoto, responsive, consultas y auditoría ya incorporada. Casos de uso, presentación como simulacro, guía de ejecución, capturas reales y sustentación. Conservar evidencia Scrum de tres sprints de siete días, Git/tablero/Padlet; no inventar reuniones ni publicar sin autorización.

## Forma de trabajo

Una rama o copia por IA desde la misma versión aceptada. Si comparten carpeta, cada una toca solo sus archivos; las pruebas en Tomcat y escrituras sobre una misma BD se coordinan. Los cambios de seguridad/estilo/utilidades compartidas se piden al dueño.

No se añaden nuevas tablas, servicios, librerías o carpetas por preferencia de una IA. La auditoría no se adelanta ni se añade como condición para registro, propiedades, citas o solicitudes.

## Mensaje listo para delegar

~~~text
Autorizo únicamente B[n] del PLAN_DELEGACION.md revisado para JSP/JSPF.

Use controlador/ para acciones JSP, WEB-INF/modelo/ para operaciones JSPF,
WEB-INF/vista/ para pantallas JSP y WEB-INF/jspf/ para fragmentos comunes.
No organice carpetas por rol. Respete sus archivos y la separación MVC.
Resuelva con JSP/JSPF todo lo viable en servidor. Limite JavaScript al mínimo
necesario para el navegador y al requisito del parcial; no duplique lógica.

Compruebe que sus dependencias estén integradas. No cree clases Java propias,
subcarpetas innecesarias, archivos vacíos ni auditoría anticipada.

Al terminar, entregue archivos, una comprobación breve y pendientes.
La revisión global y las evidencias se harán al final en B9.
No comience otro bloque sin que se lo asigne.
~~~
