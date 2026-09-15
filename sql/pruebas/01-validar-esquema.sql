-- Ejecutar sobre el modelo simplificado en una base de prueba.
BEGIN;
SET LOCAL search_path TO inmobiliaria;

INSERT INTO rol VALUES (-1, 'CLIENTE'), (-2, 'INMOBILIARIA');
INSERT INTO usuario VALUES
    (-1, 'cliente@example.test', 'hash_solo_prueba', TRUE),
    (-2, 'inmobiliaria@example.test', 'hash_solo_prueba', TRUE);
INSERT INTO usuario_rol VALUES (-1, -1), (-2, -1), (-2, -2);
INSERT INTO perfil (id_perfil, id_usuario, nombres) VALUES (-1, -1, 'Cliente');
INSERT INTO inmobiliaria (id_inmobiliaria, id_usuario, nombre, identificacion_empresarial)
    VALUES (-1, -2, 'Inmobiliaria de prueba', 'NIT-PRUEBA-1');
INSERT INTO ciudad VALUES (-1, 'Ciudad de prueba');
INSERT INTO tipo_propiedad VALUES (-1, 'Casa de prueba');
INSERT INTO caracteristica VALUES (-1, 'Patio'), (-2, 'Garaje');
INSERT INTO propiedad
    (id_propiedad, matricula_inmobiliaria, id_inmobiliaria, id_ciudad,
     id_tipo_propiedad, titulo, direccion, precio, area, tipo_operacion)
SELECT i, 'PRUEBA-' || i, -1, -1, -1, 'Casa', 'Calle 1', 100000, 80, 'VENTA'
FROM (VALUES (-1), (-2)) AS datos(i);

INSERT INTO propiedad_caracteristica VALUES (-1, -1), (-1, -2), (-2, -1);
INSERT INTO favorito VALUES (-1, -1), (-1, -2), (-2, -1);
INSERT INTO cita VALUES (-1, -1, -1, '2030-01-10 10:00', 'PENDIENTE');
INSERT INTO solicitud (id_solicitud, id_cliente, id_propiedad) VALUES (-1, -1, -1);
INSERT INTO documento_solicitud (id_documento, id_solicitud, nombre, ruta)
VALUES (-1, -1, 'Documento', 'prueba.pdf');
INSERT INTO auditoria (id_auditoria, id_usuario, accion) VALUES (-1, -1, 'Prueba');

DO $pruebas$
DECLARE
    prueba RECORD;
    total INTEGER := 0;
BEGIN
    FOR prueba IN SELECT * FROM (VALUES
        ('Correo repetido', $$UPDATE usuario SET correo = 'cliente@example.test' WHERE id_usuario = -2$$, '23505'),
        ('Segundo perfil', $$INSERT INTO perfil (id_usuario) VALUES (-1)$$, '23505'),
        ('Matricula repetida', $$UPDATE propiedad SET matricula_inmobiliaria = 'PRUEBA--1' WHERE id_propiedad = -2$$, '23505'),
        ('Identificacion empresarial repetida', $$INSERT INTO inmobiliaria (id_usuario, nombre, identificacion_empresarial) VALUES (-1, 'Otra Inmobiliaria', 'NIT-PRUEBA-1')$$, '23505'),
        ('Segunda inmobiliaria para el mismo usuario', $$INSERT INTO inmobiliaria (id_usuario, nombre, identificacion_empresarial) VALUES (-2, 'Otra Empresa', 'NIT-PRUEBA-2')$$, '23505'),
        ('Rol repetido', $$INSERT INTO usuario_rol VALUES (-1, -1)$$, '23505'),
        ('Caracteristica repetida', $$INSERT INTO propiedad_caracteristica VALUES (-1, -1)$$, '23505'),
        ('Favorito repetido', $$INSERT INTO favorito VALUES (-1, -1)$$, '23505'),
        ('Cita ocupada', $$INSERT INTO cita (id_cliente, id_propiedad, fecha_hora) VALUES (-2, -1, '2030-01-10 10:00')$$, '23505'),
        ('Referencia inexistente', $$UPDATE propiedad SET id_ciudad = -999 WHERE id_propiedad = -1$$, '23503'),
        ('Borrado con historial', $$DELETE FROM propiedad WHERE id_propiedad = -1$$, '23001'),
        ('Precio negativo', $$UPDATE propiedad SET precio = -1 WHERE id_propiedad = -1$$, '23514'),
        ('Area cero', $$UPDATE propiedad SET area = 0 WHERE id_propiedad = -1$$, '23514'),
        ('Estado de cita invalido', $$UPDATE cita SET estado = 'OTRO' WHERE id_cita = -1$$, '23514'),
        ('Estado de solicitud invalido', $$UPDATE solicitud SET estado = 'OTRO' WHERE id_solicitud = -1$$, '23514'),
        ('Estado de documento invalido', $$UPDATE documento_solicitud SET estado = 'OTRO' WHERE id_documento = -1$$, '23514')
    ) AS casos(nombre, sentencia, error_esperado)
    LOOP
        BEGIN
            EXECUTE prueba.sentencia;
            RAISE EXCEPTION 'No se rechazo: %', prueba.nombre;
        EXCEPTION WHEN OTHERS THEN
            IF SQLSTATE <> prueba.error_esperado THEN
                RAISE;
            END IF;
        END;
        total := total + 1;
    END LOOP;
    RAISE NOTICE '% rechazos esperados comprobados', total;
END;
$pruebas$;

UPDATE cita SET estado = 'CANCELADA' WHERE id_cita = -1;
INSERT INTO cita (id_cliente, id_propiedad, fecha_hora)
VALUES (-2, -1, '2030-01-10 10:00');

INSERT INTO imagen_propiedad (id_propiedad, ruta) VALUES (-2, 'imagen.jpg');
DELETE FROM propiedad WHERE id_propiedad = -2;
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM imagen_propiedad WHERE id_propiedad = -2)
        OR EXISTS (SELECT 1 FROM propiedad_caracteristica WHERE id_propiedad = -2)
        OR EXISTS (SELECT 1 FROM favorito WHERE id_propiedad = -2) THEN
        RAISE EXCEPTION 'Fallo el borrado en cascada de los detalles';
    END IF;
    RAISE NOTICE 'Relaciones N:M, reutilizacion de horario y cascadas comprobadas';
END;
$$;

ROLLBACK;
