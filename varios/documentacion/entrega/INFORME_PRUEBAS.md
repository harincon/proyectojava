# Informe de pruebas finales

Fecha de ejecución: 16 de septiembre de 2026, zona `America/Bogota`.

Entorno probado: Apache Tomcat 8.5 en `localhost:8080`, PostgreSQL 18 en `localhost:5432`, base `proyectojava`, esquema `inmobiliaria`, Microsoft Edge headless y páginas JSP/JSPF de Habita.

## Resultado general

- 30 de 30 comprobaciones funcionales aprobadas.
- Recorrido completo realizado con CLIENTE, INMOBILIARIA y ADMINISTRADOR.
- Dos citas concurrentes para la misma propiedad y hora produjeron una sola cita activa.
- Dos cierres concurrentes de la misma solicitud produjeron una sola finalización y una propiedad `VENDIDA`.
- El cliente dueño, la inmobiliaria propietaria y el administrador descargaron el PDF. Un cliente y una inmobiliaria ajenos recibieron 403. La ruta física bajo `WEB-INF` devolvió 404.
- Los PDF sin firma `%PDF-` y de 5 MB + 1 byte fueron rechazados sin insertar documentos.
- Los tres anchos revisados, 390, 768 y 1366 px, no presentaron desbordamiento horizontal.
- La limpieza devolvió los conteos controlados de `21|20|15|15|20|10` antes y después de la prueba.

## Recorrido por rol

### Cliente

1. Se registró una cuenta temporal desde la pantalla pública.
2. Inició sesión y actualizó documento, teléfono y dirección.
3. Localizó la publicación temporal en el catálogo y abrió el detalle.
4. Agregó dos veces el mismo favorito. La relación quedó una sola vez.
5. Intentó crear un favorito sin token. La base no cambió.
6. Intentó una cita pasada. El servidor la rechazó.
7. Agendó una cita futura y radicó una solicitud.
8. Intentó radicar otra solicitud abierta sobre la misma propiedad. Solo quedó una.
9. Probó documento inválido, documento mayor de 5 MB y PDF válido.
10. Descargó su documento y consultó sus citas y solicitudes.

### Inmobiliaria

1. Camila Rojas publicó una propiedad temporal asociada a Raíz Santandereana y Bucaramanga.
2. Un precio negativo fue rechazado antes de insertar.
3. Confirmó la cita del cliente.
4. Aprobó el documento y la solicitud.
5. Dos peticiones simultáneas intentaron finalizar la misma solicitud. Solo una cambió la solicitud a `FINALIZADA` y la propiedad a `VENDIDA`.
6. Consultó el reporte limitado a su empresa.

### Administrador

1. Consultó usuarios, reportes generales y auditoría.
2. Descargó el documento privado por el controlador.
3. Verificó el filtro de auditoría con los eventos B9.

## Permisos y acceso directo

| Caso | Resultado |
|---|---|
| Cliente intenta cancelar una cita ajena por `id_cita` | 403 y estado intacto |
| Inmobiliaria ajena intenta editar una propiedad por `id_propiedad` | 403 |
| Inmobiliaria ajena abre una solicitud por `id_solicitud` | 403 |
| Cliente abre auditoría escribiendo la URL | 403 |
| Cliente ajeno descarga documento por `id_documento` | 403 |
| Inmobiliaria ajena descarga documento por `id_documento` | 403 |
| Acceso HTTP directo a `WEB-INF/archivos/...` | 404 |

La autorización se comprobó tanto por rol como por pertenencia del registro. El mecanismo actual es `seguridad.jspf`; el requisito literal de un Filter sigue pendiente.

## Concurrencia

### Dos citas al mismo horario

Daniela Moreno y Carlos Ruiz enviaron en paralelo una cita para la misma propiedad y la misma hora. PostgreSQL conservó una sola fila en estado activo y la otra respuesta mostró `Ese horario ya está reservado`. La comprobación combinó la respuesta de la página con un conteo directo de la base.

### Dos cierres de la misma solicitud

Se enviaron en paralelo dos POST de finalización para una solicitud `APROBADA`. El resultado fue una solicitud `FINALIZADA`, una propiedad `VENDIDA` y un solo evento `SOLICITUD_FINALIZADA`. La segunda petición informó que solo puede finalizarse una solicitud aprobada sobre una propiedad disponible.

## Datos y consultas

`sql/pruebas/02-validar-datos.sql` se ejecutó dentro de su propia transacción y mostró `Datos de B8 verificados correctamente`.

Conteos verificados de las 16 tablas:

| Tabla | Registros | Tabla | Registros |
|---|---:|---|---:|
| auditoria | 19 | caracteristica | 10 |
| cita | 15 | ciudad | 10 |
| documento_solicitud | 20 | favorito | 10 |
| imagen_propiedad | 30 | inmobiliaria | 10 |
| perfil | 21 | propiedad | 20 |
| propiedad_caracteristica | 30 | rol | 3 |
| solicitud | 15 | tipo_propiedad | 5 |
| usuario | 21 | usuario_rol | 22 |

`sql/04-consultas.sql` se ejecutó dentro de `BEGIN TRANSACTION READ ONLY` y `ROLLBACK`. Las siete consultas devolvieron, en orden, 20, 15, 15, 30, 5, 4 y 4 filas.

## Diseño responsivo

| Pantalla | Ancho | Ancho del documento | Resultado |
|---|---:|---:|---|
| Catálogo móvil | 390 px | 390 px | Sin desbordamiento horizontal |
| Catálogo tableta | 768 px | 768 px | Sin desbordamiento horizontal |
| Catálogo escritorio | 1366 px | 1366 px | Sin desbordamiento horizontal |

La revisión visual confirmó que el menú se convierte en botón en móvil, los campos de precio se acomodan en la rejilla y las tarjetas permanecen dentro del ancho. En 390 y 768 px el bloque de filtros ocupa el primer tramo de la página y las propiedades aparecen al desplazarse; funciona, aunque exige más desplazamiento que en escritorio.

## Limpieza

Se eliminaron la cuenta, propiedad, favorito, citas, solicitud, documento, asociaciones, eventos y archivos creados por B9. La comprobación final encontró cero correos `b9.recorrido.%`, cero matrículas `B9-%`, 19 eventos de auditoría con máximo ID 326 y ningún PDF temporal referenciado o suelto.

## Detalle de los 30 casos

La evidencia completa y los valores obtenidos están en `evidencia/resultado_pruebas_b9.json`.

| # | Caso | Resultado obtenido | Estado |
|---:|---|---|---|
| 1 | Registro de cliente | HTTP 200, usuario 51 | APROBADO |
| 2 | Ingreso del cliente | HTTP login 200, perfil 200 | APROBADO |
| 3 | Actualización de perfil | B920260916114503\|+57 300 999 0000\|Calle 9 # 9-09 | APROBADO |
| 4 | Validación de propiedad en servidor | HTTP 200, filas 0 | APROBADO |
| 5 | Publicación de propiedad | HTTP 200, DISPONIBLE\|true\|Raíz Santandereana\|Bucaramanga | APROBADO |
| 6 | Catálogo y detalle | Catálogo 200, detalle 200 | APROBADO |
| 7 | Token en POST | Filas favorito: 0 | APROBADO |
| 8 | Favoritos sin duplicados | Filas 1 | APROBADO |
| 9 | Fecha pasada de cita | Filas 0 | APROBADO |
| 10 | Agendamiento de cita | 58\|PENDIENTE | APROBADO |
| 11 | Concurrencia de citas | Activas 1, ganador daniela.moreno@habita.local, HTTP 200/200 | APROBADO |
| 12 | Cita ajena por URL | HTTP 403, estado PENDIENTE | APROBADO |
| 13 | Confirmación de cita | CONFIRMADA | APROBADO |
| 14 | Radicación de solicitud | 34\|PENDIENTE | APROBADO |
| 15 | Solicitud abierta duplicada | Filas 1 | APROBADO |
| 16 | Firma %PDF- | Documentos 0 | APROBADO |
| 17 | Límite PDF 5 MB | Documentos 0 | APROBADO |
| 18 | Subida PDF válida | 36\|solicitudes/s34-AbVYyAcoGM7I.pdf | APROBADO |
| 19 | Documento privado: autorizados | 200\|application/pdf\|68 / 200\|application/pdf\|68 / 200\|application/pdf\|68, firma %PDF- | APROBADO |
| 20 | Documento privado: ajenos | 403\|text/html;charset=UTF-8\|3936 / 403\|text/html;charset=UTF-8\|3936 | APROBADO |
| 21 | Documento privado: ruta física | 404\|text/html;charset=UTF-8\|3710 | APROBADO |
| 22 | Propiedad ajena por URL | HTTP 403 | APROBADO |
| 23 | Solicitud ajena por URL | HTTP 403 | APROBADO |
| 24 | Auditoría por URL con CLIENTE | HTTP 403 | APROBADO |
| 25 | Revisión de documento | APROBADO | APROBADO |
| 26 | Aprobación de solicitud | APROBADA | APROBADO |
| 27 | Concurrencia de cierre | FINALIZADA\|VENDIDA, eventos 1, HTTP 200/200 | APROBADO |
| 28 | Reporte de inmobiliaria | HTTP 200 | APROBADO |
| 29 | Reportes de administrador | HTTP 200 | APROBADO |
| 30 | Auditoría y filtro | HTTP admin 200, cliente 403 | APROBADO |
