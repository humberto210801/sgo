<%@ page language="java" pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="sgo.entidad.Cliente" %>
<%@ page import="sgo.entidad.Operacion" %>
<%@ page import="sgo.entidad.Estacion" %>
<%@ page import="sgo.entidad.Producto" %>
<%@ page import="sgo.entidad.TableAttributes" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="sgo.utilidades.Constante" %>
<% HashMap<?,?> mapaValores = (HashMap<?,?>) request.getAttribute("mapaValores"); %>
<% TableAttributes tableAttributes = (TableAttributes) request.getAttribute("tableAttributes"); %>

<link href="tema/table-scroll/css/table-scroll.css" rel="stylesheet" type="text/css"/>
<link href="tema/table-scroll/css/turno.css" rel="stylesheet" type="text/css"/>

<script type="text/javascript" src="tema/read-excel-file/0.13.5/xlsx.full.min.js"></script>
<script type="text/javascript" src="tema/read-excel-file/0.13.5/jszip.js"></script>

<div class="content-wrapper">

	<section class="content-header">
    	<h1>Turno / <small id="tituloSeccion"><%=mapaValores.get("TITULO_LISTADO_REGISTROS")%></small></h1>
  	</section>

  <section class="content">
    <div class="row">
      <div class="col-md-12">
        <div id="bandaInformacion" class="callout callout-info"><%=mapaValores.get("MENSAJE_CARGANDO")%></div>
      </div>
    </div>
  <div class="row" id="cntTabla">
    <div class="col-md-12">
      <div class="box">
        <div class="box-header">
          <form id="frmBuscar" class="form" role="form"  novalidate="novalidate">
            <table class="sgo-simple-table table table-condensed">
                <thead>
                  <tr>
                    <td class="celda-detalle" style="width:12%;">
                    	<label class="etiqueta-titulo-horizontal">Operación / Cliente: </label>
                   	</td>
        			<td class="celda-detalle" >
        			<select style="width:100%;" id="filtroOperacion" name="filtroOperacion" class="form-control espaciado input-sm" >
                 		<% 
                 		ArrayList<?> listaOperaciones = (ArrayList<?>) request.getAttribute("operaciones"); 
	                    String fechaActual = (String) request.getAttribute("fechaActual");   
	                    int numeroOperaciones = listaOperaciones.size();
	                    Operacion eOperacion=null;
	                    Cliente eCliente=null;
	                    String seleccionado="selected='selected'";
	                    seleccionado="";
	                    for(int indiceOperaciones=0; indiceOperaciones < numeroOperaciones; indiceOperaciones++){ 
		                    eOperacion =(Operacion) listaOperaciones.get(indiceOperaciones);
		                    eCliente = eOperacion.getCliente();
		                    
		                    if (eOperacion.getEstado() != Constante.ESTADO_ACTIVO || eCliente.getEstado() != Constante.ESTADO_ACTIVO) {
		                    	continue;
		                    }
		                    	
		                    %>
		                    <option <%=seleccionado%> data-operacion-cliente='<%=eOperacion.getNombre().trim() + " / " + eCliente.getNombreCorto().trim() %>' data-idCliente='<%=eOperacion.getIdCliente()%>' data-idOperacion='<%=eOperacion.getId()%>' data-fecha-actual='<%=fechaActual%>' data-nombre-operacion='<%=eOperacion.getNombre().trim()%>' data-nombre-cliente='<%=eCliente.getNombreCorto().trim()%>' value='<%=eOperacion.getId()%>'><%=eOperacion.getNombre().trim() + " / " + eCliente.getNombreCorto().trim() %></option>
		                    <%
	                    }%>
                    </select>
                    </td> 
                    <td></td>
                    <td class="celda-detalle" style="width:5%;">
                    	<label class="etiqueta-titulo-horizontal">Estación: </label>
                    </td>
                    <td class="celda-detalle" >
	                    <select style="width:100%;" id="filtroEstacion" name="filtroEstacion" class="form-control espaciado input-sm" >
	                 		<% 
	                 		ArrayList<?> listaEstaciones = (ArrayList<?>) request.getAttribute("estaciones"); 
		                    int numeroEstaciones = listaEstaciones.size();
		                    Estacion eEstacion=null;
		                    String estacionSeleccionada="selected='selected'";
		                    estacionSeleccionada="";
		                    for(int indiceEstaciones=0; indiceEstaciones < numeroEstaciones; indiceEstaciones++){ 
		                    	eEstacion =(Estacion) listaEstaciones.get(indiceEstaciones);
			                    %>
			                    <option <%=estacionSeleccionada%> 
			                    	data-estacion='<%=eEstacion.getNombre().trim()%>' 
             						data-idEstacion='<%=eEstacion.getId()%>' 
			                    	value='<%=eEstacion.getId()%>'>
			                    	<%=eEstacion.getNombre().trim()%>
			                    </option>
			                    <%
		                    } %>
	                    </select>
                    </td>
        			<td></td>
        			<td class="celda-detalle" style="width:10%;">
        				<label class="etiqueta-titulo-horizontal">Día Operativo: </label>
        			</td>
	                <td class="celda-detalle" style="width:15%;">
	                	<input id="filtroFechaJornada" type="text" style="width:100%" class="form-control espaciado input-sm" data-fecha-actual="<%=fechaActual%>" />
	                </td>
            		<td></td>
                  	<td>
                  		<a id="btnFiltrar" class="btn btn-default btn-sm col-md-12">
                  			<i class="fa fa-refresh"></i> <%=mapaValores.get("ETIQUETA_BOTON_FILTRAR")%>
                		</a>
                	</td>
                </tr>
                </thead>
              </table>
          </form>
        </div>

		<div class="box-body">
		<FONT COLOR=red><B><label>Listado de Jornadas.</label></B></FONT>
            <table id="tablaJornada" class="sgo-table table table-striped" width="100%">
              <thead>
                <tr>
 					<th>#</th>
 					<th>ID</th>
 					<th>ID Estacion</th>
 					<th>Estacion</th>
                 	<th>D&iacute;a Operativo</th>
                 	<th>Tipo de Horario</th>
                 	<th>Total Despachos</th>
                 	<th>Ult. Actualizaci&oacute;n</th>
                 	<th>Usuario</th>
                 	<th>Estado</th>
                 </tr>
              </thead>
            </table>
		</div>

        <div class="box-header">
          <div>
            <a id="btnApertura" class="btn btn-default btn-sm espaciado"><i class="fa fa-folder-open-o"></i>  Apertura</a>
            <a id="btnCierre" class="btn btn-default btn-sm espaciado"><i class="fa fa-folder-o"></i>  Cierre</a>
            <a id="btnVer" class="btn btn-default btn-sm espaciado"><i class="fa fa-search"></i>  Ver</a>
          </div>
        </div>
        
			<!--se agrego style="background-color:#F2DEF5" al style por req 9000003068 -->  
          <div class="box-body" style="background-color:#F2DEF5"">
          <FONT COLOR=red><B><label>Listado de Turnos.</label></B></FONT>      
            <table id="tablaTurno" class="sgo-table table table-striped" width="100%">
              <thead>
                <tr>
 					<th>#</th>
 					<th>ID</th>
 					<th style="width:13%;">Inicio</th>
 					<th style="width:13%;">Fin</th>
                 	<th style="width:17%;">Estaci&oacute;n</th>
                 	<th style="width:22%;">Turno Predefinido</th>
                 	<th style="width:22%;">Responsable</th>
                 	<th style="width:22%;">Ayudante</th>
                 	<th style="width:13%;">Estado</th>
                 	<th>FechaOperativa</th>
                 </tr>
              </thead>
            </table>
          </div>
	 	  <div class="overlay" id="ocultaContenedorTabla">
            <i class="fa fa-refresh fa-spin"></i>
          </div>  
        </div>
    </div>
   </div>
      	
	<div class="row" id="cntApertura" style="display: none;">
		<div class="col-md-12">
			<div class="box box-default">
				<div class="box-body">
					<form id="frmApertura" role="form">
						<table class="sgo-simple-table table table-condensed">
		                  <thead>
		                    <tr>
		                      <td class="celda-detalle" style="width:13%;"><label>Operación / Cliente: </label></td>
		        	 		  <td class="celda-detalle" style="width:27%;"><span id='cmpClienteApertura'>	</span> </td>
		                      <td class="celda-detalle" style="width:10%;"><label>Estaci&oacute;n: </label></td>
		                      <td class="celda-detalle" style="width:27%;"><span id='cmpEstacion'>	</span> </td>
		                      <td class="celda-detalle" style="width:10%;"><label>Día Operativo: </label></td>
		        			  <td class="celda-detalle" style="width:13%;">
		        			  	<span class="form-control alert-danger text-center espaciado input-sm text-uppercase" id='cmpDiaOperativoApertura'></span>
		        			  </td>
		                     </tr>
		                     <tr>
		                      <td class="celda-detalle" style="width:13%;"><label>Responsable: </label></td>
		                      <td class="celda-detalle" style="width:27%;">		                     
									<select style="width:100%;"  id="cmpOperarioResponsable" name="cmpOperarioResponsable" class="form-control input-sm">
				                    	<option value="0" selected="selected">Seleccionar...</option>
				                    </select>		                      
		                      </td>
		        			  <td class="celda-detalle" style="width:10%;"><label>Ayudante: </label></td>
			                  <td class="celda-detalle" style="width:27%;">
			                  		<select style="width:100%;"  id="cmpOperarioAyudante" name="cmpOperarioAyudante" class="form-control input-sm">
				                    	<option value="0" selected="selected">Seleccionar...</option>
				                    </select>			                  
			                  </td>
		        	 		  <!-- <td class="celda-detalle" style="width:18%;"><input id="cmpEstacion" name="cmpEstacion" type="text" class="form-control input-sm text-left" value="" disabled="disabled"/></td> -->
		                      <td class="celda-detalle" style="width:10%;">
		                      	<label>Hora Apertura: </label>
		                      </td>
		        			  <td class="celda-detalle" style="width:13%;">
		        			  	<input 
		        			  		id="cmpHoraInicio" 
		        			  		name="cmpHoraInicio" 
		        			  		type="text" 
		        			  		class="form-control input-sm text-center" 
		        			  		value="" 
		        			  		placeholder="dd/mm/yyyy HH:mm"/> 	<!-- se quita ss del placeholder por req 9000003068-->
	        			  	  </td>
		                   </tr>
		                  </thead>
		                </table>
		                <br>
		                <div class="box-body">
				    	  <label>Tanques Despachando</label>
				          <table id="grillaApertura" class="sgo-table table table-striped" style="width:100%;"> </table>
				        </div>
				        <br>
		                 <label>Cont&oacute;metros</label>
		                 	
					    <table 
					    	class="grupo-apertura table-scroll sgo-simple-table table table-condensed" 
					    	data-contometro-registros="<%=tableAttributes.getContometroRegistros() %>">
			      			<thead>
			      				<tr>
			      					<td><label>Secuencia</label></td>
				      				<td><label>Cont&oacute;metro</label></td>
									<td><label>Producto</label></td>
									<td><label>Lectura Inicial</label></td>
			      				</tr>
			      			</thead>
			      			<tbody id="GrupoApertura" style="<%=tableAttributes.getBodyStyle() %>">
			      				<tr id="GrupoApertura_template">
			      					<td class="celda-detalle">				
			      						<input elemento-grupo="secuencia" id="GrupoApertura_#index#_Secuencia" name="programacion[detalle][#index#][secuencia]" type="text" readonly="readonly" class="form-control input-sm text-left"/>
			      					</td>
			      					<td class="celda-detalle">				
			      						<input elemento-grupo="contometro" id="GrupoApertura_#index#_Contometro" name="programacion[detalle][#index#][id_contometro]" type="text" readonly="readonly" class="form-control input-sm text-left"/>
			      					</td>
			      					<td class="celda-detalle">
										<input elemento-grupo="producto" id="GrupoApertura_#index#_Producto" name="programacion[detalle][#index#][id_producto]" type="text" readonly="readonly" class="form-control input-sm text-left"/>
			      					</td>
			      					<td class="celda-detalle">
										<input elemento-grupo="lecturaInicial" id="GrupoApertura_#index#_LecturaInicial" name="programacion[detalle][#index#][lectura_inicial]" readonly="readonly" type="text" class="form-control input-sm text-left"/>
			      					</td>
			      				</tr>
			      				<tr id="GrupoApertura_noforms_template">
			      					<td></td>
			      				</tr>    			
			      			</tbody>
		      		    </table>
      		    <br>
      		    <label>Observaciones</label>
      		    <table class="sgo-simple-table table table-condensed">
                  <thead>
                    <tr>
                      <td class="celda-detalle" style="width:20%;">
    					<textarea id="cmpObservacionApertura" name="cmpObservacionApertura" type="text" class="form-control input-sm text-uppercase" maxlength="700" rows="0"></textarea>
    				  </td>
                   </tr>
                  </thead>
                </table>
				</form>
				</div>
				<div class="box-footer">
					<a id="btnGuardarApertura" class="btn btn-primary btn-sm">
						<i class="fa fa-save"></i> <%=mapaValores.get("ETIQUETA_BOTON_GUARDAR")%>
					</a>
            		<a id="btnCancelarApertura" class="btn btn-danger btn-sm">
            			<i class="fa fa-close"></i> <%=mapaValores.get("ETIQUETA_BOTON_CANCELAR")%>
            		</a>
		    	</div>
		    	<div class="overlay" id="ocultaContenedorApertura" style="display:none;">
		            <i class="fa fa-refresh fa-spin"></i>
		        </div>
			</div>
		</div>
	</div>

	<div class="row" id="cntCierre" style="display: none;">
		<div class="col-md-12">
			<div class="box box-default">
				<div class="box-body">
					<form id="frmCierre" role="form">
						<table class="sgo-simple-table table table-condensed">
		                  <thead>
		                  	<tr>
		                      <td class="celda-detalle" style="width:13%;"><label>Operación / Cliente: </label></td>
		        	 		  <td class="celda-detalle" style="width:27%;"><span id='cmpClienteCierre'>	</span> </td>
		                      <td class="celda-detalle" style="width:10%;"><label>Estaci&oacute;n: </label></td>
		                      <td class="celda-detalle" style="width:27%;"><span id='cmpEstacionCierre'>	</span> </td>
		                      <td class="celda-detalle" style="width:10%;"><label>Día Operativo: </label></td>
		        			  <td class="celda-detalle" style="width:13%;"><span  class="form-control alert-danger text-center espaciado input-sm text-uppercase" id='cmpDiaOperativoCierre'>	</span> </td>
		                     </tr>
		                    <tr>
		                      <td class="celda-detalle" style="width:13%;"><label>Responsable: </label></td>
		                      <td class="celda-detalle" style="width:27%;"><input id="cmpCierreResponsable" name="cmpCierreResponsable" type="text" class="form-control input-sm text-left" value="" disabled="disabled"/></td>
		        			  <td class="celda-detalle" style="width:10%;"><label>Ayudante: </label></td>
			                  <td class="celda-detalle" style="width:27%;"><input id="cmpCierreAyudante" name="cmpCierreAyudante" type="text" class="form-control input-sm text-left" value="" disabled="disabled"/></td>
			                  <td class="celda-detalle" style="width:10%;"><label>Hora Cierre: </label></td>
		        			  <td class="celda-detalle" style="width:13%;">
		        			  	<input 
		        			  		id="cmpHoraCierre" 
		        			  		name="cmpHoraCierre" 
		        			  		type="text" 
		        			  		class="form-control input-sm text-center" 
		        			  		placeholder="dd/mm/yyyy HH:mm:ss"/>
	        			  	  </td>
		                   </tr>
		                  </thead>
		                </table>
		                <br>
		                <div class="box-body">
				    	  <label>Tanques Despachando</label>
				          <table id="grillaCierre" class="sgo-table table table-striped" style="width:100%;"></table>
				        </div>
		                <br>
		                 <label>Cont&oacute;metros</label>		
					    <table 
					    	class="grupo-cierre loading table-scroll sgo-simple-table table table-condensed"
					    	data-contometro-registros="<%=tableAttributes.getContometroRegistros() %>">
			      			<thead>
			      				<tr>
				      				<td><label>Secuencia</label></td>
				      				<td><label>Cont&oacute;metro</label></td>
									<td><label>Producto</label></td>
									<td><label>Lectura Inicial</label></td>
									<td><label>Lectura Final</label></td>
									<td><label>Dif. Vol. Encontrado</label></td>
			      				</tr>
			      			</thead>
			      			<tbody id="GrupoCierre" style="<%=tableAttributes.getBodyStyle() %>">
			      				<tr id="GrupoCierre_template">
			      					<td class="celda-detalle">				
			      						<input elemento-grupo="secuencia" id="GrupoCierre_#index#_Secuencia" name="cierre[detalle][#index#][secuencia]" type="text" readonly="readonly" class="form-control input-sm text-left"/>
			      					</td>
			      					<td class="celda-detalle">				
			      						<input elemento-grupo="contometro" id="GrupoCierre_#index#_Contometro" name="cierre[detalle][#index#][id_contometro]" type="text" readonly="readonly" class="form-control input-sm text-left"/>
			      					</td>
			      					<td class="celda-detalle">
									 <input elemento-grupo="producto" id="GrupoCierre_#index#_Producto" name="cierre[detalle][#index#][id_producto]" type="text" class="form-control input-sm text-left" readonly="readonly"/>
			      					</td>
			      					<td class="celda-detalle">
										<input elemento-grupo="lecturaInicial" id="GrupoCierre_#index#_LecturaInicial" name="cierre[detalle][#index#][lectura_inicial]" type="text" readonly="readonly"  class="form-control input-sm text-left"/>
			      					</td>
			      					<td class="celda-detalle">
										<input elemento-grupo="lecturaFinal" id="GrupoCierre_#index#_LecturaFinal" name="cierre[detalle][#index#][lectura_final]" maxlength="8" type="text" class="form-control input-sm text-left"/>
			      					</td>
			      					<td class="celda-detalle">
										<input elemento-grupo="lecturaDifVolEncontrado" id="GrupoCierre_#index#_LecturaDifVolEncontrado" name="cierre[detalle][#index#][lectura_dif_vol_encontrado]" readonly="readonly" type="text" class="form-control input-sm text-left"/>
			      					</td>
			      				</tr>
			      				<tr id="GrupoCierre_noforms_template">
			      					<td></td>
			      				</tr>    			
			      			</tbody>
			      		</table>
		      		<br>
		      		  <label>Observaciones</label>
		      		    <table class="sgo-simple-table table table-condensed">
		                  <thead>
		                    <tr>
		                      <td class="celda-detalle" style="width:20%;">
		    					<textarea id="cmpObservacionCierre" name="cmpObservacionCierre" type="text" class="form-control input-sm text-uppercase" maxlength="700" rows="0"></textarea>
		    				  </td>
		                   </tr>
		                  </thead>
		                </table>
					</form>
				</div>
				<div class="box-footer">
		            <button id="btnGuardarCierre" type="submit" class="btn btn-primary btn-sm">Guardar</button>
		            <button id="btnCancelarCierre" class="btn btn-danger btn-sm">Cancelar</button>
		            <button id="btnPlantillaContometros" class="btn btn-success btn-sm">
		            	<i class="fa fa-fw fa-file-excel-o"></i> Plantilla Cont&oacute;metros
	            	</button>
		            <button id="btnCargarArchivoContometros" class="btn btn-success btn-sm">
		            	<i class="fa fa-fw fa-cloud-upload"></i> Cargar Archivo Cont&oacute;metros
	            	</button>
		    	</div>
		    	<div class="overlay" id="ocultaContenedorCierre" style="display:none;">
		            <i class="fa fa-refresh fa-spin"></i>
		        </div>
			</div>
		</div>
	</div>
	
	<div class="row" id="cntVistaDetalleTurno" style="display: none;">
		<div class="col-md-12">
			<div class="box box-default">
				<div class="box-body">
					   <table class="sgo-table table"  style="width:100%;">
		                  <thead>
		                  </thead>
		                  <tbody>
		                    <tr>
		                      <td class="tabla-vista-titulo" style="width:12%;">Cliente/Operaci&oacute;n: </td>
		        	 		  <td class="text-left" style="width:23%;"><span id='cmpVistaClienteOperacion'>	</span> </td>
		                      <td class="tabla-vista-titulo" style="width:12%;">Estaci&oacute;n: </td>
		        			  <td class="text-left" style="width:23%;"><span id='cmpVistaEstacion'>	</span> </td>
		                      <td class="tabla-vista-titulo" style="width:5%;">F.Inicio: </td>
		                      <td class="text-left" style="width:10%;"><span id='cmpVistaFInicio'>	</span> </td>
		        		   	  <td class="tabla-vista-titulo" style="width:5%;">F.Final: </td>
			                  <td class="text-left" style="width:10%;"><span id='cmpVistaFFinal'>	</span> </td>
		        		   </tr>
		        		   </tbody>
		        		</table>
		        		<table class="sgo-table table"  style="width:100%;">
		                   <thead>
		                   </thead>
		                   <tbody>
		                   <tr>
		                      <td class="tabla-vista-titulo" style="width:12%;">Responsable: </td>
		        	 		  <td class="text-left" style="width:30%;"><span id='cmpVistaResponsable'>	</span> </td>
		        	 		  <td class="tabla-vista-titulo" style="width:13%;">Ayudante: </td>
		        	 		  <td class="text-left" style="width:30%;"><span id='cmpVistaAyudante'>	</span> </td>
		        	 		  <td class="tabla-vista-titulo" style="width:5%;">Estado: </td>
		        	 		  <td class="text-left"  style="width:10%;"><FONT COLOR=red><B>	<span id='cmpVistaEstado'>	</span> </B></FONT> </td>
		                   </tr>
		                  </tbody>
		                </table>
			      		<br>	
					    <table id="tablaVistaDetalle" class="sgo-table table table-striped" style="width:100%;">
		      			<thead>
		      				<tr>
				                <th>Cont&oacute;metro</th>
				                <th>Producto</th>
				                <th>Lect. Inicial</th>
				                <th>Lect. Final</th>
				                <th>Dif. Vol Obs.</th>
		      				</tr>
		      			</thead>			
						<tbody>					
						</tbody>
						</table>
						<br>
	      		      	<table class="sgo-table table" style="width:100%;">
		                    <thead> </thead>
		                    <tbody> 
		                    	<tr>
		                    		<td class="tabla-vista-titulo" style="width:15%;">Observaciones del Turno: </td>
		                    		<td class="text-left"  style="width:85%;"> 
		                    			<textarea style="resize: none;" disabled="disabled" rows="6" cols="180" id='cmpVistaObservacion'></textarea>	
		                    		</td>
		                    	</tr>
		                    </tbody>
	                  	</table>
	                  	<br>
						<table class="sgo-table table" style="width:100%;">
							<thead>
				      		</thead>
							<tbody>
								<tr>
									<td class="tabla-vista-titulo" style="width:10%;">Creado el:</td>
									<td class="text-center" style="width:23%;"> <span id='vistaCreadoEl'></span></td>
									<td class="tabla-vista-titulo" style="width:10%;">Creado Por:</td>
									<td class="text-left" style="width:23%;"> <span id='vistaCreadoPor'></span></td>
									<td class="tabla-vista-titulo" style="width:10%;">IP Creaci&oacute;n:</td>
									<td class="text-left"> <span id='vistaIPCreacion'></span></td>
								</tr>
								<tr>
									<td class="tabla-vista-titulo" style="width:10%;">Actualizado el:</td>
									<td class="text-center" style="width:23%;"> <span id='vistaActualizadoEl'></span></td>
									<td class="tabla-vista-titulo" style="width:10%;">Actualizado Por:</td>
									<td class="text-left" style="width:23%;"> <span id='vistaActualizadoPor'></span></td>
									<td class="tabla-vista-titulo" style="width:10%;">IP Actualizaci&oacute;n:</td>
									<td class="text-left"> <span id='vistaIPActualizacion'></span></td>
								</tr>
							</tbody>
						</table>
				</div>
				<div class="box-footer" align="right">
					<button id="btnCerrarVistaTurno" class="btn btn-danger btn-sm">Cerrar</button>
				</div>
				<div class="overlay" id="ocultaContenedorVistaTurno">
			      <i class="fa fa-refresh fa-spin"></i>
			    </div>
			</div>
		</div>
	</div>
	</section>
