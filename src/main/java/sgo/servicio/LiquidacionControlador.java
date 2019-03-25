package sgo.servicio;

import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.support.DefaultTransactionDefinition;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import sgo.datos.BitacoraDao;
import sgo.datos.ClienteDao;
import sgo.datos.DiaOperativoDao;
import sgo.datos.EnlaceDao;
import sgo.datos.EstacionDao;
import sgo.datos.JornadaDao;
import sgo.datos.LiquidacionDao;
import sgo.datos.OperacionDao;
import sgo.entidad.Bitacora;
import sgo.entidad.Enlace;
import sgo.entidad.Estacion;
import sgo.entidad.Jornada;
import sgo.entidad.Liquidacion;
import sgo.entidad.MenuGestor;
import sgo.entidad.Operacion;
import sgo.entidad.ParametrosListar;
import sgo.entidad.RespuestaCompuesta;
import sgo.seguridad.AuthenticatedUserDetails;
import sgo.utilidades.Constante;
import sgo.utilidades.ReporteLiquidacion;
import sgo.utilidades.Reporteador;
import sgo.utilidades.Utilidades;

@Controller
public class LiquidacionControlador {
 @Autowired
 private MessageSource gestorDiccionario;
 @Autowired
 private BitacoraDao dBitacora;
 @Autowired
 private EnlaceDao dEnlace;
 @Autowired
 private MenuGestor menu;
 @Autowired
 private ClienteDao dCliente;
 @Autowired
 private DiaOperativoDao dDiaOperativo;
 @Autowired
 private OperacionDao dOperacion;
 @Autowired
 private LiquidacionDao dLiquidacion;
 @Autowired
 private JornadaDao dJornada;
 @Autowired
 private EstacionDao dEstacion;
 @Autowired
 ServletContext servletContext;
 //
 private DataSourceTransactionManager transaccion;// Gestor de la transaccion
 
 // urls generaleson
 private static final String URL_GESTION_COMPLETA = "/admin/liquidacion";
 private static final String URL_GESTION_RELATIVA = "/liquidacion";
 private static final String URL_LIQUIDAR_JORNADA_COMPLETA = "/admin/liquidacion/liquidar-jornada";
 private static final String URL_LIQUIDAR_JORNADA_RELATIVA = "/liquidacion/liquidar-jornada";
 private static final String URL_LISTAR_COMPLETA = "/admin/liquidacion/listar";
 private static final String URL_LISTAR_RELATIVA = "/liquidacion/listar";
 private static final String URL_LISTAR_POR_ESTACION_COMPLETA = "/admin/liquidacion/listar-estacion";
 private static final String URL_LISTAR_POR_ESTACION_RELATIVA = "/liquidacion/listar-estacion";
 private static final String URL_LISTAR_POR_TANQUE_COMPLETA = "/admin/liquidacion/listar-tanque";
 private static final String URL_LISTAR_POR_TANQUE_RELATIVA = "/liquidacion/listar-tanque";
 private static final String URL_REPORTE_COMPLETA = "/admin/liquidacion/reporte";
 private static final String URL_REPORTE_RELATIVA = "/liquidacion/reporte";

