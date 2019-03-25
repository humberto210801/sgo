--inicio agregar tablas==
--producto_equivalente
CREATE SEQUENCE sgo.secuencia_id_producto_equivalencia
    INCREMENT 1
    START 370
    MINVALUE 0
    MAXVALUE 9223372036854775807
    CACHE 1;

ALTER SEQUENCE sgo.secuencia_id_producto_equivalencia
    OWNER TO sgo_user;

-- ALTER TABLE sgo.producto_equivalente ADD COLUMN estado INTEGER DEFAULT 1;
CREATE TABLE sgo.producto_equivalente(
	id_producto_equivalencia integer NOT NULL DEFAULT nextval('sgo.secuencia_id_producto_equivalencia'::regclass),
	id_operacion integer,
	id_producto_principal integer,
	id_producto_secundario integer,
	centimetros integer,
	creado_el bigint,
    creado_por integer,
	ip_creacion character varying(40) COLLATE pg_catalog."default",
    estado integer DEFAULT 1,
	CONSTRAINT producto_equivalente_pkey PRIMARY KEY (id_producto_equivalencia),
	CONSTRAINT producto_equivalente_id_operacion_fkey FOREIGN KEY (id_operacion)
        REFERENCES sgo.operacion (id_operacion) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
	CONSTRAINT producto_equivalente_id_producto_principal_fkey FOREIGN KEY (id_producto_principal)
        REFERENCES sgo.producto (id_producto) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
	CONSTRAINT producto_equivalente_id_producto_secundario_fkey FOREIGN KEY (id_producto_secundario)
        REFERENCES sgo.producto (id_producto) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);
ALTER TABLE sgo.producto_equivalente
    OWNER to sgo_user;

--perfil_horario
CREATE SEQUENCE sgo.secuencia_id_perfil_horario
    INCREMENT 1
    START 400
    MINVALUE 0
    MAXVALUE 9223372036854775807
    CACHE 1;

ALTER SEQUENCE sgo.secuencia_id_perfil_horario
    OWNER TO sgo_user;
	
CREATE TABLE sgo.perfil_horario(
	id_perfil_horario integer NOT NULL DEFAULT nextval('sgo.secuencia_id_perfil_horario'::regclass),
	nombre_perfil character varying(60) COLLATE pg_catalog."default" NOT NULL,
	numero_turnos integer NOT NULL,
	estado integer NOT NULL,
	creado_el bigint,
    creado_por integer,
    actualizado_por integer,
    actualizado_el bigint,
    ip_creacion character varying(40) COLLATE pg_catalog."default",
    ip_actualizacion character varying(40) COLLATE pg_catalog."default",
	CONSTRAINT perfil_horario_pkey PRIMARY KEY (id_perfil_horario)
);
ALTER TABLE sgo.perfil_horario
    OWNER to sgo_user;

ALTER TABLE sgo.perfil_horario 
	ADD CONSTRAINT chk_perfil_horario_estado CHECK (estado in (1,2));

COMMENT ON COLUMN sgo.perfil_horario.estado IS
'1=Activo,2=Inactivo';
	
--perfil_detalle_horario
CREATE SEQUENCE sgo.secuencia_id_perfil_detalle_horario
    INCREMENT 1
    START 370
    MINVALUE 0
    MAXVALUE 9223372036854775807
    CACHE 1;

ALTER SEQUENCE sgo.secuencia_id_perfil_detalle_horario
    OWNER TO sgo_user;
	
CREATE TABLE sgo.perfil_detalle_horario(
	id_perfil_detalle_horario integer NOT NULL DEFAULT nextval('sgo.secuencia_id_perfil_detalle_horario'::regclass),
	id_perfil_horario integer NOT NULL,
	numero_orden integer NOT NULL,
	glosa_turno character varying(25) COLLATE pg_catalog."default" NOT NULL,
	hora_inicio_turno character varying(6) COLLATE pg_catalog."default" NOT NULL,
	hora_fin_turno character varying(6) COLLATE pg_catalog."default" NOT NULL,
	creado_el bigint,
    creado_por integer,
    actualizado_por integer,
    actualizado_el bigint,
    ip_creacion character varying(40) COLLATE pg_catalog."default",
    ip_actualizacion character varying(40) COLLATE pg_catalog."default",
	CONSTRAINT perfil_detalle_horario_pkey PRIMARY KEY (id_perfil_detalle_horario),
	CONSTRAINT perfil_detalle_horario_id_operacion_fkey FOREIGN KEY (id_perfil_horario)
        REFERENCES sgo.perfil_horario (id_perfil_horario) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);
ALTER TABLE sgo.perfil_detalle_horario
    OWNER to sgo_user;
--fin agregar tablas====================================================================================================

--inicio agregar campos=================================================================================================
ALTER TABLE sgo.operacion
	ADD COLUMN tipo_volumen_descargado integer NOT NULL default 1;

ALTER TABLE sgo.operacion 
	ADD CONSTRAINT chk_operacion_tipo_volumen_descargado CHECK (tipo_volumen_descargado in (1,2));

COMMENT ON COLUMN sgo.operacion.tipo_volumen_descargado IS
'1=Volumen de Cisterna(s),2=Volumen en tanque';

ALTER TABLE sgo.estacion
	ADD COLUMN tipo_apertura_tanque integer NOT NULL default 1,
	ADD COLUMN numero_decimales_contometro integer NOT NULL default 2;

ALTER TABLE sgo.estacion 
	ADD CONSTRAINT chk_operacion_tipo_apertura_tanque CHECK (tipo_apertura_tanque in (1,2)),
	ADD CONSTRAINT chk_operacion_numero_decimales_contometro CHECK (numero_decimales_contometro in (2,3,4,5,6));

COMMENT ON COLUMN sgo.estacion.tipo_apertura_tanque IS
'1=Uno por producto,2=Varios por producto';

COMMENT ON COLUMN sgo.estacion.numero_decimales_contometro IS
'2=numero con 2 decimales,
 3=numero con 3 decimales,
 4=numero con 4 decimales,
 5=numero con 5 decimales,
 6=numero con 6 decimales';

ALTER TABLE sgo.estacion
	ADD COLUMN id_perfil_horario integer;
	
ALTER TABLE sgo.estacion
	ADD CONSTRAINT estacion_id_perfil_horario_fkey FOREIGN KEY (id_perfil_horario)
        REFERENCES sgo.perfil_horario (id_perfil_horario) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION;
		
ALTER TABLE sgo.jornada
	ADD COLUMN id_perfil_horario integer;
	
ALTER TABLE sgo.jornada
	ADD CONSTRAINT jornada_id_perfil_horario_fkey FOREIGN KEY (id_perfil_horario)
        REFERENCES sgo.perfil_horario (id_perfil_horario) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION;
	
ALTER TABLE sgo.turno
	ADD COLUMN id_perfil_detalle_horario integer;
	
ALTER TABLE sgo.turno
	ADD CONSTRAINT turno_id_perfil_detalle_horario_fkey FOREIGN KEY (id_perfil_detalle_horario)
        REFERENCES sgo.perfil_detalle_horario (id_perfil_detalle_horario) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION;
	
ALTER TABLE sgo.turno		
	ADD COLUMN numero_orden integer,
	ADD COLUMN hora_inicio_turno character varying(6) COLLATE pg_catalog."default",
	ADD COLUMN hora_fin_turno character varying(6) COLLATE pg_catalog."default";
	
ALTER TABLE sgo.despacho
	ADD COLUMN id_turno integer,
	ADD COLUMN flag_calculo_corregido integer NOT NULL default 0;

ALTER TABLE sgo.despacho 
	ADD CONSTRAINT chk_despacho_flag_calculo_corregido CHECK (flag_calculo_corregido in (0,1,2));

ALTER TABLE sgo.despacho
	ADD CONSTRAINT despacho_id_turno_fkey FOREIGN KEY (id_turno)
        REFERENCES sgo.turno (id_turno) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION;
	
COMMENT ON COLUMN sgo.estacion.tipo_apertura_tanque IS
'0=Cuando al crear el registro el volumen corregido  es cero o nulo y volumen observado > 0. Valor por defecto,1=Cuando al crear el registro el volumen corregido > 0 y volumen observado > 0,2=Se asigna este valor (originalmente es cero) cuando se calcula el volumen corregido en el cierre de la jornada';
--fin agregar campos====================================================================================================

--inicio actualizar campos==============================================================================================
--eliminamos vistas asociadas
DROP VIEW sgo.v_detalle_turno;
DROP VIEW sgo.v_reporte_conciliacion_estacion;
DROP VIEW sgo.v_reporte_conciliacion_contometro;
DROP VIEW sgo.v_contometro_jornada;
DROP VIEW sgo.v_jornada;
DROP VIEW sgo.v_despacho;
DROP VIEW sgo.v_reporte_conciliacion_despacho;

DROP VIEW sgo.v_liquidacion_inventario_x_tanque_total;
DROP VIEW sgo.v_liquidacion_inventario_x_tanque_completo;
DROP VIEW sgo.v_liquidacion_inventario_x_tanque;
DROP VIEW sgo.v_liquidacion_inventario_x_tanque3;
DROP VIEW sgo.v_reporte_conciliacion_volumetrica;
DROP VIEW sgo.v_liquidacion_inventario_x_estacion_completo_total;
DROP VIEW sgo.v_liquidacion_inventario_x_estacion_completo;
DROP VIEW sgo.v_liquidacion_inventario_x_estacion;
DROP VIEW sgo.v_liquidacion_inventario_x_estacion3;
DROP VIEW sgo.v_liquidacion_inventario_a_resumen_completo_total;
DROP VIEW sgo.v_liquidacion_inventario_a_resumen_completo;
DROP VIEW sgo.v_liquidacion_inventario_a_resumen;
DROP VIEW sgo.v_liquidacion_inventario_a_resumen3;
DROP VIEW sgo.v_liquidacion_despacho_p4;
DROP VIEW sgo.v_liquidacion_despacho_p3;
DROP VIEW sgo.v_liquidacion_despacho_p2;
DROP VIEW sgo.v_liquidacion_despacho_p1;
DROP VIEW sgo.v_despacho_carga;
--actualizamos
ALTER TABLE sgo.detalle_turno
	ALTER COLUMN lectura_inicial TYPE numeric(16,6),
	ALTER COLUMN lectura_final TYPE numeric(16,6);

ALTER TABLE sgo.contometro_jornada
	ALTER COLUMN lectura_inicial TYPE numeric(16,6),
	ALTER COLUMN lectura_final TYPE numeric(16,6);
	
ALTER TABLE sgo.despacho
	ALTER COLUMN lectura_inicial TYPE numeric(16,6),
	ALTER COLUMN lectura_final TYPE numeric(16,6),
	ALTER COLUMN volumen_corregido TYPE numeric(16,6),
	ALTER COLUMN volumen_observado TYPE numeric(16,6);
	
ALTER TABLE sgo.despacho_carga
	ALTER COLUMN comentario TYPE text;
	
--creamos vistas nuevamente
CREATE OR REPLACE VIEW sgo.v_detalle_turno AS
 SELECT t1.id_turno,
    t1.id_dturno,
    t1.lectura_inicial,
    t1.lectura_final,
    t1.id_producto,
    t3.nombre AS nombre_producto,
    t1.id_contometro,
    t4.alias AS alias_contometro,
    t2.id_jornada,
    t2.estado,
    t2.id_estacion,
    t2.estacion,
    t2.fecha_hora_apertura,
    t2.fecha_hora_cierre,
    t2.creado_el,
    t2.creado_por,
    t2.actualizado_por,
    t2.actualizado_el,
    t2.ip_creacion,
    t2.ip_actualizacion,
    t2.usuario_creacion,
    t2.usuario_actualizacion,
    t5.fecha_operativa,
    t2.observacion
   FROM sgo.detalle_turno t1
     JOIN sgo.v_turno t2 ON t2.id_turno = t1.id_turno
     JOIN sgo.producto t3 ON t3.id_producto = t1.id_producto
     JOIN sgo.contometro t4 ON t4.id_contometro = t1.id_contometro
     JOIN sgo.jornada t5 ON t5.id_jornada = t2.id_jornada;

ALTER TABLE sgo.v_detalle_turno
    OWNER TO sgo_user;

CREATE OR REPLACE VIEW sgo.v_reporte_conciliacion_contometro AS
 SELECT t1.id_jornada,
    t1.id_producto,
    t1.lectura_inicial,
    t1.lectura_final,
    t1.volumen_observado,
    t2.factor_muestreo * t1.volumen_observado AS volumen_corregido
   FROM ( SELECT t3.id_jornada,
            sum(t3.lectura_final) AS lectura_final,
            sum(t3.lectura_inicial) AS lectura_inicial,
            sum(t3.lectura_final - t3.lectura_inicial) AS volumen_observado,
            t3.id_producto
           FROM sgo.contometro_jornada t3
          GROUP BY t3.id_jornada, t3.id_producto) t1
     LEFT JOIN sgo.v_muestreo_ultimo t2 ON t2.producto_muestreado = t1.id_producto AND t2.id_jornada = t1.id_jornada;

ALTER TABLE sgo.v_reporte_conciliacion_contometro
    OWNER TO sgo_user;
	
CREATE OR REPLACE VIEW sgo.v_reporte_conciliacion_despacho AS
 SELECT t3.id_jornada,
    sum(t3.volumen_observado) AS volumen_observado,
    sum(t3.volumen_corregido) AS volumen_corregido,
    t3.id_producto
   FROM sgo.despacho t3
  GROUP BY t3.id_jornada, t3.id_producto;

ALTER TABLE sgo.v_reporte_conciliacion_despacho
    OWNER TO sgo_user;

CREATE OR REPLACE VIEW sgo.v_reporte_conciliacion_estacion AS
 SELECT j.fecha_operativa,
    p.nombre AS producto,
    e.nombre AS estacion,
    t1.medida_inicial AS medida_inicial_t,
    t1.medida_final AS medida_final_t,
    t1.volumen_observado AS volumen_observado_t,
    t1.volumen_corregido AS volumen_corregido_t,
    t2.lectura_inicial AS lectura_inicial_c,
    t2.lectura_final AS lectura_final_c,
    t2.volumen_observado AS volumen_observado_c,
    t2.volumen_corregido AS volumen_corregido_c,
    t3.volumen_observado AS volumen_observado_d,
    t3.volumen_corregido AS volumen_corregido_d,
    t1.volumen_observado - t2.volumen_observado AS volumen_observado_tc,
    t1.volumen_corregido - t2.volumen_corregido AS volumen_corregido_tc,
    t1.volumen_observado - t3.volumen_observado AS volumen_observado_td,
    t1.volumen_corregido - t3.volumen_corregido AS volumen_corregido_td,
    t2.volumen_observado - t3.volumen_observado AS volumen_observado_cd,
    t2.volumen_corregido - t3.volumen_corregido AS volumen_corregido_cd,
    e.id_operacion,
        CASE
            WHEN j.estado = 1 THEN 'ABIERTO'::text
            WHEN j.estado = 2 THEN 'REGISTRADO'::text
            WHEN j.estado = 3 THEN 'CERRADO'::text
            WHEN j.estado = 4 THEN 'LIQUIDADO'::text
            ELSE 'ABIERTO'::text
        END AS estado
   FROM sgo.v_reporte_conciliacion_tanque t1
     LEFT JOIN sgo.v_reporte_conciliacion_contometro t2 ON t2.id_jornada = t1.id_jornada AND t2.id_producto = t1.id_producto
     LEFT JOIN sgo.v_reporte_conciliacion_despacho t3 ON t3.id_jornada = t1.id_jornada AND t3.id_producto = t1.id_producto
     JOIN sgo.producto p ON p.id_producto = COALESCE(t1.id_producto, t2.id_producto, t3.id_producto)
     JOIN sgo.jornada j ON j.id_jornada = COALESCE(t1.id_jornada, t2.id_jornada, t3.id_jornada)
     JOIN sgo.estacion e ON e.id_estacion = j.id_estacion;

