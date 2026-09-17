# Entrega final de Habita

Esta carpeta reúne la evidencia de B9 sin modificar la funcionalidad de la aplicación.

## Documentos

- [Informe técnico final en PDF](INFORME_TECNICO_HABITA.pdf): documento principal de entrega con arquitectura, seguridad, base de datos, módulos, pruebas y capturas reales.
- [Informe de pruebas](INFORME_PRUEBAS.md): recorrido completo, permisos, concurrencia, documentos privados, validaciones y diseño responsivo.
- [Casos de uso](CASOS_DE_USO.md): actores, alcance y flujos principales del sistema.
- [Guía de ejecución](GUIA_EJECUCION.md): creación de la base, scripts, conexión JDBC y despliegue en Tomcat.
- [Evidencia Scrum](SCRUM_EVIDENCIA.md): backlog, distribución propuesta en tres sprints y evidencia que realmente existe.
- [Historial de Git](HISTORIAL_GIT.md): commits y merges leídos del reflog sin usar comandos de Git.
- [Pendientes de entrega](PENDIENTES.md): decisiones y correcciones que B9 no aplicó.
- [Índice de capturas](CAPTURAS.md): 17 imágenes reales de la aplicación.
- [Presentación de sustentación](PRESENTACION_HABITA.pptx): material auxiliar anterior; la entrega principal es el informe PDF.

## Evidencia técnica

- `evidencia/resultado_pruebas_b9.json`: resultado estructurado de 30 comprobaciones.
- `evidencia/resultado_responsive_b9.json`: mediciones reales del navegador.
- `evidencia/pruebas_b9_temporal.ps1`: recorrido automatizado con datos temporales y verificación en PostgreSQL.
- `evidencia/capturar_pantallas_b9.ps1`: captura de las vistas públicas y autenticadas con Edge headless.
- `evidencia/generar_presentacion_b9.ps1`: generación reproducible de la presentación con las capturas reales.

## Resultado

Las 30 comprobaciones funcionales pasaron. La validación de datos B8 también pasó y la limpieza restauró los conteos iniciales: 21 usuarios, 20 propiedades, 15 citas, 15 solicitudes, 20 documentos y 10 favoritos. Los cinco PDF temporales creados durante las repeticiones de la prueba se eliminaron y la auditoría volvió a sus 19 registros originales.

El Filter de seguridad se implementa mediante `WEB-INF/jspf/seguridad.jspf`, incluido en los controladores privados para validar sesión, cuenta activa y roles. La contraseña inicial del administrador, las páginas de diagnóstico, la instancia remota y la evidencia real de las ceremonias Scrum permanecen documentadas como asuntos de entrega.
