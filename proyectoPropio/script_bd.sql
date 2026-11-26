CREATE TABLE alcaldia (
    id_alcaldia SMALLINT PRIMARY KEY,
    nombre VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE colonia (
    id_alcaldia SMALLINT NOT NULL,
    nombre_colonia VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_alcaldia, nombre_colonia),
    FOREIGN KEY (id_alcaldia) REFERENCES alcaldia (id_alcaldia) ON DELETE CASCADE
);

CREATE TABLE subestacion (
    id_subestacion INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    estado_operativo VARCHAR(20) NOT NULL,
    latitud NUMERIC(9,6) NOT NULL,
    longitud NUMERIC(9,6) NOT NULL,
    CONSTRAINT ck_sub_estado CHECK (estado_operativo IN ('en_operacion', 'fuera_de_servicio')),
    CONSTRAINT ck_sub_lat CHECK (latitud BETWEEN -90 AND 90),
    CONSTRAINT ck_sub_lon CHECK (longitud BETWEEN -180 AND 180)
);

CREATE TABLE transformador (
    id_transformador INT PRIMARY KEY,
    numero_serie_cfe VARCHAR(30) NOT NULL UNIQUE,
    capacidad_kva NUMERIC(8,2) NOT NULL,
    tipo_instalacion VARCHAR(20) NOT NULL,
    latitud NUMERIC(9,6) NOT NULL,
    longitud NUMERIC(9,6) NOT NULL,
    fecha_ultimo_mantenimiento TIMESTAMP,
    id_subestacion INT NOT NULL,
    id_alcaldia SMALLINT NOT NULL,
    nombre_colonia VARCHAR(100) NOT NULL,
    FOREIGN KEY (id_subestacion) REFERENCES subestacion (id_subestacion),
    FOREIGN KEY (id_alcaldia, nombre_colonia) REFERENCES colonia (id_alcaldia, nombre_colonia),
    CONSTRAINT ck_tr_cap CHECK (capacidad_kva > 0),
    CONSTRAINT ck_tr_tipo CHECK (tipo_instalacion IN ('poste', 'pedestal', 'subterraneo')),
    CONSTRAINT ck_tr_lat CHECK (latitud BETWEEN -90 AND 90),
    CONSTRAINT ck_tr_lon CHECK (longitud BETWEEN -180 AND 180)
);

CREATE TABLE suministro (
    numero_servicio CHAR(12) PRIMARY KEY,
    id_transformador INT NOT NULL,
    FOREIGN KEY (id_transformador) REFERENCES transformador (id_transformador),
    CONSTRAINT ck_sum_num CHECK (numero_servicio ~ '^[0-9]{12}$')
);

CREATE TABLE lectura_carga (
    id_transformador INT NOT NULL,
    fecha_hora TIMESTAMP NOT NULL,
    carga_kva NUMERIC(8,2) NOT NULL,
    PRIMARY KEY (id_transformador, fecha_hora),
    FOREIGN KEY (id_transformador) REFERENCES transformador (id_transformador) ON DELETE CASCADE,
    CONSTRAINT ck_lec_carga CHECK (carga_kva >= 0)
);

CREATE TABLE cuadrilla (
    id_cuadrilla INT PRIMARY KEY,
    codigo_cuadrilla VARCHAR(20) NOT NULL UNIQUE,
    zona VARCHAR(100) NOT NULL,
    estatus_disponibilidad VARCHAR(15) NOT NULL,
    CONSTRAINT ck_cua_estatus CHECK (estatus_disponibilidad IN ('disponible', 'en_servicio', 'fuera_de_turno'))
);

CREATE TABLE cuadrilla_telefono (
    id_cuadrilla INT NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    PRIMARY KEY (id_cuadrilla, telefono),
    FOREIGN KEY (id_cuadrilla) REFERENCES cuadrilla (id_cuadrilla) ON DELETE CASCADE,
    CONSTRAINT ck_cuatel CHECK (telefono ~ '^[0-9+() -]{7,15}$')
);