ALTER TABLE sgo.v_reporte_conciliacion_estacion
    OWNER TO sgo_user;

CREATE OR REPLACE VIEW sgo.v_despacho AS
 SELECT t1.id_despacho,
    t1.id_jornada,
    t1.id_vehiculo,
    t1.kilometro_horometro,
    t1.numero_vale,
    t1.tipo_registro,
    t1.fecha_hora_inicio,
    t1.fecha_hora_fin,
    t1.clasificacion,
    t1.id_producto,
    t1.lectura_inicial,
    t1.lectura_final,
    t1.factor_correccion,
    t1.api_corregido,
    t1.temperatura,
    t1.volumen_corregido,
    t1.id_tanque,
    t1.id_contometro,
    t1.estado,
    t1.creado_el,
    t1.creado_por,
    t1.actualizado_por,
    t1.actualizado_el,
    t1.ip_creacion,
    t1.ip_actualizacion,
    u1.identidad AS usuario_creacion,
    u2.identidad AS usuario_actualizacion,
    t2.fecha_operativa,
    t2.id_estacion,
    t7.nombre AS nombre_estacion,
    t7.id_operacion,
    t8.nombre AS nombre_operacion,
    t8.id_cliente,
    t3.nombre_corto,
    t3.descripcion,
    t3.id_propietario,
    t6.razon_social,
    t6.nombre_corto AS nombre_corto_propietario,
    t4.descripcion AS descripcion_tanque,
    t5.alias AS alias_contometro,
    t5.tipo_contometro,
    t9.nombre AS nombre_producto,
    t9.abreviatura,
    t1.codigo_archivo_origen,
    t1.volumen_observado
   FROM sgo.despacho t1
     JOIN seguridad.usuario u1 ON t1.creado_por = u1.id_usuario
     JOIN seguridad.usuario u2 ON t1.actualizado_por = u2.id_usuario
     JOIN sgo.jornada t2 ON t1.id_jornada = t2.id_jornada
     JOIN sgo.vehiculo t3 ON t1.id_vehiculo = t3.id_vehiculo
     JOIN sgo.tanque t4 ON t1.id_tanque = t4.id_tanque
     JOIN sgo.contometro t5 ON t1.id_contometro = t5.id_contometro
     JOIN sgo.propietario t6 ON t3.id_propietario = t6.id_propietario
     JOIN sgo.estacion t7 ON t2.id_estacion = t7.id_estacion
     JOIN sgo.operacion t8 ON t7.id_operacion = t8.id_operacion
     JOIN sgo.producto t9 ON t1.id_producto = t9.id_producto;

ALTER TABLE sgo.v_despacho
    OWNER TO sgo_user;
	
CREATE OR REPLACE VIEW sgo.v_jornada AS
 SELECT t1.id_jornada,
    t1.fecha_operativa,
    t1.id_estacion,
    t1.comentario,
    t1.estado,
    t2.nombre,
    t2.tipo,
    t2.estado AS estado_estacion,
    t2.id_operacion,
    t1.creado_el,
    t1.creado_por,
    t1.actualizado_por,
    t1.actualizado_el,
    t1.ip_creacion,
    t1.ip_actualizacion,
    u1.identidad AS usuario_creacion,
    u2.identidad AS usuario_actualizacion,
    t1.operario1,
    t1.operario2,
    count(t3.id_despacho) AS total_despachos,
    t1.observacion
   FROM sgo.jornada t1
     JOIN sgo.estacion t2 ON t1.id_estacion = t2.id_estacion
     JOIN seguridad.usuario u1 ON t1.creado_por = u1.id_usuario
     JOIN seguridad.usuario u2 ON t1.actualizado_por = u2.id_usuario
     LEFT JOIN sgo.v_despacho t3 ON t1.id_jornada = t3.id_jornada
  GROUP BY t1.id_jornada, t1.fecha_operativa, t1.id_estacion, t1.comentario, t1.estado, t2.nombre, t2.tipo, t2.estado, t2.id_operacion, t1.creado_el, t1.creado_por, t1.actualizado_por, t1.actualizado_el, t1.ip_creacion, t1.ip_actualizacion, u1.identidad, u2.identidad, t1.operario1, t1.operario2, t1.observacion;

ALTER TABLE sgo.v_jornada
    OWNER TO sgo_user;

CREATE OR REPLACE VIEW sgo.v_contometro_jornada AS
 SELECT t1.id_cjornada,
    t1.id_jornada,
    t1.lectura_inicial,
    t1.lectura_final,
    t1.estado_servicio,
    t1.id_contometro,
    t1.id_producto,
    t4.alias AS alias_contometro,
    t2.fecha_operativa,
    t2.id_estacion,
    t5.nombre AS nombre_estacion,
    t5.id_operacion,
    t3.nombre AS nombre_producto,
    t2.operario1,
    t2.operario2
   FROM sgo.contometro_jornada t1
     JOIN sgo.v_jornada t2 ON t2.id_jornada = t1.id_jornada
     JOIN sgo.producto t3 ON t3.id_producto = t1.id_producto
     JOIN sgo.contometro t4 ON t4.id_contometro = t1.id_contometro
     JOIN sgo.estacion t5 ON t5.id_estacion = t2.id_estacion;

ALTER TABLE sgo.v_contometro_jornada
    OWNER TO sgo_user;

CREATE OR REPLACE VIEW sgo.v_liquidacion_despacho_p1 AS
 SELECT t2.fecha_operativa,
    t2.id_estacion,
    t1.id_jornada,
    t1.id_tanque,
    t1.id_producto,
    t1.volumen_observado,
    t1.volumen_corregido,
    t1.estado
   FROM sgo.despacho t1
     JOIN sgo.jornada t2 ON t1.id_jornada = t2.id_jornada
  WHERE t1.estado = 1;

ALTER TABLE sgo.v_liquidacion_despacho_p1
    OWNER TO sgo_user;

CREATE OR REPLACE VIEW sgo.v_liquidacion_despacho_p2 AS
 SELECT t2.id_operacion,
    t1.fecha_operativa,
    t1.id_estacion,
    t1.id_jornada,
    t1.id_tanque,
    t1.id_producto,
    t1.volumen_observado,
    t1.volumen_corregido,
    t1.estado
   FROM sgo.v_liquidacion_despacho_p1 t1
     JOIN sgo.estacion t2 ON t1.id_estacion = t2.id_estacion;

ALTER TABLE sgo.v_liquidacion_despacho_p2
    OWNER TO sgo_user;

CREATE OR REPLACE VIEW sgo.v_liquidacion_despacho_p3 AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_estacion,
    t1.id_jornada,
    t1.id_tanque,
    t1.id_producto,
    COALESCE(t1.volumen_observado, 0::numeric) AS volumen_observado,
    COALESCE(t1.volumen_corregido, 0::numeric) AS volumen_corregido,
    t1.estado,
    t2.tipo_volumen
   FROM sgo.v_liquidacion_despacho_p2 t1
     JOIN sgo.tolerancia t2 ON t1.id_estacion = t2.id_estacion AND t1.id_producto = t2.id_producto;

ALTER TABLE sgo.v_liquidacion_despacho_p3
    OWNER TO sgo_user;

CREATE OR REPLACE VIEW sgo.v_liquidacion_despacho_p4 AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_estacion,
    t1.id_jornada,
    t1.id_tanque,
    t1.id_producto,
    t1.volumen_observado,
    t1.volumen_corregido,
    t1.estado,
    t1.tipo_volumen,
    t1.volumen_observado AS volumen_despachado
   FROM sgo.v_liquidacion_despacho_p3 t1
  WHERE t1.tipo_volumen = 1
UNION ALL
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_estacion,
    t1.id_jornada,
    t1.id_tanque,
    t1.id_producto,
    t1.volumen_observado,
    t1.volumen_corregido,
    t1.estado,
    t1.tipo_volumen,
    t1.volumen_corregido AS volumen_despachado
   FROM sgo.v_liquidacion_despacho_p3 t1
  WHERE t1.tipo_volumen = 2;

ALTER TABLE sgo.v_liquidacion_despacho_p4
    OWNER TO sgo_user;
	
CREATE OR REPLACE VIEW sgo.v_liquidacion_inventario_a_resumen3 AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_producto,
    sum(t1.volumen_despachado) AS volumen_despacho
   FROM sgo.v_liquidacion_despacho_p4 t1
  GROUP BY t1.id_operacion, t1.fecha_operativa, t1.id_producto;

ALTER TABLE sgo.v_liquidacion_inventario_a_resumen3
    OWNER TO sgo_user;

CREATE OR REPLACE VIEW sgo.v_liquidacion_inventario_a_resumen AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_producto,
    t1.porcentaje_actual,
    t1.stock_final_fisico,
    t1.stock_inicial_fisico,
    COALESCE(t2.volumen_descargado, 0::numeric) AS volumen_descargado,
    COALESCE(t3.volumen_despacho, 0::numeric) AS volumen_despacho
   FROM sgo.v_liquidacion_inventario_a_resumen1 t1
     LEFT JOIN sgo.v_liquidacion_inventario_a_resumen2 t2 ON t1.id_operacion = t2.id_operacion AND t1.fecha_operativa = t2.fecha_operativa AND t1.id_producto = t2.id_producto
     LEFT JOIN sgo.v_liquidacion_inventario_a_resumen3 t3 ON t1.id_operacion = t3.id_operacion AND t1.fecha_operativa = t3.fecha_operativa AND t1.id_producto = t3.id_producto;

ALTER TABLE sgo.v_liquidacion_inventario_a_resumen
    OWNER TO sgo_user;

CREATE OR REPLACE VIEW sgo.v_liquidacion_inventario_a_resumen_completo AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_producto,
    t1.porcentaje_actual,
    t1.stock_final_fisico AS stock_final,
    t1.stock_inicial_fisico AS stock_inicial,
    t1.volumen_descargado,
    t1.volumen_despacho,
    round(t1.stock_final_fisico * (t1.porcentaje_actual / 100::numeric), 0) AS tolerancia,
    t1.stock_inicial_fisico + t1.volumen_descargado - t1.volumen_despacho AS stock_final_calculado,
    t1.stock_final_fisico - (t1.stock_inicial_fisico + t1.volumen_descargado - t1.volumen_despacho) AS variacion,
    @ (t1.stock_final_fisico - (t1.stock_inicial_fisico + t1.volumen_descargado - t1.volumen_despacho)) AS variacion_absoluta,
    t2.nombre AS nombre_producto,
    t3.nombre AS nombre_operacion,
    t3.nombre_corto_cliente AS nombre_cliente
   FROM sgo.v_liquidacion_inventario_a_resumen t1
     JOIN sgo.producto t2 ON t1.id_producto = t2.id_producto
     JOIN sgo.v_operacion t3 ON t1.id_operacion = t3.id_operacion;

ALTER TABLE sgo.v_liquidacion_inventario_a_resumen_completo
    OWNER TO sgo_user;

CREATE OR REPLACE VIEW sgo.v_liquidacion_inventario_a_resumen_completo_total AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_producto,
    t1.porcentaje_actual,
    t1.stock_final,
    t1.stock_inicial,
    t1.volumen_descargado,
    t1.volumen_despacho,
    t1.tolerancia,
    t1.stock_final_calculado,
    t1.variacion,
    t1.variacion_absoluta,
    t1.nombre_producto,
    t1.nombre_operacion,
    t1.nombre_cliente,
        CASE
            WHEN t1.variacion > 0::numeric THEN (t1.variacion_absoluta - t1.tolerancia) * 0::numeric
            WHEN t1.variacion < 0::numeric THEN (t1.variacion_absoluta - t1.tolerancia) * '-1'::integer::numeric
            ELSE NULL::numeric
        END AS faltante,
    0 AS id_estacion,
    ''::character(1) AS nombre_estacion,
    0 AS id_tanque,
    ''::character(1) AS nombre_tanque
   FROM sgo.v_liquidacion_inventario_a_resumen_completo t1;

ALTER TABLE sgo.v_liquidacion_inventario_a_resumen_completo_total
    OWNER TO sgo_user;
	
CREATE OR REPLACE VIEW sgo.v_liquidacion_inventario_x_estacion3 AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_producto,
    t1.id_estacion,
    sum(t1.volumen_despachado) AS volumen_despacho
   FROM sgo.v_liquidacion_despacho_p4 t1
  GROUP BY t1.id_operacion, t1.fecha_operativa, t1.id_producto, t1.id_estacion
  ORDER BY t1.fecha_operativa;

ALTER TABLE sgo.v_liquidacion_inventario_x_estacion3
    OWNER TO sgo_user;
	
CREATE OR REPLACE VIEW sgo.v_liquidacion_inventario_x_estacion AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_producto,
    t1.porcentaje_actual,
    t1.id_estacion,
    t1.stock_final_fisico,
    t1.stock_inicial_fisico,
    COALESCE(t2.volumen_descargado, 0::numeric) AS volumen_descargado,
    COALESCE(t3.volumen_despacho, 0::numeric) AS volumen_despacho
   FROM sgo.v_liquidacion_inventario_x_estacion1 t1
     LEFT JOIN sgo.v_liquidacion_inventario_x_estacion2 t2 ON t1.id_operacion = t2.id_operacion AND t1.fecha_operativa = t2.fecha_operativa AND t1.id_producto = t2.id_producto AND t1.id_estacion = t2.id_estacion
     LEFT JOIN sgo.v_liquidacion_inventario_x_estacion3 t3 ON t1.id_operacion = t3.id_operacion AND t1.fecha_operativa = t3.fecha_operativa AND t1.id_producto = t3.id_producto AND t1.id_estacion = t3.id_estacion;

ALTER TABLE sgo.v_liquidacion_inventario_x_estacion
    OWNER TO sgo_user;
	
CREATE OR REPLACE VIEW sgo.v_liquidacion_inventario_x_estacion_completo AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_producto,
    t1.id_estacion,
    t1.porcentaje_actual,
    t1.stock_final_fisico AS stock_final,
    t1.stock_inicial_fisico AS stock_inicial,
    t1.volumen_descargado,
    t1.volumen_despacho,
    round(t1.stock_final_fisico * (t1.porcentaje_actual / 100::numeric), 0) AS tolerancia,
    t1.stock_inicial_fisico + t1.volumen_descargado - t1.volumen_despacho AS stock_final_calculado,
    t1.stock_final_fisico - (t1.stock_inicial_fisico + t1.volumen_descargado - t1.volumen_despacho) AS variacion,
    @ (t1.stock_final_fisico - (t1.stock_inicial_fisico + t1.volumen_descargado - t1.volumen_despacho)) AS variacion_absoluta,
    t2.nombre AS nombre_producto,
    t3.nombre AS nombre_operacion,
    t3.nombre_corto_cliente AS nombre_cliente,
    t4.nombre AS nombre_estacion
   FROM sgo.v_liquidacion_inventario_x_estacion t1
     JOIN sgo.producto t2 ON t1.id_producto = t2.id_producto
     JOIN sgo.v_operacion t3 ON t1.id_operacion = t3.id_operacion
     JOIN sgo.estacion t4 ON t1.id_estacion = t4.id_estacion;