</div>

<div id="modalCargarArchivoContometros" class="modal" data-keyboard="false" data-backdrop="static">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-label="Close">
					<span aria-hidden="true">&times;</span>
				</button>
				<h4 class="modal-title">
					<strong>Turno / Cierre</strong> - Carga de datos de cont&oacute;metros
				</h4>
			</div>
			<div class="modal-body">
			
				<div class="callout callout-danger callout-width" style="display: none;"></div>
				<div class="callout callout-warning callout-width" style="display: none;">
					<i class="fa fa-fw fa-spin fa-refresh"></i> Inicio de validación...
				</div>
				
				<table class="sgo-simple-table table table-condensed">
					<thead>
						<tr>
							<td class="celda-detalle">
								<label>Operación / Cliente:</label>
							</td>
							<td class="celda-detalle">
								<span id="modalClienteCierre"></span>
							</td>
						</tr>
						<tr>
							<td class="celda-detalle">
								<label>Estación:</label>
							</td>
							<td class="celda-detalle">
								<span id="modalEstacionCierre"></span>
							</td>
						</tr>
						<tr>
							<td class="celda-detalle">
								<label>Día Operativo:</label>
							</td>
							<td class="celda-detalle">
								<span 
									class="form-control alert-primary text-center espaciado input-sm text-uppercase" 
									id="modalDiaOperativoCierre"></span>
							</td>
						</tr>
						<tr>
							<td class="celda-detalle">
								<label>Archivo:</label>
							</td>
							<td class="celda-detalle">
								<input type="file" id="fileUpload" />
							</td>
						</tr>
					</thead>
				</table>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default pull-left" data-dismiss="modal">Cancelar</button>
				<button id="btnProcesarArchivoContometros" type="button" class="btn btn-primary">Cargar</button>
			</div>
		</div>
	</div>
</div>

<div id="modalConfirmacionAccion" class="modal" data-keyboard="false" data-backdrop="static">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-label="Close">
					<span aria-hidden="true">&times;</span>
				</button>
				<h4 class="modal-title">
					<i class="fa fa-fw fa-check-circle"></i> <strong>Turno</strong> - Confirmación de la acción.
				</h4>
			</div>
			<div class="modal-body">
				<p>Esta seguro de realizar <span class="apertura">la apertura</span><span class="cierre">el cierre</span> del turno?</p>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default pull-left" data-dismiss="modal">Cancelar</button>
				<button type="button" class="confirmar btn btn-primary">Confirmar</button>
			</div>
		</div>
	</div>
</div>