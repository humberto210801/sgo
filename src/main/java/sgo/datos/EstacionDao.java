package sgo.datos;

import java.util.ArrayList;
import java.util.List;
import javax.sql.DataSource;

import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import sgo.entidad.Cisterna;
import sgo.entidad.Estacion;
import sgo.entidad.Jornada;
import sgo.entidad.Contenido;
import sgo.entidad.ParametrosListar;
import sgo.entidad.RespuestaCompuesta;
import sgo.utilidades.Constante;

@Repository
public class EstacionDao {
	
	private JdbcTemplate jdbcTemplate;
	private NamedParameterJdbcTemplate namedJdbcTemplate;
	public static final String NOMBRE_TABLA = Constante.ESQUEMA_APLICACION + "estacion";
	public static final String NOMBRE_VISTA = Constante.ESQUEMA_APLICACION + "v_estacion";
	public final static String NOMBRE_CAMPO_CLAVE = "id_estacion";
	public final static String NOMBRE_CAMPO_FILTRO = "nombre";
	public final static String NOMBRE_CAMPO_FILTRO_OPERACION = "id_operacion";
	public final static String NOMBRE_CAMPO_ORDENAMIENTO_DEFECTO = "nombre";
	
	public final static String NOMBRE_CAMPO_FILTRO_ESTADO = "estado";
	public final static String O = " OR ";
	public final static String Y = " AND ";
	public final static String ENTRE = "BETWEEN";
	
	@Autowired
	public void setDataSource(DataSource dataSource) {
		this.jdbcTemplate = new JdbcTemplate(dataSource);
		this.namedJdbcTemplate = new NamedParameterJdbcTemplate(dataSource);
	}
	
	public DataSource getDataSource(){
		return this.jdbcTemplate.getDataSource();
	}
	
	public String mapearCampoOrdenamiento(String propiedad){
		String campoOrdenamiento=NOMBRE_CAMPO_ORDENAMIENTO_DEFECTO;
		
		try {
			if (propiedad.equals("id")){
				campoOrdenamiento="id_estacion";
			}
			if (propiedad.equals("nombre")){
				campoOrdenamiento="nombre";
			}
			if (propiedad.equals("tipo")){
				campoOrdenamiento="tipo";
			}
			if (propiedad.equals("estado")){
				campoOrdenamiento="estado";
			}
			if (propiedad.equals("id_operacion")){
				campoOrdenamiento="id_operacion";
			}
			if (propiedad.equals("operacion.nombre")){
				campoOrdenamiento="nombre_operacion";
			}
			//Campos de auditoria
		}catch(Exception excepcion){
			
		}
		return campoOrdenamiento;
	}