ALTER TABLE sgo.v_liquidacion_inventario_x_estacion_completo
    OWNER TO sgo_user;

CREATE OR REPLACE VIEW sgo.v_liquidacion_inventario_x_estacion_completo_total AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_producto,
    t1.id_estacion,
    t1.porcentaje_actual,
    t1.stock_final,
    t1.stock_inicial,
    t1.volumen_descargado,
    t1.volumen_despacho,
    t1.tolerancia,
    t1.stock_final_calculado,
    t1.variacion,
    t1.variacion_absoluta,
    t1.nombre_producto,
    t1.nombre_operacion,
    t1.nombre_cliente,
    t1.nombre_estacion,
        CASE
            WHEN t1.variacion > 0::numeric THEN (t1.variacion_absoluta - t1.tolerancia) * 0::numeric
            WHEN t1.variacion < 0::numeric THEN (t1.variacion_absoluta - t1.tolerancia) * '-1'::integer::numeric
            ELSE NULL::numeric
        END AS faltante,
    0 AS id_tanque,
    ''::character(1) AS nombre_tanque
   FROM sgo.v_liquidacion_inventario_x_estacion_completo t1;

ALTER TABLE sgo.v_liquidacion_inventario_x_estacion_completo_total
    OWNER TO sgo_user;
	
CREATE OR REPLACE VIEW sgo.v_reporte_conciliacion_volumetrica AS
 SELECT t1.id_operacion,
    t2.fecha_operativa AS diaoperativo,
    t1.nombre_estacion AS estacion,
    t1.nombre_producto AS producto,
    t1.stock_inicial AS invinicial,
    t1.volumen_descargado AS descargas,
    t1.volumen_despacho AS despachos,
    0 AS otrosmovimientos,
    t1.stock_final_calculado AS invfinalteorico,
    t1.stock_final AS invfinalfisico,
    t1.variacion AS diferencia,
    t1.tolerancia * '-1'::integer::numeric AS tolerancia,
        CASE
            WHEN t2.estado = 1 THEN 'ABIERTO'::text
            WHEN t2.estado = 2 THEN 'REGISTRADO'::text
            WHEN t2.estado = 3 THEN 'CERRADO'::text
            WHEN t2.estado = 4 THEN 'LIQUIDADO'::text
            ELSE ''::text
        END AS estadojornada,
        CASE
            WHEN t1.faltante < 0::numeric THEN 'OBSERVADO'::text
            ELSE 'OK'::text
        END AS situacionregistro,
    t2.comentario AS observaciones,
    t1.id_operacion AS idoperacion,
    t1.nombre_operacion AS operacion
   FROM sgo.v_liquidacion_inventario_x_estacion_completo_total t1
     JOIN sgo.jornada t2 ON t1.fecha_operativa = t2.fecha_operativa AND t1.id_estacion = t2.id_estacion;

ALTER TABLE sgo.v_reporte_conciliacion_volumetrica
    OWNER TO sgo_user;

CREATE OR REPLACE VIEW sgo.v_liquidacion_inventario_x_tanque3 AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_producto,
    t1.id_estacion,
    t1.id_tanque,
    sum(t1.volumen_despachado) AS volumen_despacho
   FROM sgo.v_liquidacion_despacho_p4 t1
  GROUP BY t1.id_operacion, t1.fecha_operativa, t1.id_producto, t1.id_estacion, t1.id_tanque
  ORDER BY t1.fecha_operativa;

ALTER TABLE sgo.v_liquidacion_inventario_x_tanque3
    OWNER TO sgo_user;

CREATE OR REPLACE VIEW sgo.v_liquidacion_inventario_x_tanque AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_producto,
    t1.porcentaje_actual,
    t1.id_estacion,
    t1.id_tanque,
    t1.stock_final_fisico,
    t1.stock_inicial_fisico,
    COALESCE(t2.volumen_descargado, 0::numeric) AS volumen_descargado,
    COALESCE(t3.volumen_despacho, 0::numeric) AS volumen_despacho,
    COALESCE(t4.volumen_otros, 0::bigint) AS volumen_otros
   FROM sgo.v_liquidacion_inventario_x_tanque1 t1
     LEFT JOIN sgo.v_liquidacion_inventario_x_tanque2 t2 ON t1.id_operacion = t2.id_operacion AND t1.fecha_operativa = t2.fecha_operativa AND t1.id_producto = t2.id_producto AND t1.id_estacion = t2.id_estacion AND t1.id_tanque = t2.id_tanque
     LEFT JOIN sgo.v_liquidacion_inventario_x_tanque3 t3 ON t1.id_operacion = t3.id_operacion AND t1.fecha_operativa = t3.fecha_operativa AND t1.id_producto = t3.id_producto AND t1.id_estacion = t3.id_estacion AND t1.id_tanque = t3.id_tanque
     LEFT JOIN sgo.v_liquidacion_inventario_x_tanque4 t4 ON t1.id_operacion = t4.id_operacion AND t1.fecha_operativa = t4.fecha_operativa AND t1.id_producto = t4.id_producto AND t1.id_estacion = t4.id_estacion AND t1.id_tanque = t4.id_tanque;

ALTER TABLE sgo.v_liquidacion_inventario_x_tanque
    OWNER TO sgo_user;

CREATE OR REPLACE VIEW sgo.v_liquidacion_inventario_x_tanque_completo AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_producto,
    t1.id_estacion,
    t1.id_tanque,
    t1.porcentaje_actual,
    t1.stock_final_fisico AS stock_final,
    t1.stock_inicial_fisico AS stock_inicial,
    t1.volumen_descargado,
    t1.volumen_despacho,
    round(t1.stock_final_fisico * (t1.porcentaje_actual / 100::numeric), 0) AS tolerancia,
    t1.stock_inicial_fisico + t1.volumen_descargado - t1.volumen_despacho + t1.volumen_otros::numeric AS stock_final_calculado,
    t1.stock_final_fisico - (t1.stock_inicial_fisico + t1.volumen_descargado - t1.volumen_despacho + t1.volumen_otros::numeric) AS variacion,
    @ (t1.stock_final_fisico - (t1.stock_inicial_fisico + t1.volumen_descargado - t1.volumen_despacho + t1.volumen_otros::numeric)) AS variacion_absoluta,
    t2.nombre AS nombre_producto,
    t3.nombre AS nombre_operacion,
    t3.nombre_corto_cliente AS nombre_cliente,
    t4.nombre AS nombre_estacion,
    t5.descripcion AS nombre_tanque,
    t1.volumen_otros
   FROM sgo.v_liquidacion_inventario_x_tanque t1
     JOIN sgo.producto t2 ON t1.id_producto = t2.id_producto
     JOIN sgo.v_operacion t3 ON t1.id_operacion = t3.id_operacion
     JOIN sgo.estacion t4 ON t1.id_estacion = t4.id_estacion
     JOIN sgo.tanque t5 ON t1.id_tanque = t5.id_tanque;

ALTER TABLE sgo.v_liquidacion_inventario_x_tanque_completo
    OWNER TO sgo_user;

CREATE OR REPLACE VIEW sgo.v_liquidacion_inventario_x_tanque_total AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_producto,
    t1.id_estacion,
    t1.id_tanque,
    t1.porcentaje_actual,
    t1.stock_final,
    t1.stock_inicial,
    t1.volumen_descargado,
    t1.volumen_despacho,
    t1.tolerancia,
    t1.stock_final_calculado,
    t1.variacion,
    t1.variacion_absoluta,
    t1.nombre_producto,
    t1.nombre_operacion,
    t1.nombre_cliente,
    t1.nombre_estacion,
    t1.nombre_tanque,
        CASE
            WHEN t1.variacion > 0::numeric THEN (t1.variacion_absoluta - t1.tolerancia) * 0::numeric
            WHEN t1.variacion < 0::numeric THEN (t1.variacion_absoluta - t1.tolerancia) * '-1'::integer::numeric
            ELSE NULL::numeric
        END AS faltante,
    t1.volumen_otros
   FROM sgo.v_liquidacion_inventario_x_tanque_completo t1;

ALTER TABLE sgo.v_liquidacion_inventario_x_tanque_total
    OWNER TO sgo_user;
	
CREATE OR REPLACE VIEW sgo.v_despacho_carga AS
 SELECT t1.id_dcarga,
    t1.nombre_archivo,
    t1.fecha_carga,
    t1.comentario,
    t1.id_operario,
    t1.id_estacion,
    t2.nombre_operario,
    t2.apellido_paterno_operario,
    t2.apellido_materno_operario,
    t2.dni_operario,
    t2.id_cliente,
    t3.nombre,
    t3.tipo,
    t3.id_operacion,
    t4.id_jornada
   FROM sgo.despacho_carga t1
     JOIN sgo.operario t2 ON t1.id_operario = t2.id_operario
     JOIN sgo.estacion t3 ON t1.id_estacion = t3.id_estacion
     JOIN sgo.jornada t4 ON t1.id_jornada = t4.id_jornada;

ALTER TABLE sgo.v_despacho_carga
    OWNER TO sgo_user;


--fin actualizar campos=================================================================================================

--PERMISOS LEER PERFIL HORARIO
INSERT INTO seguridad.permiso(nombre, estado, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion)
        VALUES('LEER_PERFIL_HORARIO', 1, 1456317900163, 2, 2, 1456317900163, '127.0.0.1', '127.0.0.1');
        
INSERT INTO seguridad.permiso(nombre, estado, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion)
        VALUES('CREAR_PERFIL_HORARIO', 1, 1456317900163, 2, 2, 1456317900163, '127.0.0.1', '127.0.0.1');

INSERT INTO seguridad.permiso(nombre, estado, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion)
        VALUES('ACTUALIZAR_PERFIL_HORARIO', 1, 1456317900163, 2, 2, 1456317900163, '127.0.0.1', '127.0.0.1');
        
INSERT INTO seguridad.permiso(nombre, estado, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion)
        VALUES('RECUPERAR_PERFIL_HORARIO', 1, 1456317900163, 2, 2, 1456317900163, '127.0.0.1', '127.0.0.1');
            
INSERT INTO seguridad.permisos_rol(id_rol, id_permiso) 
        VALUES(1, (SELECT id_permiso FROM seguridad.permiso where nombre = 'LEER_PERFIL_HORARIO'));
        
INSERT INTO seguridad.permisos_rol(id_rol, id_permiso) 
        VALUES(1, (SELECT id_permiso FROM seguridad.permiso where nombre = 'CREAR_PERFIL_HORARIO'));
        
INSERT INTO seguridad.permisos_rol(id_rol, id_permiso) 
        VALUES(1, (SELECT id_permiso FROM seguridad.permiso where nombre = 'ACTUALIZAR_PERFIL_HORARIO'));
        
INSERT INTO seguridad.permisos_rol(id_rol, id_permiso) 
        VALUES(1, (SELECT id_permiso FROM seguridad.permiso where nombre = 'RECUPERAR_PERFIL_HORARIO'));
                
INSERT INTO sgo.enlace(url_completa, padre, orden, url_relativa, tipo, id_permiso, titulo, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion)
        VALUES('/admin/perfilHorario', 10, 255, '/perfilHorario', 2, 
            (SELECT id_permiso FROM seguridad.permiso where nombre = 'LEER_PERFIL_HORARIO'), 'Perfil Horario', 1456317900163, 1, 1, 1456317900163, '127.0.0.1', '127.0.0.1');
            
INSERT INTO sgo.enlace(url_completa, padre, orden, url_relativa, tipo, id_permiso, titulo, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion)
        VALUES('/admin/perfilHorario/listar', (SELECT id_enlace FROM sgo.enlace WHERE url_completa = '/admin/perfilHorario'), 180, '/perfilHorario/listar', 3, 
            (SELECT id_permiso FROM seguridad.permiso where nombre = 'LEER_PERFIL_HORARIO'), 'Listar perfil horario', 1456317900163, 1, 1, 1456317900163, '127.0.0.1', '127.0.0.1');
            
INSERT INTO sgo.enlace(url_completa, padre, orden, url_relativa, tipo, id_permiso, titulo, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion)
        VALUES('/admin/perfilHorario/crear', (SELECT id_enlace FROM sgo.enlace WHERE url_completa = '/admin/perfilHorario'), 181, '/perfilHorario/crear', 3, 
            (SELECT id_permiso FROM seguridad.permiso where nombre = 'CREAR_PERFIL_HORARIO'), 'Crear perfil horario', 1456317900163, 1, 1, 1456317900163, '127.0.0.1', '127.0.0.1');
            
INSERT INTO sgo.enlace(url_completa, padre, orden, url_relativa, tipo, id_permiso, titulo, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion)
        VALUES('/admin/perfilHorario/actualizar', (SELECT id_enlace FROM sgo.enlace WHERE url_completa = '/admin/perfilHorario'), 182, '/perfilHorario/actualizar', 3, 
            (SELECT id_permiso FROM seguridad.permiso where nombre = 'ACTUALIZAR_PERFIL_HORARIO'), 'Actualizar perfil horario', 1456317900163, 1, 1, 1456317900163, '127.0.0.1', '127.0.0.1');
    
INSERT INTO sgo.enlace(url_completa, padre, orden, url_relativa, tipo, id_permiso, titulo, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion)
        VALUES('/admin/perfilHorario/actualizarEstado', (SELECT id_enlace FROM sgo.enlace WHERE url_completa = '/admin/perfilHorario'), 183, '/perfilHorario/actualizarEstado', 3, 
            (SELECT id_permiso FROM seguridad.permiso where nombre = 'ACTUALIZAR_PERFIL_HORARIO'), 'Actualizar perfil horario', 1456317900163, 1, 1, 1456317900163, '127.0.0.1', '127.0.0.1');
            
INSERT INTO sgo.enlace(url_completa, padre, orden, url_relativa, tipo, id_permiso, titulo, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion)
        VALUES('/admin/perfilHorario/recuperar', (SELECT id_enlace FROM sgo.enlace WHERE url_completa = '/admin/perfilHorario'), 184, '/perfilHorario/recuperar', 3, 
            (SELECT id_permiso FROM seguridad.permiso where nombre = 'RECUPERAR_PERFIL_HORARIO'), 'Recuperar perfil horario', 1456317900163, 1, 1, 1456317900163, '127.0.0.1', '127.0.0.1');
            

-- ******************************** UNIFICACION DE SQL *********************************************

CREATE OR REPLACE VIEW sgo.v_estacion AS
 SELECT t1.id_estacion,
    t1.metodo_descarga,
    t1.nombre,
    t1.tipo,
    t1.estado,
    t1.id_operacion,
    t4.nombre AS nombre_operacion,
    t1.creado_el,
    t1.creado_por,
    t1.actualizado_por,
    t1.actualizado_el,
    t1.ip_creacion,
    t1.ip_actualizacion,
    u1.identidad AS usuario_creacion,
    u2.identidad AS usuario_actualizacion,
    t5.id_planta,
    t5.descripcion AS planta_despacho,
    t1.cantidad_turnos,
    t1.tipo_apertura_tanque,
    t1.numero_decimales_contometro,
    t6.nombre_perfil,
    t6.id_perfil_horario
   FROM sgo.estacion t1
     JOIN seguridad.usuario u1 ON t1.creado_por = u1.id_usuario
     JOIN seguridad.usuario u2 ON t1.actualizado_por = u2.id_usuario
     JOIN sgo.operacion t4 ON t1.id_operacion = t4.id_operacion
     LEFT JOIN sgo.planta t5 ON t4.planta_despacho_defecto = t5.id_planta
     LEFT JOIN sgo.perfil_horario t6 ON t6.id_perfil_horario = t1.id_perfil_horario
     ;