 private HashMap<String, String> recuperarMapaValores(Locale locale) {
	 
  HashMap<String, String> mapaValores = new HashMap<String, String>();
  
  try {
   mapaValores.put("ESTADO_ACTIVO", String.valueOf(Constante.ESTADO_ACTIVO));
   mapaValores.put("ESTADO_INACTIVO", String.valueOf(Constante.ESTADO_INACTIVO));
   mapaValores.put("FILTRO_TODOS", String.valueOf(Constante.FILTRO_TODOS));
   mapaValores.put("TEXTO_INACTIVO", gestorDiccionario.getMessage("sgo.estadoInactivo", null, locale));
   mapaValores.put("TEXTO_ACTIVO", gestorDiccionario.getMessage("sgo.estadoActivo", null, locale));
   mapaValores.put("TEXTO_TODOS", gestorDiccionario.getMessage("sgo.filtroTodos", null, locale));
   mapaValores.put("TEXTO_BUSCAR", gestorDiccionario.getMessage("sgo.buscarElemento", null, locale));

   mapaValores.put("TITULO_AGREGAR_REGISTRO", gestorDiccionario.getMessage("sgo.tituloFormularioAgregar", null, locale));
   mapaValores.put("TITULO_MODIFICA_REGISTRO", gestorDiccionario.getMessage("sgo.tituloFormularioEditar", null, locale));
   mapaValores.put("TITULO_DETALLE_REGISTRO", gestorDiccionario.getMessage("sgo.tituloFormularioVer", null, locale));
   mapaValores.put("TITULO_LISTADO_REGISTROS", gestorDiccionario.getMessage("sgo.tituloFormularioListado", null, locale));
   
   //
   mapaValores.put("ETIQUETA_BOTON_CERRAR", gestorDiccionario.getMessage("sgo.etiquetaBotonCerrar", null, locale));
   mapaValores.put("ETIQUETA_BOTON_GUARDAR", gestorDiccionario.getMessage("sgo.etiquetaBotonGuardar", null, locale));

   mapaValores.put("ETIQUETA_BOTON_AGREGAR", gestorDiccionario.getMessage("sgo.etiquetaBotonAgregar", null, locale));
   mapaValores.put("ETIQUETA_BOTON_MODIFICAR", gestorDiccionario.getMessage("sgo.etiquetaBotonModificar", null, locale));
   mapaValores.put("ETIQUETA_BOTON_VER", gestorDiccionario.getMessage("sgo.etiquetaBotonVer", null, locale));
   mapaValores.put("ETIQUETA_BOTON_FILTRAR", gestorDiccionario.getMessage("sgo.etiquetaBotonFiltrar", null, locale));
   mapaValores.put("ETIQUETA_BOTON_ACTIVAR", gestorDiccionario.getMessage("sgo.etiquetaBotonActivar", null, locale));

   mapaValores.put("ETIQUETA_BOTON_CANCELAR", gestorDiccionario.getMessage("sgo.etiquetaBotonCancelar", null, locale));
   mapaValores.put("ETIQUETA_BOTON_CONFIRMAR", gestorDiccionario.getMessage("sgo.etiquetaBotonConfirmar", null, locale));
   mapaValores.put("MENSAJE_CAMBIAR_ESTADO", gestorDiccionario.getMessage("sgo.mensajeCambiarEstado", null, locale));

   mapaValores.put("MENSAJE_CARGANDO", gestorDiccionario.getMessage("sgo.mensajeCargando", null, locale));
   mapaValores.put("TITULO_VENTANA_MODAL", gestorDiccionario.getMessage("sgo.tituloVentanaModal", null, locale));

  } catch (Exception ex) {

  }
  
  return mapaValores;
 }

