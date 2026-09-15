-- Modelo definitivo de 16 tablas para la aplicación inmobiliaria.
BEGIN;

CREATE SCHEMA inmobiliaria;
SET LOCAL search_path TO inmobiliaria;

CREATE TABLE rol (
    id_rol SERIAL PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE usuario (
    id_usuario SERIAL PRIMARY KEY,
    correo VARCHAR(150) NOT NULL UNIQUE,
    contraseña_hash VARCHAR(255) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE usuario_rol (
    id_usuario INTEGER REFERENCES usuario(id_usuario) ON UPDATE RESTRICT ON DELETE CASCADE,
    id_rol INTEGER REFERENCES rol(id_rol) ON UPDATE RESTRICT ON DELETE CASCADE,
    PRIMARY KEY (id_usuario, id_rol)
);

CREATE TABLE perfil (
    id_perfil SERIAL PRIMARY KEY,
    id_usuario INTEGER NOT NULL UNIQUE REFERENCES usuario(id_usuario) ON UPDATE RESTRICT ON DELETE RESTRICT,
    nombres VARCHAR(100),
    apellidos VARCHAR(100),
    documento VARCHAR(30),
    telefono VARCHAR(25),
    direccion VARCHAR(200),
    foto VARCHAR(255)
);

CREATE TABLE inmobiliaria (
    id_inmobiliaria SERIAL PRIMARY KEY,
    id_usuario INTEGER NOT NULL UNIQUE REFERENCES usuario(id_usuario) ON UPDATE RESTRICT ON DELETE RESTRICT,
    nombre VARCHAR(150) NOT NULL,
    identificacion_empresarial VARCHAR(50) NOT NULL UNIQUE,
    telefono VARCHAR(25),
    correo_contacto VARCHAR(150),
    direccion VARCHAR(200)
);

CREATE TABLE ciudad (
    id_ciudad SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE tipo_propiedad (
    id_tipo_propiedad SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE caracteristica (
    id_caracteristica SERIAL PRIMARY KEY,
    nombre VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE propiedad (
    id_propiedad SERIAL PRIMARY KEY,
    matricula_inmobiliaria VARCHAR(50) NOT NULL UNIQUE,
    id_inmobiliaria INTEGER NOT NULL REFERENCES inmobiliaria(id_inmobiliaria) ON UPDATE RESTRICT ON DELETE RESTRICT,
    id_ciudad INTEGER NOT NULL REFERENCES ciudad(id_ciudad) ON UPDATE RESTRICT ON DELETE RESTRICT,
    id_tipo_propiedad INTEGER NOT NULL REFERENCES tipo_propiedad(id_tipo_propiedad) ON UPDATE RESTRICT ON DELETE RESTRICT,
    titulo VARCHAR(150) NOT NULL,
    descripcion TEXT,
    direccion VARCHAR(200) NOT NULL,
    precio NUMERIC(14,2) NOT NULL CHECK (precio > 0),
    area NUMERIC(10,2) NOT NULL CHECK (area > 0),
    habitaciones INTEGER NOT NULL DEFAULT 0,
    baños INTEGER NOT NULL DEFAULT 0,
    tipo_operacion VARCHAR(10) NOT NULL CHECK (tipo_operacion IN ('VENTA', 'ARRIENDO')),
    estado VARCHAR(15) NOT NULL DEFAULT 'DISPONIBLE'
        CHECK (estado IN ('DISPONIBLE', 'VENDIDA', 'ARRENDADA')),
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    destacada BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE imagen_propiedad (
    id_imagen SERIAL PRIMARY KEY,
    id_propiedad INTEGER NOT NULL REFERENCES propiedad(id_propiedad) ON UPDATE RESTRICT ON DELETE CASCADE,
    ruta TEXT NOT NULL
);

CREATE TABLE propiedad_caracteristica (
    id_propiedad INTEGER REFERENCES propiedad(id_propiedad) ON UPDATE RESTRICT ON DELETE CASCADE,
    id_caracteristica INTEGER REFERENCES caracteristica(id_caracteristica) ON UPDATE RESTRICT ON DELETE CASCADE,
    PRIMARY KEY (id_propiedad, id_caracteristica)
);

CREATE TABLE cita (
    id_cita SERIAL PRIMARY KEY,
    id_cliente INTEGER NOT NULL REFERENCES usuario(id_usuario) ON UPDATE RESTRICT ON DELETE RESTRICT,
    id_propiedad INTEGER NOT NULL REFERENCES propiedad(id_propiedad) ON UPDATE RESTRICT ON DELETE RESTRICT,
    fecha_hora TIMESTAMP NOT NULL,
    estado VARCHAR(15) NOT NULL DEFAULT 'PENDIENTE'
        CHECK (estado IN ('PENDIENTE', 'CONFIRMADA', 'REALIZADA', 'CANCELADA', 'RECHAZADA'))
);

CREATE UNIQUE INDEX uq_cita_horario
    ON cita (id_propiedad, fecha_hora)
    WHERE estado IN ('PENDIENTE', 'CONFIRMADA');

CREATE TABLE solicitud (
    id_solicitud SERIAL PRIMARY KEY,
    id_cliente INTEGER NOT NULL REFERENCES usuario(id_usuario) ON UPDATE RESTRICT ON DELETE RESTRICT,
    id_propiedad INTEGER NOT NULL REFERENCES propiedad(id_propiedad) ON UPDATE RESTRICT ON DELETE RESTRICT,
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(15) NOT NULL DEFAULT 'PENDIENTE'
        CHECK (estado IN ('PENDIENTE', 'APROBADA', 'RECHAZADA', 'FINALIZADA')),
    observacion TEXT
);

CREATE TABLE documento_solicitud (
    id_documento SERIAL PRIMARY KEY,
    id_solicitud INTEGER NOT NULL REFERENCES solicitud(id_solicitud) ON UPDATE RESTRICT ON DELETE RESTRICT,
    nombre VARCHAR(100) NOT NULL,
    ruta VARCHAR(255) NOT NULL,
    estado VARCHAR(15) NOT NULL DEFAULT 'PENDIENTE'
        CHECK (estado IN ('PENDIENTE', 'APROBADO', 'RECHAZADO')),
    observacion TEXT
);

CREATE TABLE favorito (
    id_cliente INTEGER REFERENCES usuario(id_usuario) ON UPDATE RESTRICT ON DELETE CASCADE,
    id_propiedad INTEGER REFERENCES propiedad(id_propiedad) ON UPDATE RESTRICT ON DELETE CASCADE,
    PRIMARY KEY (id_cliente, id_propiedad)
);

CREATE TABLE auditoria (
    id_auditoria SERIAL PRIMARY KEY,
    id_usuario INTEGER REFERENCES usuario(id_usuario) ON UPDATE RESTRICT ON DELETE RESTRICT,
    accion VARCHAR(255) NOT NULL,
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMIT;
