# Plan de estructura MVC con JSP y JSPF

Estado: planificación revisada el 14 de septiembre de 2026 por instrucción del estudiante. Sustituye la estructura anterior de clases Java propias; B0 debe rehacerse antes de continuar.

## 1. Criterio de trabajo

Usar JSP/JSPF y la sencillez del [simulacro del restaurante](../referencias/SIMULACRO_PARCIAL_PRACTICO_Aplicacion_Web_JSP_Restaurante.pdf), pero organizar el proyecto por modelo, vista y controlador, según la última instrucción del estudiante. No organizar carpetas por roles.

No crear paquetes de modelos, DAO, controladores Java ni clases Filter propias. El código Java necesario se escribe dentro de JSP/JSPF y Tomcat compila las páginas internamente. No se mantiene un paso manual de javac. La conexión ya está implementada en conexion.jspf; los demás componentes están pendientes.

La aplicación utiliza JSP, JSPF, JDBC, HTML5, CSS3, JavaScript, Bootstrap, PostgreSQL y Tomcat. Se conserva el driver y la configuración privada de conexión.

Por preferencia del estudiante, toda función viable en servidor se implementa con JSP/JSPF. Buscar, filtrar, ordenar y paginar mediante formularios GET; guardar, decidir y cambiar estados mediante POST, con validación del servidor. La confirmación puede ser una vista JSP. Usar HTML5/CSS para la presentación y restricciones básicas del formulario. No agregar AJAX, filtros de datos en JavaScript ni una librería de validación cliente por defecto. JavaScript se reserva para el requisito del parcial y las interacciones de navegador necesarias, como un componente interactivo de Bootstrap. La carpeta js/ se conserva para ese uso mínimo.

## 2. Separación prevista

El controlador JSP recibe la petición, valida sesión/roles y parámetros, llama al modelo y elige la vista. El modelo JSPF contiene funciones de datos y reglas, sin HTML, redirecciones ni lectura de parámetros HTTP. La vista JSP presenta los datos recibidos, sin consultas SQL ni modificaciones de BD.

Los fragmentos comunes permanecen en WEB-INF/jspf. El SQL de negocio va en WEB-INF/modelo; conexion.jspf sigue centralizando JDBC. Los fragmentos del modelo se incluyen en los controladores, no en las vistas.

Esta es una estructura MVC propuesta, todavía sin lógica implementada. El [parcial](../referencias/PARCIAL_JAVA_1_CORTE_PRACTICO_V2.pdf) también pide un Filter de servlet; esa parte sigue pendiente y no queda satisfecha por crear carpetas ni por incluir seguridad.jspf. No se crearán clases Java propias durante esta fase de estructura.

## 3. Estructura prevista

proyectojava/ es la raíz pública de Tomcat. Las carpetas MVC ya se crearon; están vacías mientras se define la estructura. index.jsp sigue siendo una entrada temporal al plano y conexion.jspf es el único fragmento implementado.

~~~text
proyectojava/
├── index.jsp
├── controlador/                 acciones y navegación, en JSP
├── css/
├── js/
├── img/
├── WEB-INF/
│   ├── web.xml
│   ├── lib/
│   │   └── postgresql-42.7.13.jar
│   ├── modelo/                  operaciones de datos, en JSPF
│   ├── vista/                   pantallas, en JSP
│   └── jspf/                    fragmentos comunes
│       └── conexion.jspf
├── sql/
└── varios/                      referencias y documentación
~~~

No se crea una carpeta por rol ni una subcarpeta por cada tabla. Por ejemplo, al implementar propiedades: controlador/propiedad.jsp, WEB-INF/modelo/propiedad.jspf y WEB-INF/vista/propiedades.jsp. Los roles determinan permisos y opciones, no la organización física.

Modelo y vista se guardan en WEB-INF para impedir acceso directo por URL. Los enlaces apuntarán a controladores; estos mostrarán las vistas mediante forward. La seguridad se comprueba antes de llamar al modelo. Los archivos subidos tendrán almacenamiento privado cuando se implemente esa función.

## 4. Base y reglas conservadas

Se conserva [01-esquema.sql](../../sql/01-esquema.sql) y sus 16 tablas: rol, usuario, usuario_rol, perfil, inmobiliaria, ciudad, tipo_propiedad, caracteristica, propiedad, imagen_propiedad, propiedad_caracteristica, cita, solicitud, documento_solicitud, favorito y auditoria.

