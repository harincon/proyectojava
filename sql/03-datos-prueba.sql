BEGIN;
SET LOCAL search_path TO inmobiliaria;

-- Usuarios y perfiles
INSERT INTO usuario (correo, contraseña_hash, activo)
SELECT datos.correo,
       'pbkdf2-sha256$120000$RiPdkp+xz3VYK4N6iVRXHQ==$/VY7HGSXXcnqm0r8aqaGUbHVIYulwl30Vid2IGcjl0g=',
       TRUE
FROM (VALUES
    ('camila.rojas@habita.local'),
    ('andres.gomez@habita.local'),
    ('valentina.torres@habita.local'),
    ('santiago.perez@habita.local'),
    ('natalia.ramirez@habita.local'),
    ('felipe.vargas@habita.local'),
    ('juliana.mendoza@habita.local'),
    ('sebastian.castro@habita.local'),
    ('maria.lopez@habita.local'),
    ('juan.sanchez@habita.local'),
    ('daniela.moreno@habita.local'),
    ('carlos.ruiz@habita.local'),
    ('paula.herrera@habita.local'),
    ('miguel.ortiz@habita.local'),
    ('sofia.cardenas@habita.local'),
    ('diego.navarro@habita.local'),
    ('isabella.reyes@habita.local'),
    ('mateo.silva@habita.local'),
    ('gabriela.acosta@habita.local'),
    ('nicolas.parra@habita.local')
) AS datos(correo);

INSERT INTO perfil (id_usuario, nombres, apellidos, documento, telefono, direccion, foto)
SELECT (SELECT id_usuario FROM usuario WHERE correo = datos.correo),
       datos.nombres, datos.apellidos, datos.documento, datos.telefono, datos.direccion,
       NULL
FROM (VALUES
    ('camila.rojas@habita.local', 'Camila', 'Rojas', '1098701001', '3004101001', 'Calle 34 # 18-20, Bucaramanga'),
    ('andres.gomez@habita.local', 'Andrés', 'Gómez', '1098701002', '3004101002', 'Carrera 27 # 45-18, Bucaramanga'),
    ('valentina.torres@habita.local', 'Valentina', 'Torres', '1098701003', '3004101003', 'Calle 12 # 8-30, Floridablanca'),
    ('santiago.perez@habita.local', 'Santiago', 'Pérez', '1098701004', '3004101004', 'Carrera 15 # 22-41, Girón'),
    ('natalia.ramirez@habita.local', 'Natalia', 'Ramírez', '1098701005', '3004101005', 'Calle 9 # 6-25, Piedecuesta'),
    ('felipe.vargas@habita.local', 'Felipe', 'Vargas', '1098701006', '3004101006', 'Carrera 7 # 72-15, Bogotá'),
    ('juliana.mendoza@habita.local', 'Juliana', 'Mendoza', '1098701007', '3004101007', 'Calle 10 # 36-22, Medellín'),
    ('sebastian.castro@habita.local', 'Sebastián', 'Castro', '1098701008', '3004101008', 'Carrera 5 # 16-40, Cali'),
    ('maria.lopez@habita.local', 'María Fernanda', 'López', '1098701009', '3004101009', 'Calle 84 # 51-12, Barranquilla'),
    ('juan.sanchez@habita.local', 'Juan David', 'Sánchez', '1098701010', '3004101010', 'Carrera 3 # 24-50, Cartagena'),
    ('daniela.moreno@habita.local', 'Daniela', 'Moreno', '1098702001', '3015202001', 'Calle 56 # 31-44, Bucaramanga'),
    ('carlos.ruiz@habita.local', 'Carlos', 'Ruiz', '1098702002', '3015202002', 'Carrera 22 # 30-17, Floridablanca'),
    ('paula.herrera@habita.local', 'Paula', 'Herrera', '1098702003', '3015202003', 'Calle 28 # 20-11, Girón'),
    ('miguel.ortiz@habita.local', 'Miguel', 'Ortiz', '1098702004', '3015202004', 'Carrera 9 # 14-36, Piedecuesta'),
    ('sofia.cardenas@habita.local', 'Sofía', 'Cárdenas', '1098702005', '3015202005', 'Calle 127 # 18-14, Bogotá'),
    ('diego.navarro@habita.local', 'Diego', 'Navarro', '1098702006', '3015202006', 'Carrera 43A # 7-32, Medellín'),
    ('isabella.reyes@habita.local', 'Isabella', 'Reyes', '1098702007', '3015202007', 'Calle 5 # 38-19, Cali'),
    ('mateo.silva@habita.local', 'Mateo', 'Silva', '1098702008', '3015202008', 'Carrera 53 # 80-26, Barranquilla'),
    ('gabriela.acosta@habita.local', 'Gabriela', 'Acosta', '1098702009', '3015202009', 'Calle 32 # 4-21, Cartagena'),
    ('nicolas.parra@habita.local', 'Nicolás', 'Parra', '1098702010', '3015202010', 'Carrera 12 # 18-45, Pereira')
) AS datos(correo, nombres, apellidos, documento, telefono, direccion);

