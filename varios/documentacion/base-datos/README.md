# Base de datos de Habita

[Abrir el diagrama actual](bdjava%20%282%29.png).

El diagrama se conserva como referencia visual. La definición vigente es
[`sql/01-esquema.sql`](../../../sql/01-esquema.sql) y contiene 16 tablas y 18 claves
foráneas. Los scripts se ejecutan en este orden:

1. `sql/01-esquema.sql`: crea el esquema y sus tablas.
2. `sql/02-datos-base.sql`: crea los roles y el administrador inicial.
3. `sql/03-datos-prueba.sql`: agrega los datos de B8.
4. `sql/04-consultas.sql`: será creado por B7.

## Tablas principales y conteos

Se consideran principales las tablas que representan cuentas, personas, empresas,
inmuebles y trámites: `usuario`, `perfil`, `inmobiliaria`, `propiedad`, `cita`,
`solicitud` y `documento_solicitud`. Las demás son catálogos, asociaciones o soporte.

Los conteos corresponden a una base nueva después de ejecutar los tres primeros
scripts.

| Tabla | Clasificación | Registros |
| --- | --- | ---: |
| rol | Catálogo | 3 |
| usuario | Principal | 21 |
| usuario_rol | Asociación | 22 |
| perfil | Principal | 21 |
| inmobiliaria | Principal | 10 |
| ciudad | Catálogo | 10 |
| tipo_propiedad | Catálogo | 5 |
| caracteristica | Catálogo | 10 |
| propiedad | Principal | 20 |
| imagen_propiedad | Soporte | 30 |
| propiedad_caracteristica | Asociación | 30 |
| cita | Principal | 15 |
| solicitud | Principal | 15 |
| documento_solicitud | Principal | 20 |
| favorito | Asociación | 10 |
| auditoria | Soporte | 0 |

`auditoria` queda vacía después de la carga: sus eventos los registra la aplicación
desde el primer uso (ingresos, cambios y trámites) y no se inventan eventos anteriores. Las fotografías de
`imagen_propiedad` apuntan a los 29 archivos del proyecto en `img/habita/`. La primera de
cada propiedad es la del catálogo y no se repite entre las publicadas; nueve propiedades
tienen una segunda para la galería del detalle (créditos en `varios/referencias/fotografias.md`). Las rutas de
`documento_solicitud`, por ejemplo `solicitudes/001/cedula.pdf`, son relativas a la
carpeta privada `WEB-INF/archivos/`. Esos PDF de ejemplo no se guardan en Git: se crean
con `varios/herramientas/generar-pdf-ejemplo.ps1` después de cargar los datos de prueba,
y B6 los protege y los sirve solo a quien tiene permiso.

## Relaciones

### Uno a uno (1:1)

- `usuario` - `perfil`, materializada por `perfil.id_usuario`, que es FK y UNIQUE.
- `usuario` - `inmobiliaria`, materializada por `inmobiliaria.id_usuario`, que es
  FK y UNIQUE. Una cuenta responsable puede administrar como máximo una empresa.

### Uno a muchos (1:N)

- `inmobiliaria` - `propiedad`, mediante `propiedad.id_inmobiliaria`.
- `ciudad` - `propiedad`, mediante `propiedad.id_ciudad`.
- `tipo_propiedad` - `propiedad`, mediante `propiedad.id_tipo_propiedad`.
- `propiedad` - `imagen_propiedad`, mediante `imagen_propiedad.id_propiedad`.
- `usuario` - `cita`, mediante `cita.id_cliente`.
- `propiedad` - `cita`, mediante `cita.id_propiedad`.
- `usuario` - `solicitud`, mediante `solicitud.id_cliente`.
- `propiedad` - `solicitud`, mediante `solicitud.id_propiedad`.
- `solicitud` - `documento_solicitud`, mediante
  `documento_solicitud.id_solicitud`.
