# Diagrama de la base de datos

[Abrir el diagrama actual](bdjava%20%282%29.png).

Es el único diagrama vigente. Representa el esquema creado en PostgreSQL:

- 16 tablas.
- 18 relaciones FK.
- inmobiliaria.id_usuario vincula la empresa con su cuenta responsable.
- propiedad.id_inmobiliaria vincula cada propiedad con su inmobiliaria.
- Relaciones 1:1, 1:N y N:M requeridas por el parcial.

La definición ejecutable se encuentra en [sql/01-esquema.sql](../../../sql/01-esquema.sql).