 @RequestMapping(URL_GESTION_RELATIVA)
 public ModelAndView mostrarFormulario(Locale locale) {
	 
  ModelAndView vista =null;
  AuthenticatedUserDetails principal = null;
  ArrayList<Enlace> listaEnlaces = null;
  RespuestaCompuesta respuesta = null;
  HashMap<String, String> mapaValores = null;
  ArrayList<?> listaOperaciones = null;
  ParametrosListar parametros = null;
  
  try {
	  
    principal = this.getCurrentUser();
    respuesta = menu.Generar(principal.getRol().getId(),URL_GESTION_COMPLETA);
    if (respuesta.estado==false){
      throw new Exception(gestorDiccionario.getMessage("sgo.menuNoGenerado",null,locale));
    }      
    listaEnlaces = (ArrayList<Enlace>) respuesta.contenido.carga;
    
    parametros = new ParametrosListar();
    parametros.setPaginacion(Constante.SIN_PAGINACION);
    parametros.setFiltroEstado(Constante.ESTADO_ACTIVO);
    parametros.setIdCliente(principal.getCliente().getId());
    parametros.setIdOperacion(principal.getOperacion().getId());
    respuesta = dOperacion.recuperarRegistros(parametros);
    if (respuesta.estado == false) {
     throw new Exception(gestorDiccionario.getMessage("sgo.noPermisosDisponibles", null, locale));
    }
    listaOperaciones = (ArrayList<?>) respuesta.contenido.carga;      
    mapaValores = recuperarMapaValores(locale);
    vista = new ModelAndView("plantilla");
    vista.addObject("vistaJSP", "operaciones/liquidacion.jsp");
    vista.addObject("vistaJS", "operaciones/liquidacion.js");
    vista.addObject("identidadUsuario",principal.getIdentidad());
    vista.addObject("mapaValores", mapaValores);
    vista.addObject("fechaActual", dDiaOperativo.recuperarFechaActual().valor);
    vista.addObject("operaciones", listaOperaciones);
    vista.addObject("menu",listaEnlaces);
  } catch(Exception ex){
    
  }
  return vista;
 }

@RequestMapping(value = URL_LISTAR_RELATIVA, method = RequestMethod.GET)
public @ResponseBody
RespuestaCompuesta recuperarRegistros(HttpServletRequest httpRequest, Locale locale) {

    RespuestaCompuesta respuesta = null;
    ParametrosListar parametros = null;
    AuthenticatedUserDetails principal = null;
    String mensajeRespuesta = "";

    try {

        // Recuperar el usuario actual
        principal = this.getCurrentUser();
        // Recuperar el enlace de la accion
        respuesta = dEnlace.recuperarRegistro(URL_LISTAR_COMPLETA);
        if (respuesta.estado == false) {
        	mensajeRespuesta = gestorDiccionario.getMessage("sgo.accionNoHabilitada", null, locale);
            throw new Exception(mensajeRespuesta);
        }
        
        Enlace eEnlace = (Enlace) respuesta.getContenido().getCarga().get(0);
        // Verificar si cuenta con el permiso necesario
        if (!principal.getRol().searchPermiso(eEnlace.getPermiso())) {
            mensajeRespuesta = gestorDiccionario.getMessage("sgo.faltaPermiso", null, locale);
            throw new Exception(mensajeRespuesta);
        }

        // Recuperar parametros
        parametros = new ParametrosListar();
        if (httpRequest.getParameter("paginacion") != null) {
            parametros.setPaginacion(Integer.parseInt(httpRequest.getParameter("paginacion")));
        }

        parametros.setPaginacion(Constante.SIN_PAGINACION);

        if (httpRequest.getParameter("registrosxPagina") != null) {
            parametros.setRegistrosxPagina(Integer.parseInt(httpRequest.getParameter("registrosxPagina")));
        }

        if (httpRequest.getParameter("inicioPagina") != null) {
            parametros.setInicioPaginacion(Integer.parseInt(httpRequest.getParameter("inicioPagina")));
        }

        if (httpRequest.getParameter("filtroOperacion") != null) {
            parametros.setIdOperacion(Integer.parseInt(httpRequest.getParameter("filtroOperacion")));
        }

        if (httpRequest.getParameter("filtroFechaDiaOperativo") != null) {
            parametros.setFiltroFechaDiaOperativo((httpRequest.getParameter("filtroFechaDiaOperativo")));
        }

        // Recuperar registros
        respuesta = dLiquidacion.recuperarRegistros(parametros);
        respuesta.mensaje = gestorDiccionario.getMessage("sgo.listarExitoso", null, locale);
    } catch (Exception ex) {
        ex.printStackTrace();
        respuesta.estado = false;
        respuesta.contenido = null;
        respuesta.mensaje = ex.getMessage();
    }
    return respuesta;
}
 
 
 @RequestMapping(value = URL_LISTAR_POR_ESTACION_RELATIVA, method = RequestMethod.GET)
 public @ResponseBody
 RespuestaCompuesta recuperarRegistrosxEstacion(HttpServletRequest httpRequest, Locale locale) {
  RespuestaCompuesta respuesta = null;
  ParametrosListar parametros = null;
  AuthenticatedUserDetails principal = null;
  String mensajeRespuesta = "";
  try {
   // Recuperar el usuario actual
   principal = this.getCurrentUser();
   // Recuperar el enlace de la accion
   respuesta = dEnlace.recuperarRegistro(URL_LISTAR_POR_ESTACION_COMPLETA);
   if (respuesta.estado == false) {
    mensajeRespuesta = gestorDiccionario.getMessage("sgo.accionNoHabilitada", null, locale);
    throw new Exception(mensajeRespuesta);
   }
   Enlace eEnlace = (Enlace) respuesta.getContenido().getCarga().get(0);
   // Verificar si cuenta con el permiso necesario
   if (!principal.getRol().searchPermiso(eEnlace.getPermiso())) {
    mensajeRespuesta = gestorDiccionario.getMessage("sgo.faltaPermiso", null, locale);
    throw new Exception(mensajeRespuesta);
   }
   // Recuperar parametros
   parametros = new ParametrosListar();
   if (httpRequest.getParameter("paginacion") != null) {
    parametros.setPaginacion(Integer.parseInt(httpRequest.getParameter("paginacion")));
   }
   
   parametros.setPaginacion(Constante.SIN_PAGINACION);

   if (httpRequest.getParameter("registrosxPagina") != null) {
    parametros.setRegistrosxPagina(Integer.parseInt(httpRequest.getParameter("registrosxPagina")));
   }

   if (httpRequest.getParameter("inicioPagina") != null) {
    parametros.setInicioPaginacion(Integer.parseInt(httpRequest.getParameter("inicioPagina")));
   }

  if (httpRequest.getParameter("filtroOperacion") != null) {
   parametros.setIdOperacion(Integer.parseInt(httpRequest.getParameter("filtroOperacion")));
  }

  if (httpRequest.getParameter("filtroFechaDiaOperativo") != null) {
   parametros.setFiltroFechaDiaOperativo((httpRequest.getParameter("filtroFechaDiaOperativo")));
  }
  
  if (httpRequest.getParameter("filtroProducto") != null) {
   parametros.setFiltroProducto(Integer.parseInt(httpRequest.getParameter("filtroProducto")));
  }
   // Recuperar registros
   respuesta = dLiquidacion.recuperarRegistrosxEstacion(parametros);
   respuesta.mensaje = gestorDiccionario.getMessage("sgo.listarExitoso", null, locale);
  } catch (Exception ex) {
   ex.printStackTrace();
   respuesta.estado = false;
   respuesta.contenido = null;
   respuesta.mensaje = ex.getMessage();
  }
  return respuesta;
 }
 