- `usuario` - `auditoria`, mediante `auditoria.id_usuario`.

### Muchos a muchos (N:M)

- `usuario` - `rol`, materializada en `usuario_rol`.
- `propiedad` - `caracteristica`, materializada en
  `propiedad_caracteristica`.
- `usuario` - `propiedad` como favoritos, materializada en `favorito`.

Las claves primarias compuestas de las tablas asociativas impiden repetir la misma
relación.

## Tercera forma normal (3FN)

El modelo cumple 3FN porque cada tabla representa un solo concepto, sus campos
dependen de su clave primaria y no se guardan datos que dependan de otra columna no
clave.

- `propiedad` guarda las FK de ciudad, tipo e inmobiliaria, pero los nombres y datos
  de esas entidades se almacenan una sola vez en sus propias tablas.
- Los roles y las características no se repiten como texto dentro de usuarios o
  propiedades; las tablas `usuario_rol` y `propiedad_caracteristica` resuelven las
  relaciones N:M.
- Los datos personales están en `perfil` y las credenciales en `usuario`, unidos por
  una relación 1:1.
- Los documentos dependen de una solicitud concreta y se almacenan en
  `documento_solicitud`, sin repetir los datos del cliente o del inmueble.

## Diccionario de datos

Abreviaturas: **PK** clave primaria, **FK** clave foránea, **UQ** valor único y
**PKC** parte de una clave primaria compuesta.

### rol

| Campo | Tipo | Nulo | Clave | Restricción | Descripción |
| --- | --- | --- | --- | --- | --- |
| id_rol | SERIAL | No | PK | Autonumérico | Identificador del rol. |
| nombre | VARCHAR(30) | No | UQ | Único | Nombre del permiso asignable. |

### usuario

| Campo | Tipo | Nulo | Clave | Restricción | Descripción |
| --- | --- | --- | --- | --- | --- |
| id_usuario | SERIAL | No | PK | Autonumérico | Identificador de la cuenta. |
| correo | VARCHAR(150) | No | UQ | Único | Correo usado para ingresar. |
| contraseña_hash | VARCHAR(255) | No | - | Obligatorio | Hash de la contraseña con sal. |
| activo | BOOLEAN | No | - | DEFAULT TRUE | Indica si la cuenta puede utilizarse. |

### usuario_rol

| Campo | Tipo | Nulo | Clave | Restricción | Descripción |
| --- | --- | --- | --- | --- | --- |
| id_usuario | INTEGER | No | PKC, FK | ON DELETE CASCADE | Usuario que recibe el rol. |
| id_rol | INTEGER | No | PKC, FK | ON DELETE CASCADE | Rol asignado al usuario. |

### perfil

| Campo | Tipo | Nulo | Clave | Restricción | Descripción |
| --- | --- | --- | --- | --- | --- |
| id_perfil | SERIAL | No | PK | Autonumérico | Identificador del perfil. |
| id_usuario | INTEGER | No | FK, UQ | ON DELETE RESTRICT | Cuenta propietaria del perfil. |
| nombres | VARCHAR(100) | Sí | - | - | Nombres de la persona. |
| apellidos | VARCHAR(100) | Sí | - | - | Apellidos de la persona. |
| documento | VARCHAR(30) | Sí | - | - | Documento de identidad. |
| telefono | VARCHAR(25) | Sí | - | - | Teléfono de contacto. |
| direccion | VARCHAR(200) | Sí | - | - | Dirección de residencia. |
| foto | VARCHAR(255) | Sí | - | - | Ruta de la fotografía del perfil. |

### inmobiliaria

