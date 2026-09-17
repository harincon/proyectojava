# Pendientes de entrega

B9 no aplicó estos cambios porque alteran funcionalidad, configuración o evidencia externa. La columna de dueño indica quién debe decidir o ejecutar.

| Prioridad | Pendiente | Evidencia | Propuesta | Dueño |
|---|---|---|---|---|
| Alta | El parcial exige un Filter de servlet | `WEB-INF/web.xml` no declara `<filter>`; `WEB-INF/jspf/seguridad.jspf:45-66` controla sesión y roles desde cada controlador | Consultar al profesor. Si exige Filter literal, implementar una clase `javax.servlet.Filter` compatible con Tomcat 8.5 y mapear rutas privadas; conservar validaciones de pertenencia en los controladores | Profesor y coordinador |
| Alta | Contraseña inicial del administrador | `sql/02-datos-base.sql:6` documenta `Admin123` | Cambiarla mediante el flujo acordado o reemplazar el hash inicial antes de publicar. Actualizar la guía privada de acceso | Coordinador/administrador |
| Media | Páginas de diagnóstico | `controlador/prueba_conexion.jsp:6-10`, `prueba_diseno.jsp:4-8` y `prueba_subida.jsp:5-9` solo aceptan loopback; `WEB-INF/web.xml:16-28` registra la subida | Para entrega local pueden conservarse. Antes de publicar, retirarlas o exigir rol ADMINISTRADOR. Quitar también el registro multipart de `prueba_subida.jsp` si se elimina | Coordinador |
| Alta | Instancia de base en línea | El parcial pide instancia local y en línea; la guía y conexión actuales son locales | Crear PostgreSQL remoto solo si el profesor lo exige, cargar 01-03, configurar credenciales fuera del repositorio y repetir validaciones sin publicar secretos | Coordinador |
| Alta | Despliegue web en línea | La aplicación solo se probó en Tomcat local y el usuario prohibió publicarla en B9 | Mantenerlo como punto adicional pendiente hasta recibir autorización y elegir un servicio compatible con JSP/Tomcat | Coordinador |
| Media | JavaScript obligatorio | El parcial enumera JavaScript; el proyecto prioriza JSP y Bootstrap local y no implementa lógica propia en JavaScript | Preguntar qué evidencia mínima acepta el profesor. Si la exige, añadir una interacción accesible y pequeña sin mover validaciones ni reglas de negocio al cliente | Profesor y B1 |
| Alta | Ceremonias Scrum y tablero | Solo hay planificación, documentación por bloques e historial de 28 commits entre el 14 y el 16 de septiembre | Anexar evidencia real que ya exista. No crear actas con fechas o asistentes inventados | Equipo y Product Owner |

## Fallos funcionales encontrados en B9

No se encontró un fallo funcional en los 30 casos ejecutados. Las observaciones anteriores son brechas de requisito o preparación para publicación.
