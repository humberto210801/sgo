package sgo.datos;

import java.sql.Date;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

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
import sgo.entidad.Conductor;
import sgo.entidad.Contenido;
import sgo.entidad.DetalleProgramacion;
import sgo.entidad.DetalleProgramacionCorreos;
import sgo.entidad.DiaOperativo;
import sgo.entidad.Operacion;
import sgo.entidad.ParametrosListar;
import sgo.entidad.Planta;
import sgo.entidad.Producto;
import sgo.entidad.Programacion;
import sgo.entidad.Respuesta;
import sgo.entidad.RespuestaCompuesta;
import sgo.entidad.Tracto;
import sgo.entidad.Transportista;
import sgo.utilidades.Constante;
import sgo.utilidades.Utilidades;

@Repository
public class DetalleProgramacionDao {
	private JdbcTemplate jdbcTemplate;
	private NamedParameterJdbcTemplate namedJdbcTemplate;
	public static final String NOMBRE_TABLA = Constante.ESQUEMA_APLICACION + "detalle_programacion";
	public static final String NOMBRE_VISTA = Constante.ESQUEMA_APLICACION + "v_detalle_programacion";
	public static final String NOMBRE_VISTA_CORREO = Constante.ESQUEMA_APLICACION + "v_correo_programacion";
	public static final String NOMBRE_VISTA_PROG_2_TRANS = Constante.ESQUEMA_APLICACION + "v_detalle_programacion_to_transportista";
	public static final String NOMBRE_VISTA_PROG_2_PROD = Constante.ESQUEMA_APLICACION + "v_detalle_programacion_to_producto";
	public final static String NOMBRE_CAMPO_CLAVE = "id_dprogramacion";
	public final static String NOMBRE_CAMPO_CLAVE_PROGRAMACION = "id_programacion";
	public final static String NOMBRE_CAMPO_CLAVE_DIAOPERATIVO = "id_doperativo";
	/** Nombre de la clase. */
	 private static final String sNombreClase = "DetalleProgramacionDao";
	@Autowired
	public void setDataSource(DataSource dataSource) {
		this.jdbcTemplate = new JdbcTemplate(dataSource);
		this.namedJdbcTemplate = new NamedParameterJdbcTemplate(dataSource);
	}
	
	public DataSource getDataSource(){
		return this.jdbcTemplate.getDataSource();
	}
	
	public String mapearCampoOrdenamiento(String propiedad){
		String campoOrdenamiento="";
		try {
			if (propiedad.equals("id")){
				campoOrdenamiento="id_dprogramacion";
			}
			if (propiedad.equals("idProgramacion")){
				campoOrdenamiento="id_programacion";
			}
			if (propiedad.equals("idCisterna")){
				campoOrdenamiento="id_cisterna";
			}
			if (propiedad.equals("idProducto")){
				campoOrdenamiento="id_producto";
			}
			if (propiedad.equals("idConductor")){
				campoOrdenamiento="id_conductor";
			}
			if (propiedad.equals("idPlanta")){
				campoOrdenamiento="id_planta";
			}
			if (propiedad.equals("ordenCompra")){
				campoOrdenamiento="orden_compra";
			}
			if (propiedad.equals("codigoScop")){
				campoOrdenamiento="codigo_scop";
			}
			if (propiedad.equals("codigoSapPedido")){
				campoOrdenamiento="codigo_sap_pedido";
			}
			// Inicio Ticket 9000002608
			if (propiedad.equals("numeroCompartimento")){
				campoOrdenamiento = "numero_compartimento";
			}
			if (propiedad.equals("numeroCompartimento")){
				campoOrdenamiento = "numero_compartimento";
			}
			// Fin Ticket 9000002608
			//Campos de auditoria
		}catch(Exception excepcion){
			
		}
		return campoOrdenamiento;
	}

