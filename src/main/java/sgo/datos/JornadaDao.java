package sgo.datos;

import java.sql.Date;
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

import sgo.entidad.Estacion;
import sgo.entidad.Jornada;
import sgo.entidad.Contenido;
import sgo.entidad.ParametrosListar;
import sgo.entidad.Respuesta;
import sgo.entidad.RespuestaCompuesta;
import sgo.utilidades.Constante;

@Repository
public class JornadaDao {
	private JdbcTemplate jdbcTemplate;
	private NamedParameterJdbcTemplate namedJdbcTemplate;
	public static final String NOMBRE_TABLA = Constante.ESQUEMA_APLICACION + "jornada";
	public static final String NOMBRE_VISTA = Constante.ESQUEMA_APLICACION + "v_jornada";
	public final static String NOMBRE_CAMPO_CLAVE = "id_jornada";
	public final static String NOMBRE_CAMPO_FILTRO = "fecha_operativa";
	public final static String NOMBRE_CAMPO_ORDENAMIENTO_DEFECTO = "fecha_operativa";
	
	public final static String NOMBRE_CAMPO_FILTRO_ESTADO = "estado";
	public final static String O = "OR";
	public final static String Y = "AND";
	public final static String ENTRE = "BETWEEN";
	public final static String FECHA_OPERATIVA = "fecha_operativa";
	
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
			if (propiedad.equals("fechaOperativa")){
				campoOrdenamiento="fecha_operativa";
			}
			if (propiedad.equals("estado")){
				campoOrdenamiento="estado";
			}
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
		Contenido<Jornada> contenido = new Contenido<Jornada>();
		List<Jornada> listaRegistros = new ArrayList<Jornada>();
		List<Object> parametros = new ArrayList<Object>();
		
		try {
			
			if (argumentosListar.getPaginacion() == Constante.CON_PAGINACION) {
				sqlLimit = Constante.SQL_LIMIT_CONFIGURADO;
				parametros.add(argumentosListar.getInicioPaginacion());
				parametros.add(argumentosListar.getRegistrosxPagina());
			}
			
			sqlOrderBy = Constante.SQL_ORDEN + FECHA_OPERATIVA + " desc ";
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
				filtrosWhere.add(" t1."+NOMBRE_CAMPO_FILTRO_ESTADO + "=" + argumentosListar.getFiltroEstado() + " "); 
			}
			
			if (argumentosListar.getFiltroEstados() != null) {
			    String estadoCadena = "";

			    for (int e:argumentosListar.getFiltroEstados()) {
			        estadoCadena = estadoCadena + String.valueOf(e) + ",";
			    }

			    if(estadoCadena.length() > 0) estadoCadena=estadoCadena.substring(0, estadoCadena.length() - 1);
			    filtrosWhere.add(" t1.estado in(" + estadoCadena +")");
			}
			
			if(!argumentosListar.getFiltroFechaJornada().isEmpty()){ 
				filtrosWhere.add(" t1."+ FECHA_OPERATIVA + " ='" + argumentosListar.getFiltroFechaJornada() + "' ");
			}
			
			if(argumentosListar.getFiltroOperacion() != Constante.FILTRO_TODOS){
				filtrosWhere.add(" t1.id_operacion = " + argumentosListar.getFiltroOperacion() + " ");
			}
			
			if(argumentosListar.getFiltroEstacion() != Constante.FILTRO_TODOS){
				filtrosWhere.add(" t1.id_estacion = " + argumentosListar.getFiltroEstacion() + " ");
			}

			// Esto es para un rango de fechas
			if (!argumentosListar.getFiltroFechaInicio().isEmpty() && !argumentosListar.getFiltroFechaFinal().isEmpty()) {
				filtrosWhere.add(" t1." + FECHA_OPERATIVA + Constante.SQL_ENTRE + ("'" + argumentosListar.getFiltroFechaInicio() + "'" + Constante.SQL_Y + "'" + argumentosListar.getFiltroFechaFinal() + "'"));
			} else {
				if (!argumentosListar.getFiltroFechaInicio().isEmpty()) {
				filtrosWhere.add(" t1." + FECHA_OPERATIVA + " >= '" + argumentosListar.getFiltroFechaInicio() + "'");
				}
				if (!argumentosListar.getFiltroFechaFinal().isEmpty()) {
				filtrosWhere.add(" t1." + FECHA_OPERATIVA + " <= '" + argumentosListar.getFiltroFechaFinal() + "'");
				}
			}

