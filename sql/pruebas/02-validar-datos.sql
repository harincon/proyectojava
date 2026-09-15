BEGIN TRANSACTION READ ONLY;
SET LOCAL search_path TO inmobiliaria;

DO $pruebas$
DECLARE
    requisito RECORD;
    total BIGINT;
BEGIN
    FOR requisito IN
        SELECT * FROM (VALUES
            ('rol', 3),
            ('usuario', 21),
            ('usuario_rol', 22),
            ('perfil', 21),
            ('inmobiliaria', 10),
            ('ciudad', 10),
            ('tipo_propiedad', 5),
            ('caracteristica', 10),
            ('propiedad', 20),
            ('imagen_propiedad', 20),
            ('propiedad_caracteristica', 30),
            ('cita', 15),
            ('solicitud', 15),
            ('documento_solicitud', 20),
            ('favorito', 10)
        ) AS requisitos(tabla, minimo)
    LOOP
        EXECUTE format('SELECT count(*) FROM %I', requisito.tabla) INTO total;
        IF total < requisito.minimo THEN
            RAISE EXCEPTION 'La tabla % tiene % registros; requiere al menos %.',
                requisito.tabla, total, requisito.minimo;
        END IF;
    END LOOP;

    SELECT count(*) INTO total
    FROM usuario
    WHERE correo LIKE '%@habita.local';
    IF total <> 20 THEN
        RAISE EXCEPTION 'Se esperaban 20 usuarios de prueba y se encontraron %.', total;
    END IF;

    SELECT count(*) INTO total
    FROM usuario u
    WHERE u.correo LIKE '%@habita.local'
      AND u.contraseña_hash <> 'pbkdf2-sha256$120000$RiPdkp+xz3VYK4N6iVRXHQ==$/VY7HGSXXcnqm0r8aqaGUbHVIYulwl30Vid2IGcjl0g=';
    IF total > 0 THEN
        RAISE EXCEPTION 'Hay % usuarios de prueba con una contraseña distinta a Clave123.', total;
    END IF;

    SELECT count(*) INTO total
    FROM usuario u
    JOIN usuario_rol ur ON ur.id_usuario = u.id_usuario
    JOIN rol r ON r.id_rol = ur.id_rol
    WHERE u.correo LIKE '%@habita.local'
      AND r.nombre = 'INMOBILIARIA';
    IF total <> 10 THEN
        RAISE EXCEPTION 'Se esperaban 10 responsables con rol INMOBILIARIA y se encontraron %.', total;
    END IF;

    SELECT count(*) INTO total
    FROM usuario u
    JOIN usuario_rol ur ON ur.id_usuario = u.id_usuario
    JOIN rol r ON r.id_rol = ur.id_rol
    WHERE u.correo LIKE '%@habita.local'
      AND r.nombre = 'CLIENTE';
    IF total < 10 THEN
        RAISE EXCEPTION 'Se requieren al menos 10 usuarios de prueba con rol CLIENTE; hay %.', total;
    END IF;

    SELECT count(*) INTO total
    FROM (
        SELECT ur.id_usuario
        FROM usuario_rol ur
        JOIN usuario u ON u.id_usuario = ur.id_usuario
        WHERE u.correo LIKE '%@habita.local'
        GROUP BY ur.id_usuario
        HAVING count(*) >= 2
    ) usuarios_multirrol;
    IF total < 1 THEN
        RAISE EXCEPTION 'No existe un usuario de prueba con dos o más roles.';
    END IF;

    SELECT count(*) INTO total
    FROM inmobiliaria i
    WHERE NOT EXISTS (
        SELECT 1
        FROM usuario_rol ur
        JOIN rol r ON r.id_rol = ur.id_rol
        WHERE ur.id_usuario = i.id_usuario
          AND r.nombre = 'INMOBILIARIA'
    );
    IF total > 0 THEN
        RAISE EXCEPTION 'Hay % inmobiliarias cuyo responsable no tiene el rol INMOBILIARIA.', total;
    END IF;

    SELECT count(*) INTO total
    FROM solicitud s
    JOIN propiedad p ON p.id_propiedad = s.id_propiedad
    WHERE s.estado = 'FINALIZADA'
      AND NOT (
          (p.tipo_operacion = 'VENTA' AND p.estado = 'VENDIDA')
          OR (p.tipo_operacion = 'ARRIENDO' AND p.estado = 'ARRENDADA')
      );
    IF total > 0 THEN
        RAISE EXCEPTION 'Hay % solicitudes finalizadas que no coinciden con el estado del inmueble.', total;
    END IF;

    SELECT count(*) INTO total
    FROM solicitud
    WHERE estado = 'FINALIZADA';
    IF total < 1 THEN
        RAISE EXCEPTION 'Debe existir al menos una solicitud FINALIZADA.';
    END IF;

    SELECT count(*) INTO total
    FROM (
        SELECT id_propiedad, fecha_hora
        FROM cita
        WHERE estado IN ('PENDIENTE', 'CONFIRMADA')
        GROUP BY id_propiedad, fecha_hora
        HAVING count(*) > 1
    ) cruces;
    IF total > 0 THEN
        RAISE EXCEPTION 'Hay % cruces de citas activas para la misma propiedad y hora.', total;
    END IF;

    SELECT count(*) INTO total
    FROM cita
    WHERE estado IN ('PENDIENTE', 'CONFIRMADA')
      AND fecha_hora <= CURRENT_TIMESTAMP;
    IF total > 0 THEN
        RAISE EXCEPTION 'Hay % citas activas que no están en una fecha futura.', total;
    END IF;

    SELECT count(*) INTO total
    FROM cita
    WHERE estado = 'REALIZADA'
      AND fecha_hora >= CURRENT_TIMESTAMP;
    IF total > 0 THEN
        RAISE EXCEPTION 'Hay % citas REALIZADAS que no están en el pasado.', total;
    END IF;

    SELECT count(*) INTO total
    FROM propiedad p
    WHERE NOT EXISTS (
        SELECT 1 FROM cita c WHERE c.id_propiedad = p.id_propiedad
    );
    IF total < 1 THEN
        RAISE EXCEPTION 'Debe existir al menos una propiedad sin citas.';
    END IF;

    SELECT count(*) INTO total
    FROM (
        SELECT id_ciudad
        FROM propiedad
        WHERE estado = 'DISPONIBLE'
        GROUP BY id_ciudad
        HAVING count(*) >= 2
    ) ciudades_disponibles;
    IF total < 2 THEN
        RAISE EXCEPTION 'Se requieren dos ciudades con al menos dos propiedades disponibles; hay %.', total;
    END IF;

    SELECT count(*) INTO total
    FROM propiedad p
    JOIN imagen_propiedad ip ON ip.id_propiedad = p.id_propiedad
    WHERE p.matricula_inmobiliaria LIKE 'HAB-2026-%'
      AND ip.ruta <> 'img/sin_foto.svg';
    IF total > 0 THEN
        RAISE EXCEPTION 'Hay % imágenes de prueba con una ruta diferente a img/sin_foto.svg.', total;
    END IF;

    RAISE NOTICE 'Datos de B8 verificados correctamente.';