INSERT INTO usuario_rol (id_usuario, id_rol)
SELECT (SELECT id_usuario FROM usuario WHERE correo = datos.correo),
       (SELECT id_rol FROM rol WHERE nombre = 'INMOBILIARIA')
FROM (VALUES
    ('camila.rojas@habita.local'), ('andres.gomez@habita.local'),
    ('valentina.torres@habita.local'), ('santiago.perez@habita.local'),
    ('natalia.ramirez@habita.local'), ('felipe.vargas@habita.local'),
    ('juliana.mendoza@habita.local'), ('sebastian.castro@habita.local'),
    ('maria.lopez@habita.local'), ('juan.sanchez@habita.local')
) AS datos(correo);

INSERT INTO usuario_rol (id_usuario, id_rol)
SELECT (SELECT id_usuario FROM usuario WHERE correo = datos.correo),
       (SELECT id_rol FROM rol WHERE nombre = 'CLIENTE')
FROM (VALUES
    ('daniela.moreno@habita.local'), ('carlos.ruiz@habita.local'),
    ('paula.herrera@habita.local'), ('miguel.ortiz@habita.local'),
    ('sofia.cardenas@habita.local'), ('diego.navarro@habita.local'),
    ('isabella.reyes@habita.local'), ('mateo.silva@habita.local'),
    ('gabriela.acosta@habita.local'), ('nicolas.parra@habita.local'),
    ('camila.rojas@habita.local')
) AS datos(correo);

-- Catálogos y empresas
INSERT INTO ciudad (nombre) VALUES
    ('Bucaramanga'), ('Floridablanca'), ('Girón'), ('Piedecuesta'), ('Bogotá'),
    ('Medellín'), ('Cali'), ('Barranquilla'), ('Cartagena'), ('Pereira');

INSERT INTO tipo_propiedad (nombre) VALUES
    ('Casa'), ('Apartamento'), ('Local'), ('Oficina'), ('Terreno');

INSERT INTO caracteristica (nombre) VALUES
    ('Parqueadero'), ('Piscina'), ('Ascensor'), ('Gimnasio'), ('Balcón'),
    ('Terraza'), ('Vigilancia'), ('Zona verde'), ('Depósito'), ('Patio');

INSERT INTO inmobiliaria
    (id_usuario, nombre, identificacion_empresarial, telefono, correo_contacto, direccion)
SELECT (SELECT id_usuario FROM usuario WHERE correo = datos.correo),
       datos.nombre, datos.nit, datos.telefono, datos.contacto, datos.direccion
FROM (VALUES
    ('camila.rojas@habita.local', 'Raíz Santandereana', 'NIT-901500101-1', '6076301001', 'contacto@raizsantandereana.co', 'Carrera 33 # 48-15, Bucaramanga'),
    ('andres.gomez@habita.local', 'Horizonte Urbano', 'NIT-901500102-2', '6063401002', 'contacto@horizonteurbano.co', 'Carrera 13 # 15-28, Pereira'),
    ('valentina.torres@habita.local', 'Vivienda Cañaveral', 'NIT-901500103-3', '6076301003', 'contacto@viviendacanaveral.co', 'Carrera 26 # 30-55, Floridablanca'),
    ('santiago.perez@habita.local', 'Patrimonio Colonial', 'NIT-901500104-4', '6076301004', 'contacto@patrimoniocolonial.co', 'Calle 31 # 25-20, Girón'),
    ('natalia.ramirez@habita.local', 'Espacios del Valle', 'NIT-901500105-5', '6076301005', 'contacto@espaciosdelvalle.co', 'Carrera 8 # 12-40, Piedecuesta'),
    ('felipe.vargas@habita.local', 'Capital Inmuebles', 'NIT-901500106-6', '6017401006', 'contacto@capitalinmuebles.co', 'Calle 93 # 14-25, Bogotá'),
    ('juliana.mendoza@habita.local', 'Aburrá Propiedad', 'NIT-901500107-7', '6045201007', 'contacto@aburrapropiedad.co', 'Carrera 43A # 10-32, Medellín'),
    ('sebastian.castro@habita.local', 'Valle Hogar', 'NIT-901500108-8', '6024801008', 'contacto@vallehogar.co', 'Avenida 6N # 24-18, Cali'),
    ('maria.lopez@habita.local', 'Caribe Bienes Raíces', 'NIT-901500109-9', '6053601009', 'contacto@caribebienes.co', 'Carrera 53 # 80-67, Barranquilla'),
    ('juan.sanchez@habita.local', 'Murallas Inmobiliarias', 'NIT-901500110-0', '6056601010', 'contacto@murallas.co', 'Calle de la Moneda # 7-45, Cartagena')
) AS datos(correo, nombre, nit, telefono, contacto, direccion);