	public RespuestaCompuesta recuperarRegistros(ParametrosListar argumentosListar) {
		
		String sqlLimit = "";
		String sqlOrderBy = "";
		List<String> filtrosWhere = new ArrayList<String>();
		String sqlWhere = "";
		int totalRegistros = 0, 
		totalEncontrados = 0;
		RespuestaCompuesta respuesta = new RespuestaCompuesta();
		Contenido<Estacion> contenido = new Contenido<Estacion>();
		List<Estacion> listaRegistros = new ArrayList<Estacion>();
		List<Object> parametros = new ArrayList<Object>();
		
		try {
			
			if (argumentosListar.getPaginacion() == Constante.CON_PAGINACION) {
				sqlLimit = Constante.SQL_LIMIT_CONFIGURADO;
				parametros.add(argumentosListar.getInicioPaginacion());
				parametros.add(argumentosListar.getRegistrosxPagina());
			}
			
			sqlOrderBy= " ORDER BY " + this.mapearCampoOrdenamiento(argumentosListar.getCampoOrdenamiento()) + " "  + argumentosListar.getSentidoOrdenamiento();
			
			StringBuilder consultaSQL = new StringBuilder();
			consultaSQL.setLength(0);
			consultaSQL.append("SELECT count(" + NOMBRE_CAMPO_CLAVE+ ") as total FROM " + NOMBRE_TABLA);
			totalRegistros = jdbcTemplate.queryForObject(consultaSQL.toString(), null, Integer.class);
			totalEncontrados=totalRegistros;

			if (!argumentosListar.getValorBuscado().isEmpty()){
				filtrosWhere.add("lower(t1."+NOMBRE_CAMPO_FILTRO+") like lower('%"+ argumentosListar.getValorBuscado() +"%') ");
			}
			
			if (!argumentosListar.getTxtFiltro().isEmpty()){
				filtrosWhere.add("lower(t1."+NOMBRE_CAMPO_FILTRO+") like lower('%"+ argumentosListar.getTxtFiltro() +"%') ");
			}
			
			if(argumentosListar.getFiltroEstado() != Constante.FILTRO_TODOS){
				filtrosWhere.add(" t1."+NOMBRE_CAMPO_FILTRO_ESTADO + "=" + argumentosListar.getFiltroEstado());
			}
			
		    if(argumentosListar.getFiltroOperacion() != Constante.FILTRO_TODOS){
		    	 filtrosWhere.add(" t1."+ NOMBRE_CAMPO_FILTRO_OPERACION + "=" + argumentosListar.getFiltroOperacion());
		    }
		    
//		    Inicio Agregado por req 9000003068
		    if(argumentosListar.getIdPerfilHorario() != 0){
		    	 filtrosWhere.add(" t1.id_perfil_horario " + "=" + argumentosListar.getIdPerfilHorario());
		    }
//		    Fin Agregado por req 9000003068
		     
			if (!filtrosWhere.isEmpty()) {
				consultaSQL.setLength(0);
				sqlWhere = "WHERE " + StringUtils.join(filtrosWhere, Y);
				
				consultaSQL.append("SELECT count(t1." + NOMBRE_CAMPO_CLAVE+ ") as total FROM " + NOMBRE_VISTA + " t1 " + sqlWhere);
				totalEncontrados = jdbcTemplate.queryForObject(consultaSQL.toString(), null, Integer.class);
			}

			consultaSQL.setLength(0);
			consultaSQL.append("SELECT ");
			consultaSQL.append("t1.id_estacion,");
			consultaSQL.append("t1.nombre,");
			consultaSQL.append("t1.tipo,");
			consultaSQL.append("t1.cantidad_turnos,");
			consultaSQL.append("t1.estado,");
			consultaSQL.append("t1.id_operacion,");
			consultaSQL.append("t1.nombre_operacion,");
			consultaSQL.append("t1.metodo_descarga,");
			consultaSQL.append("tipo_apertura_tanque,");
			// 9000003068
			consultaSQL.append("t1.numero_decimales_contometro,");
			consultaSQL.append("id_perfil_horario,");
			consultaSQL.append("nombre_perfil,");
			
			//Campos de auditoria
			consultaSQL.append("t1.creado_el,");
			consultaSQL.append("t1.creado_por,");
			consultaSQL.append("t1.actualizado_por,");
			consultaSQL.append("t1.actualizado_el,");
			consultaSQL.append("t1.usuario_creacion,");
			consultaSQL.append("t1.usuario_actualizacion,");
			consultaSQL.append("t1.ip_creacion,");
			consultaSQL.append("t1.ip_actualizacion");
			consultaSQL.append(" FROM ");
			consultaSQL.append(NOMBRE_VISTA);
			consultaSQL.append(" t1 ");
			consultaSQL.append(sqlWhere);
			consultaSQL.append(sqlOrderBy);
			consultaSQL.append(sqlLimit);
			
			listaRegistros = jdbcTemplate.query(consultaSQL.toString(),parametros.toArray(), new EstacionMapper());
			contenido.carga = listaRegistros;
			respuesta.estado = true;
			respuesta.contenido = contenido;
			respuesta.contenido.totalRegistros = totalRegistros;
			respuesta.contenido.totalEncontrados = totalEncontrados;
		} catch (DataAccessException excepcionAccesoDatos) {
			excepcionAccesoDatos.printStackTrace();
			respuesta.error=  Constante.EXCEPCION_ACCESO_DATOS;
			respuesta.estado = false;
			respuesta.contenido=null;
		} catch (Exception excepcionGenerica) {
			excepcionGenerica.printStackTrace();
			respuesta.error= Constante.EXCEPCION_GENERICA;
			respuesta.contenido=null;
			respuesta.estado = false;
		}
		return respuesta;
	}
	