La cuenta responsable de cada empresa es única. Propiedad referencia la empresa; imágenes y características permiten varias asociaciones. Perfil es único por usuario. No cambiar contraseña_hash, baños ni ruta TEXT, ni agregar campos solo para copiar Figma.

Usuario–perfil demuestra 1:1; inmobiliaria–propiedad e inmueble–imagen, 1:N; usuario–rol y propiedad–característica, N:M. Conservar PK, FK, UNIQUE, CHECK, baja lógica y restricciones referenciales. Justificar 3FN en el diccionario.

## 5. Funciones y roles

| Rol | Pantallas y acciones |
| --- | --- |
| Visitante | Inicio, catálogo y detalle; registro/login. Sin contacto completo ni acceso a paneles |
| Cliente | Perfil con documento y foto, favoritos, citas, solicitudes y documentos propios |
| Inmobiliaria | Datos de empresa, publicaciones propias, galería/características, citas, revisión de solicitudes/documentos y reportes |
| Administrador | Usuarios con varios roles, activación de cuentas, empresas, ciudades/tipos/características, reportes y auditoría; acceso total autorizado |

Registro crea cuenta, perfil y rol CLIENTE en una sola transacción. No permite elegir roles privilegiados. Asignación/revocación de roles y estado activo se vuelven a comprobar en las páginas privadas.

Propiedades: matrícula, título, descripción, dirección, ciudad, tipo, venta/arriendo, precio, área, habitaciones, baños, características, imágenes y destacada. Publicación activa/inactiva es independiente de disponible/vendida/arrendada.

Fotos: campo de enlace, agregar otra y quitar. Validar visualización real; Drive puede requerir visor y permisos públicos, no se garantiza una imagen directa por pegar cualquier enlace.

Citas: horarios futuros, sin solapamientos de inmueble, cliente o responsable; cancelar libera reserva. Turnos de 60 minutos siguen siendo propuesta. Estados según el SQL.

Solicitudes: radicar documentos PDF privados, consultar estados/observaciones, revisar y aprobar/rechazar cada documento y solicitud. Finalizar una solicitud aprobada actualiza el inmueble de forma atómica; no permite cierres duplicados. Sin pagos ni facturación.

## 6. Reutilización y seguridad

- conexion.jspf centraliza JDBC y los datos de conexión local/remota, sin archivos .properties. El modelo cierra consultas y resultados; el responsable de la transacción cierra su conexión. La vista no abre JDBC. El fragmento local contiene credenciales y está excluido de Git.
- utilidades.jspf concentra funciones breves de hash con sal, escape HTML, token de formulario, formatos y validación.
- seguridad.jspf comprueba sesión, cuenta activa y roles vigentes antes de llamar al modelo. Cada controlador privado debe incluirlo; también las acciones y descargas. No basta con ocultar botones.
- El controlador y las operaciones del modelo comprueban además la pertenencia del registro al cliente o empresa permitidos.
- UTF-8 se fija antes de leer parámetros; los fragmentos con declaraciones se incluyen una sola vez.
- Consultas con PreparedStatement; validar también en servidor y traducir errores SQL.
- POST modifica y redirige después de éxito; GET consulta. Los formularios preservan datos ante errores.
- Transacciones para registro, asignación empresa/rol, reservas y cierres. Coordinar bloqueos entre módulos; no confiar solo en una consulta previa de disponibilidad.
- Documentos y fotos de perfil: validar tamaño/tipo y nombres generados. Descargar documentos mediante una JSP autorizada. Verificar primero el soporte de carga multipart con JSP y web.xml, sin añadir clases propias por sorpresa.
- La auditoría se implementará al final, cuando los módulos principales estén terminados, con su modelo, controlador y vista. Entonces se incorporará registro real de accesos y cambios. No hacerla dependencia de B0–B6.

seguridad.jspf, el token, el hash y la subida de fotos están implementados desde B2. La pertenencia de cada registro, las transacciones de empresa, reservas y cierres, y la descarga de documentos se comprueban al implementar B3–B6.

## 7. Ajustes visuales respecto a Figma

La referencia vigente está en `varios/referencias/figma-habita/`. Se conserva el nombre Habita y el lema «Encuentra tu próximo espacio». La paleta aplicada es verde bosque `#243B32`, terracota `#C96E4B`, oliva `#83946A`, arena `#E8D8C4`, crema `#F7F2E8` y carbón `#252525`. Los recursos usados por la aplicación están en `img/habita/` y los estilos comunes en `css/estilos.css`.