ALTER TABLE sgo.v_estacion
    OWNER TO sgo_user;


-- *****************************************************************************

CREATE OR REPLACE VIEW sgo.v_jornada AS
 SELECT 
    t1.id_jornada,
    t1.fecha_operativa,
    t1.id_estacion,
    t1.comentario,
    t1.estado,
    t2.nombre,
    t2.tipo,
    t2.estado AS estado_estacion,
    t2.id_operacion,
    t1.creado_el,
    t1.creado_por,
    t1.actualizado_por,
    t1.actualizado_el,
    t1.ip_creacion,
    t1.ip_actualizacion,
    u1.identidad AS usuario_creacion,
    u2.identidad AS usuario_actualizacion,
    t1.operario1,
    t1.operario2,
    count(t3.id_despacho) AS total_despachos,
    t1.observacion,
    t4.nombre_perfil,
    t4.id_perfil_horario,
	t2.tipo_apertura_tanque,
	t2.numero_decimales_contometro		--> Agregado por HT 19/02/2019 09:56am
   FROM sgo.jornada t1
     JOIN sgo.estacion t2 ON t1.id_estacion = t2.id_estacion
     JOIN seguridad.usuario u1 ON t1.creado_por = u1.id_usuario
     JOIN seguridad.usuario u2 ON t1.actualizado_por = u2.id_usuario
     LEFT JOIN sgo.v_despacho t3 ON t1.id_jornada = t3.id_jornada
     LEFT JOIN sgo.perfil_horario t4 ON t4.id_perfil_horario = t2.id_perfil_horario
  GROUP BY 
    t1.id_jornada, t1.fecha_operativa, t1.id_estacion, t1.comentario, 
    t1.estado, t2.nombre, t2.tipo, t2.estado, t2.id_operacion, 
    t1.creado_el, t1.creado_por, t1.actualizado_por, t1.actualizado_el, 
    t1.ip_creacion, t1.ip_actualizacion, u1.identidad, u2.identidad, 
    t1.operario1, t1.operario2, t1.observacion,
    t4.nombre_perfil, t4.id_perfil_horario, t2.tipo_apertura_tanque
	,t2.numero_decimales_contometro		--> Agregado por HT 19/02/2019 09:56am
    ;

ALTER TABLE sgo.v_jornada
    OWNER TO sgo_user;

-- *****************************************************************************

CREATE OR REPLACE VIEW sgo.v_turno AS
 SELECT t1.id_turno,
    t1.fecha_hora_apertura,
    t2.id_estacion,
    t3.nombre AS estacion,
    t3.id_operacion,
    t2.fecha_operativa,
    t1.id_jornada,
    t4.nombre_operario,
    t4.apellido_paterno_operario,
    t4.apellido_materno_operario,
    t5.nombre_operario AS ayudante,
    t5.apellido_paterno_operario AS ayudante_paterno,
    t5.apellido_materno_operario AS ayudante_materno,
    t1.estado,
    t1.comentario,
    t1.fecha_hora_cierre,
    t1.creado_el,
    t1.creado_por,
    t1.actualizado_por,
    t1.actualizado_el,
    t1.ip_creacion,
    t1.ip_actualizacion,
    u1.identidad AS usuario_creacion,
    u2.identidad AS usuario_actualizacion,
    t1.observacion,
    t3.cantidad_turnos,
    t1.id_perfil_detalle_horario,
    t3.id_perfil_horario,
    t6.nombre_perfil
   FROM sgo.turno t1
     JOIN sgo.jornada t2 ON t2.id_jornada = t1.id_jornada
     JOIN sgo.estacion t3 ON t3.id_estacion = t2.id_estacion
     LEFT JOIN sgo.operario t4 ON t4.id_operario = t1.responsable
     LEFT JOIN sgo.operario t5 ON t5.id_operario = t1.ayudante
     LEFT JOIN seguridad.usuario u1 ON t1.creado_por = u1.id_usuario
     LEFT JOIN seguridad.usuario u2 ON t1.actualizado_por = u2.id_usuario
     LEFT JOIN sgo.perfil_horario t6 ON t6.id_perfil_horario = t3.id_perfil_horario
     ;

ALTER TABLE sgo.v_turno
    OWNER TO sgo_user;

-- *****************************************************************************

CREATE OR REPLACE VIEW sgo.v_operacion AS
 SELECT t1.id_operacion,
    t1.nombre,
    t1.alias,
    t1.id_cliente,
    t1.referencia_planta_recepcion,
    t1.referencia_destinatario_mercaderia,
    t1.volumen_promedio_cisterna,
    t1.fecha_inicio_planificacion,
    t1.eta_origen,
    t1.planta_despacho_defecto,
    t1.estado,
    t1.creado_el,
    t1.creado_por,
    t1.actualizado_por,
    t1.actualizado_el,
    t1.ip_creacion,
    t1.ip_actualizacion,
    t4.razon_social AS razon_social_cliente,
    t4.nombre_corto AS nombre_corto_cliente,
    u1.identidad AS usuario_creacion,
    u2.identidad AS usuario_actualizacion,
    t5.descripcion AS descripcion_planta_despacho,
    t1.correopara,
    t1.correocc,
    t1.indicador_tipo_registro_tanque,
    t4.estado AS estado_cliente
   FROM sgo.operacion t1
     JOIN seguridad.usuario u1 ON t1.creado_por = u1.id_usuario
     JOIN seguridad.usuario u2 ON t1.actualizado_por = u2.id_usuario
     JOIN sgo.cliente t4 ON t1.id_cliente = t4.id_cliente
     LEFT JOIN sgo.planta t5 ON t1.planta_despacho_defecto = t5.id_planta;

ALTER TABLE sgo.v_operacion
    OWNER TO sgo_user;

-- *****************************************************************************

CREATE OR REPLACE VIEW sgo.v_perfil_horario AS
 SELECT t1.id_perfil_horario,
        t1.nombre_perfil,
        t1.numero_turnos,
        t1.estado,
        t1.creado_el,
        t1.creado_por,
        t1.actualizado_por,
        t1.actualizado_el,
        t1.ip_creacion,
        t1.ip_actualizacion,
        u1.identidad AS usuario_creacion,
        u2.identidad AS usuario_actualizacion,
    (select count(*) :: integer from sgo.estacion where id_perfil_horario = t1.id_perfil_horario) estaciones_asociadas 
   FROM sgo.perfil_horario t1
   JOIN seguridad.usuario u1 ON t1.creado_por = u1.id_usuario
   JOIN seguridad.usuario u2 ON t1.actualizado_por = u2.id_usuario;

ALTER TABLE sgo.v_perfil_horario
    OWNER TO sgo_user;
    
-- *****************************************************************************

CREATE OR REPLACE VIEW sgo.v_perfil_detalle_horario AS
 SELECT t1.id_perfil_detalle_horario,
        t1.numero_orden,
        t1.glosa_turno,
        t1.hora_inicio_turno,
        t1.hora_fin_turno,
        t1.id_perfil_horario,
        t1.creado_el,
        t1.creado_por,
        t1.actualizado_por,
        t1.actualizado_el,
        t1.ip_creacion,
        t1.ip_actualizacion,
        u1.identidad AS usuario_creacion,
        u2.identidad AS usuario_actualizacion
   FROM sgo.perfil_detalle_horario t1
        JOIN seguridad.usuario u1 ON t1.creado_por = u1.id_usuario
        JOIN seguridad.usuario u2 ON t1.actualizado_por = u2.id_usuario;

ALTER TABLE sgo.v_perfil_detalle_horario
    OWNER TO sgo_user;

-- ******************* TURNOS JORNADA 2019-02-04 10:10 ******************************
INSERT INTO seguridad.permiso(nombre, estado, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion)
        VALUES('URL_TURNOS_JORNADA', 1, 1456317900163, 2, 2, 1456317900163, '127.0.0.1', '127.0.0.1');

INSERT INTO seguridad.permisos_rol(id_rol, id_permiso) 
        VALUES(1, (SELECT id_permiso FROM seguridad.permiso where nombre = 'URL_TURNOS_JORNADA'));

INSERT INTO sgo.enlace(url_completa, padre, orden, url_relativa, tipo, id_permiso, titulo, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion)
        VALUES('/admin/perfilHorario/turnosJornada', 10, 255, '/perfilHorario', 0, 
            (SELECT id_permiso FROM seguridad.permiso where nombre = 'URL_TURNOS_JORNADA'), 'Turnos por Jornada', 1456317900163, 1, 1, 1456317900163, '127.0.0.1', '127.0.0.1');


-- ******************* TURNOS JORNADA 2019-02-05 10:10 ******************************
INSERT INTO seguridad.permiso(nombre, estado, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion)
        VALUES('URL_RECUPERAR_CIERRE', 1, 1456317900163, 2, 2, 1456317900163, '127.0.0.1', '127.0.0.1');

INSERT INTO seguridad.permisos_rol(id_rol, id_permiso) 
        VALUES(1, (SELECT id_permiso FROM seguridad.permiso where nombre = 'URL_RECUPERAR_CIERRE'));

INSERT INTO sgo.enlace(url_completa, padre, orden, url_relativa, tipo, id_permiso, titulo, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion)
        VALUES('/admin/turno/recuperarCierre', 10, 255, '/turno', 0, 
            (SELECT id_permiso FROM seguridad.permiso where nombre = 'URL_RECUPERAR_CIERRE'), 'Recuperar cierre', 1456317900163, 1, 1, 1456317900163, '127.0.0.1', '127.0.0.1');


-- ******************* PROGRAMA 2019-02-12 12:01 ******************************
INSERT INTO sgo.parametro 
(valor, alias, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion)
VALUES 
(15, 'CONTOMETRO_REGISTROS', 1549984064053, 2, 2, 1549984064053, '127.0.0.1', '127.0.0.1');


-- ******************* TURNOS JORNADA 2019-02-13 11:50 ******************************
INSERT INTO seguridad.permiso(nombre, estado, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion)
        VALUES('URL_GENERAR_PLANTILLA_CONTOMETROS', 1, 1456317900163, 2, 2, 1456317900163, '127.0.0.1', '127.0.0.1');

INSERT INTO seguridad.permisos_rol(id_rol, id_permiso) 
        VALUES(1, (SELECT id_permiso FROM seguridad.permiso where nombre = 'URL_GENERAR_PLANTILLA_CONTOMETROS'));

INSERT INTO sgo.enlace(url_completa, padre, orden, url_relativa, tipo, id_permiso, titulo, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion)
        VALUES('/admin/turno/generarPlantillaContometros', 10, 255, '/turno', 0, 
            (SELECT id_permiso FROM seguridad.permiso where nombre = 'URL_GENERAR_PLANTILLA_CONTOMETROS'), 'Generar Plantilla Contometros', 1456317900163, 1, 1, 1456317900163, '127.0.0.1', '127.0.0.1');


-- ******************* PROGRAMA 2019-02-15 15:23 ******************************
INSERT INTO sgo.parametro 
(valor, alias, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion)
VALUES 
(5, 'VALIDACION_EXCEL_ROW', 1549984064053, 2, 2, 1549984064053, '127.0.0.1', '127.0.0.1');



-- ******************* PROGRAMA 2019-02-18 17:00 ******************************
CREATE OR REPLACE VIEW sgo.v_operacion AS
 SELECT t1.id_operacion,
    t1.nombre,
    t1.alias,
    t1.id_cliente,
    t1.referencia_planta_recepcion,
    t1.referencia_destinatario_mercaderia,
    t1.volumen_promedio_cisterna,
    t1.fecha_inicio_planificacion,
    t1.eta_origen,
    t1.planta_despacho_defecto,
    t1.estado,
    t1.creado_el,
    t1.creado_por,
    t1.actualizado_por,
    t1.actualizado_el,
    t1.ip_creacion,
    t1.ip_actualizacion,
    t4.razon_social AS razon_social_cliente,
    t4.nombre_corto AS nombre_corto_cliente,
    u1.identidad AS usuario_creacion,
    u2.identidad AS usuario_actualizacion,
    t5.descripcion AS descripcion_planta_despacho,
    t1.correopara,
    t1.correocc,
    t1.indicador_tipo_registro_tanque,
    t4.estado AS estado_cliente,
    t1.tipo_volumen_descargado
   FROM sgo.operacion t1
     JOIN seguridad.usuario u1 ON t1.creado_por = u1.id_usuario
     JOIN seguridad.usuario u2 ON t1.actualizado_por = u2.id_usuario
     JOIN sgo.cliente t4 ON t1.id_cliente = t4.id_cliente
     LEFT JOIN sgo.planta t5 ON t1.planta_despacho_defecto = t5.id_planta;



-- ******************* TURNOS JORNADA 2019-02-19 1605 ******************************
INSERT INTO seguridad.permiso(nombre, estado, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion)
        VALUES('URL_RECUPERAR_PRODUCTOS_EQUIVALENTES', 1, 1456317900163, 2, 2, 1456317900163, '127.0.0.1', '127.0.0.1');

INSERT INTO seguridad.permisos_rol(id_rol, id_permiso) 
        VALUES(1, (SELECT id_permiso FROM seguridad.permiso where nombre = 'URL_RECUPERAR_PRODUCTOS_EQUIVALENTES'));

INSERT INTO sgo.enlace(url_completa, padre, orden, url_relativa, tipo, id_permiso, titulo, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion)
        VALUES('/admin/operacion/recuperarProductosEquivalentes', 10, 255, '/operacion', 0, 
            (SELECT id_permiso FROM seguridad.permiso where nombre = 'URL_RECUPERAR_PRODUCTOS_EQUIVALENTES'), 'Productos Equivalentes', 1456317900163, 1, 1, 1456317900163, '127.0.0.1', '127.0.0.1');



-- ******************* TURNOS JORNADA 2019-02-20 1100 ******************************
INSERT INTO seguridad.permiso(nombre, estado, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion)
        VALUES('URL_GUARDAR_PRODUCTOS_EQUIVALENTES', 1, 1456317900163, 2, 2, 1456317900163, '127.0.0.1', '127.0.0.1');

INSERT INTO seguridad.permisos_rol(id_rol, id_permiso) 
        VALUES(1, (SELECT id_permiso FROM seguridad.permiso where nombre = 'URL_GUARDAR_PRODUCTOS_EQUIVALENTES'));

INSERT INTO sgo.enlace(url_completa, padre, orden, url_relativa, tipo, id_permiso, titulo, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion)
        VALUES('/admin/operacion/guardarProductosEquivalentes', 10, 255, '/operacion', 0, 
            (SELECT id_permiso FROM seguridad.permiso where nombre = 'URL_GUARDAR_PRODUCTOS_EQUIVALENTES'), 'Guardar Productos Equivalentes', 1456317900163, 1, 1, 1456317900163, '127.0.0.1', '127.0.0.1');