| Campo | Tipo | Nulo | Clave | Restricción | Descripción |
| --- | --- | --- | --- | --- | --- |
| id_inmobiliaria | SERIAL | No | PK | Autonumérico | Identificador de la empresa. |
| id_usuario | INTEGER | No | FK, UQ | ON DELETE RESTRICT | Cuenta responsable de la empresa. |
| nombre | VARCHAR(150) | No | - | Obligatorio | Nombre comercial. |
| identificacion_empresarial | VARCHAR(50) | No | UQ | Único | NIT o identificación empresarial. |
| telefono | VARCHAR(25) | Sí | - | - | Teléfono de contacto. |
| correo_contacto | VARCHAR(150) | Sí | - | - | Correo público de la empresa. |
| direccion | VARCHAR(200) | Sí | - | - | Dirección de la empresa. |

### ciudad

| Campo | Tipo | Nulo | Clave | Restricción | Descripción |
| --- | --- | --- | --- | --- | --- |
| id_ciudad | SERIAL | No | PK | Autonumérico | Identificador de la ciudad. |
| nombre | VARCHAR(100) | No | UQ | Único | Nombre de la ciudad. |

### tipo_propiedad

| Campo | Tipo | Nulo | Clave | Restricción | Descripción |
| --- | --- | --- | --- | --- | --- |
| id_tipo_propiedad | SERIAL | No | PK | Autonumérico | Identificador del tipo. |
| nombre | VARCHAR(50) | No | UQ | Único | Casa, apartamento, local, oficina o terreno. |

### caracteristica

| Campo | Tipo | Nulo | Clave | Restricción | Descripción |
| --- | --- | --- | --- | --- | --- |
| id_caracteristica | SERIAL | No | PK | Autonumérico | Identificador de la característica. |
| nombre | VARCHAR(60) | No | UQ | Único | Servicio o cualidad de un inmueble. |

### propiedad

| Campo | Tipo | Nulo | Clave | Restricción | Descripción |
| --- | --- | --- | --- | --- | --- |
| id_propiedad | SERIAL | No | PK | Autonumérico | Identificador del inmueble. |
| matricula_inmobiliaria | VARCHAR(50) | No | UQ | Único | Matrícula oficial del inmueble. |
| id_inmobiliaria | INTEGER | No | FK | ON DELETE RESTRICT | Empresa que publica el inmueble. |
| id_ciudad | INTEGER | No | FK | ON DELETE RESTRICT | Ciudad donde está ubicado. |
| id_tipo_propiedad | INTEGER | No | FK | ON DELETE RESTRICT | Tipo de inmueble. |
| titulo | VARCHAR(150) | No | - | Obligatorio | Título del anuncio. |
| descripcion | TEXT | Sí | - | - | Información detallada. |
| direccion | VARCHAR(200) | No | - | Obligatorio | Dirección del inmueble. |
| precio | NUMERIC(14,2) | No | - | CHECK precio > 0 | Precio de venta o canon de arriendo en COP. |
| area | NUMERIC(10,2) | No | - | CHECK area > 0 | Área del inmueble en metros cuadrados. |
| habitaciones | INTEGER | No | - | DEFAULT 0 | Cantidad entera de habitaciones. |
| baños | INTEGER | No | - | DEFAULT 0 | Cantidad entera de baños. |
| tipo_operacion | VARCHAR(10) | No | - | CHECK VENTA/ARRIENDO | Operación ofrecida. |
| estado | VARCHAR(15) | No | - | CHECK DISPONIBLE/VENDIDA/ARRENDADA; DEFAULT DISPONIBLE | Estado comercial. |
| activa | BOOLEAN | No | - | DEFAULT TRUE | Controla si la publicación está activa. |
| destacada | BOOLEAN | No | - | DEFAULT FALSE | Indica si aparece como destacada. |

### imagen_propiedad

| Campo | Tipo | Nulo | Clave | Restricción | Descripción |
| --- | --- | --- | --- | --- | --- |
| id_imagen | SERIAL | No | PK | Autonumérico | Identificador de la imagen. |
| id_propiedad | INTEGER | No | FK | ON DELETE CASCADE | Propiedad a la que pertenece. |
| ruta | TEXT | No | - | Obligatorio | Ruta o referencia de la imagen. |