END
$pruebas$;

SELECT 'rol' AS tabla, count(*) AS registros FROM rol
UNION ALL SELECT 'usuario', count(*) FROM usuario
UNION ALL SELECT 'usuario_rol', count(*) FROM usuario_rol
UNION ALL SELECT 'perfil', count(*) FROM perfil
UNION ALL SELECT 'inmobiliaria', count(*) FROM inmobiliaria
UNION ALL SELECT 'ciudad', count(*) FROM ciudad
UNION ALL SELECT 'tipo_propiedad', count(*) FROM tipo_propiedad
UNION ALL SELECT 'caracteristica', count(*) FROM caracteristica
UNION ALL SELECT 'propiedad', count(*) FROM propiedad
UNION ALL SELECT 'imagen_propiedad', count(*) FROM imagen_propiedad
UNION ALL SELECT 'propiedad_caracteristica', count(*) FROM propiedad_caracteristica
UNION ALL SELECT 'cita', count(*) FROM cita
UNION ALL SELECT 'solicitud', count(*) FROM solicitud
UNION ALL SELECT 'documento_solicitud', count(*) FROM documento_solicitud
UNION ALL SELECT 'favorito', count(*) FROM favorito
UNION ALL SELECT 'auditoria', count(*) FROM auditoria
ORDER BY tabla;

ROLLBACK;