-- ******************* TURNOS JORNADA 2019-02-21 1424 ******************************
CREATE OR REPLACE VIEW sgo.v_producto_equivalente AS
 SELECT 
    t1.id_producto_equivalencia,
    t1.id_operacion,
    t1.id_producto_principal,
    t1.id_producto_secundario,
    t1.centimetros,
    t1.creado_el,
    t1.creado_por,
    t1.ip_creacion,
    t1.estado,
    t2.nombre AS nombre_producto_principal,
    t3.nombre AS nombre_producto_secundario
   FROM sgo.producto_equivalente t1
   JOIN sgo.producto t2 ON t2.id_producto = t1.id_producto_principal
   JOIN sgo.producto t3 ON t3.id_producto = t1.id_producto_secundario
   ;

ALTER TABLE sgo.v_producto_equivalente
    OWNER TO sgo_user;



-- ******************* TURNOS JORNADA 2019-02-21 1424 ******************************
INSERT INTO seguridad.permiso(nombre, estado, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion)
        VALUES('URL_UPDATE_PRODUCTOS_EQUIVALENTES', 1, 1456317900163, 2, 2, 1456317900163, '127.0.0.1', '127.0.0.1');

INSERT INTO seguridad.permisos_rol(id_rol, id_permiso) 
        VALUES(1, (SELECT id_permiso FROM seguridad.permiso where nombre = 'URL_UPDATE_PRODUCTOS_EQUIVALENTES'));

INSERT INTO sgo.enlace
(url_completa, 
padre, 
orden, 
url_relativa, 
tipo, id_permiso, titulo, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion)
VALUES
('/admin/operacion/updateProductosEquivalentes', 
10, 
255,
'/operacion', 
0, 
(SELECT id_permiso FROM seguridad.permiso where nombre = 'URL_UPDATE_PRODUCTOS_EQUIVALENTES'), 'Update Productos Equivalentes', 1456317900163, 1, 1, 1456317900163, '127.0.0.1', '127.0.0.1');

-- ******************** SCRIPTS DE DESPACHO - 9000003068 *************************
CREATE OR REPLACE VIEW sgo.v_despacho AS
 SELECT t1.id_despacho,
    t1.id_jornada,
    t1.id_vehiculo,
    t1.kilometro_horometro,
    t1.numero_vale,
    t1.tipo_registro,
    t1.fecha_hora_inicio,
    t1.fecha_hora_fin,
    t1.clasificacion,
    t1.id_producto,
    t1.lectura_inicial,
    t1.lectura_final,
    t1.factor_correccion,
    t1.api_corregido,
    t1.temperatura,
    t1.volumen_corregido,
    t1.id_tanque,
    t1.id_contometro,
    t1.estado,
    t1.creado_el,
    t1.creado_por,
    t1.actualizado_por,
    t1.actualizado_el,
    t1.ip_creacion,
    t1.ip_actualizacion,
    u1.identidad AS usuario_creacion,
    u2.identidad AS usuario_actualizacion,
    t2.fecha_operativa,
    t2.id_estacion,
    t7.nombre AS nombre_estacion,
    t7.id_operacion,
    t8.nombre AS nombre_operacion,
    t8.id_cliente,
    t3.nombre_corto,
    t3.descripcion,
    t3.id_propietario,
    t6.razon_social,
    t6.nombre_corto AS nombre_corto_propietario,
    t4.descripcion AS descripcion_tanque,
    t5.alias AS alias_contometro,
    t5.tipo_contometro,
    t9.nombre AS nombre_producto,
    t9.abreviatura,
    t1.codigo_archivo_origen,
    t1.volumen_observado,
	t1.id_turno,	
	t7.numero_decimales_contometro,
	t1.flag_calculo_corregido
   FROM sgo.despacho t1
     JOIN seguridad.usuario u1 ON t1.creado_por = u1.id_usuario
     JOIN seguridad.usuario u2 ON t1.actualizado_por = u2.id_usuario
     JOIN sgo.jornada t2 ON t1.id_jornada = t2.id_jornada
     JOIN sgo.vehiculo t3 ON t1.id_vehiculo = t3.id_vehiculo
     JOIN sgo.tanque t4 ON t1.id_tanque = t4.id_tanque
     JOIN sgo.contometro t5 ON t1.id_contometro = t5.id_contometro
     JOIN sgo.propietario t6 ON t3.id_propietario = t6.id_propietario
     JOIN sgo.estacion t7 ON t2.id_estacion = t7.id_estacion
     JOIN sgo.operacion t8 ON t7.id_operacion = t8.id_operacion
     JOIN sgo.producto t9 ON t1.id_producto = t9.id_producto;

ALTER TABLE sgo.v_despacho
    OWNER TO sgo_user;

-- ******************** SCRIPT PERMISO PLANTILLA DESPACHO (9000003068) *************************
INSERT INTO seguridad.permiso(nombre, estado, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion)
VALUES('URL_GENERAR_PLANTILLA_DESPACHO', 1, 1550765850819, 2, 2, 1550765850819, '127.0.0.1', '127.0.0.1');

INSERT INTO seguridad.permisos_rol(id_rol, id_permiso) 
VALUES(1, (SELECT id_permiso FROM seguridad.permiso where nombre = 'URL_GENERAR_PLANTILLA_DESPACHO'));

INSERT INTO sgo.enlace(url_completa, padre, orden, url_relativa, tipo, id_permiso, titulo, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion)
VALUES('/admin/despacho/plantilla-despacho', 600, 359, '/despacho/plantilla-despacho', 3, (SELECT id_permiso FROM seguridad.permiso where nombre = 'URL_GENERAR_PLANTILLA_DESPACHO'), 'Generar Plantilla Despacho', 1550766359243, 2, 2, 1550766359243, '127.0.0.1', '127.0.0.1');



-- ******************** SCRIPT MODIFICACIONES VISTAS REPORTE CONCILIACION VOLUMETRICA (9000003068) *************************
CREATE OR REPLACE VIEW sgo.v_liquidacion_carga1 AS
 SELECT t1.id_ctanque,
    t1.id_doperativo,
    t1.id_estacion,
    t1.id_tanque,
    t1.volumen_observado_final - t1.volumen_observado_inicial AS volumen_cargado_observado,
    t1.volumen_corregido_final - t1.volumen_corregido_inicial AS volumen_cargado_corregido,
    t2.fecha_operativa,
    t2.id_operacion,
	SUM(t4.volumen_recibido_observado) AS volumen_cargado_observado_cisterna,
	SUM(t4.volumen_recibido_corregido) AS volumen_cargado_corregido_cisterna
   FROM sgo.carga_tanque t1
     JOIN sgo.dia_operativo t2 ON t1.id_doperativo = t2.id_doperativo
	 LEFT JOIN sgo.descarga_cisterna t3 ON t1.id_ctanque = t3.id_ctanque
	 LEFT JOIN sgo.descarga_compartimento t4 ON t3.id_dcisterna = t4.id_dcisterna
	GROUP BY 
		t1.id_ctanque, t1.id_doperativo, t1.id_estacion, t1.id_tanque, t1.volumen_observado_final, t1.volumen_observado_inicial, 
		t1.volumen_corregido_final, t1.volumen_corregido_inicial, t2.fecha_operativa, t2.id_operacion;

ALTER TABLE sgo.v_liquidacion_carga1
    OWNER TO sgo_user;

CREATE OR REPLACE VIEW sgo.v_liquidacion_carga2 AS
 SELECT t1.id_ctanque,
    t1.id_doperativo,
    t1.id_estacion,
    t1.id_tanque,
    t1.volumen_cargado_observado,
    t1.volumen_cargado_corregido,
    t1.fecha_operativa,
    t1.id_operacion,
    t2.id_producto,
    t2.nombre_producto,
	t1.volumen_cargado_observado_cisterna,
	t1.volumen_cargado_corregido_cisterna
   FROM sgo.v_liquidacion_carga1 t1
     JOIN sgo.v_tanque_jornada t2 ON t1.fecha_operativa = t2.fecha_operativa AND t1.id_tanque = t2.id_tanque AND t1.id_estacion = t2.id_estacion
  WHERE t2.cierre = 1;

ALTER TABLE sgo.v_liquidacion_carga2
    OWNER TO sgo_user;

CREATE OR REPLACE VIEW sgo.v_liquidacion_carga3 AS
 SELECT t1.id_ctanque,
    t1.id_doperativo,
    t1.id_estacion,
    t1.id_tanque,
    t1.volumen_cargado_observado,
    t1.volumen_cargado_corregido,
    t1.fecha_operativa,
    t1.id_operacion,
    t1.id_producto,
    t1.nombre_producto,
    t2.tipo_volumen,
        CASE
            WHEN t2.tipo_volumen = 1 THEN t1.volumen_cargado_observado
            WHEN t2.tipo_volumen = 2 THEN t1.volumen_cargado_corregido
            ELSE NULL::numeric
        END AS volumen_cargado_usar,
	CASE
		WHEN t2.tipo_volumen = 1 THEN t1.volumen_cargado_observado_cisterna
		WHEN t2.tipo_volumen = 2 THEN t1.volumen_cargado_corregido_cisterna
		ELSE NULL::numeric
	END AS volumen_cargado_usar_cisterna
   FROM sgo.v_liquidacion_carga2 t1
     JOIN sgo.tolerancia t2 ON t1.id_estacion = t2.id_estacion AND t1.id_producto = t2.id_producto;

ALTER TABLE sgo.v_liquidacion_carga3
    OWNER TO sgo_user;

CREATE OR REPLACE VIEW sgo.v_liquidacion_inventario_x_estacion2 AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_producto,
    t1.id_estacion,
    sum(t1.volumen_cargado_usar) AS volumen_descargado,
	SUM(t1.volumen_cargado_usar_cisterna) AS volumen_descargado_cisterna
   FROM sgo.v_liquidacion_carga3 t1
  GROUP BY t1.id_operacion, t1.fecha_operativa, t1.id_producto, t1.id_estacion
  ORDER BY t1.fecha_operativa;

ALTER TABLE sgo.v_liquidacion_inventario_x_estacion2
    OWNER TO sgo_user;

CREATE OR REPLACE VIEW sgo.v_liquidacion_inventario_x_estacion AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_producto,
    t1.porcentaje_actual,
    t1.id_estacion,
    t1.stock_final_fisico,
    t1.stock_inicial_fisico,
    COALESCE(t2.volumen_descargado, 0::numeric) AS volumen_descargado,
    COALESCE(t3.volumen_despacho, 0::numeric) AS volumen_despacho,
	COALESCE(t2.volumen_descargado_cisterna, 0::numeric) AS volumen_descargado_cisterna
   FROM sgo.v_liquidacion_inventario_x_estacion1 t1
     LEFT JOIN sgo.v_liquidacion_inventario_x_estacion2 t2 ON t1.id_operacion = t2.id_operacion AND t1.fecha_operativa = t2.fecha_operativa AND t1.id_producto = t2.id_producto AND t1.id_estacion = t2.id_estacion
     LEFT JOIN sgo.v_liquidacion_inventario_x_estacion3 t3 ON t1.id_operacion = t3.id_operacion AND t1.fecha_operativa = t3.fecha_operativa AND t1.id_producto = t3.id_producto AND t1.id_estacion = t3.id_estacion;

ALTER TABLE sgo.v_liquidacion_inventario_x_estacion
    OWNER TO sgo_user;

CREATE OR REPLACE VIEW sgo.v_liquidacion_inventario_x_estacion_completo AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_producto,
    t1.id_estacion,
    t1.porcentaje_actual,
    t1.stock_final_fisico AS stock_final,
    t1.stock_inicial_fisico AS stock_inicial,
    t1.volumen_descargado,
    t1.volumen_despacho,
    round(t1.stock_final_fisico * (t1.porcentaje_actual / 100::numeric), 0) AS tolerancia,
    t1.stock_inicial_fisico + t1.volumen_descargado - t1.volumen_despacho AS stock_final_calculado,
    t1.stock_final_fisico - (t1.stock_inicial_fisico + t1.volumen_descargado - t1.volumen_despacho) AS variacion,
    @ (t1.stock_final_fisico - (t1.stock_inicial_fisico + t1.volumen_descargado - t1.volumen_despacho)) AS variacion_absoluta,
    t2.nombre AS nombre_producto,
    t3.nombre AS nombre_operacion,
    t3.nombre_corto_cliente AS nombre_cliente,
    t4.nombre AS nombre_estacion,
	t1.volumen_descargado_cisterna
   FROM sgo.v_liquidacion_inventario_x_estacion t1
     JOIN sgo.producto t2 ON t1.id_producto = t2.id_producto
     JOIN sgo.v_operacion t3 ON t1.id_operacion = t3.id_operacion
     JOIN sgo.estacion t4 ON t1.id_estacion = t4.id_estacion;

ALTER TABLE sgo.v_liquidacion_inventario_x_estacion_completo
    OWNER TO sgo_user;

CREATE OR REPLACE VIEW sgo.v_liquidacion_inventario_x_estacion_completo_total AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_producto,
    t1.id_estacion,
    t1.porcentaje_actual,
    t1.stock_final,
    t1.stock_inicial,
    t1.volumen_descargado,
    t1.volumen_despacho,
    t1.tolerancia,
    t1.stock_final_calculado,
    t1.variacion,
    t1.variacion_absoluta,
    t1.nombre_producto,
    t1.nombre_operacion,
    t1.nombre_cliente,
    t1.nombre_estacion,
        CASE
            WHEN t1.variacion > 0::numeric THEN (t1.variacion_absoluta - t1.tolerancia) * 0::numeric
            WHEN t1.variacion < 0::numeric THEN (t1.variacion_absoluta - t1.tolerancia) * '-1'::integer::numeric
            ELSE NULL::numeric
        END AS faltante,
    0 AS id_tanque,
    ''::character(1) AS nombre_tanque,
	t1.volumen_descargado_cisterna
   FROM sgo.v_liquidacion_inventario_x_estacion_completo t1;

ALTER TABLE sgo.v_liquidacion_inventario_x_estacion_completo_total
    OWNER TO sgo_user;

CREATE OR REPLACE VIEW sgo.v_reporte_conciliacion_volumetrica AS
 SELECT t1.id_operacion,
    t2.fecha_operativa AS diaoperativo,
    t1.nombre_estacion AS estacion,
    t1.nombre_producto AS producto,
    t1.stock_inicial AS invinicial,
    CASE 
		WHEN t3.tipo_volumen_descargado = 1 THEN t1.volumen_descargado_cisterna
		WHEN t3.tipo_volumen_descargado = 2 THEN t1.volumen_descargado 
		ELSE 0
	END AS descargas,
    ROUND(t1.volumen_despacho, 2) AS despachos,
    0 AS otrosmovimientos,
    t1.stock_final_calculado AS invfinalteorico,
    t1.stock_final AS invfinalfisico,
    t1.variacion AS diferencia,
    t1.tolerancia * '-1'::integer::numeric AS tolerancia,
        CASE
            WHEN t2.estado = 1 THEN 'ABIERTO'::text
            WHEN t2.estado = 2 THEN 'REGISTRADO'::text
            WHEN t2.estado = 3 THEN 'CERRADO'::text
            WHEN t2.estado = 4 THEN 'LIQUIDADO'::text
            ELSE ''::text
        END AS estadojornada,
        CASE
            WHEN t1.faltante < 0::numeric THEN 'OBSERVADO'::text
            ELSE 'OK'::text
        END AS situacionregistro,
    t2.comentario AS observaciones,
    t1.id_operacion AS idoperacion,
    t1.nombre_operacion AS operacion
   FROM sgo.v_liquidacion_inventario_x_estacion_completo_total t1
     JOIN sgo.jornada t2 ON t1.fecha_operativa = t2.fecha_operativa AND t1.id_estacion = t2.id_estacion
	 JOIN sgo.operacion t3 ON t1.id_operacion = t3.id_operacion;