-- Propiedades
INSERT INTO propiedad
    (matricula_inmobiliaria, id_inmobiliaria, id_ciudad, id_tipo_propiedad, titulo,
     descripcion, direccion, precio, area, habitaciones, baños, tipo_operacion,
     estado, activa, destacada)
SELECT datos.matricula,
       (SELECT id_inmobiliaria FROM inmobiliaria WHERE identificacion_empresarial = datos.nit),
       (SELECT id_ciudad FROM ciudad WHERE nombre = datos.ciudad),
       (SELECT id_tipo_propiedad FROM tipo_propiedad WHERE nombre = datos.tipo),
       datos.titulo, datos.descripcion, datos.direccion, datos.precio, datos.area,
       datos.habitaciones, datos.banos, datos.operacion, datos.estado, datos.activa,
       datos.destacada
FROM (VALUES
    ('HAB-2026-001', 'NIT-901500101-1', 'Bucaramanga', 'Casa', 'Casa familiar en Cabecera', 'Casa amplia cerca de parques y comercio.', 'Calle 42 # 35-18', 680000000.00, 180.00, 4, 3, 'VENTA', 'DISPONIBLE', TRUE, TRUE),
    ('HAB-2026-002', 'NIT-901500101-1', 'Bucaramanga', 'Apartamento', 'Apartamento con vista al parque', 'Apartamento iluminado en zona residencial.', 'Carrera 38 # 52-40', 390000000.00, 92.00, 3, 2, 'VENTA', 'DISPONIBLE', TRUE, TRUE),
    ('HAB-2026-003', 'NIT-901500103-3', 'Floridablanca', 'Casa', 'Casa en conjunto de Cañaveral', 'Vivienda de dos niveles con zona social.', 'Calle 30 # 24-60', 2800000.00, 145.00, 3, 3, 'ARRIENDO', 'DISPONIBLE', TRUE, TRUE),
    ('HAB-2026-004', 'NIT-901500103-3', 'Floridablanca', 'Apartamento', 'Apartamento cerca de clínica', 'Ubicación central y transporte cercano.', 'Carrera 23 # 31-12', 1900000.00, 78.00, 2, 2, 'ARRIENDO', 'DISPONIBLE', TRUE, FALSE),
    ('HAB-2026-005', 'NIT-901500104-4', 'Girón', 'Local', 'Local sobre vía principal', 'Espacio comercial con alta circulación peatonal.', 'Carrera 26 # 32-18', 310000000.00, 64.00, 0, 1, 'VENTA', 'VENDIDA', TRUE, FALSE),
    ('HAB-2026-006', 'NIT-901500104-4', 'Girón', 'Casa', 'Casa colonial remodelada', 'Conserva fachada tradicional y espacios renovados.', 'Calle 29 # 24-11', 450000000.00, 160.00, 3, 2, 'VENTA', 'DISPONIBLE', TRUE, FALSE),
    ('HAB-2026-007', 'NIT-901500105-5', 'Piedecuesta', 'Terreno', 'Lote campestre en la mesa', 'Terreno plano con acceso vehicular.', 'Vereda La Mata, lote 18', 220000000.00, 950.00, 0, 0, 'VENTA', 'DISPONIBLE', TRUE, TRUE),
    ('HAB-2026-008', 'NIT-901500105-5', 'Piedecuesta', 'Casa', 'Casa campestre amoblada', 'Casa rodeada de zonas verdes.', 'Kilómetro 4 vía Guatiguará', 3500000.00, 210.00, 4, 3, 'ARRIENDO', 'ARRENDADA', TRUE, FALSE),
    ('HAB-2026-009', 'NIT-901500106-6', 'Bogotá', 'Apartamento', 'Apartamento en Cedritos', 'Edificio residencial con acceso controlado.', 'Calle 145 # 12-30', 520000000.00, 88.00, 3, 2, 'VENTA', 'DISPONIBLE', TRUE, TRUE),
    ('HAB-2026-010', 'NIT-901500106-6', 'Bogotá', 'Oficina', 'Oficina en corredor empresarial', 'Planta abierta para equipo de trabajo.', 'Carrera 11 # 93-20', 4600000.00, 105.00, 0, 2, 'ARRIENDO', 'DISPONIBLE', TRUE, FALSE),
    ('HAB-2026-011', 'NIT-901500107-7', 'Medellín', 'Apartamento', 'Apartamento en Laureles', 'Sector tranquilo con rutas de transporte.', 'Circular 4 # 72-35', 2600000.00, 84.00, 3, 2, 'ARRIENDO', 'DISPONIBLE', TRUE, TRUE),
    ('HAB-2026-012', 'NIT-901500107-7', 'Medellín', 'Local', 'Local comercial en El Poblado', 'Local en primer piso con vitrina exterior.', 'Calle 10 # 34-22', 780000000.00, 96.00, 0, 2, 'VENTA', 'VENDIDA', TRUE, FALSE),
    ('HAB-2026-013', 'NIT-901500108-8', 'Cali', 'Casa', 'Casa amplia en Ciudad Jardín', 'Vivienda con patio interior y terraza.', 'Carrera 105 # 15-42', 890000000.00, 240.00, 4, 4, 'VENTA', 'DISPONIBLE', FALSE, FALSE),
    ('HAB-2026-014', 'NIT-901500108-8', 'Cali', 'Oficina', 'Oficina cerca del centro financiero', 'Oficina dividida con sala de reuniones.', 'Avenida 6N # 28-16', 3200000.00, 90.00, 0, 2, 'ARRIENDO', 'DISPONIBLE', TRUE, FALSE),
    ('HAB-2026-015', 'NIT-901500109-9', 'Barranquilla', 'Apartamento', 'Apartamento en Alto Prado', 'Balcón amplio y zonas comunes.', 'Carrera 55 # 82-30', 610000000.00, 118.00, 3, 3, 'VENTA', 'DISPONIBLE', TRUE, TRUE),
    ('HAB-2026-016', 'NIT-901500109-9', 'Barranquilla', 'Local', 'Local para restaurante', 'Área abierta con punto para cocina.', 'Calle 84 # 50-25', 5800000.00, 130.00, 0, 2, 'ARRIENDO', 'ARRENDADA', TRUE, FALSE),
    ('HAB-2026-017', 'NIT-901500110-0', 'Cartagena', 'Casa', 'Casa en zona norte', 'Conjunto residencial próximo al mar.', 'Vía al Mar, kilómetro 8', 4800000.00, 175.00, 4, 3, 'ARRIENDO', 'DISPONIBLE', TRUE, TRUE),
    ('HAB-2026-018', 'NIT-901500110-0', 'Cartagena', 'Terreno', 'Terreno para proyecto turístico', 'Lote con acceso desde vía secundaria.', 'Manzanillo del Mar, lote 7', 950000000.00, 1400.00, 0, 0, 'VENTA', 'DISPONIBLE', FALSE, FALSE),
    ('HAB-2026-019', 'NIT-901500102-2', 'Pereira', 'Oficina', 'Oficina en Circunvalar', 'Espacio listo para consultorio o despacho.', 'Avenida Circunvalar # 12-18', 430000000.00, 82.00, 0, 2, 'VENTA', 'DISPONIBLE', TRUE, FALSE),
    ('HAB-2026-020', 'NIT-901500102-2', 'Pereira', 'Apartamento', 'Apartamento en Pinares', 'Apartamento moderno con vista a la ciudad.', 'Carrera 17 # 9-44', 2300000.00, 86.00, 3, 2, 'ARRIENDO', 'DISPONIBLE', TRUE, TRUE)
) AS datos(matricula, nit, ciudad, tipo, titulo, descripcion, direccion, precio, area,
           habitaciones, banos, operacion, estado, activa, destacada);

