package sgo.datos;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Locale;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.jdbc.core.RowMapper;

import sgo.entidad.Cliente;
import sgo.entidad.Operacion;
import sgo.entidad.Planta;
import sgo.utilidades.Utilidades;

public class OperacionMapper implements RowMapper<Operacion> {
	
	public Operacion mapRow(ResultSet rs, int arg1) throws SQLException 
	{
		Operacion eOperacion = null;
		Cliente eCliente = null;
		Planta ePlanta = null;
		
		try {
			
			eOperacion = new Operacion();
			eOperacion.setId(rs.getInt("id_operacion"));
			eOperacion.setIdCliente(rs.getInt("id_cliente"));
			eOperacion.setNombre(Utilidades.cleanXSS(rs.getString("nombre")));
			eOperacion.setAlias(Utilidades.cleanXSS(rs.getString("alias")));
			eOperacion.setVolumenPromedioCisterna(rs.getFloat("volumen_promedio_cisterna"));
			eOperacion.setReferenciaPlantaRecepcion(Utilidades.cleanXSS(rs.getString("referencia_planta_recepcion")));
			eOperacion.setReferenciaDestinatarioMercaderia(Utilidades.cleanXSS(rs.getString("referencia_destinatario_mercaderia")));
			eOperacion.setFechaInicioPlanificacion(rs.getDate("fecha_inicio_planificacion"));
			eOperacion.setEta(rs.getInt("eta_origen"));
			eOperacion.setIndicadorTipoRegistroTanque(rs.getInt("indicador_tipo_registro_tanque"));
			eOperacion.setIdPlantaDespacho(rs.getInt("planta_despacho_defecto"));
			eOperacion.setEstado(rs.getInt("estado"));		
			eOperacion.setCorreoPara(Utilidades.cleanXSS(rs.getString("correoPara")));
			eOperacion.setCorreoCC(Utilidades.cleanXSS(rs.getString("correoCC")));
			eOperacion.setTipoVolumenDescargado(rs.getInt("tipo_volumen_descargado"));
			
			if (rs.getInt("tipo_volumen_descargado") == Operacion.VOLUMEN_DESCARGADO_CISTERNA) {
				eOperacion.setTipoVolumenDescargadotxt("Volumen descargado por cisterna(s).");
			} else if (rs.getInt("tipo_volumen_descargado") == Operacion.VOLUMEN_RECIBIDO_EN_TANQUE) {
				eOperacion.setTipoVolumenDescargadotxt("Volumen recibido en el tanque.");
			}

			//Parametros de auditoria
			eOperacion.setCreadoPor(rs.getInt("creado_por"));
			eOperacion.setCreadoEl(rs.getLong("creado_el"));
			eOperacion.setActualizadoPor(rs.getInt("actualizado_por"));
			eOperacion.setActualizadoEl(rs.getLong("actualizado_el"));
			eOperacion.setUsuarioActualizacion(rs.getString("usuario_actualizacion"));
			eOperacion.setUsuarioCreacion(rs.getString("usuario_creacion"));
			eOperacion.setIpCreacion(rs.getString("ip_creacion"));
			eOperacion.setIpActualizacion(rs.getString("ip_actualizacion"));	

			ePlanta = new Planta();
			ePlanta.setId(rs.getInt("planta_despacho_defecto"));
			ePlanta.setDescripcion(Utilidades.cleanXSS(rs.getString("descripcion_planta_despacho")));
			eOperacion.setPlantaDespacho(ePlanta);

			eCliente = new Cliente();
			eCliente.setId(rs.getInt("id_cliente"));
			eCliente.setRazonSocial(Utilidades.cleanXSS(rs.getString("razon_social_cliente")));
			eCliente.setNombreCorto(Utilidades.cleanXSS(rs.getString("nombre_corto_cliente")));
			eCliente.setEstado(rs.getInt("estado_cliente"));
			eOperacion.setCliente(eCliente);
			
		} catch(Exception e) {
			e.printStackTrace();
		}
		
		return eOperacion;
	}
}