### propiedad_caracteristica

| Campo | Tipo | Nulo | Clave | Restricción | Descripción |
| --- | --- | --- | --- | --- | --- |
| id_propiedad | INTEGER | No | PKC, FK | ON DELETE CASCADE | Propiedad relacionada. |
| id_caracteristica | INTEGER | No | PKC, FK | ON DELETE CASCADE | Característica asignada. |

### cita

| Campo | Tipo | Nulo | Clave | Restricción | Descripción |
| --- | --- | --- | --- | --- | --- |
| id_cita | SERIAL | No | PK | Autonumérico | Identificador de la visita. |
| id_cliente | INTEGER | No | FK | ON DELETE RESTRICT | Cliente que agenda la visita. |
| id_propiedad | INTEGER | No | FK | ON DELETE RESTRICT | Propiedad que se visitará. |
| fecha_hora | TIMESTAMP | No | - | Índice único parcial para citas activas | Fecha y hora programadas. |
| estado | VARCHAR(15) | No | - | CHECK de 5 estados; DEFAULT PENDIENTE | Estado de la cita. |

El índice `uq_cita_horario` impide dos citas `PENDIENTE` o `CONFIRMADA` para la
misma propiedad y hora.

### solicitud

| Campo | Tipo | Nulo | Clave | Restricción | Descripción |
| --- | --- | --- | --- | --- | --- |
| id_solicitud | SERIAL | No | PK | Autonumérico | Identificador del trámite. |
| id_cliente | INTEGER | No | FK | ON DELETE RESTRICT | Cliente que presenta la solicitud. |
| id_propiedad | INTEGER | No | FK | ON DELETE RESTRICT | Propiedad solicitada. |
| fecha | TIMESTAMP | No | - | DEFAULT CURRENT_TIMESTAMP | Fecha de radicación. |
| estado | VARCHAR(15) | No | - | CHECK de 4 estados; DEFAULT PENDIENTE | Estado del trámite. |
| observacion | TEXT | Sí | - | - | Comentario sobre el trámite. |

### documento_solicitud

| Campo | Tipo | Nulo | Clave | Restricción | Descripción |
| --- | --- | --- | --- | --- | --- |
| id_documento | SERIAL | No | PK | Autonumérico | Identificador del documento. |
| id_solicitud | INTEGER | No | FK | ON DELETE RESTRICT | Solicitud a la que pertenece. |
| nombre | VARCHAR(100) | No | - | Obligatorio | Nombre descriptivo del documento. |
| ruta | VARCHAR(255) | No | - | Obligatorio | Ruta privada del archivo. |
| estado | VARCHAR(15) | No | - | CHECK PENDIENTE/APROBADO/RECHAZADO; DEFAULT PENDIENTE | Estado de revisión. |
| observacion | TEXT | Sí | - | - | Resultado o comentario de revisión. |

### favorito

| Campo | Tipo | Nulo | Clave | Restricción | Descripción |
| --- | --- | --- | --- | --- | --- |
| id_cliente | INTEGER | No | PKC, FK | ON DELETE CASCADE | Cliente que guarda el inmueble. |
| id_propiedad | INTEGER | No | PKC, FK | ON DELETE CASCADE | Propiedad guardada. |

### auditoria

| Campo | Tipo | Nulo | Clave | Restricción | Descripción |
| --- | --- | --- | --- | --- | --- |
| id_auditoria | SERIAL | No | PK | Autonumérico | Identificador del evento. |
| id_usuario | INTEGER | Sí | FK | ON DELETE RESTRICT | Usuario relacionado, si existe. |
| accion | VARCHAR(255) | No | - | Obligatorio | Descripción breve de la acción. |
| fecha | TIMESTAMP | No | - | DEFAULT CURRENT_TIMESTAMP | Momento del evento. |