-- Fotografías locales de img/habita/ (Unsplash; créditos en varios/referencias/fotografias.md).
-- La primera de cada propiedad es la del catálogo: en las 14 publicadas y disponibles no se repite.
-- Nueve propiedades tienen una segunda foto (interior) para la galería del detalle.
INSERT INTO imagen_propiedad (id_propiedad, ruta)
SELECT (SELECT id_propiedad FROM propiedad WHERE matricula_inmobiliaria = datos.matricula),
       datos.ruta
FROM (VALUES
    (1,  'HAB-2026-001', 'img/habita/17-casa-colonial-jardin.jpg'),
    (2,  'HAB-2026-001', 'img/habita/03-casa-jardin.jpg'),
    (3,  'HAB-2026-001', 'img/habita/25-habitacion-principal.jpg'),
    (4,  'HAB-2026-002', 'img/habita/11-ciudad-cali.jpg'),
    (5,  'HAB-2026-002', 'img/habita/23-sala-apartamento.jpg'),
    (6,  'HAB-2026-003', 'img/habita/26-casa-piscina-moderna.jpg'),
    (7,  'HAB-2026-003', 'img/habita/13-casa-campestre-piscina.jpg'),
    (8,  'HAB-2026-004', 'img/habita/21-sala-apartaestudio.jpg'),
    (9,  'HAB-2026-004', 'img/habita/27-cocina-comedor.jpg'),
    (10, 'HAB-2026-005', 'img/habita/08-bodega-bucaramanga.jpg'),
    (11, 'HAB-2026-006', 'img/habita/20-casa-porche.jpg'),
    (12, 'HAB-2026-007', 'img/habita/18-lote-urbano-aereo.jpg'),
    (13, 'HAB-2026-008', 'img/habita/15-casa-campestre-bosque.jpg'),
    (14, 'HAB-2026-009', 'img/habita/01-hero-edificio.jpg'),
    (15, 'HAB-2026-009', 'img/habita/04-penthouse.jpg'),
    (16, 'HAB-2026-010', 'img/habita/05-oficina.jpg'),
    (17, 'HAB-2026-010', 'img/habita/12-ciudad-barranquilla.jpg'),
    (18, 'HAB-2026-011', 'img/habita/16-loft-doble-altura.jpg'),
    (19, 'HAB-2026-011', 'img/habita/02-apartamento-chapinero.jpg'),
    (20, 'HAB-2026-012', 'img/habita/06-local-comercial.jpg'),
    (21, 'HAB-2026-013', 'img/habita/14-casa-moderna-blanca.jpg'),
    (22, 'HAB-2026-014', 'img/habita/28-oficina-vista-ciudad.jpg'),
    (23, 'HAB-2026-015', 'img/habita/19-edificio-balcones.jpg'),
    (24, 'HAB-2026-015', 'img/habita/09-apartamento-mar-cartagena.jpg'),
    (25, 'HAB-2026-016', 'img/habita/29-local-vidriado.jpg'),
    (26, 'HAB-2026-017', 'img/habita/22-fachada-moderna.jpg'),
    (27, 'HAB-2026-018', 'img/habita/18-lote-urbano-aereo.jpg'),
    (28, 'HAB-2026-019', 'img/habita/10-banner-publicar.jpg'),
    (29, 'HAB-2026-020', 'img/habita/24-cocina-vista-ciudad.jpg'),
    (30, 'HAB-2026-020', 'img/habita/07-apartaestudio.jpg')
) AS datos(orden, matricula, ruta)
ORDER BY datos.orden;