ALTER TABLE sgo.v_reporte_conciliacion_volumetrica
    OWNER TO sgo_user;







-- ******************* SCRIPT 2019-02-25 1621 ******************************
DROP VIEW IF EXISTS sgo.v_reporte_conciliacion_volumetrica;
DROP VIEW IF EXISTS sgo.v_liquidacion_inventario_x_estacion_completo_total;
DROP VIEW IF EXISTS sgo.v_liquidacion_inventario_x_estacion_completo;
DROP VIEW IF EXISTS sgo.v_liquidacion_inventario_x_estacion;
DROP VIEW IF EXISTS sgo.v_liquidacion_inventario_x_estacion2;
DROP VIEW IF EXISTS sgo.v_liquidacion_inventario_a_resumen_completo_total;
DROP VIEW IF EXISTS sgo.v_liquidacion_inventario_a_resumen_completo;
DROP VIEW IF EXISTS sgo.v_liquidacion_inventario_a_resumen;
DROP VIEW IF EXISTS sgo.v_liquidacion_inventario_a_resumen2;
DROP VIEW IF EXISTS sgo.v_liquidacion_inventario_x_tanque_total;
DROP VIEW IF EXISTS sgo.v_liquidacion_inventario_x_tanque_completo;
DROP VIEW IF EXISTS sgo.v_liquidacion_inventario_x_tanque;
DROP VIEW IF EXISTS sgo.v_liquidacion_inventario_x_tanque2;
DROP VIEW IF EXISTS sgo.v_liquidacion_carga3;
DROP VIEW IF EXISTS sgo.v_liquidacion_carga2;
DROP VIEW IF EXISTS public.v_liquidacion_carga2;
DROP VIEW IF EXISTS sgo.v_liquidacion_carga1;

-- ************************************************************************************
CREATE OR REPLACE VIEW sgo.v_liquidacion_carga1 AS
 SELECT t1.id_ctanque,
    t1.id_doperativo,
    t1.id_estacion,
    t1.id_tanque,
    -- t1.volumen_observado_final - t1.volumen_observado_inicial AS volumen_cargado_observado,
    -- t1.volumen_corregido_final - t1.volumen_corregido_inicial AS volumen_cargado_corregido,
    t2.fecha_operativa,
    t2.id_operacion,
    SUM(t4.volumen_recibido_observado) AS volumen_cargado_observado_cisterna,
    SUM(t4.volumen_recibido_corregido) AS volumen_cargado_corregido_cisterna,

    CASE
        WHEN t5.tipo_volumen_descargado = 1 THEN t1.volumen_observado_final - t1.volumen_observado_inicial
        WHEN t5.tipo_volumen_descargado = 2 THEN (
            SELECT 
            SUM(dcomp.volumen_recibido_observado)
            FROM sgo.descarga_cisterna dcist
            LEFT JOIN sgo.descarga_compartimento dcomp ON dcomp.id_dcisterna = dcist.id_dcisterna
            WHERE dcist.id_ctanque = t1.id_ctanque
        )
        ELSE NULL::numeric
    END AS volumen_cargado_observado,

    CASE
        WHEN t5.tipo_volumen_descargado = 1 THEN t1.volumen_corregido_final - t1.volumen_corregido_inicial
        WHEN t5.tipo_volumen_descargado = 2 THEN (
            SELECT 
            SUM(dcomp.volumen_recibido_corregido)
            FROM sgo.descarga_cisterna dcist
            LEFT JOIN sgo.descarga_compartimento dcomp ON dcomp.id_dcisterna = dcist.id_dcisterna
            WHERE dcist.id_ctanque = t1.id_ctanque
        )
        ELSE NULL::numeric
    END AS volumen_cargado_corregido

   FROM sgo.carga_tanque t1
     JOIN sgo.dia_operativo t2 ON t1.id_doperativo = t2.id_doperativo
     LEFT JOIN sgo.descarga_cisterna t3 ON t1.id_ctanque = t3.id_ctanque
     LEFT JOIN sgo.descarga_compartimento t4 ON t3.id_dcisterna = t4.id_dcisterna
     LEFT JOIN sgo.v_operacion t5 ON t5.id_operacion = t1.id_doperativo
    GROUP BY 
        t1.id_ctanque, t1.id_doperativo, t1.id_estacion, t1.id_tanque, t1.volumen_observado_final, t1.volumen_observado_inicial, 
        t1.volumen_corregido_final, t1.volumen_corregido_inicial, t2.fecha_operativa, t2.id_operacion,
        t5.tipo_volumen_descargado
        ;

ALTER TABLE sgo.v_liquidacion_carga1
    OWNER TO sgo_user;
-- ************************************************************************************
CREATE OR REPLACE VIEW public.v_liquidacion_carga2 AS
 SELECT t1.id_ctanque,
    t1.id_doperativo,
    t1.id_estacion,
    t1.id_tanque,
    t1.volumen_cargado_observado,
    t1.volumen_cargado_corregido,
    t1.fecha_operativa,
    t1.id_operacion,
    t2.id_producto,
    t2.nombre_producto
   FROM sgo.v_liquidacion_carga1 t1
     JOIN sgo.v_tanque_jornada t2 ON t1.fecha_operativa = t2.fecha_operativa AND t1.id_tanque = t2.id_tanque AND t1.id_estacion = t2.id_estacion;

ALTER TABLE public.v_liquidacion_carga2
    OWNER TO sgo_user;
-- ************************************************************************************
CREATE OR REPLACE VIEW sgo.v_liquidacion_carga2 AS
 SELECT t1.id_ctanque,
    t1.id_doperativo,
    t1.id_estacion,
    t1.id_tanque,
    t1.volumen_cargado_observado,
    t1.volumen_cargado_corregido,
    t1.fecha_operativa,
    t1.id_operacion,
    t2.id_producto,
    t2.nombre_producto,
    t1.volumen_cargado_observado_cisterna,
    t1.volumen_cargado_corregido_cisterna
   FROM sgo.v_liquidacion_carga1 t1
     JOIN sgo.v_tanque_jornada t2 ON t1.fecha_operativa = t2.fecha_operativa AND t1.id_tanque = t2.id_tanque AND t1.id_estacion = t2.id_estacion
  WHERE t2.cierre = 1;

ALTER TABLE sgo.v_liquidacion_carga2
    OWNER TO sgo_user;
-- ************************************************************************************
CREATE OR REPLACE VIEW sgo.v_liquidacion_carga3 AS
 SELECT t1.id_ctanque,
    t1.id_doperativo,
    t1.id_estacion,
    t1.id_tanque,
    t1.volumen_cargado_observado,
    t1.volumen_cargado_corregido,
    t1.fecha_operativa,
    t1.id_operacion,
    t1.id_producto,
    t1.nombre_producto,
    t2.tipo_volumen,
        CASE
            WHEN t2.tipo_volumen = 1 THEN t1.volumen_cargado_observado
            WHEN t2.tipo_volumen = 2 THEN t1.volumen_cargado_corregido
            ELSE NULL::numeric
        END AS volumen_cargado_usar,
    CASE
        WHEN t2.tipo_volumen = 1 THEN t1.volumen_cargado_observado_cisterna
        WHEN t2.tipo_volumen = 2 THEN t1.volumen_cargado_corregido_cisterna
        ELSE NULL::numeric
    END AS volumen_cargado_usar_cisterna
   FROM sgo.v_liquidacion_carga2 t1
     JOIN sgo.tolerancia t2 ON t1.id_estacion = t2.id_estacion AND t1.id_producto = t2.id_producto;

ALTER TABLE sgo.v_liquidacion_carga3
    OWNER TO sgo_user;
-- ************************************************************************************
CREATE OR REPLACE VIEW sgo.v_liquidacion_inventario_x_tanque2 AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_producto,
    t1.id_estacion,
    t1.id_tanque,
    sum(t1.volumen_cargado_usar) AS volumen_descargado
   FROM sgo.v_liquidacion_carga3 t1
  GROUP BY t1.id_operacion, t1.fecha_operativa, t1.id_producto, t1.id_estacion, t1.id_tanque
  ORDER BY t1.fecha_operativa;

ALTER TABLE sgo.v_liquidacion_inventario_x_tanque2
    OWNER TO sgo_user;
-- ************************************************************************************
CREATE OR REPLACE VIEW sgo.v_liquidacion_inventario_x_tanque AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_producto,
    t1.porcentaje_actual,
    t1.id_estacion,
    t1.id_tanque,
    t1.stock_final_fisico,
    t1.stock_inicial_fisico,
    COALESCE(t2.volumen_descargado, 0::numeric) AS volumen_descargado,
    COALESCE(t3.volumen_despacho, 0::numeric) AS volumen_despacho,
    COALESCE(t4.volumen_otros, 0::bigint) AS volumen_otros
   FROM sgo.v_liquidacion_inventario_x_tanque1 t1
     LEFT JOIN sgo.v_liquidacion_inventario_x_tanque2 t2 ON t1.id_operacion = t2.id_operacion AND t1.fecha_operativa = t2.fecha_operativa AND t1.id_producto = t2.id_producto AND t1.id_estacion = t2.id_estacion AND t1.id_tanque = t2.id_tanque
     LEFT JOIN sgo.v_liquidacion_inventario_x_tanque3 t3 ON t1.id_operacion = t3.id_operacion AND t1.fecha_operativa = t3.fecha_operativa AND t1.id_producto = t3.id_producto AND t1.id_estacion = t3.id_estacion AND t1.id_tanque = t3.id_tanque
     LEFT JOIN sgo.v_liquidacion_inventario_x_tanque4 t4 ON t1.id_operacion = t4.id_operacion AND t1.fecha_operativa = t4.fecha_operativa AND t1.id_producto = t4.id_producto AND t1.id_estacion = t4.id_estacion AND t1.id_tanque = t4.id_tanque;

ALTER TABLE sgo.v_liquidacion_inventario_x_tanque
    OWNER TO sgo_user;
-- ************************************************************************************
CREATE OR REPLACE VIEW sgo.v_liquidacion_inventario_x_tanque_completo AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_producto,
    t1.id_estacion,
    t1.id_tanque,
    t1.porcentaje_actual,
    t1.stock_final_fisico AS stock_final,
    t1.stock_inicial_fisico AS stock_inicial,
    t1.volumen_descargado,
    t1.volumen_despacho,
    round(t1.stock_final_fisico * (t1.porcentaje_actual / 100::numeric), 0) AS tolerancia,
    t1.stock_inicial_fisico + t1.volumen_descargado - t1.volumen_despacho + t1.volumen_otros::numeric AS stock_final_calculado,
    t1.stock_final_fisico - (t1.stock_inicial_fisico + t1.volumen_descargado - t1.volumen_despacho + t1.volumen_otros::numeric) AS variacion,
    @ (t1.stock_final_fisico - (t1.stock_inicial_fisico + t1.volumen_descargado - t1.volumen_despacho + t1.volumen_otros::numeric)) AS variacion_absoluta,
    t2.nombre AS nombre_producto,
    t3.nombre AS nombre_operacion,
    t3.nombre_corto_cliente AS nombre_cliente,
    t4.nombre AS nombre_estacion,
    t5.descripcion AS nombre_tanque,
    t1.volumen_otros
   FROM sgo.v_liquidacion_inventario_x_tanque t1
     JOIN sgo.producto t2 ON t1.id_producto = t2.id_producto
     JOIN sgo.v_operacion t3 ON t1.id_operacion = t3.id_operacion
     JOIN sgo.estacion t4 ON t1.id_estacion = t4.id_estacion
     JOIN sgo.tanque t5 ON t1.id_tanque = t5.id_tanque;

ALTER TABLE sgo.v_liquidacion_inventario_x_tanque_completo
    OWNER TO sgo_user;
-- ************************************************************************************
CREATE OR REPLACE VIEW sgo.v_liquidacion_inventario_x_tanque_total AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_producto,
    t1.id_estacion,
    t1.id_tanque,
    t1.porcentaje_actual,
    t1.stock_final,
    t1.stock_inicial,
    t1.volumen_descargado,
    t1.volumen_despacho,
    t1.tolerancia,
    t1.stock_final_calculado,
    t1.variacion,
    t1.variacion_absoluta,
    t1.nombre_producto,
    t1.nombre_operacion,
    t1.nombre_cliente,
    t1.nombre_estacion,
    t1.nombre_tanque,
        CASE
            WHEN t1.variacion > 0::numeric THEN (t1.variacion_absoluta - t1.tolerancia) * 0::numeric
            WHEN t1.variacion < 0::numeric THEN (t1.variacion_absoluta - t1.tolerancia) * '-1'::integer::numeric
            ELSE NULL::numeric
        END AS faltante,
    t1.volumen_otros
   FROM sgo.v_liquidacion_inventario_x_tanque_completo t1;

ALTER TABLE sgo.v_liquidacion_inventario_x_tanque_total
    OWNER TO sgo_user;
-- ************************************************************************************
CREATE OR REPLACE VIEW sgo.v_liquidacion_inventario_a_resumen2 AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_producto,
    sum(t1.volumen_cargado_usar) AS volumen_descargado
   FROM sgo.v_liquidacion_carga3 t1
  GROUP BY t1.id_operacion, t1.fecha_operativa, t1.id_producto;

ALTER TABLE sgo.v_liquidacion_inventario_a_resumen2
    OWNER TO sgo_user;
-- ************************************************************************************
CREATE OR REPLACE VIEW sgo.v_liquidacion_inventario_a_resumen AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_producto,
    t1.porcentaje_actual,
    t1.stock_final_fisico,
    t1.stock_inicial_fisico,
    COALESCE(t2.volumen_descargado, 0::numeric) AS volumen_descargado,
    COALESCE(t3.volumen_despacho, 0::numeric) AS volumen_despacho
   FROM sgo.v_liquidacion_inventario_a_resumen1 t1
     LEFT JOIN sgo.v_liquidacion_inventario_a_resumen2 t2 ON t1.id_operacion = t2.id_operacion AND t1.fecha_operativa = t2.fecha_operativa AND t1.id_producto = t2.id_producto
     LEFT JOIN sgo.v_liquidacion_inventario_a_resumen3 t3 ON t1.id_operacion = t3.id_operacion AND t1.fecha_operativa = t3.fecha_operativa AND t1.id_producto = t3.id_producto;

ALTER TABLE sgo.v_liquidacion_inventario_a_resumen
    OWNER TO sgo_user;
-- ************************************************************************************
CREATE OR REPLACE VIEW sgo.v_liquidacion_inventario_a_resumen_completo AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_producto,
    t1.porcentaje_actual,
    t1.stock_final_fisico AS stock_final,
    t1.stock_inicial_fisico AS stock_inicial,
    t1.volumen_descargado,
    t1.volumen_despacho,
    round(t1.stock_final_fisico * (t1.porcentaje_actual / 100::numeric), 0) AS tolerancia,
    t1.stock_inicial_fisico + t1.volumen_descargado - t1.volumen_despacho AS stock_final_calculado,
    t1.stock_final_fisico - (t1.stock_inicial_fisico + t1.volumen_descargado - t1.volumen_despacho) AS variacion,
    @ (t1.stock_final_fisico - (t1.stock_inicial_fisico + t1.volumen_descargado - t1.volumen_despacho)) AS variacion_absoluta,
    t2.nombre AS nombre_producto,
    t3.nombre AS nombre_operacion,
    t3.nombre_corto_cliente AS nombre_cliente
   FROM sgo.v_liquidacion_inventario_a_resumen t1
     JOIN sgo.producto t2 ON t1.id_producto = t2.id_producto
     JOIN sgo.v_operacion t3 ON t1.id_operacion = t3.id_operacion;