CREATE TABLE tecnico (
    id_tecnico INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    rol VARCHAR(15),
    id_cuadrilla INT,
    FOREIGN KEY (id_cuadrilla) REFERENCES cuadrilla (id_cuadrilla),
    CONSTRAINT ck_tec_rol CHECK (rol IS NULL OR rol IN ('responsable', 'integrante')),
    CONSTRAINT ck_tec_rol_cuadrilla CHECK (id_cuadrilla IS NOT NULL OR rol IS NULL)
);

CREATE TABLE tecnico_especialidad (
    id_tecnico INT NOT NULL,
    especialidad VARCHAR(60) NOT NULL,
    PRIMARY KEY (id_tecnico, especialidad),
    FOREIGN KEY (id_tecnico) REFERENCES tecnico (id_tecnico) ON DELETE CASCADE
);

CREATE TABLE supervisor (
    id_supervisor INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE reporte (
    id_reporte INT PRIMARY KEY,
    folio_institucional VARCHAR(30) NOT NULL UNIQUE,
    origen_reporte VARCHAR(15) NOT NULL,
    fecha_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tipo_falla VARCHAR(20) NOT NULL,
    descripcion TEXT,
    estatus VARCHAR(15) NOT NULL DEFAULT 'registrado',
    calle VARCHAR(100),
    entre_calles VARCHAR(150),
    codigo_postal CHAR(5),
    colonia VARCHAR(100),
    alcaldia VARCHAR(60),
    entidad VARCHAR(40),
    referencias VARCHAR(200),
    id_transformador INT,
    FOREIGN KEY (id_transformador) REFERENCES transformador (id_transformador),
    CONSTRAINT ck_rep_origen CHECK (origen_reporte IN ('servicio', 'ubicacion', 'preventivo')),
    CONSTRAINT ck_rep_falla CHECK (tipo_falla IN ('sobrecarga', 'caida_arbol', 'falla_interna', 'otro')),
    CONSTRAINT ck_rep_estatus CHECK (estatus IN ('registrado', 'asignado', 'en_proceso', 'cerrado')),
    CONSTRAINT ck_rep_cp CHECK (codigo_postal IS NULL OR codigo_postal ~ '^[0-9]{5}$')
);

CREATE TABLE reporte_por_servicio (
    id_reporte INT PRIMARY KEY,
    telefono_contacto VARCHAR(15) NOT NULL,
    medio_reporte VARCHAR(20) NOT NULL,
    numero_servicio CHAR(12) NOT NULL,
    FOREIGN KEY (id_reporte) REFERENCES reporte (id_reporte) ON DELETE CASCADE,
    FOREIGN KEY (numero_servicio) REFERENCES suministro (numero_servicio),
    CONSTRAINT ck_rps_medio CHECK (medio_reporte IN ('telefono', 'app', 'web', 'ventanilla')),
    CONSTRAINT ck_rps_tel CHECK (telefono_contacto ~ '^[0-9+() -]{7,15}$')
);

CREATE TABLE reporte_por_ubicacion (
    id_reporte INT PRIMARY KEY,
    latitud NUMERIC(9,6) NOT NULL,
    longitud NUMERIC(9,6) NOT NULL,
    radio_afectacion_m INT NOT NULL,
    FOREIGN KEY (id_reporte) REFERENCES reporte (id_reporte) ON DELETE CASCADE,
    CONSTRAINT ck_rpu_lat CHECK (latitud BETWEEN -90 AND 90),
    CONSTRAINT ck_rpu_lon CHECK (longitud BETWEEN -180 AND 180),
    CONSTRAINT ck_rpu_radio CHECK (radio_afectacion_m > 0)
);

CREATE TABLE reporte_preventivo (
    id_reporte INT PRIMARY KEY,
    porcentaje_carga NUMERIC(5,2) NOT NULL,
    umbral_configurado NUMERIC(5,2) NOT NULL,
    FOREIGN KEY (id_reporte) REFERENCES reporte (id_reporte) ON DELETE CASCADE,
    CONSTRAINT ck_rpv_pct CHECK (porcentaje_carga >= 0),
    CONSTRAINT ck_rpv_umbral CHECK (umbral_configurado > 0 AND umbral_configurado <= 100)
);

CREATE TABLE orden_trabajo (
    id_orden INT PRIMARY KEY,
    id_reporte INT NOT NULL,
    prioridad VARCHAR(10) NOT NULL,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_asignacion TIMESTAMP,
    fecha_llegada TIMESTAMP,
    fecha_cierre TIMESTAMP,
    diagnostico_tecnico TEXT,
    id_cuadrilla INT,
    FOREIGN KEY (id_reporte) REFERENCES reporte (id_reporte),
    FOREIGN KEY (id_cuadrilla) REFERENCES cuadrilla (id_cuadrilla),
    CONSTRAINT ck_ord_prio CHECK (prioridad IN ('alta', 'media', 'baja')),
    CONSTRAINT ck_ord_f1 CHECK (fecha_asignacion IS NULL OR fecha_asignacion >= fecha_creacion),
    CONSTRAINT ck_ord_f2 CHECK (fecha_llegada IS NULL OR (fecha_asignacion IS NOT NULL AND fecha_llegada >= fecha_asignacion)),
    CONSTRAINT ck_ord_f3 CHECK (fecha_cierre IS NULL OR (fecha_asignacion IS NOT NULL AND fecha_cierre >= fecha_asignacion)),
    CONSTRAINT ck_ord_f4 CHECK (fecha_cierre IS NULL OR fecha_llegada IS NULL OR fecha_cierre >= fecha_llegada),
    CONSTRAINT ck_ord_asig CHECK (fecha_asignacion IS NULL OR id_cuadrilla IS NOT NULL)
);

CREATE TABLE auditoria_atencion (
    id_orden INT PRIMARY KEY,
    id_supervisor INT NOT NULL,
    fecha_auditoria TIMESTAMP NOT NULL,
    cumplio_sla BOOLEAN NOT NULL,
    FOREIGN KEY (id_orden) REFERENCES orden_trabajo (id_orden),
    FOREIGN KEY (id_supervisor) REFERENCES supervisor (id_supervisor)
);

CREATE OR REPLACE VIEW v_lectura_carga AS
SELECT l.id_transformador,
       l.fecha_hora,
       l.carga_kva,
       t.capacidad_kva,
       ROUND((l.carga_kva / t.capacidad_kva) * 100, 2) AS porcentaje_carga
FROM lectura_carga l
JOIN transformador t USING (id_transformador);

CREATE OR REPLACE VIEW v_orden_tiempos AS
SELECT id_orden,
       id_reporte,
       id_cuadrilla,
       FLOOR(EXTRACT(EPOCH FROM (fecha_llegada - fecha_asignacion)) / 60)::INT AS tiempo_respuesta_min,
       FLOOR(EXTRACT(EPOCH FROM (fecha_cierre - fecha_asignacion)) / 60)::INT AS tiempo_resolucion_min
FROM orden_trabajo;

CREATE OR REPLACE FUNCTION fn_validar_subtipo_reporte()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_origen VARCHAR(15);
    v_origen_esper VARCHAR(15) := TG_ARGV[0];
BEGIN
    SELECT origen_reporte
      INTO v_origen
      FROM reporte
     WHERE id_reporte = NEW.id_reporte;

    IF v_origen IS DISTINCT FROM v_origen_esper THEN
        RAISE EXCEPTION 'El reporte % no tiene origen_reporte = %', NEW.id_reporte, v_origen_esper;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_rps_ins_upd
BEFORE INSERT OR UPDATE ON reporte_por_servicio
FOR EACH ROW
EXECUTE FUNCTION fn_validar_subtipo_reporte('servicio');

CREATE TRIGGER trg_rpu_ins_upd
BEFORE INSERT OR UPDATE ON reporte_por_ubicacion
FOR EACH ROW
EXECUTE FUNCTION fn_validar_subtipo_reporte('ubicacion');

CREATE TRIGGER trg_rpv_ins_upd
BEFORE INSERT OR UPDATE ON reporte_preventivo
FOR EACH ROW
EXECUTE FUNCTION fn_validar_subtipo_reporte('preventivo');