INSERT INTO propiedad_caracteristica (id_propiedad, id_caracteristica)
SELECT (SELECT id_propiedad FROM propiedad WHERE matricula_inmobiliaria = datos.matricula),
       (SELECT id_caracteristica FROM caracteristica WHERE nombre = datos.caracteristica)
FROM (VALUES
    ('HAB-2026-001', 'Parqueadero'), ('HAB-2026-001', 'Patio'),
    ('HAB-2026-002', 'Ascensor'), ('HAB-2026-002', 'Gimnasio'),
    ('HAB-2026-003', 'Parqueadero'), ('HAB-2026-003', 'Piscina'),
    ('HAB-2026-004', 'Ascensor'), ('HAB-2026-004', 'Gimnasio'),
    ('HAB-2026-005', 'Parqueadero'),
    ('HAB-2026-006', 'Patio'), ('HAB-2026-006', 'Vigilancia'),
    ('HAB-2026-007', 'Zona verde'),
    ('HAB-2026-008', 'Parqueadero'), ('HAB-2026-008', 'Terraza'),
    ('HAB-2026-009', 'Ascensor'), ('HAB-2026-009', 'Depósito'),
    ('HAB-2026-010', 'Ascensor'),
    ('HAB-2026-011', 'Piscina'), ('HAB-2026-011', 'Gimnasio'),
    ('HAB-2026-012', 'Vigilancia'),
    ('HAB-2026-013', 'Patio'), ('HAB-2026-013', 'Terraza'),
    ('HAB-2026-014', 'Ascensor'),
    ('HAB-2026-015', 'Parqueadero'), ('HAB-2026-015', 'Balcón'),
    ('HAB-2026-016', 'Parqueadero'),
    ('HAB-2026-017', 'Piscina'),
    ('HAB-2026-018', 'Zona verde'),
    ('HAB-2026-019', 'Depósito'),
    ('HAB-2026-020', 'Balcón')
) AS datos(matricula, caracteristica);