 @RequestMapping(value = URL_LISTAR_POR_TANQUE_RELATIVA, method = RequestMethod.GET)
 public @ResponseBody
 RespuestaCompuesta recuperarRegistrosxTanque(HttpServletRequest httpRequest, Locale locale) {
  RespuestaCompuesta respuesta = null;
  ParametrosListar parametros = null;
  AuthenticatedUserDetails principal = null;
  String mensajeRespuesta = "";
  try {
   // Recuperar el usuario actual
   principal = this.getCurrentUser();
   // Recuperar el enlace de la accion
   respuesta = dEnlace.recuperarRegistro(URL_LISTAR_POR_ESTACION_COMPLETA);
   if (respuesta.estado == false) {
    mensajeRespuesta = gestorDiccionario.getMessage("sgo.accionNoHabilitada", null, locale);
    throw new Exception(mensajeRespuesta);
   }
   Enlace eEnlace = (Enlace) respuesta.getContenido().getCarga().get(0);
   // Verificar si cuenta con el permiso necesario
   if (!principal.getRol().searchPermiso(eEnlace.getPermiso())) {
    mensajeRespuesta = gestorDiccionario.getMessage("sgo.faltaPermiso", null, locale);
    throw new Exception(mensajeRespuesta);
   }
   // Recuperar parametros
   parametros = new ParametrosListar();
   if (httpRequest.getParameter("paginacion") != null) {
    parametros.setPaginacion(Integer.parseInt(httpRequest.getParameter("paginacion")));
   }
   
   parametros.setPaginacion(Constante.SIN_PAGINACION);

   if (httpRequest.getParameter("registrosxPagina") != null) {
    parametros.setRegistrosxPagina(Integer.parseInt(httpRequest.getParameter("registrosxPagina")));
   }

   if (httpRequest.getParameter("inicioPagina") != null) {
    parametros.setInicioPaginacion(Integer.parseInt(httpRequest.getParameter("inicioPagina")));
   }

  if (httpRequest.getParameter("filtroOperacion") != null) {
   parametros.setIdOperacion(Integer.parseInt(httpRequest.getParameter("filtroOperacion")));
  }

  if (httpRequest.getParameter("filtroFechaDiaOperativo") != null) {
   parametros.setFiltroFechaDiaOperativo((httpRequest.getParameter("filtroFechaDiaOperativo")));
  }
  
  if (httpRequest.getParameter("filtroProducto") != null) {
   parametros.setFiltroProducto(Integer.parseInt(httpRequest.getParameter("filtroProducto")));
  }
  
  if (httpRequest.getParameter("filtroEstacion") != null) {
   parametros.setFiltroEstacion(Integer.parseInt(httpRequest.getParameter("filtroEstacion")));
  }
 
   // Recuperar registros
   respuesta = dLiquidacion.recuperarRegistrosxTanque(parametros);
   respuesta.mensaje = gestorDiccionario.getMessage("sgo.listarExitoso", null, locale);
  } catch (Exception ex) {
   ex.printStackTrace();
   respuesta.estado = false;
   respuesta.contenido = null;
   respuesta.mensaje = ex.getMessage();
  }
  return respuesta;
 }

