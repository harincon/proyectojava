# Proyecto Java: aplicación inmobiliaria

Aplicación académica para publicar inmuebles, buscar propiedades, agendar visitas y tramitar solicitudes de compra o arriendo.

## Estado actual

- Base de datos: PostgreSQL, 16 tablas y 18 relaciones FK.
- [SQL vigente](sql/01-esquema.sql): conserva contraseña_hash, baños e imagen_propiedad.ruta de tipo TEXT.
- Driver JDBC conservado en WEB-INF/lib.
- B0 (base común en JSP/JSPF) terminado y verificado en Tomcat 8.5.96: conexión, utilidades, subida de archivos y pruebas de diagnóstico.
- B1 (diseño) terminado: **Habita**, paleta azul y turquesa, Bootstrap en local, cabecera, pie, menú por roles y páginas de error. Muestra: `http://localhost:8080/proyectojava/controlador/prueba_diseno.jsp`.
- B2 (acceso, usuarios, roles y perfil) terminado: ingreso y registro, panel por roles, perfil con foto y administración de usuarios. Entrada: `http://localhost:8080/proyectojava/controlador/acceso.jsp?accion=ingresar` (desarrollo: `admin@habita.com` / `Admin123`).
- B8 (datos de prueba) integrado y cargado: 20 usuarios (`Clave123`), 10 inmobiliarias, 20 propiedades, citas y solicitudes.
- B3 (empresas y catálogos) terminado: inmobiliarias con su cuenta responsable, Mi empresa y catálogos de ciudades, tipos y características.
- B4 (inicio y publicaciones) terminado: portada, catálogo con filtros, detalle con galería y publicación de propiedades con fotografías y características.
- B5 (favoritos y citas) terminado: agendar visitas sin cruces de horario, confirmar, rechazar, realizar y cancelar.
- B6 (solicitudes y documentos) terminado: radicar, revisar, documentos PDF privados y cierre que marca el inmueble como vendido o arrendado. Sigue B7.
- En otro equipo, copiar `WEB-INF/jspf/conexion.jspf.ejemplo` como `conexion.jspf` y completar la contraseña. Diagnóstico local: `http://localhost:8080/proyectojava/controlador/prueba_conexion.jsp`.

## Forma de trabajo elegida

Páginas .jsp, fragmentos .jspf, JDBC, HTML5, CSS3, JavaScript, Bootstrap, Tomcat y PostgreSQL. WEB-INF/web.xml configura la aplicación; los controladores comprobarán sesión, roles y pertenencia antes de ejecutar acciones.

Priorizar JSP/JSPF para toda función que pueda resolverse en servidor: formularios, búsquedas, filtros, paginación, validación, permisos y cambios de estado. JavaScript se limita al uso obligatorio del parcial y a interacciones de navegador que lo necesiten; no duplicar la lógica de negocio en archivos .js.

Se adopta una separación MVC con JSP/JSPF: controlador recibe peticiones, modelo opera los datos y vista presenta. Los controladores privados incluyen seguridad.jspf, que comprueba sesión, cuenta activa y roles. El requisito de Filter sigue pendiente; no se considera resuelto por esta estructura.

## Organización

La carpeta proyectojava/ ya es la raíz pública de Tomcat. controlador/ contiene las acciones JSP; WEB-INF/modelo/ las operaciones de datos en JSPF; WEB-INF/vista/ las pantallas JSP. WEB-INF/jspf/ contiene los fragmentos comunes. Los roles son permisos, no carpetas. CSS, JavaScript e imágenes conservan sus directorios.

El PDF de Figma se encuentra junto a los demás PDF en varios/referencias/. index.jsp es todavía una entrada temporal al plano. Las páginas funcionales se crearán al implementar cada bloque.

La auditoría de la aplicación y la revisión global se dejan para el final. Durante el desarrollo se realizan comprobaciones breves del cambio y un resumen por bloque, sin un informe de auditoría por cada paso.

## Documentos

- [Plan de implementación JSP/JSPF](varios/planificacion/PLAN_IMPLEMENTACION.md).
- [Plan de delegación revisado](varios/planificacion/PLAN_DELEGACION.md).
- [Acuerdos para los bloques](varios/planificacion/CONTRATOS.md).
- [Registro de cambios](README_IMPLEMENTACION.md).
- [Plano y paletas](varios/planificacion/PLANO.html).

Los PDF, diagramas y documentación se agrupan en varios/. La BD no se modifica por el cambio de organización de la aplicación.

La conexión se configura en WEB-INF/jspf/conexion.jspf, sin archivos de propiedades. Se incluye una sola vez en la unidad JSP que lo necesite y se llama abrirConexion(); quien la abre debe cerrarla. Las vistas no abren conexiones. El fragmento está excluido de Git por sus credenciales: al compartir o desplegar el proyecto se debe suministrar una copia sin claves reales y completar los datos del ambiente de forma privada.