	public RespuestaCompuesta recuperarRegistro(int ID) {
		
		StringBuilder consultaSQL = new StringBuilder();		
		List<Estacion> listaRegistros = new ArrayList<Estacion>();
		Contenido<Estacion> contenido = new Contenido<Estacion>();
		RespuestaCompuesta respuesta = new RespuestaCompuesta();
		
		try {
			consultaSQL.append("SELECT ");
			consultaSQL.append("t1.id_estacion,");
			consultaSQL.append("t1.nombre,");
			consultaSQL.append("t1.tipo,");
			consultaSQL.append("t1.cantidad_turnos,");
			consultaSQL.append("t1.estado,");
			consultaSQL.append("t1.id_operacion,");
			consultaSQL.append("t1.metodo_descarga,");
			consultaSQL.append("t1.nombre_operacion,");
			consultaSQL.append("t1.tipo_apertura_tanque,");
			consultaSQL.append("t1.numero_decimales_contometro,");
			consultaSQL.append("t1.id_perfil_horario,");
			consultaSQL.append("t1.nombre_perfil,");
			
			//Campos de auditoria
			consultaSQL.append("t1.creado_el,");
			consultaSQL.append("t1.creado_por,");
			consultaSQL.append("t1.actualizado_por,");
			consultaSQL.append("t1.actualizado_el,");	
			consultaSQL.append("t1.usuario_creacion,");
			consultaSQL.append("t1.usuario_actualizacion,");
			consultaSQL.append("t1.ip_creacion,");
			consultaSQL.append("t1.ip_actualizacion");
			consultaSQL.append(" FROM ");				
			consultaSQL.append(NOMBRE_VISTA); 
			consultaSQL.append(" t1 ");
			consultaSQL.append(" WHERE ");
			consultaSQL.append(NOMBRE_CAMPO_CLAVE);
			consultaSQL.append("=?");
			
			listaRegistros = jdbcTemplate.query(consultaSQL.toString(), new Object[] {ID}, new EstacionMapper());
			contenido.totalRegistros = listaRegistros.size();
			contenido.totalEncontrados = listaRegistros.size();
			contenido.carga = listaRegistros;
			respuesta.mensaje = "OK";
			respuesta.estado = true;
			respuesta.contenido = contenido;			
		} catch (DataAccessException e) {
			e.printStackTrace();
			respuesta.error = Constante.EXCEPCION_ACCESO_DATOS;
			respuesta.estado = false;
			respuesta.contenido = null;
		}
		
		return respuesta;
	}
	
	public RespuestaCompuesta guardarRegistro(Estacion estacion){
		RespuestaCompuesta respuesta = new RespuestaCompuesta();
		StringBuilder consultaSQL = new StringBuilder();
		KeyHolder claveGenerada = null;
		int cantidadFilasAfectadas = 0;
		
		try {
			consultaSQL.append("INSERT INTO ");
			consultaSQL.append(NOMBRE_TABLA);
			consultaSQL.append(" (nombre,tipo,cantidad_turnos,estado,id_operacion,metodo_descarga,numero_decimales_contometro, ");
			consultaSQL.append(" tipo_apertura_tanque,id_perfil_horario, ");
			consultaSQL.append(" creado_el,creado_por,actualizado_por,actualizado_el,ip_creacion,ip_actualizacion) ");
			consultaSQL.append(" VALUES ");
			consultaSQL.append(" (:Nombre,:Tipo,:CantidadTurnos,:Estado,:IdOperacion,:MetodoDescarga,:NumeroDecimalesContometro, ");
			consultaSQL.append(" :TipoAperturaTanque,:IdPerfilHorario, ");
			consultaSQL.append(" :CreadoEl,:CreadoPor,:ActualizadoPor,:ActualizadoEl,:IpCreacion,:IpActualizacion) ");
			
			MapSqlParameterSource listaParametros= new MapSqlParameterSource();   
			listaParametros.addValue("Nombre", estacion.getNombre());
			listaParametros.addValue("Tipo", estacion.getTipo());
			listaParametros.addValue("CantidadTurnos", estacion.getCantidadTurnos());
			listaParametros.addValue("Estado", estacion.getEstado());
			listaParametros.addValue("IdOperacion", estacion.getIdOperacion());
			listaParametros.addValue("MetodoDescarga", estacion.getMetodoDescarga());
			listaParametros.addValue("IdPerfilHorario", estacion.getIdPerfilHorario());
			listaParametros.addValue("NumeroDecimalesContometro", estacion.getNumeroDecimalesContometro());
			listaParametros.addValue("TipoAperturaTanque", estacion.getTipoAperturaTanque());
			
			listaParametros.addValue("CreadoEl", estacion.getCreadoEl());
			listaParametros.addValue("CreadoPor", estacion.getCreadoPor());
			listaParametros.addValue("ActualizadoPor", estacion.getActualizadoPor());
			listaParametros.addValue("ActualizadoEl", estacion.getActualizadoEl());
			listaParametros.addValue("IpCreacion", estacion.getIpCreacion());
			listaParametros.addValue("IpActualizacion", estacion.getIpActualizacion());			
			SqlParameterSource namedParameters = listaParametros;
			
			claveGenerada = new GeneratedKeyHolder();
			cantidadFilasAfectadas = namedJdbcTemplate.update(consultaSQL.toString(),namedParameters,claveGenerada,new String[] {NOMBRE_CAMPO_CLAVE});		
			if (cantidadFilasAfectadas>1){
				respuesta.error=Constante.EXCEPCION_CANTIDAD_REGISTROS_INCORRECTA;
				respuesta.estado=false;
				return respuesta;
			}
			respuesta.estado=true;
			respuesta.valor= claveGenerada.getKey().toString();
		} catch (DataIntegrityViolationException excepcionIntegridadDatos){
			excepcionIntegridadDatos.printStackTrace();
			respuesta.error= Constante.EXCEPCION_INTEGRIDAD_DATOS;
			respuesta.estado=false;
		} catch (DataAccessException excepcionAccesoDatos){
			excepcionAccesoDatos.printStackTrace();
			respuesta.error=Constante.EXCEPCION_ACCESO_DATOS;
			respuesta.estado=false;
		}
		return respuesta;
	}
	
