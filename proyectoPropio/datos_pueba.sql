INSERT INTO alcaldia VALUES (1, 'Gustavo A. Madero'), (2, 'Iztapalapa');
INSERT INTO colonia VALUES (1, 'Lindavista'), (1, 'Zacatenco'), (2, 'Santa Martha Acatitla');
INSERT INTO subestacion VALUES
    (1, 'SE Magdalena de las Salinas', 'en_operacion', 19.4950, -99.1180),
    (2, 'SE Iztapalapa Norte', 'en_operacion', 19.3600, -99.0500);

INSERT INTO transformador VALUES
    (1, 'TR-GAM-0001', 75.00, 'poste', 19.4900, -99.1300, CURRENT_TIMESTAMP - INTERVAL '400 days', 1, 1, 'Lindavista'),
    (2, 'TR-GAM-0002', 112.50, 'poste', 19.5020, -99.1370, CURRENT_TIMESTAMP - INTERVAL '30 days', 1, 1, 'Zacatenco'),
    (3, 'TR-IZT-0001', 150.00, 'pedestal', 19.3550, -99.0400, NULL, 2, 2, 'Santa Martha Acatitla');

INSERT INTO suministro VALUES
    ('010000000001', 1),
    ('010000000002', 1),
    ('010000000003', 2),
    ('020000000001', 3);

INSERT INTO lectura_carga VALUES
    (1, CURRENT_TIMESTAMP - INTERVAL '9 hours', 60.00),
    (1, CURRENT_TIMESTAMP - INTERVAL '6 hours', 68.00),
    (1, CURRENT_TIMESTAMP - INTERVAL '3 hours', 74.00),
    (2, CURRENT_TIMESTAMP - INTERVAL '3 hours', 50.00),
    (3, CURRENT_TIMESTAMP - INTERVAL '3 hours', 90.00);

BEGIN;
INSERT INTO cuadrilla VALUES
    (1, 'CUA-GAM-01', 'Gustavo A. Madero', 'disponible'),
    (2, 'CUA-IZT-01', 'Iztapalapa', 'disponible');
INSERT INTO cuadrilla_telefono VALUES
    (1, '5555550101'),
    (1, '5555550102'),
    (2, '5555550201');
COMMIT;

INSERT INTO tecnico VALUES
    (1, 'Luis Ramírez', 'responsable', 1),
    (2, 'Marta Soto', 'integrante', 1),
    (3, 'Iván Cruz', 'responsable', 2),
    (4, 'Rosa Peña', 'integrante', 2);

INSERT INTO tecnico_especialidad VALUES
    (1, 'media tensión'),
    (1, 'transformadores'),
    (2, 'redes subterráneas'),
    (3, 'transformadores');

INSERT INTO supervisor VALUES (1, 'Gabriela Núñez');

BEGIN;
INSERT INTO reporte (id_reporte, folio_institucional, origen_reporte, tipo_falla, descripcion, calle, codigo_postal, colonia, alcaldia, entidad, id_transformador)
VALUES (1, 'REP-2026-0001', 'servicio', 'falla_interna', 'Sin luz desde las 18:00', 'Av. Instituto Politécnico Nacional', '07300', 'Lindavista', 'Gustavo A. Madero', 'CDMX', 1);
INSERT INTO reporte_por_servicio VALUES (1, '5555559999', 'telefono', '010000000001');

INSERT INTO reporte (id_reporte, folio_institucional, origen_reporte, tipo_falla, descripcion, id_transformador)
VALUES (2, 'REP-2026-0002', 'ubicacion', 'caida_arbol', 'Árbol sobre la línea, sin luz en la cuadra', NULL);
INSERT INTO reporte_por_ubicacion VALUES (2, 19.5025, -99.1365, 300);

INSERT INTO reporte (id_reporte, folio_institucional, origen_reporte, tipo_falla, descripcion, id_transformador)
VALUES (3, 'REP-2026-0003', 'preventivo', 'sobrecarga', 'Carga del transformador sobre el umbral', 3);
INSERT INTO reporte_preventivo VALUES (3, 60.00, 50.00);
COMMIT;

INSERT INTO orden_trabajo (id_orden, id_reporte, prioridad, fecha_creacion, fecha_asignacion, fecha_llegada, fecha_cierre, diagnostico_tecnico, id_cuadrilla)
VALUES
    (1, 1, 'alta', CURRENT_TIMESTAMP - INTERVAL '5 hours', CURRENT_TIMESTAMP - INTERVAL '4 hours', CURRENT_TIMESTAMP - INTERVAL '3 hours', CURRENT_TIMESTAMP - INTERVAL '2 hours', 'Fusible dañado', 1),
    (2, 3, 'media', CURRENT_TIMESTAMP - INTERVAL '1 hour', NULL, NULL, NULL, NULL, NULL);

INSERT INTO auditoria_atencion VALUES (1, 1, CURRENT_TIMESTAMP - INTERVAL '1 hour', TRUE);

BEGIN;