 @RequestMapping(value = URL_LIQUIDAR_JORNADA_RELATIVA, method = RequestMethod.GET)
 public @ResponseBody RespuestaCompuesta liquidarJornada( HttpServletRequest peticionHttp, HttpServletResponse response, Locale locale) {

     RespuestaCompuesta respuesta = null;
     AuthenticatedUserDetails principal = null;
     TransactionDefinition definicionTransaccion = null;
     TransactionStatus estadoTransaccion = null;
     Bitacora eBitacora = null;
     String direccionIp = "";
     Jornada jornada = null;

     try {

         // Inicia la transaccion
         this.transaccion = new DataSourceTransactionManager(dCliente.getDataSource());
         definicionTransaccion = new DefaultTransactionDefinition();
         estadoTransaccion = this.transaccion.getTransaction(definicionTransaccion);
         
         eBitacora = new Bitacora();
         principal = this.getCurrentUser();
         respuesta = dEnlace.recuperarRegistro(URL_LIQUIDAR_JORNADA_COMPLETA);
         if (respuesta.estado == false) {
             throw new Exception(gestorDiccionario.getMessage("sgo.accionNoHabilitada", null, locale));
         }

         Enlace eEnlace = (Enlace) respuesta.getContenido().getCarga().get(0);
         if (!principal.getRol().searchPermiso(eEnlace.getPermiso())) {
        	 throw new Exception(gestorDiccionario.getMessage("sgo.faltaPermiso", null, locale));
         }

         direccionIp = peticionHttp.getHeader("X-FORWARDED-FOR");
         if (direccionIp == null) {
             direccionIp = peticionHttp.getRemoteAddr();
         }

         ParametrosListar parametros = new ParametrosListar();
         parametros.setPaginacion(Constante.SIN_PAGINACION);

         if (peticionHttp.getParameter("idOperacion") != null) {
             parametros.setFiltroOperacion(Utilidades.parseInt(peticionHttp.getParameter("idOperacion")));
         }

         if (peticionHttp.getParameter("fechaOperativa") != null) {
             parametros.setFiltroFechaJornada(peticionHttp.getParameter("fechaOperativa"));
         }

         respuesta = dJornada.recuperarRegistros(parametros);
         if (respuesta.estado==false) {
        	 throw new Exception(gestorDiccionario.getMessage("sgo.recuperarFallido", null, locale));
         }
         
         if (respuesta.contenido.carga.size()==0) {
             throw new Exception(gestorDiccionario.getMessage("sgo.recuperarFallido", null, locale));
         }  

         jornada = (Jornada) respuesta.contenido.carga.get(0);
         if (jornada.getEstado() == Jornada.ESTADO_LIQUIDADO) {
             throw new Exception(gestorDiccionario.getMessage("sgo.diaPreviamenteLiquidado", null, locale));
         }
     	
         if (peticionHttp.getParameter("comentario") != null) {
             jornada.setComentario(peticionHttp.getParameter("comentario"));
         }
         
         /**
          * Validacion de los estados de las jornadas
          * Todas las jornadas tienen que estar en estado CERRADO, para poder cambiar el estado a LIQUIDADO
          */
         parametros = new ParametrosListar();
         if (peticionHttp.getParameter("fechaOperativa") != null) {
             parametros.setFiltroFechaJornada(peticionHttp.getParameter("fechaOperativa"));
         }
         parametros.setFiltroEstados(new int[] {Jornada.ESTADO_ABIERTO, Jornada.ESTADO_REGISTRADO});
         respuesta = dJornada.recuperarRegistros(parametros);
         if (!respuesta.estado) {
             throw new Exception(gestorDiccionario.getMessage("sgo.recuperarFallido", null, locale));
         }

         if (respuesta.contenido.carga.size() > 0) {
        	 String estaciones = "";
        	 for (Jornada obj : (List<Jornada>) respuesta.contenido.carga) {
        		 estaciones = estaciones + obj.getEstacion().getNombre() + ", ";
        	 }
        	 
			 respuesta.mensaje = gestorDiccionario.getMessage("sgo.errorJornadasCerradas", null, locale);
			 respuesta.mensaje = respuesta.mensaje.replace("LISTA_ESTACIONES", estaciones);
			 throw new Exception(respuesta.mensaje);
         }
         /**
          * Fin validacion
          */
         
         
         /**
          * Validacion de las jornadas del dia anterior
          * todas las estaciones asociadas deben encontrarse con el estado "Liquidado" para la jornada anterior a la actual.
          */
         parametros = new ParametrosListar();
         if (peticionHttp.getParameter("fechaOperativa") != null) {
        	 String date = peticionHttp.getParameter("fechaOperativa");
        	 date = Utilidades.subtractDateDays(date, 1);
             parametros.setFiltroFechaJornada(date);
         }
         
         parametros.setFiltroOperacion(Utilidades.parseInt(peticionHttp.getParameter("idOperacion")));
         respuesta = dJornada.recuperarRegistros(parametros);
         if (!respuesta.estado) {
             throw new Exception(gestorDiccionario.getMessage("sgo.recuperarFallido", null, locale));
         }

         if (respuesta.contenido.carga.size() > 0) {
        	 for (Jornada obj : (List<Jornada>) respuesta.contenido.carga) {
        		 if (obj.getEstado() != Jornada.ESTADO_LIQUIDADO) {
        			 throw new Exception(gestorDiccionario.getMessage("sgo.errorJornadaAnterior", null, locale));
        		 }
        	 }
         }
         /**
          * Fin validacion
          */
         
         
         /**
          * Validacion de las estaciones no utilizadas por la operacion.
          * Lista las estaciones de la operacion, filtrado por las no utilizadas el dia operativo
          */
         parametros = new ParametrosListar();
         if (peticionHttp.getParameter("fechaOperativa") != null) {
             parametros.setFiltroFechaJornada(peticionHttp.getParameter("fechaOperativa"));
         }
         
         parametros.setFiltroOperacion(Utilidades.parseInt(peticionHttp.getParameter("idOperacion")));
         respuesta = dEstacion.recuperarEstaciones(parametros);
         if (!respuesta.estado) {
             throw new Exception(gestorDiccionario.getMessage("sgo.recuperarFallido", null, locale));
         }

         if (respuesta.contenido.carga.size() > 0) {
        	 
        	 String nombres = "";
        	 for (Estacion obj : (List<Estacion>) respuesta.contenido.carga) {
        		 nombres += obj.getNombre() + ",";
        	 }
        	 
        	 String mensaje = gestorDiccionario.getMessage("sgo.estacionesExistentes", null, locale);
        	 mensaje = mensaje.replaceAll("ESTACION_NAME", nombres);
        	 
        	 throw new Exception(mensaje);
         }
         /**
          * Fin validacion
          */
         
         
         /**
          * Actualizar estado a: LIQUIDADO
          */
         jornada.setEstado(Jornada.ESTADO_LIQUIDADO);
         respuesta = dJornada.liquidarRegistro(jornada);
         if (!respuesta.estado) {
             throw new Exception(gestorDiccionario.getMessage("sgo.actualizarFallido", null, locale));
         }

         respuesta.estado = true;
         respuesta.mensaje = gestorDiccionario.getMessage("sgo.liquidacionDiaExitosa", null, locale);
         this.transaccion.commit(estadoTransaccion);

     } catch (Exception e) {
         e.printStackTrace();
         this.transaccion.rollback(estadoTransaccion);
         respuesta.estado = false;
         respuesta.contenido = null;
         respuesta.mensaje = e.getMessage();
     }

     return respuesta;
 }