	public RespuestaCompuesta actualizarRegistro(Estacion estacion) {
		
		RespuestaCompuesta respuesta = new RespuestaCompuesta();
		StringBuilder consultaSQL = new StringBuilder();
		int cantidadFilasAfectadas = 0;
		
		try {
			consultaSQL.append("UPDATE ");
			consultaSQL.append(NOMBRE_TABLA);
			consultaSQL.append(" SET ");
			consultaSQL.append("nombre = :Nombre,");
			consultaSQL.append("tipo = :Tipo,");
			consultaSQL.append("cantidad_turnos = :CantidadTurnos,");
			consultaSQL.append("estado = :Estado,");
			consultaSQL.append("id_operacion = :IdOperacion,");
			consultaSQL.append("metodo_descarga = :MetodoDescarga,");		 
			consultaSQL.append("actualizado_por = :ActualizadoPor,");
			consultaSQL.append("actualizado_el = :ActualizadoEl,");
			consultaSQL.append("ip_actualizacion = :IpActualizacion,");
			consultaSQL.append("id_perfil_horario = :IdPerfilHorario,");
			consultaSQL.append("tipo_apertura_tanque = :TipoAperturaTanque,");
			consultaSQL.append("numero_decimales_contometro = :NumeroDecimalesContometro ");
			consultaSQL.append(" WHERE ");
			consultaSQL.append(NOMBRE_CAMPO_CLAVE);
			consultaSQL.append("=:Id");
			
			MapSqlParameterSource listaParametros= new MapSqlParameterSource();
			listaParametros.addValue("Nombre", estacion.getNombre());
			listaParametros.addValue("Tipo", estacion.getTipo());
			listaParametros.addValue("CantidadTurnos", estacion.getCantidadTurnos());
			listaParametros.addValue("Estado", estacion.getEstado());
			listaParametros.addValue("MetodoDescarga", estacion.getMetodoDescarga());
			listaParametros.addValue("IdOperacion", estacion.getIdOperacion());
			listaParametros.addValue("IdPerfilHorario", estacion.getIdPerfilHorario());
			listaParametros.addValue("TipoAperturaTanque", estacion.getTipoAperturaTanque());
			listaParametros.addValue("NumeroDecimalesContometro", estacion.getNumeroDecimalesContometro());
			
			//Valores Auditoria
			listaParametros.addValue("ActualizadoEl", estacion.getActualizadoEl());
			listaParametros.addValue("ActualizadoPor", estacion.getActualizadoPor());
			listaParametros.addValue("IpActualizacion", estacion.getIpActualizacion());
			listaParametros.addValue("Id", estacion.getId());
			
			SqlParameterSource namedParameters = listaParametros;
			/*Ejecuta la consulta y retorna las filas afectadas*/
			cantidadFilasAfectadas= namedJdbcTemplate.update(consultaSQL.toString(),namedParameters);		
			if (cantidadFilasAfectadas>1){
				respuesta.error= Constante.EXCEPCION_CANTIDAD_REGISTROS_INCORRECTA;
				respuesta.estado=false;
				return respuesta;
			}
			respuesta.estado=true;
		} catch (DataIntegrityViolationException excepcionIntegridadDatos){
			excepcionIntegridadDatos.printStackTrace();
			respuesta.error= Constante.EXCEPCION_INTEGRIDAD_DATOS;
			respuesta.estado=false;
		} catch (DataAccessException excepcionAccesoDatos){
			excepcionAccesoDatos.printStackTrace();
			respuesta.error= Constante.EXCEPCION_ACCESO_DATOS;
			respuesta.estado=false;
		}
		return respuesta;
	}
	