-- Favoritos, citas y solicitudes
INSERT INTO favorito (id_cliente, id_propiedad)
SELECT (SELECT id_usuario FROM usuario WHERE correo = datos.correo),
       (SELECT id_propiedad FROM propiedad WHERE matricula_inmobiliaria = datos.matricula)
FROM (VALUES
    ('daniela.moreno@habita.local', 'HAB-2026-002'),
    ('carlos.ruiz@habita.local', 'HAB-2026-003'),
    ('paula.herrera@habita.local', 'HAB-2026-006'),
    ('miguel.ortiz@habita.local', 'HAB-2026-007'),
    ('sofia.cardenas@habita.local', 'HAB-2026-009'),
    ('diego.navarro@habita.local', 'HAB-2026-011'),
    ('isabella.reyes@habita.local', 'HAB-2026-014'),
    ('mateo.silva@habita.local', 'HAB-2026-015'),
    ('gabriela.acosta@habita.local', 'HAB-2026-017'),
    ('nicolas.parra@habita.local', 'HAB-2026-020')
) AS datos(correo, matricula);

INSERT INTO cita (id_cliente, id_propiedad, fecha_hora, estado)
SELECT (SELECT id_usuario FROM usuario WHERE correo = datos.correo),
       (SELECT id_propiedad FROM propiedad WHERE matricula_inmobiliaria = datos.matricula),
       datos.fecha_hora, datos.estado
FROM (VALUES
    ('daniela.moreno@habita.local', 'HAB-2026-001', date_trunc('day', CURRENT_TIMESTAMP) + INTERVAL '10 days 9 hours', 'PENDIENTE'),
    ('carlos.ruiz@habita.local', 'HAB-2026-002', date_trunc('day', CURRENT_TIMESTAMP) + INTERVAL '12 days 10 hours', 'CONFIRMADA'),
    ('paula.herrera@habita.local', 'HAB-2026-003', date_trunc('day', CURRENT_TIMESTAMP) + INTERVAL '14 days 14 hours', 'PENDIENTE'),
    ('miguel.ortiz@habita.local', 'HAB-2026-004', date_trunc('day', CURRENT_TIMESTAMP) + INTERVAL '16 days 15 hours', 'CONFIRMADA'),
    ('sofia.cardenas@habita.local', 'HAB-2026-006', date_trunc('day', CURRENT_TIMESTAMP) + INTERVAL '18 days 11 hours', 'PENDIENTE'),
    ('diego.navarro@habita.local', 'HAB-2026-007', date_trunc('day', CURRENT_TIMESTAMP) + INTERVAL '20 days 16 hours', 'CONFIRMADA'),
    ('isabella.reyes@habita.local', 'HAB-2026-005', date_trunc('day', CURRENT_TIMESTAMP) + INTERVAL '-40 days 9 hours', 'REALIZADA'),
    ('mateo.silva@habita.local', 'HAB-2026-008', date_trunc('day', CURRENT_TIMESTAMP) + INTERVAL '-35 days 10 hours', 'REALIZADA'),
    ('gabriela.acosta@habita.local', 'HAB-2026-009', date_trunc('day', CURRENT_TIMESTAMP) + INTERVAL '-30 days 14 hours', 'REALIZADA'),
    ('nicolas.parra@habita.local', 'HAB-2026-010', date_trunc('day', CURRENT_TIMESTAMP) + INTERVAL '-25 days 15 hours', 'REALIZADA'),
    ('daniela.moreno@habita.local', 'HAB-2026-011', date_trunc('day', CURRENT_TIMESTAMP) + INTERVAL '-8 days 11 hours', 'CANCELADA'),
    ('carlos.ruiz@habita.local', 'HAB-2026-012', date_trunc('day', CURRENT_TIMESTAMP) + INTERVAL '-6 days 16 hours', 'RECHAZADA'),
    ('paula.herrera@habita.local', 'HAB-2026-013', date_trunc('day', CURRENT_TIMESTAMP) + INTERVAL '22 days 9 hours', 'CANCELADA'),
    ('miguel.ortiz@habita.local', 'HAB-2026-014', date_trunc('day', CURRENT_TIMESTAMP) + INTERVAL '24 days 10 hours', 'RECHAZADA'),
    ('sofia.cardenas@habita.local', 'HAB-2026-015', date_trunc('day', CURRENT_TIMESTAMP) + INTERVAL '-4 days 14 hours', 'CANCELADA')
) AS datos(correo, matricula, fecha_hora, estado);