El código React, TypeScript y Tailwind entregado por Figma es solo una referencia visual. Las pantallas del proyecto se construyen con JSP/JSPF, HTML, CSS y Bootstrap local, conservando la arquitectura y los contratos del parcial.

Quitar mensajería al asesor, blog/redes sin contenido, fecha de registro inexistente y cantidad de estacionamientos. Mostrar empresa responsable y parqueadero como característica. Simplificar el pie interno.

Añadir registro/cierre de sesión, documento en perfil, matrícula/dirección/características en propiedad, filtros por características y limpiar filtros, gestión de varios roles. Usar Desactivar/Reactivar y estados separados de disponibilidad.

Documentos pertenecen a solicitudes, no a citas. Completar favoritos, formularios de cita/solicitud, revisión, reportes, catálogos y auditoría. Añadir mensajes, vacíos y acceso denegado. Catálogo con columnas uniformes y precios/botones sin solapamientos; móvil/tableta/escritorio.

## 8. Historias y responsables

| HU | Función | Prioridad | Bloque |
| --- | --- | --- | --- |
| 01 | Landing y búsqueda rápida | Alta | B4 |
| 02 | Registro con correo único | Alta | B2 |
| 03 | Iniciar/cerrar sesión y panel por rol | Alta | B2 |
| 04 | Asignar/revocar varios roles | Alta | B2, integración B3 |
| 05 | Perfil con documento, teléfono y dirección | Media | B2 |
| 06 | Propiedades con fotos y características | Alta | B4 |
| 07 | Filtros ciudad, tipo, precio y características | Alta | B4 |
| 08 | Favoritos | Media | B5 |
| 09 | Citas disponibles sin cruces | Media | B5 |
| 10 | Documentos y estado del trámite | Media | B6 |
| 11 | Aprobar/rechazar solicitudes y documentos | Media | B6 |
| 12 | Reporte por ciudad y estado | Media | B7 |
| 13 | Auditoría de accesos/cambios | Baja | B7 al final, integración del coordinador |

Durante cada tarea, hacer únicamente las comprobaciones necesarias de lo que se acaba de cambiar. Registrar un resumen breve por bloque en README_IMPLEMENTACION.md. La revisión global y el conjunto de evidencias se concentran al final; se mantienen los registros de cada sprint que exige el parcial.

## 9. SQL, pruebas y entrega

B8 prepara mínimo diez registros por tabla principal. Propuesta: 21 usuarios/perfiles, 10 empresas, 20 propiedades, 15 citas/solicitudes y 20 imágenes/documentos; 10 ciudades/características, 5 tipos reales y 3 roles autenticados. No inventar diez roles. Crear ejemplos con múltiples asociaciones y propiedades sin citas.

B7 entrega al menos cinco consultas: dos INNER JOIN de tres o más tablas, una N:M, LEFT JOIN y agregación GROUP BY/HAVING. Reportes por ciudad/estado, citas por estado, solicitudes por empresa y ventas/arriendos finalizados.

Revisión final: funciones compartidas de hash/validación con casos aislados reproducibles, JDBC/integridad y rollback, sesiones/roles y acceso por ID ajeno, concurrencia, documentos privados y diseño en 390/768/1366 px. Se comprobó la función de conexion.jspf por JDBC; la ejecución HTTP de la base JSP está pendiente. No reutilizar resultados de las clases retiradas como prueba de esta versión.

Tres sprints de siete días: 1 base/acceso/roles y datos iniciales; 2 empresas/catálogos/perfil/publicaciones; 3 favoritos/citas/solicitudes/reportes/auditoría y cierre. Documentar planning, review y retrospectiva, backlog con criterios/responsables/estimaciones, Git y tablero/Padlet con evidencia real.

Presentación siguiendo el simulacro: contexto, roles, MER/relacional/3FN/diccionario, casos de uso, estructura JSP/JSPF/driver, pantallas reales, consultas y pruebas, Scrum y guía de ejecución/sustentación. Evaluación: 40 % aplicación, 30 % Scrum, 30 % modelo/documentación.

La auditoría comienza a registrar eventos desde su implementación; los anteriores no se inventan. Al finalizar se prueban nuevamente los recorridos para obtener eventos reales.

Verificar configuración JDBC local y remota cuando se elija Neon/Supabase. Publicación completa en línea como adicional; no contratar ni publicar automáticamente.

## 10. Próximo paso

Rehacer B0 con JSP/JSPF cuando se autorice. Después seguir el [plan de delegación revisado](PLAN_DELEGACION.md). La corrección actual retira clases y actualiza planificación; no implementa otros bloques.
