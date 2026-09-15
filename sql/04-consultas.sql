SET search_path TO inmobiliaria;

-- INNER JOIN de 4 tablas: propiedades con ciudad, estado, tipo e inmobiliaria.
SELECT c.nombre AS ciudad,
       p.estado,
       p.matricula_inmobiliaria,
       p.titulo,
       tp.nombre AS tipo_propiedad,
       i.nombre AS inmobiliaria,
       p.tipo_operacion,
       p.precio
FROM propiedad p
INNER JOIN ciudad c ON c.id_ciudad = p.id_ciudad
INNER JOIN tipo_propiedad tp ON tp.id_tipo_propiedad = p.id_tipo_propiedad
INNER JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria
ORDER BY c.nombre, p.estado, p.titulo;

-- INNER JOIN de 5 tablas: citas por estado con cliente, propiedad y ciudad.
SELECT ci.estado,
       ci.fecha_hora,
       p.matricula_inmobiliaria,
       p.titulo AS propiedad,
       c.nombre AS ciudad,
       concat_ws(' ', pe.nombres, pe.apellidos) AS cliente
FROM cita ci
INNER JOIN propiedad p ON p.id_propiedad = ci.id_propiedad
INNER JOIN ciudad c ON c.id_ciudad = p.id_ciudad
INNER JOIN usuario u ON u.id_usuario = ci.id_cliente
INNER JOIN perfil pe ON pe.id_usuario = u.id_usuario
ORDER BY ci.estado, ci.fecha_hora;

-- INNER JOIN de 3 tablas: cantidad de solicitudes por inmobiliaria y estado.
SELECT i.nombre AS inmobiliaria,
       s.estado,
       count(*) AS total_solicitudes
FROM solicitud s
INNER JOIN propiedad p ON p.id_propiedad = s.id_propiedad
INNER JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria
GROUP BY i.id_inmobiliaria, i.nombre, s.estado
ORDER BY i.nombre, s.estado;

-- Relación N:M: características asociadas a cada propiedad.
SELECT p.matricula_inmobiliaria,
       p.titulo AS propiedad,
       ca.nombre AS caracteristica
FROM propiedad p
INNER JOIN propiedad_caracteristica pc ON pc.id_propiedad = p.id_propiedad
INNER JOIN caracteristica ca ON ca.id_caracteristica = pc.id_caracteristica
ORDER BY p.matricula_inmobiliaria, ca.nombre;

-- LEFT JOIN: propiedades que todavía no tienen citas registradas.
SELECT p.matricula_inmobiliaria,
       p.titulo,
       c.nombre AS ciudad,
       p.estado
FROM propiedad p
INNER JOIN ciudad c ON c.id_ciudad = p.id_ciudad
LEFT JOIN cita ci ON ci.id_propiedad = p.id_propiedad
WHERE ci.id_cita IS NULL
ORDER BY c.nombre, p.titulo;

-- GROUP BY/HAVING: ciudades con dos o más propiedades disponibles y activas.
SELECT c.nombre AS ciudad,
       count(*) AS propiedades_disponibles
FROM propiedad p
INNER JOIN ciudad c ON c.id_ciudad = p.id_ciudad
WHERE p.estado = 'DISPONIBLE'
  AND p.activa
GROUP BY c.nombre
HAVING count(*) >= 2
ORDER BY propiedades_disponibles DESC, c.nombre;

-- INNER JOIN de 5 tablas: ventas y arriendos finalizados con empresa y cliente.
SELECT s.fecha AS fecha_solicitud,
       p.tipo_operacion,
       p.estado AS estado_propiedad,
       p.matricula_inmobiliaria,
       p.titulo AS propiedad,
       i.nombre AS inmobiliaria,
       concat_ws(' ', pe.nombres, pe.apellidos) AS cliente
FROM solicitud s
INNER JOIN propiedad p ON p.id_propiedad = s.id_propiedad
INNER JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria
INNER JOIN usuario u ON u.id_usuario = s.id_cliente
INNER JOIN perfil pe ON pe.id_usuario = u.id_usuario
WHERE s.estado = 'FINALIZADA'
ORDER BY s.fecha DESC;
