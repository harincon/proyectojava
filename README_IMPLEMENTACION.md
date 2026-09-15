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
| Nueva base B0 | Conexión creada; utilidades, seguridad y diagnóstico JSP pendientes |

La comprobación técnica /estado y los contratos de base-B0-v1 ya no están disponibles. Las pruebas anteriores de esa versión no certifican la futura base JSP.

## Próximo paso

Completar B0 cuando se autorice: utilidades.jspf y controlador/prueba_conexion.jsp; verificar ejecución de las JSP en Tomcat y publicar los acuerdos de funciones compartidas. La conexión ya está centralizada. Después se habilitan B1, B2 y B8 según sus dependencias.

Se retiraron los dos archivos de propiedades y su carpeta config. conexion.jspf conserva los datos de conexión, fija currentSchema=inmobiliaria y está excluido de Git por contener credenciales. La prueba ejecutó su función por JDBC y confirmó 16 tablas; no fue una prueba HTTP de JSP en Tomcat.

Se trasladó el PDF Figma a varios/referencias/ y se usa index.jsp como entrada temporal. Por la última instrucción del estudiante, se retiraron las carpetas vacías por rol y se crearon controlador/, WEB-INF/modelo/ y WEB-INF/vista/. Se conservan recursos y fragmentos comunes. Esta modificación solo organiza carpetas y documentación; no implementa lógica.

La auditoría se aplaza a B7, después de los módulos principales. La revisión global y las evidencias se preparan al final; durante el desarrollo solo se comprueba el cambio y se registra un resumen breve por bloque.

Se incorporó a los planes y contratos la preferencia por JSP/JSPF para todo lo viable en servidor, con JavaScript mínimo. Este ajuste solo documenta la decisión; no implementa funciones nuevas.

La limpieza no implementó login, seguridad.jspf, propiedades ni los demás módulos. El nombre Habita y los ajustes de diseño siguen siendo propuestas.

La estructura actual separa modelo, vista y controlador manteniendo JSP/JSPF. La implementación de esa separación y el requisito Filter están pendientes; esta organización no los da por terminados.

Se probó un filtro de servlet en una clase Java (AccesoFilter). Por decisión del estudiante se retiraron su código, sus compilados y su registro en web.xml, para mantener la forma del simulacro: la seguridad se hará con seguridad.jspf incluido en cada controlador privado. Se conservó en web.xml la opción trim-directive-whitespaces, que también usa el simulacro.

[Plan de delegación](varios/planificacion/PLAN_DELEGACION.md) · [Acuerdos](varios/planificacion/CONTRATOS.md) · [SQL](sql/01-esquema.sql).
