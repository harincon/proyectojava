# Proyecto Java: aplicación inmobiliaria

Aplicación académica para publicar inmuebles, buscar propiedades, agendar visitas y tramitar solicitudes de compra o arriendo.

## Estado actual

- Base de datos: PostgreSQL, 16 tablas y 18 relaciones FK.
- [SQL vigente](sql/01-esquema.sql): conserva contraseña_hash, baños e imagen_propiedad.ruta de tipo TEXT.
- Driver JDBC conservado en WEB-INF/lib.
- B0 (base común en JSP/JSPF) terminado y verificado en Tomcat 8.5.96: conexión, utilidades, subida de archivos y pruebas de diagnóstico.
- B1 (diseño) terminado: **Habita**, paleta verde bosque, terracota, oliva, arena y crema, Bootstrap en local, cabecera, pie, menú por roles y páginas de error. Muestra: `http://localhost:8080/proyectojava/controlador/prueba_diseno.jsp`.
- B2 (acceso, usuarios, roles y perfil) terminado: ingreso y registro, panel por roles, perfil con foto y administración de usuarios. Entrada: `http://localhost:8080/proyectojava/controlador/acceso.jsp?accion=ingresar` (desarrollo: `admin@habita.com` / `Admin123`).
- B8 (datos de prueba) integrado y cargado: 20 usuarios (`Clave123`), 10 inmobiliarias, 20 propiedades, citas y solicitudes.
- B3 (empresas y catálogos) terminado: inmobiliarias con su cuenta responsable, Mi empresa y catálogos de ciudades, tipos y características.
- B4 (inicio y publicaciones) terminado: portada, catálogo con filtros, detalle con galería y publicación de propiedades con fotografías y características.
- B5 (favoritos y citas) terminado: agendar visitas sin cruces de horario, confirmar, rechazar, realizar y cancelar.
- B6 (solicitudes y documentos) terminado: radicar, revisar, documentos PDF privados y cierre que marca el inmueble como vendido o arrendado.
- B7 (reportes y auditoría) terminado: reportes por rol y auditoría que registra ingresos, cambios de cuentas y roles, empresas, propiedades, citas, solicitudes y documentos.
- B9 (integración y entrega) terminado: 30 comprobaciones funcionales, 17 capturas reales, casos de uso, guía de ejecución, evidencia Scrum, historial y presentación. Ver [entrega final](varios/documentacion/entrega/README.md).
- Después de cargar `sql/03-datos-prueba.sql`, generar los PDF de ejemplo de los documentos sembrados: `powershell -ExecutionPolicy Bypass -File varios\herramientas\generar-pdf-ejemplo.ps1` (pide la contraseña de PostgreSQL). Los archivos quedan en `WEB-INF/archivos/`, que no se sube a Git.
- En otro equipo, copiar `WEB-INF/jspf/conexion.jspf.ejemplo` como `conexion.jspf` y completar la contraseña. Diagnóstico local: `http://localhost:8080/proyectojava/controlador/prueba_conexion.jsp`.

## Forma de trabajo elegida

Páginas .jsp, fragmentos .jspf, JDBC, HTML5, CSS3, JavaScript, Bootstrap, Tomcat y PostgreSQL. WEB-INF/web.xml configura la aplicación; los controladores comprobarán sesión, roles y pertenencia antes de ejecutar acciones.

Priorizar JSP/JSPF para toda función que pueda resolverse en servidor: formularios, búsquedas, filtros, paginación, validación, permisos y cambios de estado. JavaScript se limita al uso obligatorio del parcial y a interacciones de navegador que lo necesiten; no duplicar la lógica de negocio en archivos .js.

Se adopta una separación MVC con JSP/JSPF: controlador recibe peticiones, modelo opera los datos y vista presenta. Los controladores privados incluyen seguridad.jspf, que comprueba sesión, cuenta activa y roles. El requisito de Filter sigue pendiente; no se considera resuelto por esta estructura.

## Organización

La carpeta proyectojava/ ya es la raíz pública de Tomcat. controlador/ contiene las acciones JSP; WEB-INF/modelo/ las operaciones de datos en JSPF; WEB-INF/vista/ las pantallas JSP. WEB-INF/jspf/ contiene los fragmentos comunes. Los roles son permisos, no carpetas. CSS, JavaScript e imágenes conservan sus directorios.

El PDF de Figma se encuentra junto a los demás PDF en varios/referencias/. `index.jsp` sirve la portada pública vigente.

La auditoría y la revisión global se completaron en B7 y B9.

## Documentos

Este README es la entrada general. Para un tema puntual, va directo al documento especializado:

| Para esto | Ir a |
| --- | --- |
| Entregar o sustentar el proyecto (informe, pruebas, casos de uso, guía de ejecución, capturas, presentación) | [Entrega final B9](varios/documentacion/entrega/README.md) |
| Consultar las reglas técnicas y los contratos entre módulos (sesión, seguridad, funciones de modelo, rutas) | [Acuerdos para los bloques](varios/planificacion/CONTRATOS.md) |
| Entender el modelo de datos, el diccionario y la 3FN | [Documentación de la base de datos](varios/documentacion/base-datos/README.md) |
| Ver cómo se repartió el trabajo por bloques (B0–B9) y su estado | [Plan de delegación](varios/planificacion/PLAN_DELEGACION.md) |
| Ver el plan técnico original | [Plan de implementación](varios/planificacion/PLAN_IMPLEMENTACION.md) |
| Ver el material de referencia (parcial, simulacro, Figma, créditos de fotos) | [varios/referencias/](varios/referencias/) |

Los PDF, diagramas y documentación se agrupan en varios/. La BD no se modifica por el cambio de organización de la aplicación.

La conexión se configura en WEB-INF/jspf/conexion.jspf, sin archivos de propiedades. Se incluye una sola vez en la unidad JSP que lo necesite y se llama abrirConexion(); quien la abre debe cerrarla. Las vistas no abren conexiones. El fragmento está excluido de Git por sus credenciales: al compartir o desplegar el proyecto se debe suministrar una copia sin claves reales y completar los datos del ambiente de forma privada.