 @RequestMapping(value = URL_REPORTE_RELATIVA, method = RequestMethod.GET)
 public void mostrarReporteGec(HttpServletRequest httpRequest, HttpServletResponse response, Locale locale) {
  RespuestaCompuesta respuesta = null;
  ParametrosListar parametros = null;
  AuthenticatedUserDetails principal = null;
  String mensajeRespuesta = "";
  String tituloReporte ="";
  String formatoReporte="pdf";
  try {
   // Recuperar el usuario actual
   principal = this.getCurrentUser();
   // Recuperar el enlace de la accion
   respuesta = dEnlace.recuperarRegistro(URL_REPORTE_COMPLETA  );
   if (respuesta.estado == false) {
    mensajeRespuesta = gestorDiccionario.getMessage("sgo.accionNoHabilitada", null, locale);
    throw new Exception(mensajeRespuesta);
   }
   Enlace eEnlace = (Enlace) respuesta.getContenido().getCarga().get(0);
   // Verificar si cuenta con el permiso necesario
   if (!principal.getRol().searchPermiso(eEnlace.getPermiso())) {
    mensajeRespuesta = gestorDiccionario.getMessage("sgo.faltaPermiso", null, locale);
    throw new Exception(mensajeRespuesta);
   }
   // Recuperar parametros
   parametros = new ParametrosListar();  
   if (httpRequest.getParameter("formato") != null) {
    formatoReporte=((httpRequest.getParameter("formato")));
   }
   if (httpRequest.getParameter("filtroOperacion") != null) {
    parametros.setIdOperacion(Integer.parseInt(httpRequest.getParameter("filtroOperacion")));
   }
   if (httpRequest.getParameter("filtroFechaDiaOperativo") != null) {
    parametros.setFiltroFechaDiaOperativo((httpRequest.getParameter("filtroFechaDiaOperativo")));
   }
   parametros.setPaginacion(Constante.SIN_PAGINACION);
   parametros.setIdOperacion(Integer.parseInt(httpRequest.getParameter("filtroOperacion")));
   respuesta = dOperacion.recuperarRegistros(parametros);
   if (respuesta.estado==false){
    mensajeRespuesta = gestorDiccionario.getMessage("sgo.sinRegistroCliente", null, locale);
    throw new Exception(mensajeRespuesta);
   }
   Operacion operacion = (Operacion) respuesta.contenido.carga.get(0);
   // Recuperar registros
    respuesta = dLiquidacion.recuperarRegistros(parametros);
    int numeroRegistros = respuesta.contenido.carga.size();
   if (respuesta.estado==false){
    mensajeRespuesta = gestorDiccionario.getMessage("sgo.noListadoRegistros", null, locale);
    throw new Exception(mensajeRespuesta);
   }
   if (numeroRegistros==0){
    mensajeRespuesta = gestorDiccionario.getMessage("sgo.noListadoRegistros", null, locale);
    throw new Exception(mensajeRespuesta);
   }
   String titulo4="";// guia.getNumeroGuia();
     //operacion.getCliente().getRazonSocial()+ " - " +operacion.getNombre();
   String[] diaOperativo =parametros.getFiltroFechaDiaOperativo().split("-");
   tituloReporte="REPORTE DE LIQUIDACIÓN DEL DIA OPERATIVO " + diaOperativo[2] +"/" + diaOperativo[1]+"/"+diaOperativo[0]  ;
   ByteArrayOutputStream baos = null;
   ReporteLiquidacion uReporteador = new ReporteLiquidacion();
   uReporteador.setRutaServlet(servletContext.getRealPath("/"));
   
   if (formatoReporte.equals(Reporteador.FORMATO_PDF)){
    baos = uReporteador.generarReporteLiquidacion(operacion.getCliente().getRazonSocial(),tituloReporte,  principal.getIdentidad(),(ArrayList<Liquidacion>) respuesta.contenido.carga, locale);
    response.setHeader("Content-Disposition", "inline; filename=\"reporte-liquidacion.pdf\"");
    response.setDateHeader("Expires", -1);
    response.setContentType("application/pdf");   
    response.setContentLength(baos.size());
    response.getOutputStream().write(baos.toByteArray());
    response.getOutputStream().flush();
   } else if (formatoReporte.equals(Reporteador.FORMATO_CSV)){    
    response.setContentType("text/csv");
    response.setHeader("Content-Disposition", "attachment;filename=\"reporte-cierre.csv\"");
    String contenidoCSV="";
    //contenidoCSV=uReporteador.generarReporteListadoCSV( hmRegistros, listaCampos, listaCamposCabecera);
    response.getOutputStream().write(contenidoCSV.getBytes());
    response.getOutputStream().flush();
   }

  } catch (Exception ex) {

  }
 }

 

 private AuthenticatedUserDetails getCurrentUser() {
  return (AuthenticatedUserDetails) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
 }
}
