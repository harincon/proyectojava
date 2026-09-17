# Entrega final de Habita

Esta carpeta reúne la evidencia de B9 sin modificar la funcionalidad de la aplicación.

## Documentos

- [Casos de uso](CASOS_DE_USO.md): actores, alcance y flujos principales del sistema.
- [Guía de ejecución](GUIA_EJECUCION.md): creación de la base, scripts, conexión JDBC y despliegue en Tomcat.
- [Índice de capturas](CAPTURAS.md): 17 imágenes reales de la aplicación.

## Resultado

Las 30 comprobaciones funcionales pasaron. La validación de datos B8 también pasó y la limpieza restauró los conteos iniciales: 21 usuarios, 20 propiedades, 15 citas, 15 solicitudes, 20 documentos y 10 favoritos. Los cinco PDF temporales creados durante las repeticiones de la prueba se eliminaron y la auditoría volvió a sus 19 registros originales.

El Filter de seguridad se implementa mediante `WEB-INF/jspf/seguridad.jspf`, incluido en los controladores privados para validar sesión, cuenta activa y roles. La contraseña inicial del administrador, las páginas de diagnóstico, la instancia remota y la evidencia real de las ceremonias Scrum quedan como asuntos pendientes de la entrega.