ALTER TABLE sgo.v_liquidacion_inventario_a_resumen_completo
    OWNER TO sgo_user;
-- ************************************************************************************
CREATE OR REPLACE VIEW sgo.v_liquidacion_inventario_a_resumen_completo_total AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_producto,
    t1.porcentaje_actual,
    t1.stock_final,
    t1.stock_inicial,
    t1.volumen_descargado,
    t1.volumen_despacho,
    t1.tolerancia,
    t1.stock_final_calculado,
    t1.variacion,
    t1.variacion_absoluta,
    t1.nombre_producto,
    t1.nombre_operacion,
    t1.nombre_cliente,
        CASE
            WHEN t1.variacion > 0::numeric THEN (t1.variacion_absoluta - t1.tolerancia) * 0::numeric
            WHEN t1.variacion < 0::numeric THEN (t1.variacion_absoluta - t1.tolerancia) * '-1'::integer::numeric
            ELSE NULL::numeric
        END AS faltante,
    0 AS id_estacion,
    ''::character(1) AS nombre_estacion,
    0 AS id_tanque,
    ''::character(1) AS nombre_tanque
   FROM sgo.v_liquidacion_inventario_a_resumen_completo t1;

ALTER TABLE sgo.v_liquidacion_inventario_a_resumen_completo_total
    OWNER TO sgo_user;
-- ************************************************************************************
CREATE OR REPLACE VIEW sgo.v_liquidacion_inventario_x_estacion2 AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_producto,
    t1.id_estacion,
    sum(t1.volumen_cargado_usar) AS volumen_descargado,
    SUM(t1.volumen_cargado_usar_cisterna) AS volumen_descargado_cisterna
   FROM sgo.v_liquidacion_carga3 t1
  GROUP BY t1.id_operacion, t1.fecha_operativa, t1.id_producto, t1.id_estacion
  ORDER BY t1.fecha_operativa;

ALTER TABLE sgo.v_liquidacion_inventario_x_estacion2
    OWNER TO sgo_user;
-- ************************************************************************************
CREATE OR REPLACE VIEW sgo.v_liquidacion_inventario_x_estacion AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_producto,
    t1.porcentaje_actual,
    t1.id_estacion,
    t1.stock_final_fisico,
    t1.stock_inicial_fisico,
    COALESCE(t2.volumen_descargado, 0::numeric) AS volumen_descargado,
    COALESCE(t3.volumen_despacho, 0::numeric) AS volumen_despacho,
    COALESCE(t2.volumen_descargado_cisterna, 0::numeric) AS volumen_descargado_cisterna
   FROM sgo.v_liquidacion_inventario_x_estacion1 t1
     LEFT JOIN sgo.v_liquidacion_inventario_x_estacion2 t2 ON t1.id_operacion = t2.id_operacion AND t1.fecha_operativa = t2.fecha_operativa AND t1.id_producto = t2.id_producto AND t1.id_estacion = t2.id_estacion
     LEFT JOIN sgo.v_liquidacion_inventario_x_estacion3 t3 ON t1.id_operacion = t3.id_operacion AND t1.fecha_operativa = t3.fecha_operativa AND t1.id_producto = t3.id_producto AND t1.id_estacion = t3.id_estacion;

ALTER TABLE sgo.v_liquidacion_inventario_x_estacion
    OWNER TO sgo_user;
-- ************************************************************************************
CREATE OR REPLACE VIEW sgo.v_liquidacion_inventario_x_estacion_completo AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_producto,
    t1.id_estacion,
    t1.porcentaje_actual,
    t1.stock_final_fisico AS stock_final,
    t1.stock_inicial_fisico AS stock_inicial,
    t1.volumen_descargado,
    t1.volumen_despacho,
    round(t1.stock_final_fisico * (t1.porcentaje_actual / 100::numeric), 0) AS tolerancia,
    t1.stock_inicial_fisico + t1.volumen_descargado - t1.volumen_despacho AS stock_final_calculado,
    t1.stock_final_fisico - (t1.stock_inicial_fisico + t1.volumen_descargado - t1.volumen_despacho) AS variacion,
    @ (t1.stock_final_fisico - (t1.stock_inicial_fisico + t1.volumen_descargado - t1.volumen_despacho)) AS variacion_absoluta,
    t2.nombre AS nombre_producto,
    t3.nombre AS nombre_operacion,
    t3.nombre_corto_cliente AS nombre_cliente,
    t4.nombre AS nombre_estacion,
    t1.volumen_descargado_cisterna
   FROM sgo.v_liquidacion_inventario_x_estacion t1
     JOIN sgo.producto t2 ON t1.id_producto = t2.id_producto
     JOIN sgo.v_operacion t3 ON t1.id_operacion = t3.id_operacion
     JOIN sgo.estacion t4 ON t1.id_estacion = t4.id_estacion;

ALTER TABLE sgo.v_liquidacion_inventario_x_estacion_completo
    OWNER TO sgo_user;
-- ************************************************************************************ JAFETH XXXXXXXXXXXXXXX
CREATE OR REPLACE VIEW sgo.v_liquidacion_inventario_x_estacion_completo_total AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_producto,
    t1.id_estacion,
    t1.porcentaje_actual,
    t1.stock_final,
    t1.stock_inicial,
    t1.volumen_descargado,
    t1.volumen_despacho,
    t1.tolerancia,
    t1.stock_final_calculado,
    t1.variacion,
    t1.variacion_absoluta,
    t1.nombre_producto,
    t1.nombre_operacion,
    t1.nombre_cliente,
    t1.nombre_estacion,
        CASE
            WHEN t1.variacion > 0::numeric THEN (t1.variacion_absoluta - t1.tolerancia) * 0::numeric
            WHEN t1.variacion < 0::numeric THEN (t1.variacion_absoluta - t1.tolerancia) * '-1'::integer::numeric
            ELSE NULL::numeric
        END AS faltante,
    0 AS id_tanque,
    ''::character(1) AS nombre_tanque,
    t1.volumen_descargado_cisterna
   FROM sgo.v_liquidacion_inventario_x_estacion_completo t1;

ALTER TABLE sgo.v_liquidacion_inventario_x_estacion_completo_total
    OWNER TO sgo_user;
-- ************************************************************************************
CREATE OR REPLACE VIEW sgo.v_reporte_conciliacion_volumetrica AS
 SELECT t1.id_operacion,
    t2.fecha_operativa AS diaoperativo,
    t1.nombre_estacion AS estacion,
    t1.nombre_producto AS producto,
    t1.stock_inicial AS invinicial,
    CASE 
        WHEN t3.tipo_volumen_descargado = 1 THEN t1.volumen_descargado_cisterna
        WHEN t3.tipo_volumen_descargado = 2 THEN t1.volumen_descargado 
        ELSE 0
    END AS descargas,
    ROUND(t1.volumen_despacho, 2) AS despachos,
    0 AS otrosmovimientos,
    t1.stock_final_calculado AS invfinalteorico,
    t1.stock_final AS invfinalfisico,
    t1.variacion AS diferencia,
    t1.tolerancia * '-1'::integer::numeric AS tolerancia,
        CASE
            WHEN t2.estado = 1 THEN 'ABIERTO'::text
            WHEN t2.estado = 2 THEN 'REGISTRADO'::text
            WHEN t2.estado = 3 THEN 'CERRADO'::text
            WHEN t2.estado = 4 THEN 'LIQUIDADO'::text
            ELSE ''::text
        END AS estadojornada,
        CASE
            WHEN t1.faltante < 0::numeric THEN 'OBSERVADO'::text
            ELSE 'OK'::text
        END AS situacionregistro,
    t2.comentario AS observaciones,
    t1.id_operacion AS idoperacion,
    t1.nombre_operacion AS operacion
   FROM sgo.v_liquidacion_inventario_x_estacion_completo_total t1
     JOIN sgo.jornada t2 ON t1.fecha_operativa = t2.fecha_operativa AND t1.id_estacion = t2.id_estacion
     JOIN sgo.operacion t3 ON t1.id_operacion = t3.id_operacion;

ALTER TABLE sgo.v_reporte_conciliacion_volumetrica
    OWNER TO sgo_user;
-- ************************************************************************************

CREATE OR REPLACE VIEW sgo.v_reporte_conciliacion_tanque AS
SELECT t1.id_jornada, t1.id_producto, CAST(0 AS BIGINT) AS medida_inicial, CAST(0 AS BIGINT) AS medida_final, 
	SUM(t1.volumen_observado_inicial + COALESCE(t5.volumen_observado, 0) - COALESCE(t2.volumen_observado_final, 0) + COALESCE(t3.volumen_observado, 0) - COALESCE(t4.volumen_observado, 0)) AS volumen_observado, 
	SUM(t1.volumen_corregido_inicial + COALESCE(t5.volumen_corregido, 0) - COALESCE(t2.volumen_corregido_final, 0) + COALESCE(t3.volumen_corregido, 0) - COALESCE(t4.volumen_corregido, 0)) AS volumen_corregido
FROM (
	SELECT MIN(id_tjornada) AS id_tjornada, t1.id_tanque, t1.id_producto, t1.id_jornada, t1.volumen_observado_inicial, t1.volumen_corregido_inicial
	FROM sgo.tanque_jornada t1
	GROUP BY t1.id_tanque, t1.id_producto, t1.id_jornada, t1.volumen_observado_inicial, t1.volumen_corregido_inicial
) t1 
LEFT JOIN (
	SELECT MAX(id_tjornada) AS id_tjornada, t1.id_tanque, t1.id_producto, t1.id_jornada, t1.volumen_observado_final, t1.volumen_corregido_final
	FROM sgo.tanque_jornada t1
	GROUP BY t1.id_tanque, t1.id_producto, t1.id_jornada, t1.volumen_observado_final, t1.volumen_corregido_final
) t2 ON t1.id_tanque = t2.id_tanque AND t1.id_producto = t2.id_producto AND t1.id_jornada = t2.id_jornada
LEFT JOIN (
	SELECT COALESCE(SUM(volumen), 0) AS volumen_observado, COALESCE(SUM(volumen * factor_muestreo), 0) AS volumen_corregido, t2.id_tanque, t2.id_producto, t1.id_jornada 
	FROM sgo.otro_movimiento t1
	LEFT JOIN sgo.tanque t2 ON t1.id_tanque_destino = t2.id_tanque
	LEFT JOIN sgo.v_muestreo_ultimo t3 ON t1.id_jornada = t3.id_jornada AND t2.id_producto = t3.producto_muestreado
	GROUP BY t2.id_tanque, t2.id_producto, t1.id_jornada
) t3 ON t1.id_tanque = t3.id_tanque AND t1.id_jornada = t3.id_jornada AND t1.id_producto = t3.id_producto
LEFT JOIN (
	SELECT COALESCE(SUM(volumen), 0) AS volumen_observado, COALESCE(SUM(volumen * factor_muestreo), 0) AS volumen_corregido, t2.id_tanque, t2.id_producto, t1.id_jornada 
	FROM sgo.otro_movimiento t1
	LEFT JOIN sgo.tanque t2 ON t1.id_tanque_origen = t2.id_tanque
	LEFT JOIN sgo.v_muestreo_ultimo t3 ON t1.id_jornada = t3.id_jornada AND t2.id_producto = t3.producto_muestreado
	GROUP BY t2.id_tanque, t2.id_producto, t1.id_jornada
) t4 ON t1.id_tanque = t4.id_tanque AND t1.id_jornada = t4.id_jornada AND t1.id_producto = t4.id_producto
LEFT JOIN (
	SELECT t3.id_jornada, t5.id_producto, t1.id_tanque, CASE WHEN t6.tipo_volumen_descargado = 1 THEN SUM(t5.volumen_recibido_observado) 
		WHEN t6.tipo_volumen_descargado = 2 THEN (t1.volumen_observado_final - t1.volumen_observado_inicial) ELSE 0 END AS volumen_observado, 
		CASE WHEN t6.tipo_volumen_descargado = 1 THEN SUM(t5.volumen_recibido_corregido) WHEN t6.tipo_volumen_descargado = 2 THEN
		(t1.volumen_corregido_final - t1.volumen_corregido_inicial) ELSE 0 END AS volumen_corregido--, 0 AS medida_inicial, 0 AS medida_final
	FROM sgo.carga_tanque t1
	LEFT JOIN sgo.dia_operativo t2 ON t1.id_doperativo = t2.id_doperativo
	LEFT JOIN sgo.jornada t3 ON t2.fecha_operativa = t3.fecha_operativa
	LEFT JOIN sgo.descarga_cisterna t4 ON t1.id_ctanque = t4.id_ctanque
	LEFT JOIN sgo.descarga_compartimento t5 ON t4.id_dcisterna = t5.id_dcisterna
	LEFT JOIN sgo.operacion t6 ON t2.id_operacion = t6.id_operacion
	GROUP BY t3.id_jornada, t5.id_producto, t1.id_tanque, t6.tipo_volumen_descargado, t1.volumen_observado_final, t1.volumen_observado_inicial, 
		t1.volumen_corregido_final, t1.volumen_corregido_inicial
) t5 ON t1.id_tanque = t5.id_tanque AND t1.id_jornada = t5.id_jornada AND t1.id_producto = t5.id_producto
GROUP BY t1.id_jornada, t1.id_producto;

ALTER TABLE sgo.v_reporte_conciliacion_tanque
    OWNER TO sgo_user;
-- ************************************************************************************
CREATE OR REPLACE VIEW sgo.v_reporte_conciliacion_estacion AS
 SELECT j.fecha_operativa,
    p.nombre AS producto,
    e.nombre AS estacion,
    t1.medida_inicial AS medida_inicial_t,
    t1.medida_final AS medida_final_t,
    t1.volumen_observado AS volumen_observado_t,
    t1.volumen_corregido AS volumen_corregido_t,
    t2.lectura_inicial AS lectura_inicial_c,
    t2.lectura_final AS lectura_final_c,
    ROUND(t2.volumen_observado, 2) AS volumen_observado_c,
    ROUND(t2.volumen_corregido, 2) AS volumen_corregido_c,
    ROUND(t3.volumen_observado, 2) AS volumen_observado_d,
    ROUND(t3.volumen_corregido, 2) AS volumen_corregido_d,
    ROUND(t1.volumen_observado - t2.volumen_observado, 2) AS volumen_observado_tc,
    ROUND(t1.volumen_corregido - t2.volumen_corregido, 2) AS volumen_corregido_tc,
    ROUND(t1.volumen_observado - t3.volumen_observado, 2) AS volumen_observado_td,
    ROUND(t1.volumen_corregido - t3.volumen_corregido, 2) AS volumen_corregido_td,
    ROUND(t2.volumen_observado - t3.volumen_observado, 2) AS volumen_observado_cd,
    ROUND(t2.volumen_corregido - t3.volumen_corregido, 2) AS volumen_corregido_cd,
    e.id_operacion,
        CASE
            WHEN j.estado = 1 THEN 'ABIERTO'::text
            WHEN j.estado = 2 THEN 'REGISTRADO'::text
            WHEN j.estado = 3 THEN 'CERRADO'::text
            WHEN j.estado = 4 THEN 'LIQUIDADO'::text
            ELSE 'ABIERTO'::text
        END AS estado
   FROM sgo.v_reporte_conciliacion_tanque t1
     LEFT JOIN sgo.v_reporte_conciliacion_contometro t2 ON t2.id_jornada = t1.id_jornada AND t2.id_producto = t1.id_producto
     LEFT JOIN sgo.v_reporte_conciliacion_despacho t3 ON t3.id_jornada = t1.id_jornada AND t3.id_producto = t1.id_producto
     JOIN sgo.producto p ON p.id_producto = COALESCE(t1.id_producto, t2.id_producto, t3.id_producto)
     JOIN sgo.jornada j ON j.id_jornada = COALESCE(t1.id_jornada, t2.id_jornada, t3.id_jornada)
     JOIN sgo.estacion e ON e.id_estacion = j.id_estacion;