			if(!filtrosWhere.isEmpty()){
				consultaSQL.setLength(0);
				sqlWhere = "WHERE " + StringUtils.join(filtrosWhere, Y);
				consultaSQL.append("SELECT count(t1." + NOMBRE_CAMPO_CLAVE+ ") as total FROM " + NOMBRE_VISTA + " t1 " + sqlWhere);
				totalEncontrados = jdbcTemplate.queryForObject(consultaSQL.toString(), null, Integer.class);
			}
			
			consultaSQL.setLength(0);
			consultaSQL.append("SELECT ");
			consultaSQL.append("t1.id_jornada,");
			consultaSQL.append("t1.id_estacion,");
			consultaSQL.append("t1.estado,");
			consultaSQL.append("t1.operario1,");
			consultaSQL.append("t1.operario2,");
			consultaSQL.append("t1.comentario,");
			consultaSQL.append("t1.observacion,");
			consultaSQL.append("t1.fecha_operativa,");
			consultaSQL.append("t1.id_estacion,");
			consultaSQL.append("t1.id_operacion,");
			consultaSQL.append("t1.nombre,");
			consultaSQL.append("t1.tipo,");
			consultaSQL.append("t1.estado_estacion,");
			
//			Inicio Agregado por req 9000003068===============
			consultaSQL.append("t1.tipo_apertura_tanque,");
			consultaSQL.append("t1.numero_decimales_contometro,");
//			Fin Agregado por req 9000003068=================
			
			consultaSQL.append("t1.total_despachos,");
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
			consultaSQL.append(sqlWhere);
			consultaSQL.append(sqlOrderBy);
			consultaSQL.append(sqlLimit);
			
			listaRegistros = jdbcTemplate.query(consultaSQL.toString(), parametros.toArray(), new JornadaMapper());
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
		List<Jornada> listaRegistros = new ArrayList<Jornada>();
		Contenido<Jornada> contenido = new Contenido<Jornada>();
		RespuestaCompuesta respuesta = new RespuestaCompuesta();
		