	public RespuestaCompuesta eliminarRegistro(int idRegistro){		
		RespuestaCompuesta respuesta = new RespuestaCompuesta();
		int cantidadFilasAfectadas=0;	
		String consultaSQL="";
		Object[] parametros = {idRegistro};
		try {
			consultaSQL="DELETE FROM " + NOMBRE_TABLA + " WHERE " + NOMBRE_CAMPO_CLAVE + "=?";
        	cantidadFilasAfectadas = jdbcTemplate.update(consultaSQL, parametros);
			if (cantidadFilasAfectadas > 1){
				respuesta.error= Constante.EXCEPCION_CANTIDAD_REGISTROS_INCORRECTA;
				respuesta.estado=false;
				return respuesta;
			}
			respuesta.estado=true;
		} catch (DataIntegrityViolationException excepcionIntegridadDatos){	
			excepcionIntegridadDatos.printStackTrace();
			respuesta.error= Constante.EXCEPCION_INTEGRIDAD_DATOS;
			respuesta.estado=false;
		} catch (DataAccessException excepcionAccesoDatos){
			excepcionAccesoDatos.printStackTrace();
			respuesta.error= Constante.EXCEPCION_ACCESO_DATOS;
			respuesta.estado=false;
		}
		return respuesta;
	}
	
	public RespuestaCompuesta ActualizarEstadoRegistro(Cisterna cisterna){
		RespuestaCompuesta respuesta = new RespuestaCompuesta();
		StringBuilder consultaSQL= new StringBuilder();
		int cantidadFilasAfectadas=0;
		try {
			
			consultaSQL.append("UPDATE ");
			consultaSQL.append(NOMBRE_TABLA);
			consultaSQL.append(" SET ");
			consultaSQL.append("estado=:Estado,");		 
			consultaSQL.append("actualizado_por=:ActualizadoPor,");
			consultaSQL.append("actualizado_el=:ActualizadoEl,");
			consultaSQL.append("ip_actualizacion=:IpActualizacion");
			consultaSQL.append(" WHERE ");
			consultaSQL.append(NOMBRE_CAMPO_CLAVE);
			consultaSQL.append("=:Id");
			MapSqlParameterSource listaParametros= new MapSqlParameterSource();
			listaParametros.addValue("Estado", cisterna.getEstado());
			//Valores Auditoria
			listaParametros.addValue("ActualizadoEl", cisterna.getActualizadoEl());
			listaParametros.addValue("ActualizadoPor", cisterna.getActualizadoPor());
			listaParametros.addValue("IpActualizacion", cisterna.getIpActualizacion());
			listaParametros.addValue("Id", cisterna.getId());
			SqlParameterSource namedParameters= listaParametros;
			/*Ejecuta la consulta y retorna las filas afectadas*/
			cantidadFilasAfectadas= namedJdbcTemplate.update(consultaSQL.toString(),namedParameters);		
			if (cantidadFilasAfectadas>1){
				respuesta.error= Constante.EXCEPCION_CANTIDAD_REGISTROS_INCORRECTA;
				respuesta.estado=false;
				return respuesta;
			}
			respuesta.estado=true;
		} catch (DataIntegrityViolationException excepcionIntegridadDatos){
			excepcionIntegridadDatos.printStackTrace();
			respuesta.error= Constante.EXCEPCION_INTEGRIDAD_DATOS;
			respuesta.estado=false;
		} catch (DataAccessException excepcionAccesoDatos){
			excepcionAccesoDatos.printStackTrace();
			respuesta.error= Constante.EXCEPCION_ACCESO_DATOS;
			respuesta.estado=false;
		}
		return respuesta;
	}
	