INSERT INTO solicitud (id_cliente, id_propiedad, fecha, estado, observacion)
SELECT (SELECT id_usuario FROM usuario WHERE correo = datos.correo),
       (SELECT id_propiedad FROM propiedad WHERE matricula_inmobiliaria = datos.matricula),
       datos.fecha, datos.estado, datos.observacion
FROM (VALUES
    ('daniela.moreno@habita.local', 'HAB-2026-005', CURRENT_TIMESTAMP - INTERVAL '55 days', 'FINALIZADA', 'Compra formalizada.'),
    ('carlos.ruiz@habita.local', 'HAB-2026-008', CURRENT_TIMESTAMP - INTERVAL '48 days', 'FINALIZADA', 'Contrato de arriendo formalizado.'),
    ('paula.herrera@habita.local', 'HAB-2026-012', CURRENT_TIMESTAMP - INTERVAL '45 days', 'FINALIZADA', 'Compra formalizada.'),
    ('miguel.ortiz@habita.local', 'HAB-2026-016', CURRENT_TIMESTAMP - INTERVAL '38 days', 'FINALIZADA', 'Contrato de arriendo formalizado.'),
    ('sofia.cardenas@habita.local', 'HAB-2026-001', CURRENT_TIMESTAMP - INTERVAL '12 days', 'PENDIENTE', 'Interés en compra para vivienda familiar.'),
    ('diego.navarro@habita.local', 'HAB-2026-002', CURRENT_TIMESTAMP - INTERVAL '11 days', 'APROBADA', 'Documentación revisada.'),
    ('isabella.reyes@habita.local', 'HAB-2026-003', CURRENT_TIMESTAMP - INTERVAL '10 days', 'PENDIENTE', 'Interés en arriendo por un año.'),
    ('mateo.silva@habita.local', 'HAB-2026-004', CURRENT_TIMESTAMP - INTERVAL '9 days', 'RECHAZADA', 'Ingresos insuficientes para el canon.'),
    ('gabriela.acosta@habita.local', 'HAB-2026-006', CURRENT_TIMESTAMP - INTERVAL '8 days', 'APROBADA', 'Solicitud aprobada para continuar trámite.'),
    ('nicolas.parra@habita.local', 'HAB-2026-007', CURRENT_TIMESTAMP - INTERVAL '7 days', 'PENDIENTE', 'Compra para proyecto campestre.'),
    ('daniela.moreno@habita.local', 'HAB-2026-009', CURRENT_TIMESTAMP - INTERVAL '6 days', 'RECHAZADA', 'Oferta económica no aceptada.'),
    ('carlos.ruiz@habita.local', 'HAB-2026-010', CURRENT_TIMESTAMP - INTERVAL '5 days', 'APROBADA', 'Documentos comerciales completos.'),
    ('paula.herrera@habita.local', 'HAB-2026-011', CURRENT_TIMESTAMP - INTERVAL '4 days', 'PENDIENTE', 'Solicitud de arriendo en estudio.'),
    ('miguel.ortiz@habita.local', 'HAB-2026-014', CURRENT_TIMESTAMP - INTERVAL '3 days', 'RECHAZADA', 'Se eligió otra propuesta.'),
    ('sofia.cardenas@habita.local', 'HAB-2026-015', CURRENT_TIMESTAMP - INTERVAL '2 days', 'PENDIENTE', 'Interés en compra del apartamento.')
) AS datos(correo, matricula, fecha, estado, observacion);