ALTER TABLE sgo.v_reporte_conciliacion_estacion
    OWNER TO sgo_user;


-- ******************** Permisos al admin 20190301-1117 *************************
INSERT INTO seguridad.permiso(nombre, estado, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion)
VALUES('URL_LIQUIDAR_JORNADA', 1, 1550765850819, 2, 2, 1550765850819, '127.0.0.1', '127.0.0.1');

INSERT INTO seguridad.permisos_rol(id_rol, id_permiso) 
VALUES(1, (SELECT id_permiso FROM seguridad.permiso where nombre = 'URL_LIQUIDAR_JORNADA'));

INSERT INTO sgo.enlace(url_completa, padre, orden, url_relativa, tipo, id_permiso, titulo, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion)
VALUES('/admin/liquidacion/liquidar-jornada', 600, 359, '/liquidacion/liquidar-jornada', 0, (SELECT id_permiso FROM seguridad.permiso where nombre = 'URL_GENERAR_PLANTILLA_DESPACHO'), 'Generar Plantilla Despacho', 1550766359243, 2, 2, 1550766359243, '127.0.0.1', '127.0.0.1');

-- Inicio Agregado por HT 01-03-2019 15:37
CREATE OR REPLACE VIEW sgo.v_tanque_jornada AS
 SELECT t1.id_tjornada,
    t1.id_tanque,
    t1.id_producto,
    t1.medida_inicial,
    t1.medida_final,
    t1.volumen_observado_inicial,
    t1.volumen_observado_final,
    t1.api_corregido_inicial,
    t1.api_corregido_final,
    t1.temperatura_inicial,
    t1.temperatura_final,
    t1.factor_correccion_inicial,
    t1.factor_correccion_final,
    t1.volumen_corregido_inicial,
    t1.volumen_corregido_final,
    t1.estado_servicio,
    t1.en_linea,
    t1.volumen_agua_final,
    t1.id_jornada,
    t2.nombre AS nombre_producto,
    t2.abreviatura,
    t2.indicador_producto,
    t3.descripcion AS nombre_tanque,
    t3.volumen_total,
    t3.volumen_trabajo,
    t4.id_estacion,
    t4.fecha_operativa,
    t4.estado AS estado_jornada,
    t5.nombre AS nombre_estacion,
    t5.id_operacion,
    t1.hora_inicial,
    t1.hora_final,
    t1.apertura,
    t1.cierre,
    t3.estado AS estado_tanque
   FROM sgo.tanque_jornada t1
     JOIN sgo.producto t2 ON t1.id_producto = t2.id_producto
     JOIN sgo.tanque t3 ON t1.id_tanque = t3.id_tanque
     JOIN sgo.jornada t4 ON t1.id_jornada = t4.id_jornada
     JOIN sgo.estacion t5 ON t4.id_estacion = t5.id_estacion;

ALTER TABLE sgo.v_tanque_jornada
    OWNER TO sgo_user;

-- Fin Agregado por HT 01-03-2019 15:37

-- Inicio Agregado por HT 04-03-2019 11:08
insert into sgo.perfil_horario(id_perfil_horario, nombre_perfil, numero_turnos, estado, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion) values(374, 'P. JORN. CALENDARIO 1T', 1, 1, '1549570678266', 2, 2, '1549570678266', '127.0.0.1', '127.0.0.1');

insert into sgo.perfil_detalle_horario(id_perfil_horario, numero_orden, glosa_turno, hora_inicio_turno,  hora_fin_turno, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion) values(374, 1, 'TURNO JORNADA', '00:00', '23:59', '1549570678266', 2, 2, '1549570678266', '127.0.0.1', '127.0.0.1');

insert into sgo.perfil_horario(id_perfil_horario, nombre_perfil, numero_turnos, estado, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion) values(375, 'P. JORN. CALENDARIO 2T', 2, 1, '1549570678266', 2, 2, '1549570678266', '127.0.0.1', '127.0.0.1');

insert into sgo.perfil_detalle_horario(id_perfil_horario, numero_orden, glosa_turno, hora_inicio_turno,  hora_fin_turno, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion) values(375, 1, 'TURNO 1', '00:00', '12:00', '1549570678266', 2, 2, '1549570678266', '127.0.0.1', '127.0.0.1');

insert into sgo.perfil_detalle_horario(id_perfil_horario, numero_orden, glosa_turno, hora_inicio_turno,  hora_fin_turno, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion) values(375, 2, 'TURNO 2', '12:00', '23:59', '1549570678266', 2, 2, '1549570678266', '127.0.0.1', '127.0.0.1');

insert into sgo.perfil_horario(id_perfil_horario, nombre_perfil, numero_turnos, estado, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion) values(381, 'P. JORN. CALENDARIO 3T', 3, 1, '1549570678266', 2, 2, '1549570678266', '127.0.0.1', '127.0.0.1');

insert into sgo.perfil_detalle_horario(id_perfil_horario, numero_orden, glosa_turno, hora_inicio_turno,  hora_fin_turno, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion) values(381, 1, 'TURNO NOCHE', '00:00', '08:00', '1549570678266', 2, 2, '1549570678266', '127.0.0.1', '127.0.0.1');

insert into sgo.perfil_detalle_horario(id_perfil_horario, numero_orden, glosa_turno, hora_inicio_turno,  hora_fin_turno, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion) values(381, 2, 'TURNO MAÑANA', '08:00', '16:00', '1549570678266', 2, 2, '1549570678266', '127.0.0.1', '127.0.0.1');

insert into sgo.perfil_detalle_horario(id_perfil_horario, numero_orden, glosa_turno, hora_inicio_turno,  hora_fin_turno, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion) values(381, 3, 'TURNO TARDE', '16:00', '23:59', '1549570678266', 2, 2, '1549570678266', '127.0.0.1', '127.0.0.1');

insert into sgo.perfil_horario(id_perfil_horario, nombre_perfil, numero_turnos, estado, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion) values(373, 'PERFIL KIO 3T', 3, 1, '1549570678266', 2, 2, '1549570678266', '127.0.0.1', '127.0.0.1');

insert into sgo.perfil_detalle_horario(id_perfil_horario, numero_orden, glosa_turno, hora_inicio_turno,  hora_fin_turno, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion) values(373, 1, 'TURNO DIA', '06:00', '14:00', '1549570678266', 2, 2, '1549570678266', '127.0.0.1', '127.0.0.1');

insert into sgo.perfil_detalle_horario(id_perfil_horario, numero_orden, glosa_turno, hora_inicio_turno,  hora_fin_turno, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion) values(373, 2, 'TURNO TARDE', '14:00', '22:00', '1549570678266', 2, 2, '1549570678266', '127.0.0.1', '127.0.0.1');

insert into sgo.perfil_detalle_horario(id_perfil_horario, numero_orden, glosa_turno, hora_inicio_turno,  hora_fin_turno, creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion) values(373, 3, 'TURNO NOCHE', '22:00', '05:59', '1549570678266', 2, 2, '1549570678266', '127.0.0.1', '127.0.0.1');

-- Fin Agregado por HT 04-03-2019 11:08

-- Inicio Agregado por HT 11-03-2019 17:43
CREATE OR REPLACE VIEW sgo.v_liquidacion_inventario_x_estacion_completo AS
 SELECT t1.id_operacion,
    t1.fecha_operativa,
    t1.id_producto,
    t1.id_estacion,
    t1.porcentaje_actual,
    t1.stock_final_fisico AS stock_final,
    t1.stock_inicial_fisico AS stock_inicial,
    t1.volumen_descargado,
    t1.volumen_despacho,
    round(t1.stock_final_fisico * (t1.porcentaje_actual / 100::numeric), 0) AS tolerancia,
    
	CASE
            WHEN t3.tipo_volumen_descargado = 1 THEN (t1.stock_inicial_fisico + t1.volumen_descargado_cisterna - t1.volumen_despacho )
            WHEN t3.tipo_volumen_descargado = 2 THEN (t1.stock_inicial_fisico + t1.volumen_descargado - t1.volumen_despacho )
            ELSE 0::numeric
    END AS stock_final_calculado,
	
	CASE
            WHEN t3.tipo_volumen_descargado = 1 THEN (t1.stock_final_fisico - (t1.stock_inicial_fisico + t1.volumen_descargado_cisterna - t1.volumen_despacho) )
            WHEN t3.tipo_volumen_descargado = 2 THEN (t1.stock_final_fisico - (t1.stock_inicial_fisico + t1.volumen_descargado - t1.volumen_despacho) )
            ELSE 0::numeric
    END AS variacion,
	
    @ (t1.stock_final_fisico - (t1.stock_inicial_fisico + t1.volumen_descargado - t1.volumen_despacho)) AS variacion_absoluta,
    t2.nombre AS nombre_producto,
    t3.nombre AS nombre_operacion,
    t3.nombre_corto_cliente AS nombre_cliente,
    t4.nombre AS nombre_estacion,
    t1.volumen_descargado_cisterna
   FROM sgo.v_liquidacion_inventario_x_estacion t1
     JOIN sgo.producto t2 ON t1.id_producto = t2.id_producto
     JOIN sgo.v_operacion t3 ON t1.id_operacion = t3.id_operacion
     JOIN sgo.estacion t4 ON t1.id_estacion = t4.id_estacion;

ALTER TABLE sgo.v_liquidacion_inventario_x_estacion_completo
    OWNER TO sgo_user;
--Fin por HT 11-03-2019 17:43

--Inicio Agregado por HT 12-03-2019 10:41
CREATE OR REPLACE VIEW sgo.v_liquidacion_carga1 AS
 SELECT t1.id_ctanque,
    t1.id_doperativo,
    t1.id_estacion,
    t1.id_tanque,
    t2.fecha_operativa,
    t2.id_operacion,
    sum(t4.volumen_recibido_observado) AS volumen_cargado_observado_cisterna,
    sum(t4.volumen_recibido_corregido) AS volumen_cargado_corregido_cisterna,
        CASE
            WHEN t5.tipo_volumen_descargado = 2 THEN t1.volumen_observado_final - t1.volumen_observado_inicial
            WHEN t5.tipo_volumen_descargado = 1 THEN ( SELECT sum(dcomp.volumen_recibido_observado) AS sum
               FROM sgo.descarga_cisterna dcist
                 LEFT JOIN sgo.descarga_compartimento dcomp ON dcomp.id_dcisterna = dcist.id_dcisterna
              WHERE dcist.id_ctanque = t1.id_ctanque)
            ELSE NULL::numeric
        END AS volumen_cargado_observado,
        CASE
            WHEN t5.tipo_volumen_descargado = 2 THEN t1.volumen_corregido_final - t1.volumen_corregido_inicial
            WHEN t5.tipo_volumen_descargado = 1 THEN ( SELECT sum(dcomp.volumen_recibido_corregido) AS sum
               FROM sgo.descarga_cisterna dcist
                 LEFT JOIN sgo.descarga_compartimento dcomp ON dcomp.id_dcisterna = dcist.id_dcisterna
              WHERE dcist.id_ctanque = t1.id_ctanque)
            ELSE NULL::numeric
        END AS volumen_cargado_corregido
   FROM sgo.carga_tanque t1
     JOIN sgo.dia_operativo t2 ON t1.id_doperativo = t2.id_doperativo
     LEFT JOIN sgo.descarga_cisterna t3 ON t1.id_ctanque = t3.id_ctanque
     LEFT JOIN sgo.descarga_compartimento t4 ON t3.id_dcisterna = t4.id_dcisterna
     LEFT JOIN sgo.v_operacion t5 ON t5.id_operacion = t2.id_operacion
  GROUP BY t1.id_ctanque, t1.id_doperativo, t1.id_estacion, t1.id_tanque, t1.volumen_observado_final, t1.volumen_observado_inicial, t1.volumen_corregido_final, t1.volumen_corregido_inicial, t2.fecha_operativa, t2.id_operacion, t5.tipo_volumen_descargado;

ALTER TABLE sgo.v_liquidacion_carga1
    OWNER TO sgo_user;
--Fin Agregado por HT 12-03-2019 10:41

--Inicio Agregado por HT 12-03-2019 15:44
CREATE OR REPLACE VIEW sgo.v_reporte_conciliacion_volumetrica AS
 SELECT t1.id_operacion,
    t2.fecha_operativa AS diaoperativo,
    t1.nombre_estacion AS estacion,
    t1.nombre_producto AS producto,
    t1.stock_inicial AS invinicial,
    t1.volumen_descargado AS descargas,
    round(t1.volumen_despacho, 2) AS despachos,
    0 AS otrosmovimientos,
    t1.stock_final_calculado AS invfinalteorico,
    t1.stock_final AS invfinalfisico,
    t1.variacion AS diferencia,
    t1.tolerancia * '-1'::integer::numeric AS tolerancia,
        CASE
            WHEN t2.estado = 1 THEN 'ABIERTO'::text
            WHEN t2.estado = 2 THEN 'REGISTRADO'::text
            WHEN t2.estado = 3 THEN 'CERRADO'::text
            WHEN t2.estado = 4 THEN 'LIQUIDADO'::text
            ELSE ''::text
        END AS estadojornada,
        CASE
            WHEN t1.faltante < 0::numeric THEN 'OBSERVADO'::text
            ELSE 'OK'::text
        END AS situacionregistro,
    t2.comentario AS observaciones,
    t1.id_operacion AS idoperacion,
    t1.nombre_operacion AS operacion
   FROM sgo.v_liquidacion_inventario_x_estacion_completo_total t1
     JOIN sgo.jornada t2 ON t1.fecha_operativa = t2.fecha_operativa AND t1.id_estacion = t2.id_estacion
     JOIN sgo.operacion t3 ON t1.id_operacion = t3.id_operacion;

ALTER TABLE sgo.v_reporte_conciliacion_volumetrica
    OWNER TO sgo_user;
--Fin Agregado por HT 12-03-2019 15:44


-- ******************** Modificaciones en VIEW v_detalle_gec 20190313-1000 *************************
CREATE OR REPLACE VIEW sgo.v_detalle_gec AS
 SELECT t1.id_dgec,
    t1.id_gcombustible,
    t1.volumen_despachado,
    t1.volumen_recibido,
    t1.numero_guia,
    t1.fecha_emision,
    t1.fecha_recepcion,
    t1.estado,
t2.id_producto
   FROM sgo.detalle_gec t1
   JOIN sgo.guia_combustible t2 ON t1.id_gcombustible = t2.id_gcombustible;
 
ALTER TABLE sgo.v_detalle_gec
    OWNER TO sgo_user;