	public RespuestaCompuesta ActualizarEstadoRegistro(Estacion estacion){
		RespuestaCompuesta respuesta = new RespuestaCompuesta();
		StringBuilder consultaSQL= new StringBuilder();
		int cantidadFilasAfectadas=0;
		try {
			
			consultaSQL.append("UPDATE ");
			consultaSQL.append(NOMBRE_TABLA);
			consultaSQL.append(" SET ");
			consultaSQL.append("estado=:Estado,");		 
			consultaSQL.append("actualizado_por=:ActualizadoPor,");
			consultaSQL.append("actualizado_el=:ActualizadoEl,");
			consultaSQL.append("ip_actualizacion=:IpActualizacion");
			consultaSQL.append(" WHERE ");
			consultaSQL.append(NOMBRE_CAMPO_CLAVE);
			consultaSQL.append("=:Id");
			MapSqlParameterSource listaParametros= new MapSqlParameterSource();
			listaParametros.addValue("Estado", estacion.getEstado());

			//Valores Auditoria
			listaParametros.addValue("ActualizadoEl", estacion.getActualizadoEl());
			listaParametros.addValue("ActualizadoPor", estacion.getActualizadoPor());
			listaParametros.addValue("IpActualizacion", estacion.getIpActualizacion());
			listaParametros.addValue("Id", estacion.getId());
			SqlParameterSource namedParameters= listaParametros;
			/*Ejecuta la consulta y retorna las filas afectadas*/
			cantidadFilasAfectadas= namedJdbcTemplate.update(consultaSQL.toString(),namedParameters);		
			if (cantidadFilasAfectadas>1){
				respuesta.error= Constante.EXCEPCION_CANTIDAD_REGISTROS_INCORRECTA;
				respuesta.estado=false;
				return respuesta;
			}
			respuesta.estado=true;
		} catch (DataIntegrityViolationException excepcionIntegridadDatos){
			excepcionIntegridadDatos.printStackTrace();
			respuesta.error= Constante.EXCEPCION_INTEGRIDAD_DATOS;
			respuesta.estado=false;
		} catch (DataAccessException excepcionAccesoDatos){
			excepcionAccesoDatos.printStackTrace();
			respuesta.error= Constante.EXCEPCION_ACCESO_DATOS;
			respuesta.estado=false;
		}
		return respuesta;
	}
	
	public RespuestaCompuesta recuperarEstaciones(ParametrosListar parameter) {

		int totalRegistros = 0, 
		totalEncontrados = 0;
		RespuestaCompuesta respuesta = new RespuestaCompuesta();
		Contenido<Estacion> contenido = new Contenido<Estacion>();
		List<Estacion> listaRegistros = new ArrayList<Estacion>();
		List<Object> parametros = new ArrayList<Object>();
		
		try {
			
			StringBuilder sql = new StringBuilder();
			sql.setLength(0);
			sql.append(" SELECT * FROM sgo.estacion ");
			sql.append(" WHERE id_operacion = " + parameter.getFiltroOperacion());
			sql.append(" AND estado = 1 "); 
			sql.append(" AND id_estacion NOT IN ( ");
			sql.append(" SELECT DISTINCT es.id_estacion ");
			sql.append(" FROM sgo.estacion es, sgo.jornada jo ");
			sql.append(" WHERE es.id_estacion = jo.id_estacion and ");
			sql.append(" jo.fecha_operativa = '" + parameter.getFiltroFechaJornada() + "' ");
			sql.append(" ); ");
			
			listaRegistros = jdbcTemplate.query(sql.toString(), parametros.toArray(), new EstacionMapper2());
			contenido.carga = listaRegistros;
			respuesta.estado = true;
			respuesta.contenido = contenido;
			respuesta.contenido.totalRegistros = totalRegistros;
			respuesta.contenido.totalEncontrados = totalEncontrados;
		} catch (DataAccessException e) {
			e.printStackTrace();
			respuesta.error=  Constante.EXCEPCION_ACCESO_DATOS;
			respuesta.estado = false;
			respuesta.contenido = null;
		} catch (Exception e) {
			e.printStackTrace();
			respuesta.error = Constante.EXCEPCION_GENERICA;
			respuesta.contenido = null;
			respuesta.estado = false;
		}
		
		return respuesta;
	}
}