INSERT INTO documento_solicitud (id_solicitud, nombre, ruta, estado, observacion)
SELECT (
           SELECT id_solicitud
           FROM solicitud
           WHERE id_cliente = (SELECT id_usuario FROM usuario WHERE correo = datos.correo)
             AND id_propiedad = (SELECT id_propiedad FROM propiedad WHERE matricula_inmobiliaria = datos.matricula)
       ),
       datos.nombre, datos.ruta, datos.estado, datos.observacion
FROM (VALUES
    ('daniela.moreno@habita.local', 'HAB-2026-005', 'Cédula', 'solicitudes/001/cedula.pdf', 'APROBADO', 'Documento legible.'),
    ('daniela.moreno@habita.local', 'HAB-2026-005', 'Carta de aprobación', 'solicitudes/001/carta_aprobacion.pdf', 'APROBADO', 'Aprobación firmada.'),
    ('carlos.ruiz@habita.local', 'HAB-2026-008', 'Cédula', 'solicitudes/002/cedula.pdf', 'APROBADO', 'Documento legible.'),
    ('carlos.ruiz@habita.local', 'HAB-2026-008', 'Contrato', 'solicitudes/002/contrato.pdf', 'APROBADO', 'Contrato firmado.'),
    ('paula.herrera@habita.local', 'HAB-2026-012', 'Cédula', 'solicitudes/003/cedula.pdf', 'APROBADO', 'Documento legible.'),
    ('paula.herrera@habita.local', 'HAB-2026-012', 'Carta de aprobación', 'solicitudes/003/carta_aprobacion.pdf', 'APROBADO', 'Aprobación firmada.'),
    ('miguel.ortiz@habita.local', 'HAB-2026-016', 'Cédula', 'solicitudes/004/cedula.pdf', 'APROBADO', 'Documento legible.'),
    ('miguel.ortiz@habita.local', 'HAB-2026-016', 'Contrato', 'solicitudes/004/contrato.pdf', 'APROBADO', 'Contrato firmado.'),
    ('sofia.cardenas@habita.local', 'HAB-2026-001', 'Cédula', 'solicitudes/005/cedula.pdf', 'PENDIENTE', NULL),
    ('diego.navarro@habita.local', 'HAB-2026-002', 'Cédula', 'solicitudes/006/cedula.pdf', 'APROBADO', 'Documento legible.'),
    ('diego.navarro@habita.local', 'HAB-2026-002', 'Certificado de ingresos', 'solicitudes/006/ingresos.pdf', 'APROBADO', 'Ingresos comprobados.'),
    ('isabella.reyes@habita.local', 'HAB-2026-003', 'Cédula', 'solicitudes/007/cedula.pdf', 'PENDIENTE', NULL),
    ('mateo.silva@habita.local', 'HAB-2026-004', 'Certificado de ingresos', 'solicitudes/008/ingresos.pdf', 'RECHAZADO', 'Documento incompleto.'),
    ('gabriela.acosta@habita.local', 'HAB-2026-006', 'Cédula', 'solicitudes/009/cedula.pdf', 'APROBADO', 'Documento legible.'),
    ('nicolas.parra@habita.local', 'HAB-2026-007', 'Cédula', 'solicitudes/010/cedula.pdf', 'PENDIENTE', NULL),
    ('daniela.moreno@habita.local', 'HAB-2026-009', 'Oferta de compra', 'solicitudes/011/oferta.pdf', 'RECHAZADO', 'Oferta no aceptada.'),
    ('carlos.ruiz@habita.local', 'HAB-2026-010', 'Certificado de cámara', 'solicitudes/012/camara_comercio.pdf', 'APROBADO', 'Documento vigente.'),
    ('paula.herrera@habita.local', 'HAB-2026-011', 'Cédula', 'solicitudes/013/cedula.pdf', 'PENDIENTE', NULL),
    ('miguel.ortiz@habita.local', 'HAB-2026-014', 'Certificado de ingresos', 'solicitudes/014/ingresos.pdf', 'RECHAZADO', 'No cumple vigencia requerida.'),
    ('sofia.cardenas@habita.local', 'HAB-2026-015', 'Cédula', 'solicitudes/015/cedula.pdf', 'PENDIENTE', NULL)
) AS datos(correo, matricula, nombre, ruta, estado, observacion);

COMMIT;