		try {
			
			consultaSQL.append("SELECT ");
			consultaSQL.append("t1.id_jornada,");
			consultaSQL.append("t1.id_estacion,");
			consultaSQL.append("t1.estado,");
			consultaSQL.append("t1.operario1,");
			consultaSQL.append("t1.operario2,");
			consultaSQL.append("t1.comentario,");
			consultaSQL.append("t1.observacion,");
			consultaSQL.append("t1.fecha_operativa,");
			consultaSQL.append("t1.id_estacion,");
			consultaSQL.append("t1.id_operacion,");
			consultaSQL.append("t1.nombre,");
			consultaSQL.append("t1.tipo,");
			consultaSQL.append("t1.estado_estacion,");
			consultaSQL.append("t1.total_despachos,");
			consultaSQL.append("0 AS id_perfil_horario,");
			consultaSQL.append("0 AS nombre_perfil,");
			//consultaSQL.append("0 AS horaInicioFinTurno,");

			//Campos de auditoria
			consultaSQL.append("t1.creado_el,");
			consultaSQL.append("t1.creado_por,");
			consultaSQL.append("t1.actualizado_por,");
			consultaSQL.append("t1.actualizado_el,");	
			consultaSQL.append("t1.usuario_creacion,");
			consultaSQL.append("t1.usuario_actualizacion,");
			consultaSQL.append("t1.ip_creacion,");
			
//			Inicio Agregado por req 9000003068===============
			consultaSQL.append("t1.tipo_apertura_tanque,");
			consultaSQL.append("t1.numero_decimales_contometro,");
//			Fin Agregado por req 9000003068=================
			
			consultaSQL.append("t1.ip_actualizacion");
			consultaSQL.append(" FROM ");				
			consultaSQL.append(NOMBRE_VISTA);
			consultaSQL.append(" t1 ");
			consultaSQL.append(" WHERE ");
			consultaSQL.append(NOMBRE_CAMPO_CLAVE);
			consultaSQL.append("=?");
			
			listaRegistros= jdbcTemplate.query(consultaSQL.toString(),new Object[] {ID},new JornadaMapper());
			contenido.totalRegistros=listaRegistros.size();
			contenido.totalEncontrados=listaRegistros.size();
			contenido.carga= listaRegistros;
			respuesta.mensaje="OK";
			respuesta.estado=true;
			respuesta.contenido = contenido;			
		} catch (DataAccessException excepcionAccesoDatos) {
			excepcionAccesoDatos.printStackTrace();
			respuesta.error = Constante.EXCEPCION_ACCESO_DATOS;
			respuesta.estado=false;
			respuesta.contenido=null;
		}
		return respuesta;
	}

	//TODO
	public Respuesta recuperarUltimaJornada(ParametrosListar argumentosListar) {
	  Date ultimoDia = null;
	  Respuesta respuesta = new Respuesta();
	  List<String> filtrosWhere= new ArrayList<String>();
	  String sqlWhere="";
      List<Object> parametros = new ArrayList<Object>();

	  try {
	   StringBuilder consultaSQL = new StringBuilder();
	   
	   if (!argumentosListar.getTxtFiltro().isEmpty()){
			filtrosWhere.add(argumentosListar.getTxtFiltro());
		}

	   if (argumentosListar.getFiltroEstacion() != Constante.FILTRO_TODOS){
		   filtrosWhere.add(" t1.id_estacion = " + argumentosListar.getFiltroEstacion() +" ");
		}
		if (argumentosListar.getIdOperacion()  != Constante.FILTRO_TODOS){
			filtrosWhere.add(" t2.id_operacion = " + argumentosListar.getIdOperacion() +" ");
		}
		if(argumentosListar.getFiltroEstado() != Constante.FILTRO_TODOS){
			filtrosWhere.add(" t1.estado = " + argumentosListar.getFiltroEstado() +" ");
		}

		if(!filtrosWhere.isEmpty()){
			consultaSQL.setLength(0);
			sqlWhere = " WHERE " + StringUtils.join(filtrosWhere, Y);
		}

	   consultaSQL.append("select max(t1.fecha_operativa) as fecha");
	   consultaSQL.append(" FROM sgo.v_jornada t1 ");
	   consultaSQL.append(" join sgo.estacion t2 on t1.id_estacion = t2.id_estacion ");
	   consultaSQL.append(sqlWhere);
	   ultimoDia = jdbcTemplate.queryForObject(consultaSQL.toString(),parametros.toArray(), Date.class);
	   //ultimoDia = jdbcTemplate.queryForObject(consultaSQL.toString(), new Object[] { idOperacion, estado }, Date.class);
	   if (ultimoDia == null) {
	    respuesta.estado = true;
	    respuesta.valor = null;
	   } else {
	    respuesta.estado = true;
	    respuesta.valor = ultimoDia.toString();
	   }
	  } catch (DataAccessException excepcionAccesoDatos) {
	   excepcionAccesoDatos.printStackTrace();
	   respuesta.error = Constante.EXCEPCION_ACCESO_DATOS;
	   respuesta.estado = false;
	  } catch (Exception excepcionGenerica) {
	   excepcionGenerica.printStackTrace();
	   respuesta.error = Constante.EXCEPCION_GENERICA;
	   respuesta.estado = false;
	  }
	  return respuesta;
	 }
	
	public Respuesta recuperarUltimaJornadaEstado(ParametrosListar argumentosListar) {
		  Date ultimoDia = null;
		  Respuesta respuesta = new Respuesta();
		  List<String> filtrosWhere= new ArrayList<String>();
		  String sqlWhere="";
	      List<Object> parametros = new ArrayList<Object>();

		  try {
		   StringBuilder consultaSQL = new StringBuilder();
		   
		   if (argumentosListar.getFiltroEstacion() != Constante.FILTRO_TODOS){
			   filtrosWhere.add(" t1.id_estacion = " + argumentosListar.getFiltroEstacion() +" ");
			}
			if (argumentosListar.getIdOperacion()  != Constante.FILTRO_TODOS){
				filtrosWhere.add(" t2.id_operacion = " + argumentosListar.getIdOperacion() +" ");
			}
			if(argumentosListar.getFiltroEstados() != null){
				String estadoCadena="";
				for(int e:argumentosListar.getFiltroEstados()){
					estadoCadena=estadoCadena+String.valueOf(e)+",";
				}
				if(estadoCadena.length()>0) estadoCadena=estadoCadena.substring(0, estadoCadena.length()-1);
				filtrosWhere.add(" t1.estado in(" + estadoCadena +")");
			}

			if(!filtrosWhere.isEmpty()){
				consultaSQL.setLength(0);
				sqlWhere = " WHERE " + StringUtils.join(filtrosWhere, Y);
			}

		   consultaSQL.append("select max(t1.fecha_operativa) as fecha");
		   consultaSQL.append(" FROM sgo.jornada t1 ");
		   consultaSQL.append(" join sgo.estacion t2 on t1.id_estacion = t2.id_estacion ");
		   consultaSQL.append(sqlWhere);
		   ultimoDia = jdbcTemplate.queryForObject(consultaSQL.toString(),parametros.toArray(), Date.class);
		   //ultimoDia = jdbcTemplate.queryForObject(consultaSQL.toString(), new Object[] { idOperacion, estado }, Date.class);
		   if (ultimoDia == null) {
		    respuesta.estado = true;
		    respuesta.valor = null;
		   } else {
		    respuesta.estado = true;
		    respuesta.valor = ultimoDia.toString();
		   }
		  } catch (DataAccessException excepcionAccesoDatos) {
		   excepcionAccesoDatos.printStackTrace();
		   respuesta.error = Constante.EXCEPCION_ACCESO_DATOS;
		   respuesta.estado = false;
		  } catch (Exception excepcionGenerica) {
		   excepcionGenerica.printStackTrace();
		   respuesta.error = Constante.EXCEPCION_GENERICA;
		   respuesta.estado = false;
		  }
		  return respuesta;
		 }
	public RespuestaCompuesta guardarRegistro(Jornada jornada){
		RespuestaCompuesta respuesta = new RespuestaCompuesta();
		StringBuilder consultaSQL= new StringBuilder();
		KeyHolder claveGenerada = null;
		int cantidadFilasAfectadas=0;
		try {
			consultaSQL.append("INSERT INTO ");
			consultaSQL.append(NOMBRE_TABLA);
			consultaSQL.append(" (id_estacion, operario1, operario2, comentario,observacion, fecha_operativa, estado, "
//			Inicio agregado por req 9000003068=================================================================================================
					+ "id_perfil_horario, "
//			Fin agregado por req 9000003068====================================================================================================
					+ "creado_el, creado_por, actualizado_por, actualizado_el, ip_creacion, ip_actualizacion) ");
			consultaSQL.append(" VALUES (:Estacion,:Operario1,:Operario2,:Comentario,:Observacion,:FechaOperativa,:Estado,"
//					Inicio agregado por req 9000003068=========================================================================================
					+ ":IdPerfilHorario, "
//			Fin agregado por req 9000003068====================================================================================================			
					+ ":CreadoEl,:CreadoPor,:ActualizadoPor,:ActualizadoEl,:IpCreacion,:IpActualizacion) ");
			MapSqlParameterSource listaParametros= new MapSqlParameterSource();   
			listaParametros.addValue("Estacion", jornada.getIdEstacion());
			listaParametros.addValue("Operario1", jornada.getIdOperario1());
			listaParametros.addValue("Operario2", jornada.getIdOperario2());
			listaParametros.addValue("Comentario", jornada.getComentario());
			listaParametros.addValue("Observacion", jornada.getObservacion());
			listaParametros.addValue("FechaOperativa", jornada.getFechaOperativa());
			listaParametros.addValue("Estado", jornada.getEstado());
			
//			Inicio agregado por req 9000003068=================================================================================================
			listaParametros.addValue("IdPerfilHorario", jornada.getPerfilHorario().getId());
//			Fin agregado por req 9000003068====================================================================================================
			
			listaParametros.addValue("CreadoEl", jornada.getCreadoEl());
			listaParametros.addValue("CreadoPor", jornada.getCreadoPor());
			listaParametros.addValue("ActualizadoPor", jornada.getActualizadoPor());
			listaParametros.addValue("ActualizadoEl", jornada.getActualizadoEl());
			listaParametros.addValue("IpCreacion", jornada.getIpCreacion());
			listaParametros.addValue("IpActualizacion", jornada.getIpActualizacion());
			
			SqlParameterSource namedParameters= listaParametros;
			/*Ejecuta la consulta y retorna las filas afectadas*/
			claveGenerada = new GeneratedKeyHolder();
			cantidadFilasAfectadas= namedJdbcTemplate.update(consultaSQL.toString(),namedParameters,claveGenerada,new String[] {NOMBRE_CAMPO_CLAVE});		
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
	
	public RespuestaCompuesta actualizarRegistro(Jornada jornada){
		RespuestaCompuesta respuesta = new RespuestaCompuesta();
		StringBuilder consultaSQL= new StringBuilder();
		int cantidadFilasAfectadas=0;
		try {
			consultaSQL.append("UPDATE ");
			consultaSQL.append(NOMBRE_TABLA);
			consultaSQL.append(" SET ");
			consultaSQL.append("observacion=:Observacion,");
			consultaSQL.append("estado=:Estado,");
			consultaSQL.append("actualizado_por=:ActualizadoPor,");
			consultaSQL.append("actualizado_el=:ActualizadoEl,");
			consultaSQL.append("ip_actualizacion=:IpActualizacion");
			consultaSQL.append(" WHERE ");
			consultaSQL.append(NOMBRE_CAMPO_CLAVE);
			consultaSQL.append("=:Id");
			MapSqlParameterSource listaParametros= new MapSqlParameterSource();
			listaParametros.addValue("Observacion", jornada.getObservacion());
			listaParametros.addValue("Estado", jornada.getEstado());
			listaParametros.addValue("ActualizadoPor", jornada.getActualizadoPor());
			listaParametros.addValue("ActualizadoEl", jornada.getActualizadoEl());
			listaParametros.addValue("IpActualizacion", jornada.getIpActualizacion());
			listaParametros.addValue("Id", jornada.getId());
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
	
	 public RespuestaCompuesta liquidarRegistro(Jornada jornada){
    RespuestaCompuesta respuesta = new RespuestaCompuesta();
    StringBuilder consultaSQL= new StringBuilder();
    int cantidadFilasAfectadas=0;
    try {
      consultaSQL.append("UPDATE ");
      consultaSQL.append(NOMBRE_TABLA);
      consultaSQL.append(" SET ");
      consultaSQL.append("comentario=:Comentario,");
      consultaSQL.append("estado=:Estado,");
      consultaSQL.append("actualizado_por=:ActualizadoPor,");
      consultaSQL.append("actualizado_el=:ActualizadoEl,");
      consultaSQL.append("ip_actualizacion=:IpActualizacion");
      consultaSQL.append(" WHERE ");
      consultaSQL.append(NOMBRE_CAMPO_CLAVE);
      consultaSQL.append("=:Id");
      MapSqlParameterSource listaParametros= new MapSqlParameterSource();
      listaParametros.addValue("Comentario", jornada.getComentario());
      listaParametros.addValue("Estado", jornada.getEstado());
      listaParametros.addValue("ActualizadoPor", jornada.getActualizadoPor());
      listaParametros.addValue("ActualizadoEl", jornada.getActualizadoEl());
      listaParametros.addValue("IpActualizacion", jornada.getIpActualizacion());
      listaParametros.addValue("Id", jornada.getId());
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
	
	public RespuestaCompuesta eliminarRegistro(int idRegistro) {
		
		RespuestaCompuesta respuesta = new RespuestaCompuesta();
		int cantidadFilasAfectadas = 0;	
		String consultaSQL = "";
		Object[] parametros = {idRegistro};
		
		try {
			consultaSQL="DELETE FROM " + NOMBRE_TABLA + " WHERE " + NOMBRE_CAMPO_CLAVE + "=?";
        	cantidadFilasAfectadas = jdbcTemplate.update(consultaSQL, parametros);
			if (cantidadFilasAfectadas > 1){
				respuesta.error= Constante.EXCEPCION_CANTIDAD_REGISTROS_INCORRECTA;
				respuesta.estado=false;
				return respuesta;
			}
			respuesta.estado = true;
		} catch (DataIntegrityViolationException e) {	
			e.printStackTrace();
			respuesta.error = Constante.EXCEPCION_INTEGRIDAD_DATOS;
			respuesta.estado = false;
		} catch (DataAccessException e) {
			e.printStackTrace();
			respuesta.error = Constante.EXCEPCION_ACCESO_DATOS;
			respuesta.estado = false;
		}
		
		return respuesta;
	}
	
	public RespuestaCompuesta ActualizarEstadoRegistro(Jornada jornada) {
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
			listaParametros.addValue("Estado", jornada.getEstado());
			//Valores Auditoria
			listaParametros.addValue("ActualizadoEl", jornada.getActualizadoEl());
			listaParametros.addValue("ActualizadoPor", jornada.getActualizadoPor());
			listaParametros.addValue("IpActualizacion", jornada.getIpActualizacion());
			listaParametros.addValue("Id", jornada.getId());
			SqlParameterSource namedParameters= listaParametros;
			/*Ejecuta la consulta y retorna las filas afectadas*/
			cantidadFilasAfectadas= namedJdbcTemplate.update(consultaSQL.toString(), namedParameters);		
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
	
}