$(document).ready(function() {
	
  var moduloActual = new moduloBase();  
  moduloActual.urlBase = 'operacion';
  moduloActual.SEPARADOR_MILES = ",";
  moduloActual.URL_LISTAR = moduloActual.urlBase + '/listar';
  moduloActual.URL_RECUPERAR = moduloActual.urlBase + '/recuperar';
  moduloActual.URL_RECUPERAR_PRODUCTOS_EQUIVALENTES = moduloActual.urlBase + '/recuperarProductosEquivalentes';
  moduloActual.URL_GUARDAR_PRODUCTOS_EQUIVALENTES = moduloActual.urlBase + '/guardarProductosEquivalentes';
  moduloActual.URL_UPDATE_PRODUCTOS_EQUIVALENTES = moduloActual.urlBase + '/updateProductosEquivalentes';
  
  //Agregado por req 9000002570====================
  moduloActual.URL_RECUPERAR_ETAPA = moduloActual.urlBase + '/recuperarEtapas';
  moduloActual.URL_GUARDAR_ETAPAS = moduloActual.urlBase + '/crearEtapas';
  //===============================================
  
  moduloActual.URL_ELIMINAR = moduloActual.urlBase + '/eliminar';
  moduloActual.URL_GUARDAR = moduloActual.urlBase + '/crear';
  moduloActual.URL_ACTUALIZAR = moduloActual.urlBase + '/actualizar';
  moduloActual.URL_ACTUALIZAR_ESTADO = moduloActual.urlBase + '/actualizarEstado';
  moduloActual.ordenGrilla=[[ 2, 'asc' ]];
  moduloActual.columnasGrilla.push({ "data": 'id'}); 
  moduloActual.columnasGrilla.push({ "data": 'nombre'});
  moduloActual.columnasGrilla.push({ "data": 'cliente.razonSocial'});
  moduloActual.columnasGrilla.push({ "data": 'referenciaPlantaRecepcion'});
  moduloActual.columnasGrilla.push({ "data": 'referenciaDestinatarioMercaderia'});
  moduloActual.columnasGrilla.push({ "data": 'estado'});
  moduloActual.definicionColumnas.push({"targets": 1,"searchable" : false,"orderable" : true,"visible" : false});
  moduloActual.definicionColumnas.push({"targets": 2,"searchable" : false,"orderable" : true,"visible" : true});
  moduloActual.definicionColumnas.push({"targets": 3,"searchable" : false,"orderable" : true,"visible" : true});
  moduloActual.definicionColumnas.push({"targets": 4,"searchable" : false,"orderable" : true,"visible" : true});
  moduloActual.definicionColumnas.push({"targets": 5,"searchable" : false,"orderable" : true,"visible" : true});
  moduloActual.definicionColumnas.push({"targets": 6,"searchable" : false,"orderable" : true,"visible" : true,"render" : utilitario.formatearEstado});
  
  moduloActual.reglasValidacionFormulario = {
    cmpNombre: 				   	{required: true, maxlength: 150 },
    cmpAlias:   				{required: true, maxlength: 150 },
    //cmpIdRefPlantaRecepcion:   	{required: true, maxlength: 20  },
    //cmpIdRefDestMercaderia:    	{required: true, maxlength: 20  },
    cmpVolumenPromedioCisterna: {required: true},
    cmpFechaInicioPlanificacion:{required: true},
    cmpPlantaDespacho: 			{required: true},
    cmpTipoRegistroTanqueDescarga: {required: true},
    cmpETA: 					{required: true, rangelength: [1, 2], number: true},
    cmpCorreoPara: 				{required: true}
  };
  
  moduloActual.mensajesValidacionFormulario = {
    cmpNombre: 					{ required:  "El campo es obligatorio",
    				  			  maxlength: "El campo debe contener 150 caracteres como maximo." },
    cmpAlias: 					{ required:  "El campo es obligatorio",
								  maxlength: "El campo debe contener 150 caracteres como maximo." },
    //cmpIdRefDestMercaderia:		{ required:  "El campo es obligatorio",
    //							  maxlength: "El campo debe contener 20 caracteres como maximo."  },
    //cmpIdRefPlantaRecepcion :	{ required:  "El campo es obligatorio",
    //							  maxlength: "El campo debe contener 20 caracteres como maximo."  },
    cmpVolumenPromedioCisterna: { required:  "El campo es obligatorio" },
    cmpFechaInicioPlanificacion:{ required:  "El campo es obligatorio" },
    cmpPlantaDespacho:			{ required:  "El campo es obligatorio" },
    cmpTipoRegistroTanqueDescarga:{ required:  "El campo es obligatorio" },
    cmpETA:						{ required:  "El campo es obligatorio", 
    							  rangelength: "El campo ETA debe contener 2 caracteres",
    							  number: "El campo ETA solo debe contener caracteres numericos" },
    cmpCorreoPara:				{ required:  "El campo es obligatorio" }
  };
  
  moduloActual.inicializarCampos= function() {
	  
    //Campos de formulario
    this.obj.cmpNombre=$("#cmpNombre");
    this.obj.cmpAlias=$("#cmpAlias");
    this.obj.cmpIdRefPlantaRecepcion=$("#cmpIdRefPlantaRecepcion");
    this.obj.cmpIdRefDestMercaderia=$("#cmpIdRefDestMercaderia");
    this.obj.cmpFechaInicioPlanificacion=$("#cmpFechaInicioPlanificacion");
    this.obj.cmpFechaInicioPlanificacion.inputmask(constantes.FORMATO_FECHA, 
    {
        "placeholder": constantes.FORMATO_FECHA,
        onincomplete: function(){
            $(this).val('');
        }
    });
    this.obj.cmpCorreoPara = $("#cmpCorreoPara");
    this.obj.cmpCorreoCC = $("#cmpCorreoCC");
    this.obj.cmpETA = $("#cmpETA");
    this.obj.cmpTipoVolumenDescargado = $("#cmpTipoVolumenDescargado");    
    this.obj.cmpETA.inputmask("integer");
    this.obj.cmpETA.css("text-align", "left");
    this.idTransportista = $("#idTransportista");
    this.obj.cmpTipoRegistroTanqueDescarga = $("#cmpTipoRegistroTanqueDescarga");
    this.obj.cmpTipoRegistroTanqueDescarga.nombreControl = "cmpTipoRegistroTanqueDescarga"; 
    this.obj.cmpPlantaDespacho = $("#cmpPlantaDespacho");
    this.obj.cmpPlantaDespacho.tipoControl="select2";
    this.obj.cmpPlantaDespacho.nombreControl="cmpPlantaDespacho"; 
    this.obj.cmpPlantaDespacho.select2({placeholder: "Seleccionar...", allowClear: false}); 
    this.obj.cmpVolumenPromedioCisterna=$("#cmpVolumenPromedioCisterna");
    this.obj.cmpVolumenPromedioCisterna.inputmask('decimal', {digits: 2, groupSeparator:moduloActual.SEPARADOR_MILES,autoGroup:true,groupSize:3});
    
    //esto para alinear a la izquierda un decimal
    this.obj.cmpVolumenPromedioCisterna.css("text-align", "left");
    this.obj.cmpSincronizadoEl=$("#cmpSincronizadoEl");
    
    this.obj.cmpIdCliente=$("#cmpIdCliente");
    this.obj.cmpIdCliente.tipoControl="select2";  
    this.obj.cmpIdCliente.nombreControl="cmpIdCliente"; 
    this.obj.cmpIdCliente.select2({placeholder: "Seleccionar...", allowClear: false});
    
    this.obj.btnAgregarTransportista = $("#btnAgregarTransportista");
    this.obj.btnProductosEquivalentes = $("#btnProductosEquivalentes");
    this.obj.cntProductosEquivalentes = $("#cntProductosEquivalentes");
    this.obj.btnCerrarProductosEquivalentes = $("#btnCerrarProductosEquivalentes");
    this.obj.btnAgregarTrEquivalencia = $("#btnAgregarTrEquivalencia");
    this.obj.btnGuardarEquivalencia = $("#btnGuardarEquivalencia");
    this.obj.ocultaContenedorProductosEquivalentes = $("#ocultaContenedorProductosEquivalentes");
    this.obj.modalEstadoProductoEquivalente = $("#modalEstadoProductoEquivalente");
    this.obj.btnEstadoProductoEquivalente = $(".btnEstadoProductoEquivalente");
    
    //Campos Agregados por 9000002570=========================
    this.obj.btnAgregarEtapa=$("#btnAgregarEtapa");
    this.obj.btnRefrescarEtapa=$("#btnRefrescarEtapa");
    //========================================================
    
    //SheepIt transportistas
    this.obj.grupoTransportista = $('#GrupoTransportista').sheepIt({
        separator: '',
        allowRemoveLast: true,
        allowRemoveCurrent: true,
        allowRemoveAll: true,
        allowAdd: true,
        allowAddN: false,
        maxFormsCount: 10,
        minFormsCount: 0,
        iniFormsCount: 0,
        afterAdd: function(origen, formularioNuevo) {
          var cmpIdTransportista=$(formularioNuevo).find("select[elemento-grupo='idTransportista']");
          var cmpElimina = $(formularioNuevo).find("[elemento-grupo='botonElimina']");

          cmpElimina.on("click", function(){
	          try{
	        	  moduloActual.indiceFormulario = ($(formularioNuevo).attr('id')).substring(27);
	        	  moduloActual.obj.grupoTransportista.removeForm(moduloActual.indiceFormulario);
	          } catch(error){
	            console.log(error.message);
	          
	          };
        });
      }
    });
    
    this.obj.grupoTransportista.addForm();

    this.obj.btnAgregarTransportista.on("click", function(){
    	try {
    		moduloActual.obj.grupoTransportista.addForm();
    	} catch(error) {
    		moduloActual.mostrarDepuracion(error.message);
    	};
    });
    
    this.obj.btnProductosEquivalentes.on(moduloActual.NOMBRE_EVENTO_CLICK, function() {
    	moduloActual.recuperarProductosEquivalentes();		
    });
    
    this.obj.btnCerrarProductosEquivalentes.on(moduloActual.NOMBRE_EVENTO_CLICK, function() {
    	moduloActual.cerrarProductosEquivalentes();
    });
    
    this.obj.btnAgregarTrEquivalencia.on(moduloActual.NOMBRE_EVENTO_CLICK, function() {
    	moduloActual.agregarTrEquivalencia();		
    });
    
    this.obj.btnGuardarEquivalencia.on(moduloActual.NOMBRE_EVENTO_CLICK, function() {
    	moduloActual.guardarProductoEquivalencia();	
    });
    
    $(document).on(moduloActual.NOMBRE_EVENTO_CLICK, 'button.btn-remove-row', function() {
    	$(this).closest('tr').remove();
    });
    
    $(document).on(moduloActual.NOMBRE_EVENTO_CLICK, 'input.update-producto-equivalente', function() {
    	
    	var checked = $(this).is(':checked');
    	$(this).prop('checked', true);
    	var modalBody = moduloActual.obj.modalEstadoProductoEquivalente.find('.modal-body');
		modalBody.find('p.activar').hide();
		modalBody.find('p.desactivar').show();
    	
    	if (checked) {
    		modalBody.find('p.activar').show();
    		modalBody.find('p.desactivar').hide();
    		$(this).prop('checked', false);
    	}
    	
    	moduloActual.obj.updateEstado = {};
    	moduloActual.obj.updateEstado.checked = checked;
    	moduloActual.obj.updateEstado.idProductoEquivalencia = $(this).data("producto-equivalencia");
    	moduloActual.obj.modalEstadoProductoEquivalente.modal('show');
    });
    
    this.obj.btnEstadoProductoEquivalente.on(moduloActual.NOMBRE_EVENTO_CLICK, function() {

    	var object = {};
    	object.estado = moduloActual.obj.updateEstado.checked ? constantes.ESTADO_ACTIVO : constantes.ESTADO_INACTIVO;
    	object.idProductoEquivalencia = moduloActual.obj.updateEstado.idProductoEquivalencia;
    	
    	moduloActual.updateProductoEquivalencia(object);
    });
    
    //Campos Agregados por 9000002570=========================
    //SheepIt etapas
    this.obj.grupoEtapa = $('#GrupoEtapa').sheepIt({
        separator: '',
        allowRemoveLast: true,
        allowRemoveCurrent: true,
        allowRemoveAll: true,
        allowAdd: true,
        allowAddN: false,
        maxFormsCount: 14,
        minFormsCount: 0,
        iniFormsCount: 0,
        afterAdd: function(origen, formularioNuevo) {
        	
          var cmpOrdenPrincipal = $(formularioNuevo).find("[elemento-grupo='ordenEtapa']");
          cmpOrdenPrincipal.inputmask('decimal', {digits: 0});
          
          var cmpElimina=$(formularioNuevo).find("[elemento-grupo='botonElimina']");

          cmpElimina.on("click", function(){
	          try{
	        	  moduloActual.indiceFormulario = ($(formularioNuevo).attr('id')).substring(19);
	        	  
	        	  var indiceEliminar = null;
	        	  var idEtapaTemp = $(formularioNuevo).find("[elemento-grupo='idEtapa']").val();
	        	  
	        	  var estadoTemp = $(formularioNuevo).find("[elemento-grupo='estadoEtapa']").val();

		  	      var numeroEtapas = moduloActual.obj.grupoEtapa.getForms().length;
		  	      for(var i = 0; i < numeroEtapas; i++){
			    	  var fila = moduloActual.obj.grupoEtapa.getForm(i);
			    	  var indiceTemp = fila.attr('id').substring(19);
			    	  
			    	  if(indiceTemp === moduloActual.indiceFormulario){
			    		  indiceEliminar = i;
			    		  break;
			    	  }
			      }

		        	  if(idEtapaTemp === '0' || idEtapaTemp === null){
		        		  moduloActual.obj.grupoEtapa.removeForm(indiceEliminar);
		        	  }else{
		        		 
		        		  $("#ocultaContenedorEtapas").show();
		        		  try {			  
		      			    $.ajax({
		      			    	type: constantes.PETICION_TIPO_GET,
		      			    	url: './operacion/eliminarEtapas/',
		      				    contentType: moduloActual.TIPO_CONTENIDO, 
		      				    data: {ID:parseInt(idEtapaTemp)},
		      				    success: function(respuesta) {
		      				      if (!respuesta.estado) {
		      				    	  if(respuesta.mensaje === 'YA_ASOCIADO'){
		      				    		var mensaje;
		      				    		
		      				    		if(estadoTemp === 'ACTIVO'){
		      				    			mensaje = 'No se puede eliminar el registro, ya esta asociado, solo se puede inactivar.';
		      				    		}else{
		      				    			mensaje = 'No se puede eliminar el registro, ya esta asociado.';
		      				    		}
		      				    		
		      				    		moduloActual.actualizarBandaInformacion(constantes.TIPO_MENSAJE_ERROR,mensaje);
		      				    	  }else{
		      				    		moduloActual.actualizarBandaInformacion(constantes.TIPO_MENSAJE_ERROR,respuesta.mensaje);
		      				    	  }
		      				    	  
		      				      } else { 				    	
		      				    	moduloActual.obj.grupoEtapa.removeForm(indiceEliminar);
		      				    	moduloActual.actualizarBandaInformacion(constantes.TIPO_MENSAJE_EXITO, respuesta.mensaje);
		      				      };
		      				      
		      				      $("#ocultaContenedorEtapas").hide();
		      				    },			    		    
		      				    error: function() {
		      				    	moduloActual.mostrarErrorServidor(xhr,estado,error); 
		      				    	$("#ocultaContenedorEtapas").hide();
		      				    }
		      			    });
		      			  }  catch(error){
		      				  moduloActual.mostrarDepuracion(error.message);
		      			  }
		        	  }

	          } catch(error) {
	            console.log(error.message);
	          
	          };
          });
          
          var cmpEdita = $(formularioNuevo).find("[elemento-grupo='botonEdita']");
          
          cmpEdita.on("click", function(){
        	  
        	  var nombreTemp = $(formularioNuevo).find("[elemento-grupo='nombreEtapa']");
        	  nombreTemp.prop('disabled', false);
        	  
        	  var ordenTemp = $(formularioNuevo).find("[elemento-grupo='ordenEtapa']");
        	  ordenTemp.prop('disabled', false);
          });
          
          var cmpCambiaEstado = $(formularioNuevo).find("[elemento-grupo='botonCambiarEstado']");
          
          cmpCambiaEstado.on("click", function(){
        	  
        	  var idEtapaTemp = $(formularioNuevo).find("[elemento-grupo='idEtapa']").val();
        	  
        	  var estado;
        	  var cambiaEstadoTemp = $(formularioNuevo).find("[elemento-grupo='estadoEtapa']");
        	  
        	  if(cambiaEstadoTemp.val() == "ACTIVO"){
        		  estado = '0';
        	  } else {
        		  estado = '1';
        	  }
        	  
        	  try {			  
        		  
        		  
        		  $("#ocultaContenedorEtapas").show();
    			    $.ajax({
    			    	type: constantes.PETICION_TIPO_GET,
    			    	url: './operacion/cambiaEstadoEtapa/',
    				    contentType: moduloActual.TIPO_CONTENIDO, 
    				    data: {ID:parseInt(idEtapaTemp), ESTADO:parseInt(estado)},
    				    success: function(respuesta) {
    				      if (!respuesta.estado) {
    				    	  moduloActual.actualizarBandaInformacion(constantes.TIPO_MENSAJE_ERROR,respuesta.mensaje);
    				      } else { 				    	
    			        	  var cambiaEstadoTemp = $(formularioNuevo).find("[elemento-grupo='estadoEtapa']");
    			        	  var btnCambiaEstadoTemp = $(formularioNuevo).find("[elemento-grupo='botonCambiarEstado']");
    			        	  
    			        	  if(cambiaEstadoTemp.val() == "ACTIVO"){
    			        		  cambiaEstadoTemp.val('INACTIVO');
    			        		  btnCambiaEstadoTemp.html('<i class="fa fa-cloud-upload"></i>');
    			        	  }else{
    			        		  cambiaEstadoTemp.val("ACTIVO");
    			        		  btnCambiaEstadoTemp.html('<i class="fa fa-cloud-download"></i>');
    			        	  }
    			        	  
    			        	  moduloActual.actualizarBandaInformacion(constantes.TIPO_MENSAJE_EXITO, respuesta.mensaje);
    				      };
    				      $("#ocultaContenedorEtapas").hide();
    				    },			    		    
    				    error: function() {
    				    	moduloActual.mostrarErrorServidor(xhr,estado,error); 
    				    	$("#ocultaContenedorEtapas").hide();
    				    }
    			    });
    			  }  catch(error){
    				  moduloActual.mostrarDepuracion(error.message);
    				  $("#ocultaContenedorEtapas").hide();
    			  }
        	  
          });
      }
    });
    
    this.obj.grupoEtapa.addForm();

    this.obj.btnAgregarEtapa.on("click",function(){
      try {
        moduloActual.obj.grupoEtapa.addForm();
        
        var fTemp;
    	var ordTemp;
    	var nuevoOrd = 0;
        var numeroEtapas = moduloActual.obj.grupoEtapa.getForms().length;
        for(var i = 0; i < numeroEtapas-1; i++){
        	fTemp = moduloActual.obj.grupoEtapa.getForm(i);
        	ordTemp = fTemp.find("[elemento-grupo='ordenEtapa']").val();
        	
        	if(parseInt(ordTemp) > nuevoOrd){
        		nuevoOrd = parseInt(ordTemp);
        	}
        }
        
        var fila = moduloActual.obj.grupoEtapa.getForm(numeroEtapas - 1);
        
        var IdEtapaTemp = fila.find("input[elemento-grupo='idEtapa']");
	   	var estadoEtapaTemp = fila.find("input[elemento-grupo='estadoEtapa']");
	   	var btnCambiaEstadoTemp = fila.find("[elemento-grupo='botonCambiarEstado']");
	   	var ordenEtapaTemp = fila.find("[elemento-grupo='ordenEtapa']");
	   	
	   	IdEtapaTemp.val(0);
	   	estadoEtapaTemp.val('ACTIVO');
	   	btnCambiaEstadoTemp.html('<i class="fa fa-cloud-download"></i>');
	   	ordenEtapaTemp.val(nuevoOrd + 1);
        
      } catch(error){
      	moduloActual.mostrarDepuracion(error.message);
      };
    });
    
    this.obj.btnRefrescarEtapa.on("click", function(){
    	
    	try {
    		
	    	var numeroEtapas = moduloActual.obj.grupoEtapa.getForms().length;
	    	
	    	for(var i = 0; i < numeroEtapas-1; i++){

	    		var fila = moduloActual.obj.grupoEtapa.getForm(i);
	    		var orden = fila.find("[elemento-grupo='ordenEtapa']");
	    		var id 		= fila.find("[elemento-grupo='idEtapa']");
    			var nombre 	= fila.find("[elemento-grupo='nombreEtapa']");
    			var estado 	= fila.find("[elemento-grupo='estadoEtapa']");
    			var disableNombre = nombre.prop('disabled');
    			var disableOrden = orden.prop('disabled'); 
    			
	    		var indiceSiguiente = i + 1;

    			for(var j = indiceSiguiente; j<numeroEtapas; j++){

    				var cambioFila = moduloActual.obj.grupoEtapa.getForm(j);
    				var cambioOrden = cambioFila.find("[elemento-grupo='ordenEtapa']");
    				
    				if(parseInt(orden.val()) > parseInt(cambioOrden.val())){

    	    			var cambioId 		= cambioFila.find("[elemento-grupo='idEtapa']");
    	    			var cambioNombre 	= cambioFila.find("[elemento-grupo='nombreEtapa']");
    	    			var cambioEstado 	= cambioFila.find("[elemento-grupo='estadoEtapa']");
    	    			var disableCambioNombre = cambioNombre.prop('disabled');
    	    			var disableCambioOrden = cambioOrden.prop('disabled'); 
    					
    					var idTemp = cambioId.val();
    					var nombreTemp = cambioNombre.val();
    					var estadoTemp = cambioEstado.val();
    					var ordenTemp = cambioOrden.val();
    					
    					cambioId.val(id.val());
    					cambioNombre.val(nombre.val());
    					cambioEstado.val(estado.val());
    					cambioOrden.val(orden.val());
    					cambioNombre.prop('disabled', disableNombre);
    					cambioOrden.prop('disabled', disableOrden);
    					
    					id.val(idTemp);
    					nombre.val(nombreTemp);
    					estado.val(estadoTemp);
    					orden.val(ordenTemp);
    					nombre.prop('disabled', disableCambioNombre);
    					orden.prop('disabled', disableCambioOrden);
    					disableNombre = disableCambioNombre;
    					disableOrden = disableCambioOrden;
    				}
    			}
	    	}
        } catch(error) {
        	console.log(error.message);
    	};
    });
    
    //Campos de vista
    this.obj.vistaId=$("#vistaId");
    this.obj.vistaNombre=$("#vistaNombre");
    this.obj.vistaAlias=$("#vistaAlias");
    this.obj.vistaIdCliente=$("#vistaIdCliente");
    this.obj.vistaIdRefPlantaRecepcion=$("#vistaIdRefPlantaRecepcion");
    this.obj.vistaIdRefDestMercaderia=$("#vistaIdRefDestMercaderia");
    this.obj.vistaFechaInicioPlanificacion=$("#vistaFechaInicioPlanificacion");
    this.obj.vistaPlantaDespacho=$("#vistaPlantaDespacho");
    this.obj.vistaETA=$("#vistaETA");
    this.obj.vistaCorreoPara=$("#vistaCorreoPara");
    this.obj.vistaCorreoCC=$("#vistaCorreoCC");
    this.obj.vistaIdCliente=$("#vistaIdCliente");
    this.obj.vistaVolumenPromedioCisterna=$("#vistaVolumenPromedioCisterna");
    this.obj.vistaEstado=$("#vistaEstado");
    this.obj.vistaCreadoEl=$("#vistaCreadoEl");
    this.obj.vistaCreadoPor=$("#vistaCreadoPor");
    this.obj.vistaActualizadoPor=$("#vistaActualizadoPor");
    this.obj.vistaActualizadoEl=$("#vistaActualizadoEl");
    this.obj.vistaIpCreacion=$("#vistaIpCreacion");
    this.obj.vistaIpActualizacion=$("#vistaIpActualizacion");
    
    //Campos Agregados por 9000002570=========================
    this.obj.cmpOperaciones=$("#cmpOperaciones");
    this.obj.cmpEtapaPlantaDespacho=$("#cmpEtapaPlantaDespacho");
    this.obj.cmpEtapaETA=$("#cmpEtapaETA");
    //========================================================
    
  };

  moduloActual.grillaDespuesSeleccionar= function(indice){
	  var ref=this;
		var estadoRegistro = ref.obj.datClienteApi.cell(indice,6).data();
		ref.estadoRegistro=estadoRegistro;
		if (estadoRegistro == constantes.ESTADO_ACTIVO) {
			ref.obj.btnModificarEstado.html('<i class="fa fa-cloud-download"></i> '+constantes.TITULO_DESACTIVAR_REGISTRO);			
		} else {
			ref.obj.btnModificarEstado.html('<i class="fa fa-cloud-upload"></i> '+constantes.TITULO_ACTIVAR_REGISTRO);			
		}
  };

  moduloActual.iniciarAgregar= function() {
	  
    var ref = this;
    
    try {
      ref.modoEdicion=constantes.MODO_NUEVO;
      ref.obj.tituloSeccion.text(cadenas.TITULO_AGREGAR_REGISTRO);
      ref.actualizarBandaInformacion(constantes.TIPO_MENSAJE_INFO,cadenas.INICIAR_OPERACION);
      ref.resetearFormulario();
      ref.obj.cntTabla.hide();
      ref.obj.cntVistaRegistro.hide();
      ref.obj.cntFormulario.show();
      ref.obj.ocultaContenedorFormulario.hide();
      ref.obj.grupoTransportista.removeAllForms();
      this.obj.grupoTransportista.addForm();
      
    } catch(error){
      ref.mostrarDepuracion(error.message);
    };
  };
  
//Agregado por 9000002570============================================
  moduloActual.llenarFormularioEtapas = function(registro){
	  this.idRegistroEtapas = registro.id;
	  this.obj.cmpOperaciones.val(registro.nombre + " / " + registro.cliente.nombreCorto);
	  this.obj.cmpEtapaPlantaDespacho.val(registro.plantaDespacho.descripcion);
	  this.obj.cmpEtapaETA.val(registro.eta); 
	  
	  var ordenEtapaTemp;
	  var nombreEtapaTemp;
	  
	  if(registro.etapas != null){
		  var numeroEtapas = registro.etapas.length;
	        this.obj.grupoEtapa.removeAllForms();
	        for(var contador=0; contador < numeroEtapas;contador++){
	          this.obj.grupoEtapa.addForm();
	          var formulario= this.obj.grupoEtapa.getForm(contador);
	          formulario.find("input[elemento-grupo='idEtapa']").val(registro.etapas[contador].id);
	          
	          nombreEtapaTemp = formulario.find("input[elemento-grupo='nombreEtapa']");
	          nombreEtapaTemp.val(registro.etapas[contador].nombreEtapa);
	          nombreEtapaTemp.prop('disabled', true);
	          
	          if(registro.etapas[contador].estado === 1){
	        	  formulario.find("input[elemento-grupo='estadoEtapa']").val('ACTIVO');
	        	  formulario.find("[elemento-grupo='botonCambiarEstado']").html('<i class="fa fa-cloud-download"></i>');
	          }else{
	        	  formulario.find("input[elemento-grupo='estadoEtapa']").val('INACTIVO');
	        	  formulario.find("[elemento-grupo='botonCambiarEstado']").html('<i class="fa fa-cloud-upload"></i>');
	          }
	          
	          ordenEtapaTemp = formulario.find("input[elemento-grupo='ordenEtapa']");
	          ordenEtapaTemp.val(registro.etapas[contador].orden);
	          ordenEtapaTemp.prop('disabled', true);
	          
	        }
	  }else{
		  this.obj.grupoEtapa.removeAllForms();
	  }
  };
  
  moduloActual.recuperarValoresEtapas = function(registro){
	  var eRegistro = {};
	  var ref=this;
	  try {
		  var idOperacion = parseInt(ref.idRegistroEtapas);
		  eRegistro.id = idOperacion;
		  
		  eRegistro.etapas=[];  
		  var numeroFormularios = ref.obj.grupoEtapa.getForms().length;
		  var nombreEtapasEnGrilla = [];
		  for(var contador = 0;contador < numeroFormularios; contador++){
			  var etapa = {};
			  var formulario= this.obj.grupoEtapa.getForm(contador);
			  etapa.id = formulario.find("input[elemento-grupo='idEtapa']").val();
			  etapa.idOperacion = idOperacion;
			  etapa.nombreEtapa = formulario.find("input[elemento-grupo='nombreEtapa']").val();
			  
			  if(etapa.nombreEtapa === ''){
				  ref.actualizarBandaInformacion(constantes.TIPO_MENSAJE_ERROR, "Debe completar el nombre de la etapa en la fila " + (contador + 1));
				  return null;
			  }
			  
			  for(var x = 0; x < nombreEtapasEnGrilla.length; x++){
				    if(nombreEtapasEnGrilla[x] === etapa.nombreEtapa){
				    	ref.actualizarBandaInformacion(constantes.TIPO_MENSAJE_ERROR, "El nombre de etapa en la fila " + (contador + 1) + " está repetido. Por favor revisar.");
						return null;
				    }
			  }
			  
			  nombreEtapasEnGrilla.push(etapa.nombreEtapa);
			  
			  var estadoTemp = formulario.find("input[elemento-grupo='estadoEtapa']").val();

			  if(estadoTemp === 'ACTIVO'){
				  etapa.estado = 1;
			  } else {
				  etapa.estado = 0;
			  }
			  
			  etapa.orden = parseInt(formulario.find("input[elemento-grupo='ordenEtapa']").val());
			  
			  if(isNaN(etapa.orden)){
				  ref.actualizarBandaInformacion(constantes.TIPO_MENSAJE_ERROR, "Debe completar correctamente el orden de la etapa en la fila " + (contador + 1));
				  return null;
			  }
			  
			  eRegistro.etapas.push(etapa);
		  }

	  }catch(error) {
		  console.log(error.message);
	  }

	  return eRegistro;
  };

  moduloActual.llenarFormulario = function(registro) {

    this.idRegistro = registro.id;
    this.obj.cmpNombre.val(registro.nombre);
    this.obj.cmpAlias.val(registro.alias);
    this.obj.cmpIdRefPlantaRecepcion.val(registro.referenciaPlantaRecepcion);
    this.obj.cmpIdRefDestMercaderia.val(registro.referenciaDestinatarioMercaderia);
    this.obj.cmpFechaInicioPlanificacion.val(utilitario.formatearFecha(registro.fechaInicioPlanificacion));
    this.obj.cmpVolumenPromedioCisterna.val(registro.volumenPromedioCisterna);
    this.obj.cmpSincronizadoEl.val(registro.sincronizadoEl);
    this.obj.cmpETA.val(registro.eta);
    this.obj.cmpCorreoPara.val(registro.correoPara);
    this.obj.cmpCorreoCC.val(registro.correoCC);
    
    $(cmpPlantaDespacho).find("option:selected").val(registro.plantaDespacho.id);
	$(cmpPlantaDespacho).val(registro.plantaDespacho.id).trigger('change');
	$(cmpTipoVolumenDescargado).val(registro.tipoVolumenDescargado).trigger('change');
	$(cmpTipoRegistroTanqueDescarga).val(registro.indicadorTipoRegistroTanque).change();

    var elemento = constantes.PLANTILLA_OPCION_SELECTBOX;
    elemento = elemento.replace(constantes.ID_OPCION_CONTENEDOR, registro.cliente.id);
    elemento = elemento.replace(constantes.VALOR_OPCION_CONTENEDOR, registro.cliente.razonSocial);
    this.obj.cmpIdCliente.empty().append(elemento).val(registro.cliente.id).trigger('change');

    if (registro.transportistas != null) {
        var numeroTransportistas = registro.transportistas.length;
        this.obj.grupoTransportista.removeAllForms();
        
        for(var contador=0; contador < numeroTransportistas;contador++){
        	this.obj.grupoTransportista.addForm();
        	var formulario= this.obj.grupoTransportista.getForm(contador);
        	formulario.find("select[elemento-grupo='idTransportista']").val(registro.transportistas[contador].id).trigger('change');
        }
    } else {
    	this.obj.grupoTransportista.removeAllForms();
    }
  };

  moduloActual.llenarDetalles = function(registro) {
	  
	  
	  console.log(" ***** moduloActual.llenarDetalles ******** ");
	  console.dir(registro);
	  
	  
	  
    this.idRegistro = registro.id;    
    this.obj.vistaId.text(registro.id);
    this.obj.vistaNombre.text(registro.nombre);
    this.obj.vistaAlias.text(registro.alias);
    this.obj.vistaIdCliente.text(registro.cliente.razonSocial);
    this.obj.vistaIdRefPlantaRecepcion.text(registro.referenciaPlantaRecepcion);
    this.obj.vistaIdRefDestMercaderia.text(registro.referenciaDestinatarioMercaderia);
    this.obj.vistaFechaInicioPlanificacion.text(utilitario.formatearFecha(registro.fechaInicioPlanificacion));
    this.obj.vistaVolumenPromedioCisterna.text(registro.volumenPromedioCisterna);
    this.obj.vistaPlantaDespacho.text(registro.plantaDespacho.descripcion);
    this.obj.vistaETA.text(registro.eta);
    this.obj.vistaCorreoPara.text(registro.correoPara);
    this.obj.vistaCorreoCC.text(registro.correoCC);
    this.obj.vistaEstado.text(utilitario.formatearEstado(registro.estado));   
    this.obj.vistaCreadoEl.text(registro.fechaCreacion);
    this.obj.vistaCreadoPor.text(registro.usuarioCreacion);
    this.obj.vistaActualizadoEl.text(registro.fechaActualizacion);
    this.obj.vistaActualizadoPor.text(registro.usuarioActualizacion);
    this.obj.vistaIpCreacion.text(registro.ipCreacion);
    this.obj.vistaIpActualizacion.text(registro.ipActualizacion);
    
    var indice= registro.transportistas.length;
    var grilla = $('#grilla_x');
    $('#grilla_x').html("");
    
    g_tr = '<tr><td> ID:</td><td>' +registro.id+ '</td></tr>';
    grilla.append(g_tr);
    g_tr = '<tr><td> Nombre:</td><td>' + registro.nombre + '</td></tr>';
    grilla.append(g_tr);
    g_tr = '<tr><td> Alias:</td><td>' + registro.alias + '</td></tr>';
    grilla.append(g_tr);
    g_tr = '<tr><td> Cliente:</td><td>' + registro.cliente.razonSocial + '</td></tr>';
    grilla.append(g_tr);
    g_tr = '<tr><td> Fecha de inicio de planificaci&oacuten:</td><td>' + utilitario.formatearFecha(registro.fechaInicioPlanificacion) + '</td></tr>';
    grilla.append(g_tr);
    g_tr = '<tr><td> Referencia Planta Recepci&oacuten:</td><td>'+ registro.referenciaPlantaRecepcion + '</td></tr>';
    grilla.append(g_tr);
    g_tr = '<tr><td> Referencia Destinatario Mercader&iacutea:</td><td>' + registro.referenciaDestinatarioMercaderia + '</td></tr>';
    grilla.append(g_tr);
    g_tr = '<tr><td> Volumen Promedio Cisterna:</td><td>' + registro.volumenPromedioCisterna + '</td></tr>';
    grilla.append(g_tr);
    g_tr = '<tr><td> Planta de despacho:</td><td>' + registro.plantaDespacho.descripcion + '</td></tr>';
    grilla.append(g_tr);
    g_tr = '<tr><td> ETA:</td><td>' + registro.eta + '</td></tr>';
    grilla.append(g_tr);
    g_tr = '<tr><td> Considerar volumen descargado:</td><td>' + registro.tipoVolumenDescargadotxt + '</td></tr>';
    grilla.append(g_tr);
    g_tr = '<tr><td> Tipo de registro Tanque en Descarga:</td><td>' + utilitario.tipoRegistroTanque(registro.indicadorTipoRegistroTanque) + '</td></tr>';
    grilla.append(g_tr);
    g_tr = '<tr><td> Para:</td><td>' + registro.correoPara + '</td></tr>';
    grilla.append(g_tr);
    g_tr = '<tr><td> CC:</td><td>' + registro.correoCC + '</td></tr>';
    grilla.append(g_tr);
    
    if (indice > 0) {
    	g_tr = '<tr><td> Transportistas: </td><td>' +registro.transportistas[0].razonSocial+ '</td></tr>';
		grilla.append(g_tr);
		
		for(var j=1; j < indice; j++){ 	
			var descripcion = registro.transportistas[j].razonSocial;
			g_tr = '<tr><td></td><td>' +descripcion+ '</td></tr>';
			grilla.append(g_tr);
		}
    } else {
    	var g_tr = '<tr><td> Transportistas: </td><td></td></tr> ';  
    	grilla.append(g_tr);
    }
    
    g_tr = '<tr><td> Estado:</td><td>' +utilitario.formatearEstado(registro.estado)+ '</td></tr>';
    grilla.append(g_tr);
    g_tr = '<tr><td> Creado el:</td><td>' +registro.fechaCreacion+ '</td></tr>';
    grilla.append(g_tr);
    g_tr = '<tr><td> Creado por:</td><td>' +registro.usuarioCreacion+ '</td></tr>';
    grilla.append(g_tr);
    g_tr = '<tr><td> Actualizado el:</td><td>' +registro.fechaActualizacion+ '</td></tr>';
    grilla.append(g_tr);
    g_tr = '<tr><td> Actualizado por:</td><td>' +registro.usuarioActualizacion+ '</td></tr>';
    grilla.append(g_tr);
    g_tr = '<tr><td> IP (Creaci&oacute;n):</td><td>' +registro.ipCreacion+ '</td></tr>';
    grilla.append(g_tr);
    g_tr = '<tr><td> IP (Actualizacion):</td><td>' +registro.ipActualizacion+ '</td></tr>';
    grilla.append(g_tr);
    
    
    /**
     * Productos equivalentes
     */
    var listPe = registro.listProductoEquivalente;
    
    if (listPe == null || listPe.length <= 0) {
    	return false;
    }

	$("#detalleProductosEquivalentes tbody").empty();
    for (var k = 0; k < listPe.length; k++) { 
    	$nombreProductoSecundario = listPe[k].nombreProductoSecundario;
    	$nombreProductoPrincipal = listPe[k].nombreProductoPrincipal;
    	$estado = listPe[k].estado == 1 ? "ACTIVO" : "INACTIVO";
    	$row = '<tr><td class="text-left">'+$nombreProductoSecundario+'</td><td class="text-left">'+$nombreProductoPrincipal+'</td><td class="text-center">'+$estado+'</td></tr>';
    	$("#detalleProductosEquivalentes > tbody:last").append($row);
    }
    
  };

  moduloActual.iniciarGuardar = function(){
	  var ref = this;

	  try {
		  if((ref.obj.cmpIdRefDestMercaderia.val().trim() == "") && (ref.obj.cmpIdRefPlantaRecepcion.val().trim() == "")){
	    		ref.actualizarBandaInformacion(constantes.TIPO_MENSAJE_ERROR, "Debe informar el campo Referencia Planta Recepcion o el campo Referencia Destinatario Mercaderia.");
	    	} else if((ref.obj.cmpIdRefDestMercaderia.val().trim() != "") && (ref.obj.cmpIdRefPlantaRecepcion.val().trim() != "")){
	    		ref.actualizarBandaInformacion(constantes.TIPO_MENSAJE_ERROR, "Solo debe informar el campo Referencia Planta Recepcion o el campo Referencia Destinatario Mercaderia; no ambos.");
	    	} else {
			    if (ref.modoEdicion == constantes.MODO_NUEVO){
			    	ref.guardarRegistro();
			    } else if  (ref.modoEdicion == constantes.MODO_ACTUALIZAR){
			    	ref.actualizarRegistro();
			    }
	    	}
	  } catch(error) {
		  ref.mostrarDepuracion(error.message);
	  };
	};
  
  moduloActual.recuperarValores = function(registro) {
	  
    var eRegistro = {};
    var ref = this;
    
    try {

		eRegistro.id = parseInt(ref.idRegistro);
		eRegistro.nombre = ref.obj.cmpNombre.val().toUpperCase();
		eRegistro.alias = ref.obj.cmpAlias.val().toUpperCase();
		eRegistro.idCliente = parseInt(ref.obj.cmpIdCliente.val());
		eRegistro.referenciaPlantaRecepcion = ref.obj.cmpIdRefPlantaRecepcion.val();
		eRegistro.fechaInicioPlanificacion = utilitario.formatearStringToDate(ref.obj.cmpFechaInicioPlanificacion.val());
		eRegistro.referenciaDestinatarioMercaderia = ref.obj.cmpIdRefDestMercaderia.val();
		eRegistro.volumenPromedioCisterna = parseFloat(ref.obj.cmpVolumenPromedioCisterna.val().replace(moduloActual.SEPARADOR_MILES,"")); 
		eRegistro.idPlantaDespacho = parseInt(ref.obj.cmpPlantaDespacho.val());
		eRegistro.tipoRegistroTanqueDescarga = parseInt(ref.obj.cmpTipoRegistroTanqueDescarga.val());
		eRegistro.eta = parseInt(ref.obj.cmpETA.val());
		eRegistro.indicadorTipoRegistroTanque = parseInt(ref.obj.cmpTipoRegistroTanqueDescarga.val());
		eRegistro.correoPara = ref.obj.cmpCorreoPara.val();
		eRegistro.correoCC = ref.obj.cmpCorreoCC.val();
		eRegistro.tipoVolumenDescargado = parseInt(ref.obj.cmpTipoVolumenDescargado.val());
		
		eRegistro.transportistas = [];   
	    var numeroFormularios = ref.obj.grupoTransportista.getForms().length;
	    for(var contador = 0;contador < numeroFormularios; contador++){
		    var transportista = {};
		    var formulario = ref.obj.grupoTransportista.getForm(contador);
		    var cmpIdTransportista = formulario.find("select[elemento-grupo='idTransportista']");

		    transportista.id = parseInt(cmpIdTransportista.val());
		    eRegistro.transportistas.push(transportista);
	    }

    }  catch(error){
      console.log(error.message);
    }

    return eRegistro;
  };
  
  moduloActual.recuperarProductosEquivalentes = function() {
	  
	$.ajax({
	    type: constantes.PETICION_TIPO_GET,
	    url: moduloActual.URL_RECUPERAR_PRODUCTOS_EQUIVALENTES, 
	    contentType: moduloActual.TIPO_CONTENIDO, 
	    data: {
	    	idOperacion: moduloActual.idRegistro
	    },	
	    success: function(respuesta) {
	    	
	    	if (!respuesta.estado) {
	    		moduloActual.actualizarBandaInformacion(constantes.TIPO_MENSAJE_ERROR, respuesta.mensaje);
	    	} else {
	    		
	    		var listProdEquivalente = respuesta.contenido.carga[0].listProductoEquivalente;
	    		var listProductoPrincipal = respuesta.contenido.carga[0].listProductoPrincipal;

	    		$table = $("table.productos").find("tbody");
	    		$table.empty();
	    		$tableClone = $("table.productos-clone").find("tbody");
	    		$tableCloneEdit = $("table.productos-edit-clone").find("tbody");
	    		
	    		$cmpProductosPrincipales = $tableClone.find("select.cmpProductosPrincipales");
	    		$cmpProductosPrincipales.empty();
	    		$cmpProductosPrincipales.append($("<option>", {
		    		value: "",
		    		text: "[Seleccione]"
	    		}));
    			
	    		for (var j = 0; j < listProductoPrincipal.length; j++) {
	    			var prodPrincipal = listProductoPrincipal[j];
	    			$cmpProductosPrincipales.append($("<option>", {
			    		value: prodPrincipal.id,
			    		text: prodPrincipal.nombre
		    		}));
	    		}
	    		
	    		if (typeof listProdEquivalente == 'undefined' || listProdEquivalente.length == 0) {
	    			$table.append('<tr class="empty"><td class="celda-detalle" colspan="5">No se encontro productos asociados.</td></tr>');
	    		}
	    		
	    		for (var i = 0; i < listProdEquivalente.length; i++) {
	    			
	    			var prodEquivalente = listProdEquivalente[i];
	    			
		    		$trNew = $tableCloneEdit.find('tr:last').clone();
		    		$trNew.find("input.cmpProductosPrincipales").val(prodEquivalente.nombreProductoPrincipal);
		    		$trNew.find("input.cmpProductosSecundarios").val(prodEquivalente.nombreProductoSecundario);
		    		$trNew.find("input.update-producto-equivalente").attr("data-producto-equivalencia", prodEquivalente.idProductoEquivalencia);
		    		$trNew.find("input.estado").val("ACTIVO");
		    		$trNew.find("input.estado").attr("data-producto-equivalencia", prodEquivalente.idProductoEquivalencia);
		    		$trNew.find("input.update-producto-equivalente").prop("checked", true);
		    		$trNew.find("select.cmpProductosPrincipales").val();

		    		if (prodEquivalente.estado == constantes.ESTADO_INACTIVO) {
		    			$trNew.find("input.estado").val("INACTIVO");
		    			$trNew.find("input.update-producto-equivalente").prop("checked", false);
					}
		    		
		    		$table.append($trNew);
	    		}
	    		
	    		moduloActual.actualizarBandaInformacion(constantes.TIPO_MENSAJE_EXITO, respuesta.mensaje);
    			
    			$("#cntProductosEquivalentes input.operacion").val(respuesta.contenido.carga[0].nombre);
	    		moduloActual.obj.cntProductosEquivalentes.show();
	    		moduloActual.obj.cntTabla.hide();
	    		moduloActual.obj.ocultaContenedorProductosEquivalentes.hide();
	    		moduloActual.actualizarBandaInformacion(constantes.TIPO_MENSAJE_EXITO, "Se recupero el formulario de Productos Equivalentes");
			}
	    },			    		    
	    error: function(xhr, status, error) {
	    	moduloActual.mostrarErrorServidor(xhr, status, error);
	    }
	});
  };
  
  moduloActual.cerrarProductosEquivalentes = function() {
		
	  moduloActual.obj.tituloSeccion.text(cadenas.TITULO_LISTADO_REGISTROS); 
	  moduloActual.obj.cntProductosEquivalentes.hide();
		
//		this.obj.cntVistaRegistro.hide();
//		this.obj.ocultaContenedorVista.show();
		
	  moduloActual.obj.cntTabla.show();
	  moduloActual.actualizarBandaInformacion(constantes.TIPO_MENSAJE_INFO, "Se cerró la vista de Productos Equivalentes");
  };
  
  moduloActual.desactivarBotones = function() {
	moduloActual.obj.btnModificarEstado.html(constantes.BOTON_ACTIVAR + constantes.TITULO_ACTIVAR_REGISTRO);
	moduloActual.obj.btnModificar.addClass(constantes.CSS_CLASE_DESHABILITADA);
	moduloActual.obj.btnModificarEstado.addClass(constantes.CSS_CLASE_DESHABILITADA);
	moduloActual.obj.btnEtapas.addClass(constantes.CSS_CLASE_DESHABILITADA);
	moduloActual.obj.btnVer.addClass(constantes.CSS_CLASE_DESHABILITADA);
	moduloActual.obj.btnProductosEquivalentes.addClass(constantes.CSS_CLASE_DESHABILITADA);
  };
  
  moduloBase.prototype.activarBotones = function() {	  
	  moduloActual.obj.btnModificar.removeClass(constantes.CSS_CLASE_DESHABILITADA);
	  moduloActual.obj.btnModificarEstado.removeClass(constantes.CSS_CLASE_DESHABILITADA);
	  moduloActual.obj.btnVer.removeClass(constantes.CSS_CLASE_DESHABILITADA);
	  moduloActual.obj.btnEtapas.removeClass(constantes.CSS_CLASE_DESHABILITADA);
	  moduloActual.obj.btnProductosEquivalentes.removeClass(constantes.CSS_CLASE_DESHABILITADA);
  };
  
  moduloActual.agregarTrEquivalencia = function() {
	  $("tr.empty").remove();
      $tableClone = $('table.productos-clone').find('tbody');
      $trNew = $tableClone.find('tr:last').clone();
      $trNew.find("select.cmpProductosPrincipales").select2();
      $trNew.find("select.cmpProductosSecundarios").select2();
      
      $table = $('table.productos').find('tbody');
      $table.append($trNew);
  };
  
  moduloActual.guardarProductoEquivalencia = function() {

	  var object = {};
	  object.idOperacion = moduloActual.idRegistro;
	  object.productos = [];
	  
	  $("table.productos tbody tr.new").each(function(index, value) {
		  var obj = {};
		  obj.productoPrincipal = $(this).find("td").eq(0).find("option:selected").val();
		  obj.productoSecundario = $(this).find("td").eq(1).find("option:selected").val();
		  object.productos.push(obj);
	  });
	  
	  $.ajax({
			type: constantes.PETICION_TIPO_POST,
			url: moduloActual.URL_GUARDAR_PRODUCTOS_EQUIVALENTES, 
			contentType: moduloActual.TIPO_CONTENIDO, 
			data: JSON.stringify(object),
			success: function(respuesta) {
				if (!respuesta.estado) {
					moduloActual.actualizarBandaInformacion(constantes.TIPO_MENSAJE_ERROR, respuesta.mensaje);
				} else {
					moduloActual.obj.cntProductosEquivalentes.hide();
					moduloActual.obj.cntTabla.show();
					moduloActual.actualizarBandaInformacion(constantes.TIPO_MENSAJE_EXITO, "Productos equivalentes guardados con exito.");
				}
			},			    		    
			error: function(xhr, status, error) {
				moduloActual.mostrarErrorServidor(xhr, status, error);
			}
	  });
  };
  
  moduloActual.updateProductoEquivalencia = function(object) {
	  
	  $.ajax({
			type: constantes.PETICION_TIPO_POST,
			url: moduloActual.URL_UPDATE_PRODUCTOS_EQUIVALENTES, 
			contentType: moduloActual.TIPO_CONTENIDO, 
			data: JSON.stringify(object),
			success: function(respuesta) {
				if (!respuesta.estado) {
					moduloActual.actualizarBandaInformacion(constantes.TIPO_MENSAJE_ERROR, respuesta.mensaje);
					moduloActual.obj.modalEstadoProductoEquivalente.modal('hide');
				} else {
					moduloActual.actualizarBandaInformacion(constantes.TIPO_MENSAJE_EXITO, "Estado actualizado con exito!");
			    	$('input[type=text][data-producto-equivalencia="' + moduloActual.obj.updateEstado.idProductoEquivalencia + '"]').val(moduloActual.obj.updateEstado.checked ? "ACTIVO" : "INACTIVO");
			    	$('input[type=checkbox][data-producto-equivalencia="' + moduloActual.obj.updateEstado.idProductoEquivalencia + '"]').prop('checked', moduloActual.obj.updateEstado.checked);
			    	
			    	moduloActual.obj.updateEstado.checked = null;
			    	moduloActual.obj.updateEstado.idProductoEquivalencia = null;
			    	moduloActual.obj.modalEstadoProductoEquivalente.modal('hide');
				}
			},			    		    
			error: function(xhr, status, error) {
				moduloActual.mostrarErrorServidor(xhr, status, error);
			}
	  });
  };


  moduloActual.inicializar();
  
});