	public RespuestaCompuesta recuperarRegistros(ParametrosListar argumentosListar) {
		String sqlLimit = "";
		String sqlOrderBy="";
		List<String> filtrosWhere= new ArrayList<String>();
		String sqlWhere=""; 
		int totalRegistros = 0, 
		totalEncontrados = 0;
		RespuestaCompuesta respuesta = new RespuestaCompuesta();
		Contenido<DetalleProgramacion> contenido = new Contenido<DetalleProgramacion>();
		List<DetalleProgramacion> listaRegistros = new ArrayList<DetalleProgramacion>();
		List<Object> parametros = new ArrayList<Object>();
		try {
			if (argumentosListar.getPaginacion() == Constante.CON_PAGINACION) {
				sqlLimit = Constante.SQL_LIMIT_CONFIGURADO;
				parametros.add(argumentosListar.getInicioPaginacion());
				parametros.add(argumentosListar.getRegistrosxPagina());
			}
			
			sqlOrderBy= " ORDER BY " + this.mapearCampoOrdenamiento(argumentosListar.getCampoOrdenamiento()) + " " + argumentosListar.getSentidoOrdenamiento();
			
			StringBuilder consultaSQL = new StringBuilder();
			consultaSQL.setLength(0);
			consultaSQL.append("SELECT count(" + NOMBRE_CAMPO_CLAVE+ ") as total FROM " + NOMBRE_TABLA);
			totalRegistros = jdbcTemplate.queryForObject(consultaSQL.toString(), null, Integer.class);
			totalEncontrados=totalRegistros;

			if(argumentosListar.getFiltroOperacion() > 0){
				filtrosWhere.add(" t1.id_operacion =" + argumentosListar.getFiltroOperacion() + " ");
			}
			
			if(argumentosListar.getFiltroIdProgramacion() > 0){
				filtrosWhere.add(" t1.id_programacion =" + argumentosListar.getFiltroIdProgramacion() + " ");
			}
			
			if(argumentosListar.getFiltroProducto() > 0){
				filtrosWhere.add(" t1.id_producto =" + argumentosListar.getFiltroProducto() + " ");
			}
			
			if(!filtrosWhere.isEmpty()){
				consultaSQL.setLength(0);
				sqlWhere = " WHERE " + StringUtils.join(filtrosWhere, Constante.SQL_Y);
				
				consultaSQL.append("SELECT count(t1." + NOMBRE_CAMPO_CLAVE+ ") as total FROM " + NOMBRE_VISTA + " t1 " + sqlWhere);
				totalEncontrados = jdbcTemplate.queryForObject(consultaSQL.toString(), null, Integer.class);
			}
			
			consultaSQL.setLength(0);
			consultaSQL.append("SELECT ");
			consultaSQL.append("t1.id_dprogramacion,");
			consultaSQL.append("t1.id_programacion,");
			consultaSQL.append("t1.id_cisterna,");
			consultaSQL.append("t1.id_producto,");
			consultaSQL.append("t1.id_conductor,");
			consultaSQL.append("t1.orden_compra,");
			consultaSQL.append("t1.codigo_scop,");
			consultaSQL.append("t1.codigo_sap_pedido,");
			consultaSQL.append("t1.placa,");
			consultaSQL.append("t1.id_tracto,");
			consultaSQL.append("t1.cantidad_compartimentos,");
			consultaSQL.append("t1.tarjeta_cubicacion,");
			consultaSQL.append("t1.placa_tracto,");
			consultaSQL.append("t1.nombre_producto,");
			consultaSQL.append("t1.abreviatura,");
			consultaSQL.append("t1.brevete,");
			consultaSQL.append("t1.apellidos,");
			consultaSQL.append("t1.nombres,");
			consultaSQL.append("t1.dni,");
			consultaSQL.append("t1.id_transportista,");
			consultaSQL.append("t1.id_doperativo,");
			consultaSQL.append("t1.fecha_operativa,");
			consultaSQL.append("t1.fecha_estimada_carga,");
			consultaSQL.append("t1.ultima_jornada_liquidada,");
			consultaSQL.append("t1.id_operacion,");
			consultaSQL.append("t1.nombre_operacion,");
			consultaSQL.append("t1.id_cliente,");
			consultaSQL.append("t1.eta_origen,");
			consultaSQL.append("t1.planta_despacho_defecto,");
			consultaSQL.append("t1.descripcion_planta_despacho,");
			consultaSQL.append("t1.id_planta,");
			consultaSQL.append("t1.descripcion_planta,");
			consultaSQL.append("t1.correopara,");
			consultaSQL.append("t1.correocc,");
		    consultaSQL.append("t1.creado_el,");
		    consultaSQL.append("t1.creado_por,");
		    consultaSQL.append("t1.actualizado_por,");
		    consultaSQL.append("t1.actualizado_el,");
		    consultaSQL.append("t1.ip_creacion,");
		    consultaSQL.append("t1.ip_actualizacion,");
		    consultaSQL.append("t1.usuario_creacion,");
		    consultaSQL.append("t1.usuario_actualizacion,");
		    consultaSQL.append("t1.comentario, ");
		    
			//Agregado por req 9000002841====================
			  consultaSQL.append("t1.tc_det,");
			  consultaSQL.append("t1.fecha_inicio_vigencia_tarjeta_cubicacion,");
			  consultaSQL.append("t1.fecha_fin_vigencia_tarjeta_cubicacion,");
			//Agregado por req 9000002841====================
			  
		    // Inicio Ticket 9000002608
		    consultaSQL.append("t1.numero_compartimento, ");
		    consultaSQL.append("t1.capacidad_volumetrica ");
		    // Fin Ticket 9000002608
			consultaSQL.append(" FROM ");
			consultaSQL.append(NOMBRE_VISTA);
			consultaSQL.append(" t1 ");
			consultaSQL.append(sqlWhere);
			consultaSQL.append(sqlOrderBy);
			consultaSQL.append(sqlLimit);
			listaRegistros = jdbcTemplate.query(consultaSQL.toString(),parametros.toArray(), new DetalleProgramacionMapper());
			totalEncontrados =totalRegistros;
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
	/**
	 * Recupera detalle por el dia operativo
	 * @param idDiaOperativo
	 * @return
	 */
	public RespuestaCompuesta recuperarDetalleProgramacionPorDiaOperativo(int idDiaOperativo){
	    StringBuilder consultaSQL= new StringBuilder();   
	    List<DetalleProgramacion> listaRegistros=new ArrayList<DetalleProgramacion>();
	    Contenido<DetalleProgramacion> contenido = new Contenido<DetalleProgramacion>();
	    RespuestaCompuesta respuesta= new RespuestaCompuesta();
	    try {
	      consultaSQL.setLength(0);
	      consultaSQL.append("SELECT ");
		  consultaSQL.append("t1.id_dprogramacion,");
		  consultaSQL.append("t1.id_programacion,");
		  consultaSQL.append("t1.id_cisterna,");
		  consultaSQL.append("t1.id_producto,");
		  consultaSQL.append("t1.id_conductor,");
		  consultaSQL.append("t1.orden_compra,");
		  consultaSQL.append("t1.codigo_scop,");
		  consultaSQL.append("t1.codigo_sap_pedido,");
		  consultaSQL.append("t1.placa,");
		  consultaSQL.append("t1.id_tracto,");
		  consultaSQL.append("t1.cantidad_compartimentos,");
		  consultaSQL.append("t1.tarjeta_cubicacion,");
		  consultaSQL.append("t1.placa_tracto,");
		  consultaSQL.append("t1.nombre_producto,");
		  consultaSQL.append("t1.abreviatura,");
		  consultaSQL.append("t1.brevete,");
		  consultaSQL.append("t1.apellidos,");
		  consultaSQL.append("t1.nombres,");
		  consultaSQL.append("t1.dni,");
		  consultaSQL.append("t1.id_transportista,");
		  consultaSQL.append("t1.razon_social,");
		  consultaSQL.append("t1.id_doperativo,");
		  consultaSQL.append("t1.fecha_operativa,");
		  consultaSQL.append("t1.fecha_estimada_carga,");
		  consultaSQL.append("t1.ultima_jornada_liquidada,");
		  consultaSQL.append("t1.id_operacion,");
		  consultaSQL.append("t1.nombre_operacion,");
		  consultaSQL.append("t1.id_cliente,");
		  consultaSQL.append("t1.eta_origen,");
		  consultaSQL.append("t1.planta_despacho_defecto,");
		  consultaSQL.append("t1.descripcion_planta_despacho,");
		  consultaSQL.append("t1.id_planta,");
		  consultaSQL.append("t1.descripcion_planta,");
		  consultaSQL.append("t1.correopara,");
		  consultaSQL.append("t1.correocc,");
		  consultaSQL.append("t1.creado_el,");
		  consultaSQL.append("t1.creado_por,");
		  consultaSQL.append("t1.actualizado_por,");
		  consultaSQL.append("t1.actualizado_el,");
		  consultaSQL.append("t1.ip_creacion,");
		  consultaSQL.append("t1.ip_actualizacion,");
		  consultaSQL.append("t1.usuario_creacion,");
		  consultaSQL.append("t1.usuario_actualizacion,");
		  consultaSQL.append("t1.comentario, ");
		  
			//Agregado por req 9000002841====================
		  consultaSQL.append("t1.tc_det,");
		  consultaSQL.append("t1.fecha_inicio_vigencia_tarjeta_cubicacion,");
		  consultaSQL.append("t1.fecha_fin_vigencia_tarjeta_cubicacion,");
			//Agregado por req 9000002841====================
		  
		  // Inicio Ticket 9000002608
		  consultaSQL.append("t1.numero_compartimento, ");
		  consultaSQL.append("t1.capacidad_volumetrica ");
		  // Fin Ticket 9000002608
		  consultaSQL.append(" FROM ");
		  consultaSQL.append(NOMBRE_VISTA);
		  consultaSQL.append(" t1 ");
	      consultaSQL.append(" WHERE ");
	      consultaSQL.append(NOMBRE_CAMPO_CLAVE_DIAOPERATIVO);
	      consultaSQL.append(" = ?");
	      // Inicio Ticket 9000002608
	      consultaSQL.append(" and id_producto <> 0 ");
	      // Fin Ticket 9000002608
	      listaRegistros= jdbcTemplate.query(consultaSQL.toString(),new Object[] {idDiaOperativo}, new DetalleProgramacionMapper());
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
	
	public RespuestaCompuesta recuperarDetalleProgramacion(int idProgramacion){
    StringBuilder consultaSQL= new StringBuilder();   
    List<DetalleProgramacion> listaRegistros=new ArrayList<DetalleProgramacion>();
    Contenido<DetalleProgramacion> contenido = new Contenido<DetalleProgramacion>();
    RespuestaCompuesta respuesta= new RespuestaCompuesta();
    try {
      consultaSQL.setLength(0);
      consultaSQL.append("SELECT ");
	  consultaSQL.append("t1.id_dprogramacion,");
	  consultaSQL.append("t1.id_programacion,");
	  consultaSQL.append("t1.id_cisterna,");
	  consultaSQL.append("t1.id_producto,");
	  consultaSQL.append("t1.id_conductor,");
	  consultaSQL.append("t1.orden_compra,");
	  consultaSQL.append("t1.codigo_scop,");
	  consultaSQL.append("t1.codigo_sap_pedido,");
	  consultaSQL.append("t1.placa,");
	  consultaSQL.append("t1.id_tracto,");
	  consultaSQL.append("t1.cantidad_compartimentos,");
	  consultaSQL.append("t1.tarjeta_cubicacion,");
	  consultaSQL.append("t1.placa_tracto,");
	  consultaSQL.append("t1.nombre_producto,");
	  consultaSQL.append("t1.abreviatura,");
	  consultaSQL.append("t1.brevete,");
	  consultaSQL.append("t1.apellidos,");
	  consultaSQL.append("t1.nombres,");
	  consultaSQL.append("t1.dni,");
	  consultaSQL.append("t1.id_transportista,");
	  consultaSQL.append("t1.razon_social,");
	  consultaSQL.append("t1.id_doperativo,");
	  consultaSQL.append("t1.fecha_operativa,");
	  consultaSQL.append("t1.fecha_estimada_carga,");
	  consultaSQL.append("t1.ultima_jornada_liquidada,");
	  consultaSQL.append("t1.id_operacion,");
	  consultaSQL.append("t1.nombre_operacion,");
	  consultaSQL.append("t1.id_cliente,");
	  consultaSQL.append("t1.eta_origen,");
	  consultaSQL.append("t1.planta_despacho_defecto,");
	  consultaSQL.append("t1.descripcion_planta_despacho,");
	  consultaSQL.append("t1.id_planta,");
	  consultaSQL.append("t1.descripcion_planta,");
	  consultaSQL.append("t1.correopara,");
	  consultaSQL.append("t1.correocc,");
	  consultaSQL.append("t1.creado_el,");
	  consultaSQL.append("t1.creado_por,");
	  consultaSQL.append("t1.actualizado_por,");
	  consultaSQL.append("t1.actualizado_el,");
	  consultaSQL.append("t1.ip_creacion,");
	  consultaSQL.append("t1.ip_actualizacion,");
	  consultaSQL.append("t1.usuario_creacion,");
	  consultaSQL.append("t1.usuario_actualizacion,");
	  consultaSQL.append("t1.comentario, ");
	  
		//Agregado por req 9000002841====================
	  consultaSQL.append("t1.tc_det,");
	  consultaSQL.append("t1.fecha_inicio_vigencia_tarjeta_cubicacion,");
	  consultaSQL.append("t1.fecha_fin_vigencia_tarjeta_cubicacion,");
		//Agregado por req 9000002841====================
	  
	  // Inicio Ticket 9000002608
	  consultaSQL.append("t1.numero_compartimento, ");
	  consultaSQL.append("t1.capacidad_volumetrica ");
	  // Fin Ticket 9000002608
	  consultaSQL.append(" FROM ");
	  consultaSQL.append(NOMBRE_VISTA);
	  consultaSQL.append(" t1 ");
      consultaSQL.append(" WHERE ");
      consultaSQL.append(NOMBRE_CAMPO_CLAVE_PROGRAMACION);
      consultaSQL.append(" = ?");
      // Ticket 9000002608
      consultaSQL.append(" order by t1.id_dprogramacion, t1.numero_compartimento ");
      // Ticket 9000002608
      listaRegistros= jdbcTemplate.query(consultaSQL.toString(),new Object[] {idProgramacion}, new DetalleProgramacionMapper());
      contenido.totalRegistros=listaRegistros.size();
      contenido.totalEncontrados=listaRegistros.size();
      contenido.carga= listaRegistros;
      respuesta.mensaje="OK";
      respuesta.estado=true;
      respuesta.contenido = contenido;      
      Utilidades.gestionaTrace(sNombreClase, "recuperarDetalleProgramacion");
    } catch (DataAccessException excepcionAccesoDatos) {
      //Utilidades.gestionaWarning(excepcionAccesoDatos, sNombreClase, "recuperarRegistros", consultaSQL.toString());
      excepcionAccesoDatos.printStackTrace();
      respuesta.error = Constante.EXCEPCION_ACCESO_DATOS;
      respuesta.estado=false;
      respuesta.contenido=null;
    }
    return respuesta;
  }
	
//-------------------------------------------------------------------------------------------------
	//7000001924	
	public RespuestaCompuesta recuperarDetalleProgramacion2Transportista(int idProgramacion){
	    StringBuilder consultaSQL= new StringBuilder();   
	    List<DetalleProgramacion> listaRegistros=new ArrayList<DetalleProgramacion>();
	    Contenido<DetalleProgramacion> contenido = new Contenido<DetalleProgramacion>();
	    RespuestaCompuesta respuesta= new RespuestaCompuesta();

		DetalleProgramacion eDetalleProgramacion = null;
	    Cisterna eCisterna = null;
		Conductor eConductor = null;
		Programacion eProgramacion = null;
		DiaOperativo eDiaOperativo = null;
		Operacion eOperacion = null;
		//Producto eProducto = null;
		//Planta ePlanta = null;
		//Tracto eTracto = null;
		//Transportista eTransportista=null;
	    
	    try {
	      consultaSQL.setLength(0);
	      consultaSQL.append("SELECT ");	      
	      consultaSQL.append("t1.id_programacion, ");
	      consultaSQL.append("t1.planta_despacho_defecto, ");
	      consultaSQL.append("t1.id_operacion, ");
	      consultaSQL.append("t1.id_cliente, ");
	      consultaSQL.append("t1.brevete, ");
	      consultaSQL.append("t1.codigo_scop, ");
	      consultaSQL.append("t1.id_tracto, ");
	      consultaSQL.append("t1.tarjeta_cubicacion, ");
	      consultaSQL.append("t1.id_transportista, ");
	      consultaSQL.append("t1.id_conductor, ");
	      consultaSQL.append("t1.id_cisterna, ");
	      consultaSQL.append("t1.fecha_estimada_carga, ");
	      consultaSQL.append("t1.id_doperativo ");
	      
	      //Agregado por req 9000002608 para programacion============
	      consultaSQL.append(", t1.numero_compartimento");
	      consultaSQL.append(", capacidad_volumetrica");
	      consultaSQL.append(", id_producto");
	      //=========================================================
	      
		  consultaSQL.append(" FROM ");
		  consultaSQL.append(NOMBRE_VISTA_PROG_2_TRANS);
		  consultaSQL.append(" t1 ");
	      consultaSQL.append(" WHERE ");
	      consultaSQL.append(NOMBRE_CAMPO_CLAVE_PROGRAMACION);
	      consultaSQL.append(" = ?");
	      
	    //Agregado por req 9000002608 para programacion============
	      consultaSQL.append(" ORDER BY id_dProgramacion");
	    //=========================================================
	      List<Map<String,Object>> mapRegistros= jdbcTemplate.queryForList(consultaSQL.toString(),new Object[] {idProgramacion});
	      for (Map<String, Object> map : mapRegistros) {
	    	  eDetalleProgramacion = new DetalleProgramacion();
	    	  eProgramacion = new Programacion();
	    	  eDiaOperativo = new DiaOperativo();
	    	  eOperacion = new Operacion();
	    	  eCisterna = new Cisterna();
	    	  eConductor = new Conductor();
	    	  eDiaOperativo.setOperacion(eOperacion);
	    	  eProgramacion.setDiaOperativo(eDiaOperativo);
	    	  eDetalleProgramacion.setCisterna(eCisterna);
	    	  eDetalleProgramacion.setConductor(eConductor);
	    	  eDetalleProgramacion.setProgramacion(eProgramacion);

	    	  eDetalleProgramacion.setIdProgramacion((Integer)map.get("id_programacion"));eProgramacion.setId(eDetalleProgramacion.getIdProgramacion());
	    	  eOperacion.setIdPlantaDespacho((Integer) map.get("planta_despacho_defecto"));
	    	  eDiaOperativo.setIdOperacion((Integer)map.get("id_operacion") );
	    	  eOperacion.setIdCliente( (Integer) map.get("id_cliente") );
	    	  eConductor.setBrevete((String) map.get("brevete"));
	    	  eDetalleProgramacion.setCodigoScop((String)map.get("codigo_scop"));
	    	  eCisterna.setIdTracto((Integer)map.get("id_tracto") );
	    	  eCisterna.setTarjetaCubicacion((String)map.get("tarjeta_cubicacion") );
	    	  eProgramacion.setIdTransportista((Integer)map.get("id_transportista") );
	    	  eDetalleProgramacion.setIdConductor((Integer)map.get("id_conductor") );eConductor.setId(eDetalleProgramacion.getIdConductor());
	    	  eDetalleProgramacion.setIdCisterna((Integer) map.get("id_cisterna") );eCisterna.setId(eDetalleProgramacion.getIdCisterna());
	    	  eDiaOperativo.setFechaEstimadaCarga((Date) map.get("fecha_estimada_carga") );
	    	  eDiaOperativo.setId((Integer)map.get("id_doperativo") );
	    	  
	    	//Agregado por req 9000002608 para Programacion=============================
	    	  eDetalleProgramacion.setNumeroCompartimiento((Integer)map.get("numero_compartimento"));
	    	  eDetalleProgramacion.setCapacidadVolumetrica((Integer)map.get("capacidad_volumetrica"));
	    	  eDetalleProgramacion.setIdProducto((Integer)map.get("id_producto"));
	    	 //=========================================================================

	    	  listaRegistros.add(eDetalleProgramacion);
		  }
	      contenido.totalRegistros=listaRegistros.size();
	      contenido.totalEncontrados=listaRegistros.size();
	      contenido.carga= listaRegistros;
	      respuesta.mensaje="OK";
	      respuesta.estado=true;
	      respuesta.contenido = contenido;      
	      Utilidades.gestionaTrace(sNombreClase, "recuperarDetalleProgramacion2Transportista");
	      System.out.println("clonarProgTrans: DetalleTransporteDao: recuperarDetalleProgramacion2Transportista: listaMaestros.getIdDiaOperativo() " + consultaSQL.toString());
	    } catch (DataAccessException excepcionAccesoDatos) {
	      //Utilidades.gestionaWarning(excepcionAccesoDatos, sNombreClase, "recuperarRegistros", consultaSQL.toString());
	      excepcionAccesoDatos.printStackTrace();
	      respuesta.error = Constante.EXCEPCION_ACCESO_DATOS;
	      respuesta.estado=false;
	      respuesta.contenido=null;
	    }
	    return respuesta;
	  }

	//7000001924	
	public RespuestaCompuesta recuperarDetalleProgramacionProducto(int idProgramacion,int idCisterna){
	    StringBuilder consultaSQL= new StringBuilder(); 
	    
		  //Agregado por req 9000002608 para Programacion=============================
	    List<DetalleProgramacion> listaRegistros=new ArrayList<DetalleProgramacion>();
	  //==========================================================================
	    
	  //Comentado por req 9000002608 para Programacion=============================
//	    List<Producto> listaRegistros=new ArrayList<Producto>();
	  //==========================================================================

	    //Agregado por req 9000002608 para Programacion=============================
	    Contenido<DetalleProgramacion> contenido = new Contenido<DetalleProgramacion>();
	  //==========================================================================
	    
	    //Comentado por req 9000002608 para Programacion=============================
//	    Contenido<Producto> contenido = new Contenido<Producto>();
	  //==========================================================================
	    
	    RespuestaCompuesta respuesta= new RespuestaCompuesta();
	    
	  //Agregado por req 9000002608 para Programacion=============================
	    DetalleProgramacion eDetalleProgramacion = null;
	  //==========================================================================
	    
	  //Comentado por req 9000002608 para Programacion=============================
//	    Producto producto = null;
	  //==========================================================================
	    try {
	      consultaSQL.setLength(0);
	      consultaSQL.append(" SELECT ");
		  consultaSQL.append(" t1.id_producto ");
		  
	      //Agregado por req 9000002608 para Programacion=============================
	      consultaSQL.append(",t1.numero_compartimento, t1.capacidad_volumetrica");
	      //==========================================================================
	      
		  consultaSQL.append(" FROM ");
		  consultaSQL.append(NOMBRE_VISTA_PROG_2_PROD);
		  consultaSQL.append(" t1 ");
	      consultaSQL.append(" WHERE ");
	      consultaSQL.append(" id_programacion= ? ");
	      consultaSQL.append(" and id_cisterna = ?");
	      List<Map<String, Object>> mapRegistros = jdbcTemplate.queryForList(consultaSQL.toString(), new Object[] {idProgramacion,idCisterna});
	      for (Map<String, Object> map : mapRegistros) {
//	    	  producto = new Producto();
//	    	  producto.setId((Integer) map.get("id_producto"));
//	    	  listaRegistros.add(producto);
	    	  
		      //Agregado por req 9000002608 para Programacion=============================
	    	  eDetalleProgramacion = new DetalleProgramacion();
	    	  eDetalleProgramacion.setIdProducto((Integer) map.get("id_producto"));
	    	  eDetalleProgramacion.setNumeroCompartimiento((Integer)map.get("numero_compartimento"));
	    	  eDetalleProgramacion.setCapacidadVolumetrica((Integer)map.get("capacidad_volumetrica"));
	    	  listaRegistros.add(eDetalleProgramacion);
	    	 //=========================================================================
	    	  
		  }
	      contenido.totalRegistros=listaRegistros.size();
	      contenido.totalEncontrados=listaRegistros.size();
	      contenido.carga= listaRegistros;
	      respuesta.mensaje="OK";
	      respuesta.estado=true;
	      respuesta.contenido = contenido;      
	      Utilidades.gestionaTrace(sNombreClase, "recuperarDetalleProgramacionProducto");
	    } catch (DataAccessException excepcionAccesoDatos) {
	      excepcionAccesoDatos.printStackTrace();
	      respuesta.error = Constante.EXCEPCION_ACCESO_DATOS;
	      respuesta.estado=false;
	      respuesta.contenido=null;
	    }
	    return respuesta;
	  }

//-------------------------------------------------------------------------------------------------
	/**
     * Metodo para recuperar el detalle de transporte por su identificador.
     * @param diasOperativos      Identificador del transporte.
     * @return respuesta		  Resgitro Transporte.
     */
	public RespuestaCompuesta recuperarRegistro(int ID){
		StringBuilder consultaSQL= new StringBuilder();		
		List<DetalleProgramacion> listaRegistros=new ArrayList<DetalleProgramacion>();
		Contenido<DetalleProgramacion> contenido = new Contenido<DetalleProgramacion>();
		RespuestaCompuesta respuesta= new RespuestaCompuesta();
		try {
			consultaSQL.append("SELECT ");
			consultaSQL.append("t1.id_dprogramacion,");
			consultaSQL.append("t1.id_programacion,");
			consultaSQL.append("t1.id_cisterna,");
			consultaSQL.append("t1.id_producto,");
			consultaSQL.append("t1.id_conductor,");
			consultaSQL.append("t1.orden_compra,");
			consultaSQL.append("t1.codigo_scop,");
			consultaSQL.append("t1.codigo_sap_pedido,");
			consultaSQL.append("t1.placa,");
			consultaSQL.append("t1.id_tracto,");
			consultaSQL.append("t1.cantidad_compartimentos,");
			consultaSQL.append("t1.tarjeta_cubicacion,");
			consultaSQL.append("t1.placa_tracto,");
			consultaSQL.append("t1.nombre_producto,");
			consultaSQL.append("t1.abreviatura,");
			consultaSQL.append("t1.brevete,");
			consultaSQL.append("t1.apellidos,");
			consultaSQL.append("t1.nombres,");
			consultaSQL.append("t1.dni,");
			consultaSQL.append("t1.id_transportista,");
			consultaSQL.append("t1.id_doperativo,");
			consultaSQL.append("t1.fecha_operativa,");
			consultaSQL.append("t1.fecha_estimada_carga,");
			consultaSQL.append("t1.ultima_jornada_liquidada,");
			consultaSQL.append("t1.id_operacion,");
			consultaSQL.append("t1.nombre_operacion,");
			consultaSQL.append("t1.id_cliente,");
			consultaSQL.append("t1.eta_origen,");
			consultaSQL.append("t1.planta_despacho_defecto,");
			consultaSQL.append("t1.descripcion_planta_despacho,");
			consultaSQL.append("t1.id_planta,");
			consultaSQL.append("t1.descripcion_planta,");
			consultaSQL.append("t1.correopara,");
			consultaSQL.append("t1.correocc,");
		    consultaSQL.append("t1.creado_el,");
		    consultaSQL.append("t1.creado_por,");
		    consultaSQL.append("t1.actualizado_por,");
		    consultaSQL.append("t1.actualizado_el,");
		    consultaSQL.append("t1.ip_creacion,");
		    consultaSQL.append("t1.ip_actualizacion,");
		    consultaSQL.append("t1.usuario_creacion,");
		    consultaSQL.append("t1.usuario_actualizacion, ");
		    
			//Agregado por req 9000002841====================
			  consultaSQL.append("t1.tc_det,");
			  consultaSQL.append("t1.fecha_inicio_vigencia_tarjeta_cubicacion,");
			  consultaSQL.append("t1.fecha_fin_vigencia_tarjeta_cubicacion,");
				//Agregado por req 9000002841====================
			  
		    // Inicio Ticket 9000002608
		    consultaSQL.append("t1.numero_compartimento, ");
		    consultaSQL.append("t1.capacidad_volumetrica ");
		    // Fin Ticket 9000002608
		    consultaSQL.append(", t1.comentario ");
			consultaSQL.append(" FROM ");
			consultaSQL.append(NOMBRE_VISTA);
			consultaSQL.append(" t1 ");
			consultaSQL.append(" WHERE ");
			consultaSQL.append(NOMBRE_CAMPO_CLAVE);
			consultaSQL.append("=?");
			listaRegistros= jdbcTemplate.query(consultaSQL.toString(),new Object[] {ID},new DetalleProgramacionMapper());
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
	
	public RespuestaCompuesta guardarRegistro(DetalleProgramacion eDetalleProgramacion){
		RespuestaCompuesta respuesta = new RespuestaCompuesta();
		StringBuilder consultaSQL= new StringBuilder();
		KeyHolder claveGenerada = null;
		int cantidadFilasAfectadas=0;
		try {
			consultaSQL.append("INSERT INTO ");
			consultaSQL.append(NOMBRE_TABLA);
			//consultaSQL.append(" (id_programacion, id_cisterna, id_producto, id_conductor, orden_compra, codigo_scop, codigo_sap_pedido) ");
			//consultaSQL.append(" VALUES (:IdProgramacion, :IdCisterna, :IdProducto, :IdConductor, :OrdenCompra,  :CodigoScop, :CodigoSapPedido) ");
			consultaSQL.append(" (id_programacion, id_cisterna, id_producto, id_conductor, id_planta, orden_compra, codigo_scop, ");
			
			//Agregado por req 9000002841====================
			consultaSQL.append("tarjeta_cubicacion, fecha_inicio_vigencia_tarjeta_cubicacion, fecha_fin_vigencia_tarjeta_cubicacion, ");
			//Agregado por req 9000002841====================
			
			consultaSQL.append("codigo_sap_pedido, numero_compartimento, capacidad_volumetrica) ");
			
			consultaSQL.append(" VALUES (:IdProgramacion, :IdCisterna, :IdProducto, :IdConductor, :IdPlanta, :OrdenCompra,  :CodigoScop, ");// Inicio Atención Ticket 9000002608
			
			//Agregado por req 9000002841====================
			consultaSQL.append(":tarjetaCub, :fechaInicioVigTC, :fechaFinVigTC,");
			//Agregado por req 9000002841====================
			
			consultaSQL.append(":CodigoSapPedido, :NumeroCompartimento, :CapacidadVolumetrica) ");
			// Inicio Atención Ticket 9000002608
			MapSqlParameterSource listaParametros= new MapSqlParameterSource();   
			listaParametros.addValue("IdProgramacion", eDetalleProgramacion.getIdProgramacion());
			listaParametros.addValue("IdCisterna", eDetalleProgramacion.getIdCisterna());
			listaParametros.addValue("IdProducto", eDetalleProgramacion.getIdProducto());
			listaParametros.addValue("IdConductor", eDetalleProgramacion.getIdConductor());
			listaParametros.addValue("IdPlanta", eDetalleProgramacion.getIdPlanta());
			listaParametros.addValue("OrdenCompra", eDetalleProgramacion.getOrdenCompra());
			listaParametros.addValue("CodigoScop", eDetalleProgramacion.getCodigoScop());
			
			//Agregado por req 9000002841====================
			listaParametros.addValue("tarjetaCub", eDetalleProgramacion.getTarjetaCub());
			listaParametros.addValue("fechaInicioVigTC", eDetalleProgramacion.getFechaInicioVigTC());
			listaParametros.addValue("fechaFinVigTC", eDetalleProgramacion.getFechaFinVigTC());
			//Agregado por req 9000002841====================
			
			listaParametros.addValue("CodigoSapPedido", eDetalleProgramacion.getCodigoSapPedido());
			// Inicio Atención Ticket 9000002608
			listaParametros.addValue("NumeroCompartimento", eDetalleProgramacion.getCapacidadCisternaTotal());
			listaParametros.addValue("CapacidadVolumetrica", eDetalleProgramacion.getCapacidadVolumetrica());
			// Fin Atención Ticket 9000002608
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
	
	public RespuestaCompuesta guardarRegistroCompletar(DetalleProgramacion eDetalleProgramacion){
		RespuestaCompuesta respuesta = new RespuestaCompuesta();
		StringBuilder consultaSQL= new StringBuilder();
		KeyHolder claveGenerada = null;
		int cantidadFilasAfectadas=0;
		try {
			consultaSQL.append("INSERT INTO ");
			consultaSQL.append(NOMBRE_TABLA);
			consultaSQL.append(" (id_programacion, id_cisterna, id_producto, id_conductor, id_planta, orden_compra, codigo_scop, codigo_sap_pedido) ");
			consultaSQL.append(" VALUES (:IdProgramacion, :IdCisterna, :IdProducto, :IdConductor, :IdPlanta, :OrdenCompra,  :CodigoScop, :CodigoSapPedido) ");
			MapSqlParameterSource listaParametros= new MapSqlParameterSource();   
			listaParametros.addValue("IdProgramacion", eDetalleProgramacion.getIdProgramacion());
			listaParametros.addValue("IdCisterna", eDetalleProgramacion.getIdCisterna());
			listaParametros.addValue("IdProducto", eDetalleProgramacion.getIdProducto());
			listaParametros.addValue("IdConductor", eDetalleProgramacion.getIdConductor());
			listaParametros.addValue("IdPlanta", eDetalleProgramacion.getIdPlanta());
			listaParametros.addValue("OrdenCompra", eDetalleProgramacion.getOrdenCompra());
			listaParametros.addValue("CodigoScop", eDetalleProgramacion.getCodigoScop());
			listaParametros.addValue("CodigoSapPedido", eDetalleProgramacion.getCodigoSapPedido());
			
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
	
	public RespuestaCompuesta actualizarRegistro(DetalleProgramacion eDetalleProgramacion){
		RespuestaCompuesta respuesta = new RespuestaCompuesta();
		StringBuilder consultaSQL= new StringBuilder();
		int cantidadFilasAfectadas=0;
		try {
			consultaSQL.append("UPDATE ");
			consultaSQL.append(NOMBRE_TABLA);
			consultaSQL.append(" SET ");
			consultaSQL.append("id_programacion	=:IdProgramacion,");
			consultaSQL.append("id_cisterna		=:IdCisterna,");
			consultaSQL.append("id_producto		=:IdProducto,");
			consultaSQL.append("id_conductor	=:IdConductor,");
			//consultaSQL.append("id_planta   	=:IdPlanta,");
			consultaSQL.append("orden_compra	=:OrdenCompra,");
			consultaSQL.append("codigo_scop		=:CodigoScop,");
			consultaSQL.append("codigo_sap_pedido=:CodigoSapPedido ");
			consultaSQL.append(" WHERE ");
			consultaSQL.append(NOMBRE_CAMPO_CLAVE);
			consultaSQL.append("=:Id");
			MapSqlParameterSource listaParametros= new MapSqlParameterSource();

			listaParametros.addValue("IdProgramacion", eDetalleProgramacion.getIdProgramacion());
			listaParametros.addValue("IdCisterna", eDetalleProgramacion.getIdCisterna());
			listaParametros.addValue("IdProducto", eDetalleProgramacion.getIdProducto());
			listaParametros.addValue("IdConductor", eDetalleProgramacion.getIdConductor());
			//listaParametros.addValue("IdPlanta", eDetalleProgramacion.getIdPlanta());
			listaParametros.addValue("OrdenCompra", eDetalleProgramacion.getOrdenCompra());
			listaParametros.addValue("CodigoScop", eDetalleProgramacion.getCodigoScop());
			listaParametros.addValue("CodigoSapPedido", eDetalleProgramacion.getCodigoSapPedido());
			listaParametros.addValue("Id", eDetalleProgramacion.getId());
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
	
	public RespuestaCompuesta actualizarRegistroCompletar(DetalleProgramacion eDetalleProgramacion){
		RespuestaCompuesta respuesta = new RespuestaCompuesta();
		StringBuilder consultaSQL= new StringBuilder();
		int cantidadFilasAfectadas=0;
		try {
			consultaSQL.append("UPDATE ");
			consultaSQL.append(NOMBRE_TABLA);
			consultaSQL.append(" SET ");
			consultaSQL.append("id_programacion	=:IdProgramacion,");
			consultaSQL.append("id_cisterna		=:IdCisterna,");
			consultaSQL.append("id_producto		=:IdProducto,");
			consultaSQL.append("id_conductor	=:IdConductor,");
			consultaSQL.append("id_planta   	=:IdPlanta,");
			consultaSQL.append("orden_compra	=:OrdenCompra,");
			consultaSQL.append("codigo_scop		=:CodigoScop,");
			consultaSQL.append("codigo_sap_pedido=:CodigoSapPedido ");
			consultaSQL.append(" WHERE ");
			consultaSQL.append(NOMBRE_CAMPO_CLAVE);
			consultaSQL.append("=:Id");
			MapSqlParameterSource listaParametros= new MapSqlParameterSource();

			listaParametros.addValue("IdProgramacion", eDetalleProgramacion.getIdProgramacion());
			listaParametros.addValue("IdCisterna", eDetalleProgramacion.getIdCisterna());
			listaParametros.addValue("IdProducto", eDetalleProgramacion.getIdProducto());
			listaParametros.addValue("IdConductor", eDetalleProgramacion.getIdConductor());
			listaParametros.addValue("IdPlanta", eDetalleProgramacion.getIdPlanta());
			listaParametros.addValue("OrdenCompra", eDetalleProgramacion.getOrdenCompra());
			listaParametros.addValue("CodigoScop", eDetalleProgramacion.getCodigoScop());
			listaParametros.addValue("CodigoSapPedido", eDetalleProgramacion.getCodigoSapPedido());
			listaParametros.addValue("Id", eDetalleProgramacion.getId());
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
	//7000001924
	public RespuestaCompuesta eliminarRegistroMismoCisterna(int idRegistro){
		RespuestaCompuesta respuesta = new RespuestaCompuesta();
		RespuestaCompuesta respuesta2 = null;
		int cantidadFilasAfectadas=0;	
		String consultaSQL="";
				
		try{
			List<?> listado=null;
			respuesta2 = recuperarRegistro(idRegistro);
			listado = respuesta2.getContenido().getCarga();
			DetalleProgramacion dp= (DetalleProgramacion)listado.get(0);
			int idProgramacion = dp.getIdProgramacion();
			int idCisterna = dp.getIdCisterna();
			int idConductor = dp.getIdConductor();
			Object[] parametros = {idProgramacion,idCisterna,idConductor};
			consultaSQL=" DELETE FROM " + NOMBRE_TABLA + " WHERE id_programacion=? AND id_cisterna=? AND id_conductor=?";
			cantidadFilasAfectadas = jdbcTemplate.update(consultaSQL,parametros);
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

	// Inicio Ticket 9000002608
	public RespuestaCompuesta eliminarRegistroGrupoCisterna(Integer []  registros){
		RespuestaCompuesta respuesta = new RespuestaCompuesta();
		RespuestaCompuesta respuesta2 = null;
		int cantidadFilasAfectadas=0;	
		String consultaSQL="";
		try{
			List<?> listado=null;
			//for(Integer idRegistro: registros){
				respuesta2 = recuperarRegistro(registros[0]);
				listado = respuesta2.getContenido().getCarga();
				DetalleProgramacion dp= (DetalleProgramacion)listado.get(0);
				int idProgramacion = dp.getIdProgramacion();
				int idCisterna = dp.getIdCisterna();
				int idConductor = dp.getIdConductor();
				Object[] parametros = {idProgramacion,idCisterna,idConductor};
				consultaSQL=" DELETE FROM " + NOMBRE_TABLA + " WHERE id_programacion=? AND id_cisterna=? AND id_conductor=?";
				cantidadFilasAfectadas = jdbcTemplate.update(consultaSQL,parametros);
				respuesta.estado=true;
			//}
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
	// Fin Ticket 9000002608
	
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
	
	/**
     * Metodo para cuenta todos los detalles de un transporte.
     * @param idTransporte      Identificador del transporte.
     * @return respuesta		Número de detalles de transporte que existen de un transporte.
     */
	public Respuesta numeroRegistrosPorProgramacion(int idProgramacion){		
		Respuesta respuesta = new Respuesta();
		StringBuilder consultaSQL= new StringBuilder();	
		int cantidadRegistros = 0;

		try {
			consultaSQL=new StringBuilder();
			consultaSQL.append("SELECT ");
			consultaSQL.append(" count(*) ");
			consultaSQL.append(" FROM ");				
			consultaSQL.append(" sgo.detalle_programacion ");
			consultaSQL.append(" WHERE ");
			consultaSQL.append(" id_programacion = ");
			consultaSQL.append( idProgramacion );
			
			cantidadRegistros = jdbcTemplate.queryForInt(consultaSQL.toString());
			respuesta.valor = String.valueOf(cantidadRegistros);
			respuesta.estado = true;
			
		} catch (DataAccessException excepcionAccesoDatos) {
			excepcionAccesoDatos.printStackTrace();
		} catch (Exception excepcionGenerica) {
			excepcionGenerica.printStackTrace();
			respuesta.error= Constante.EXCEPCION_GENERICA;
			respuesta.estado = false;
		}
		
		return respuesta;
	}
	
	//recuperarcorreo
	public RespuestaCompuesta recuperarCorreoProgramacion(int idDiaOperativo){
	    StringBuilder consultaSQL= new StringBuilder();   
	    List<DetalleProgramacionCorreos> listaRegistros=new ArrayList<DetalleProgramacionCorreos>();
	    Contenido<DetalleProgramacionCorreos> contenido = new Contenido<DetalleProgramacionCorreos>();
	    RespuestaCompuesta respuesta= new RespuestaCompuesta();
	    try {
	      consultaSQL.setLength(0);
	      consultaSQL.append("SELECT ");
		  consultaSQL.append("t1.id_doperativo,");
	      consultaSQL.append("t1.id_programacion,");
	      consultaSQL.append("t1.id_dprogramacion,");
	      consultaSQL.append("t1.id_planta,");
	      consultaSQL.append("t1.descripcion_planta,");
	      consultaSQL.append("t1.correopara,");
	      consultaSQL.append("t1.correocc,");
	      consultaSQL.append("t1.comentario");
		  consultaSQL.append(" FROM ");
		  consultaSQL.append(NOMBRE_VISTA_CORREO);
		  consultaSQL.append(" t1 ");
	      consultaSQL.append(" WHERE ");
	      consultaSQL.append(NOMBRE_CAMPO_CLAVE_DIAOPERATIVO);
	      consultaSQL.append(" = ?");
	      listaRegistros= jdbcTemplate.query(consultaSQL.toString(),new Object[] {idDiaOperativo}, new DetalleProgramacionCorreoMapper());
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
}