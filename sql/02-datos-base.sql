-- Datos mínimos para arrancar: los 3 roles y el administrador inicial.
-- Se ejecuta después de 01-esquema.sql y antes de 03-datos-prueba.sql.
-- Puede ejecutarse más de una vez: no duplica filas.
--
-- Administrador inicial (solo para desarrollo; cambiar antes de publicar):
--   correo: admin@habita.com   contraseña: Admin123
BEGIN;
SET LOCAL search_path TO inmobiliaria;

INSERT INTO rol (nombre) VALUES ('ADMINISTRADOR'), ('INMOBILIARIA'), ('CLIENTE')
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO usuario (correo, contraseña_hash, activo)
VALUES ('admin@habita.com',
        'pbkdf2-sha256$120000$8/gjiok1Ol5P4QyVFChzdQ==$OJoAzaEh0d3NcozYKp/Ka4kFcnNSSQ/0wd9mc7aHdNc=',
        TRUE)
ON CONFLICT (correo) DO NOTHING;

INSERT INTO perfil (id_usuario, nombres, apellidos)
SELECT u.id_usuario, 'Administrador', 'Habita'
FROM usuario u
WHERE u.correo = 'admin@habita.com'
ON CONFLICT (id_usuario) DO NOTHING;

INSERT INTO usuario_rol (id_usuario, id_rol)
SELECT u.id_usuario, r.id_rol
FROM usuario u, rol r
WHERE u.correo = 'admin@habita.com' AND r.nombre = 'ADMINISTRADOR'
ON CONFLICT DO NOTHING;

COMMIT;