-- =====================================================================
-- 1. REPORTES POR SERVICIO (origen_reporte = 'servicio')
-- =====================================================================
-- Caso 1.1: Falla interna en Zacatenco (Asociado al contrato de suministro '010000000003')
INSERT INTO reporte (id_reporte, folio_institucional, origen_reporte, tipo_falla, descripcion, calle, entre_calles, codigo_postal, colonia, alcaldia, entidad, id_transformador, estatus)
VALUES (
    10, 
    'REP-2026-0010', 
    'servicio', 
    'falla_interna', 
    'Variación severa de voltaje y apagón total en el domicilio', 
    'Av. Wilfrido Massieu', 
    'Calle Ticoman y Luis Enrique Erro', 
    '07738', 
    'Zacatenco', 
    'Gustavo A. Madero', 
    'CDMX', 
    2, 
    'registrado'
);

INSERT INTO reporte_por_servicio (id_reporte, telefono_contacto, medio_reporte, numero_servicio)
VALUES (10, '5555123456', 'app', '010000000003');

-- Caso 1.2: Falla en Santa Martha Acatitla (Asociado al contrato '020000000001')
INSERT INTO reporte (id_reporte, folio_institucional, origen_reporte, tipo_falla, descripcion, calle, codigo_postal, colonia, alcaldia, entidad, id_transformador, estatus)
VALUES (
    11, 
    'REP-2026-0011', 
    'servicio', 
    'otro', 
    'Sin suministro eléctrico desde la madrugada', 
    'Calzada Ignacio Zaragoza', 
    '09510', 
    'Santa Martha Acatitla', 
    'Iztapalapa', 
    'CDMX', 
    3, 
    'en_proceso'
);

INSERT INTO reporte_por_servicio (id_reporte, telefono_contacto, medio_reporte, numero_servicio)
VALUES (11, '5557890123', 'telefono', '020000000001');


-- =====================================================================
-- 2. REPORTES POR UBICACIÓN (origen_reporte = 'ubicacion')
-- =====================================================================
-- Caso 2.1: Caída de árbol sobre la red en Lindavista (Radio de afectación 150m)
INSERT INTO reporte (id_reporte, folio_institucional, origen_reporte, tipo_falla, descripcion, calle, entre_calles, codigo_postal, colonia, alcaldia, entidad, id_transformador, estatus)
VALUES (
    20, 
    'REP-2026-0020', 
    'ubicacion', 
    'caida_arbol', 
    'Rama grande cayó sobre líneas de media tensión bloqueando la calle', 
    'Calle Montevideo', 
    'Av. Insurgentes Norte y San Efrén', 
    '07300', 
    'Lindavista', 
    'Gustavo A. Madero', 
    'CDMX', 
    1, 
    'asignado'
);

INSERT INTO reporte_por_ubicacion (id_reporte, latitud, longitud, radio_afectacion_m)
VALUES (20, 19.4895, -99.1250, 150);

-- Caso 2.2: Falla de transformación en sector de Iztapalapa
INSERT INTO reporte (id_reporte, folio_institucional, origen_reporte, tipo_falla, descripcion, colonia, alcaldia, entidad, estatus)
VALUES (
    21, 
    'REP-2026-0021', 
    'ubicacion', 
    'sobrecarga', 
    'Explosión de boquilla en poste, afecta a varias manzanas', 
    'Santa Martha Acatitla', 
    'Iztapalapa', 
    'CDMX', 
    'registrado'
);

INSERT INTO reporte_por_ubicacion (id_reporte, latitud, longitud, radio_afectacion_m)
VALUES (21, 19.3560, -99.0410, 400);


-- =====================================================================
-- 3. REPORTES PREVENTIVOS (origen_reporte = 'preventivo')
-- =====================================================================
-- Caso 3.1: Alerta por sobrecarga en transformador TR-GAM-0001 (88% de carga frente a umbral del 85%)
INSERT INTO reporte (id_reporte, folio_institucional, origen_reporte, tipo_falla, descripcion, colonia, alcaldia, entidad, id_transformador, estatus)
VALUES (
    30, 
    'REP-2026-0030', 
    'preventivo', 
    'sobrecarga', 
    'Monitoreo automático: Operación cerca de la capacidad nominal máxima', 
    'Lindavista', 
    'Gustavo A. Madero', 
    'CDMX', 
    1, 
    'registrado'
);

INSERT INTO reporte_preventivo (id_reporte, porcentaje_carga, umbral_configurado)
VALUES (30, 88.50, 85.00);

-- Caso 3.2: Alerta en transformador TR-GAM-0002
INSERT INTO reporte (id_reporte, folio_institucional, origen_reporte, tipo_falla, descripcion, colonia, alcaldia, entidad, id_transformador, estatus)
VALUES (
    31, 
    'REP-2026-0031', 
    'preventivo', 
    'sobrecarga', 
    'Lectura telemétrica superó el umbral configurado durante hora pico', 
    'Zacatenco', 
    'Gustavo A. Madero', 
    'CDMX', 
    2, 
    'en_proceso'
);

INSERT INTO reporte_preventivo (id_reporte, porcentaje_carga, umbral_configurado)
VALUES (31, 92.10, 80.00);

COMMIT;