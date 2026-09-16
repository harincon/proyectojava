<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.math.BigDecimal,java.sql.Connection,java.sql.SQLException,java.util.ArrayList,java.util.Arrays,java.util.Collection,java.util.HashMap,java.util.HashSet,java.util.List,java.util.Map" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/modelo/propiedad.jspf" %>
<%@ include file="/WEB-INF/modelo/imagen_propiedad.jspf" %>
<%@ include file="/WEB-INF/modelo/propiedad_caracteristica.jspf" %>
<%@ include file="/WEB-INF/modelo/ciudad.jspf" %>
<%@ include file="/WEB-INF/modelo/tipo_propiedad.jspf" %>
<%@ include file="/WEB-INF/modelo/caracteristica.jspf" %>
<%@ include file="/WEB-INF/modelo/inmobiliaria.jspf" %>
<%--
  Publicaciones.
  Público:  GET ?accion=catalogo[&ciudad&tipo&operacion&precio_min&precio_max&caracteristica(varias)&q&orden&pagina]
            GET ?accion=detalle&id_propiedad=N
  Privado (INMOBILIARIA dueña o ADMINISTRADOR):
            GET  ?accion=gestionar[&q&pagina] | nueva | editar&id_propiedad=N
            POST ?accion=crear | actualizar&id_propiedad=N | cambiar_activa&id_propiedad=N (activa=true|false)
  La empresa responsable y el estado comercial no se cambian aquí; el cierre pertenece a B6.
--%>
<%!
    private static final int PROPIEDADES_POR_PAGINA = 9;

    // Lee y valida el formulario; deja los valores en "valores" y devuelve los datos listos para el modelo.
    private Map<String, Object> validarPropiedad(HttpServletRequest peticion, Map<String, String> valores,
            Map<String, String> errores) {
        String matricula = limpiar(peticion.getParameter("matricula"));
        String titulo = limpiar(peticion.getParameter("titulo"));
        String descripcion = limpiar(peticion.getParameter("descripcion"));
        String direccion = limpiar(peticion.getParameter("direccion"));
        String operacion = limpiar(peticion.getParameter("operacion"));
        Integer idCiudad = aEntero(peticion.getParameter("id_ciudad"));
        Integer idTipo = aEntero(peticion.getParameter("id_tipo_propiedad"));
        BigDecimal precio = aImporte(peticion.getParameter("precio"));
        BigDecimal area = aImporte(peticion.getParameter("area"));
        Integer habitaciones = aEntero(peticion.getParameter("habitaciones"));
        Integer banos = aEntero(peticion.getParameter("banos"));
        if (matricula != null) {
            matricula = matricula.toUpperCase(Locale.ROOT);
        }
        valores.put("matricula", matricula);
        valores.put("titulo", titulo);
        valores.put("descripcion", descripcion);
        valores.put("direccion", direccion);
        valores.put("operacion", operacion);
        valores.put("id_ciudad", idCiudad == null ? null : idCiudad.toString());
        valores.put("id_tipo_propiedad", idTipo == null ? null : idTipo.toString());
        valores.put("precio", peticion.getParameter("precio"));
        valores.put("area", peticion.getParameter("area"));
        valores.put("habitaciones", habitaciones == null ? null : habitaciones.toString());
        valores.put("banos", banos == null ? null : banos.toString());

        if (matricula == null || !matricula.matches("[0-9A-Z-]{5,50}")) {
            errores.put("matricula", "La matrícula debe tener entre 5 y 50 letras, números o guiones.");
        }
        if (!longitudValida(titulo, 3, 150)) {
            errores.put("titulo", "Escribe un título de 3 a 150 caracteres.");
        }
        if (!longitudValida(descripcion, 0, 2000)) {
            errores.put("descripcion", "La descripción admite máximo 2000 caracteres.");
        }
        if (!longitudValida(direccion, 3, 200)) {
            errores.put("direccion", "Escribe la dirección (3 a 200 caracteres).");
        }
        if (idCiudad == null) {
            errores.put("id_ciudad", "Elige la ciudad.");
        }
        if (idTipo == null) {
            errores.put("id_tipo_propiedad", "Elige el tipo de inmueble.");
        }
        if (!"VENTA".equals(operacion) && !"ARRIENDO".equals(operacion)) {
            errores.put("operacion", "Elige venta o arriendo.");
        }
        if (precio == null || precio.signum() <= 0 || precio.precision() - precio.scale() > 12) {
            errores.put("precio", "Escribe un precio mayor que cero.");
        }
        if (area == null || area.signum() <= 0 || area.precision() - area.scale() > 8) {
            errores.put("area", "Escribe el área en metros cuadrados, mayor que cero.");
        }
        if (habitaciones == null || habitaciones < 0 || habitaciones > 50) {
            errores.put("habitaciones", "Escribe un número de habitaciones entre 0 y 50.");
        }
        if (banos == null || banos < 0 || banos > 50) {
            errores.put("banos", "Escribe un número de baños entre 0 y 50.");
        }
        if (!errores.isEmpty()) {
            return null;
        }
        Map<String, Object> datos = new HashMap<String, Object>();
        datos.put("matricula", matricula);
        datos.put("titulo", titulo);
        datos.put("descripcion", descripcion);
        datos.put("direccion", direccion);
        datos.put("operacion", operacion);
        datos.put("idCiudad", idCiudad);
        datos.put("idTipoPropiedad", idTipo);
        datos.put("precio", precio);
        datos.put("area", area);
        datos.put("habitaciones", habitaciones);
        datos.put("banos", banos);
        return datos;
    }

    // Identificadores de características marcados en el formulario.
    private List<Integer> caracteristicasElegidas(HttpServletRequest peticion) {
        List<Integer> elegidas = new ArrayList<Integer>();
        String[] recibidas = peticion.getParameterValues("caracteristica");
        if (recibidas != null) {
            for (String valor : recibidas) {
                Integer id = aEntero(valor);
                if (id != null && !elegidas.contains(id)) {
                    elegidas.add(id);
                }
            }
        }
        return elegidas;
    }
%>
<%
    String ctx = request.getContextPath();
    String accion = limpiar(request.getParameter("accion"));
    boolean esPost = "POST".equals(request.getMethod());
    Integer idPropiedad = aEntero(request.getParameter("id_propiedad"));
    Map<String, String> errores = new HashMap<String, String>();
    Map<String, String> valores = new HashMap<String, String>();

    // ---------- Acciones públicas ----------
    if (accion == null || "catalogo".equals(accion)) {
        Map<String, Object> filtros = new HashMap<String, Object>();
        filtros.put("publicas", Boolean.TRUE);
        filtros.put("idCiudad", aEntero(request.getParameter("ciudad")));
        filtros.put("idTipoPropiedad", aEntero(request.getParameter("tipo")));
        String operacion = limpiar(request.getParameter("operacion"));
        if ("VENTA".equals(operacion) || "ARRIENDO".equals(operacion)) {
            filtros.put("operacion", operacion);
        }
        String estado = limpiar(request.getParameter("estado"));
        filtros.put("estado", "TODOS".equals(estado) ? null : "DISPONIBLE");
        filtros.put("precioMinimo", aImporte(request.getParameter("precio_min")));
        filtros.put("precioMaximo", aImporte(request.getParameter("precio_max")));
        filtros.put("texto", limpiar(request.getParameter("q")));
        List<Integer> caracteristicas = caracteristicasElegidas(request);
        filtros.put("caracteristicas", caracteristicas);

        String orden = limpiar(request.getParameter("orden"));
        Integer paginaPedida = aEntero(request.getParameter("pagina"));
        int pagina = paginaPedida == null || paginaPedida < 1 ? 1 : paginaPedida;
        try (Connection conexion = abrirConexion()) {
            int total = contarPropiedades(conexion, filtros);
            int paginas = Math.max(1, (total + PROPIEDADES_POR_PAGINA - 1) / PROPIEDADES_POR_PAGINA);
            pagina = Math.min(pagina, paginas);
            request.setAttribute("propiedades",
                    listarPropiedades(conexion, filtros, orden, PROPIEDADES_POR_PAGINA, (pagina - 1) * PROPIEDADES_POR_PAGINA));
            request.setAttribute("total", total);
            request.setAttribute("pagina", pagina);
            request.setAttribute("paginas", paginas);
            request.setAttribute("ciudades", listarCiudades(conexion));
            request.setAttribute("tipos", listarTiposPropiedad(conexion));
            request.setAttribute("caracteristicas", listarCaracteristicas(conexion));
        }
        request.setAttribute("elegidas", caracteristicas);
        request.setAttribute("orden", orden);
        request.getRequestDispatcher("/WEB-INF/vista/catalogo.jsp").forward(request, response);
        return;
    }

    if ("detalle".equals(accion)) {
        if (idPropiedad == null) {
            response.sendRedirect(ctx + "/controlador/propiedad.jsp?accion=catalogo");
            return;
        }
        Object rolesSesionObjeto = session.getAttribute("roles");
        Object idSesionObjeto = session.getAttribute("idUsuario");
        boolean sesionAdmin = rolesSesionObjeto instanceof Collection && ((Collection<?>) rolesSesionObjeto).contains("ADMINISTRADOR");
        try (Connection conexion = abrirConexion()) {
            Map<String, Object> propiedad = buscarPropiedad(conexion, idPropiedad);
            boolean esResponsable = propiedad != null && idSesionObjeto != null
                    && idSesionObjeto.equals(propiedad.get("idResponsable"));
            // Una publicación retirada solo la ve su empresa o el administrador.
            if (propiedad == null || (!(Boolean) propiedad.get("activa") && !sesionAdmin && !esResponsable)) {
                session.setAttribute("mensajeError", "La propiedad no está disponible.");
                response.sendRedirect(ctx + "/controlador/propiedad.jsp?accion=catalogo");
                return;
            }
            request.setAttribute("propiedad", propiedad);
            request.setAttribute("imagenes", listarImagenes(conexion, idPropiedad));
            request.setAttribute("caracteristicas", caracteristicasDePropiedad(conexion, idPropiedad));
            Map<String, Object> similares = new HashMap<String, Object>();
            similares.put("publicas", Boolean.TRUE);
            similares.put("estado", "DISPONIBLE");
            similares.put("idCiudad", propiedad.get("idCiudad"));
            List<Map<String, Object>> parecidas = new ArrayList<Map<String, Object>>();
            for (Map<String, Object> otra : listarPropiedades(conexion, similares, null, 4, 0)) {
                if (!otra.get("idPropiedad").equals(propiedad.get("idPropiedad")) && parecidas.size() < 3) {
                    parecidas.add(otra);
                }
            }
            request.setAttribute("parecidas", parecidas);
            request.setAttribute("puedeEditar", sesionAdmin || esResponsable);
        }
        request.getRequestDispatcher("/WEB-INF/vista/propiedad.jsp").forward(request, response);
        return;
    }
%>
<%
    request.setAttribute("rolesPermitidos", new HashSet<String>(Arrays.asList("ADMINISTRADOR", "INMOBILIARIA")));
%>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    // ---------- Acciones privadas ----------
    boolean esAdmin = rolesUsuario.contains("ADMINISTRADOR");
    Integer miInmobiliaria = null;
    try (Connection conexion = abrirConexion()) {
        Map<String, Object> empresa = buscarInmobiliariaPorUsuario(conexion, idUsuarioSesion);
        if (empresa != null) {
            miInmobiliaria = (Integer) empresa.get("idInmobiliaria");
        }
    }
    if (miInmobiliaria == null && !esAdmin) {
        session.setAttribute("mensajeError", "Tu cuenta no tiene una empresa vinculada.");
        response.sendRedirect(ctx + "/controlador/inmobiliaria.jsp?accion=empresa");
        return;
    }
    String destinoGestion = ctx + "/controlador/propiedad.jsp?accion=gestionar";

    // Propiedad sobre la que se actúa y comprobación de pertenencia.
    Map<String, Object> propiedadActual = null;
    if (idPropiedad != null && !"crear".equals(accion)) {
        try (Connection conexion = abrirConexion()) {
            propiedadActual = buscarPropiedad(conexion, idPropiedad);
        }
        if (propiedadActual == null) {
            session.setAttribute("mensajeError", "La propiedad no existe.");
            response.sendRedirect(destinoGestion);
            return;
        }
        if (!esAdmin && !propiedadActual.get("idInmobiliaria").equals(miInmobiliaria)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
    }

    if ("cambiar_activa".equals(accion) && esPost) {
        boolean activar = "true".equals(request.getParameter("activa"));
        if (!tokenValido(request)) {
            session.setAttribute("mensajeError", "El formulario expiró. Vuelve a intentarlo.");
        } else if (propiedadActual == null) {
            session.setAttribute("mensajeError", "No se indicó la propiedad.");
        } else {
            try (Connection conexion = abrirConexion()) {
                cambiarActivaPropiedad(conexion, idPropiedad, activar);
                session.setAttribute("mensaje", activar ? "Publicación activada." : "Publicación retirada del catálogo.");
            }
        }
        response.sendRedirect(destinoGestion);
        return;
    }

    if (("crear".equals(accion) || "actualizar".equals(accion)) && esPost) {
        boolean creando = "crear".equals(accion);
        Map<String, Object> datos = validarPropiedad(request, valores, errores);
        List<Integer> elegidas = caracteristicasElegidas(request);
        boolean destacada = esAdmin ? request.getParameter("destacada") != null
                : propiedadActual != null && (Boolean) propiedadActual.get("destacada");
        Integer idEmpresa = esAdmin ? aEntero(request.getParameter("id_inmobiliaria")) : miInmobiliaria;
        if (creando && esAdmin && idEmpresa == null) {
            errores.put("id_inmobiliaria", "Elige la empresa que publica.");
        }
        if (!tokenValido(request)) {
            errores.put("general", "El formulario expiró. Vuelve a intentarlo.");
        }
        if (!creando && propiedadActual == null) {
            response.sendRedirect(destinoGestion);
            return;
        }

        if (errores.isEmpty() && datos != null) {
            datos.put("destacada", Boolean.valueOf(destacada));
            datos.put("idInmobiliaria", creando ? idEmpresa : propiedadActual.get("idInmobiliaria"));
            Connection conexion = null;
            try {
                conexion = abrirConexion();
                conexion.setAutoCommit(false);
                int idGuardada;
                if (creando) {
                    idGuardada = crearPropiedad(conexion, datos);
                } else {
                    idGuardada = idPropiedad.intValue();
                    actualizarPropiedad(conexion, idGuardada, datos);
                }
                reemplazarCaracteristicas(conexion, idGuardada, elegidas);
                conexion.commit();
                session.setAttribute("mensaje", creando
                        ? "Propiedad publicada. Agrega sus fotografías." : "Propiedad actualizada.");
                response.sendRedirect(ctx + "/controlador/propiedad.jsp?accion=editar&id_propiedad=" + idGuardada);
                return;
            } catch (SQLException e) {
                if (conexion != null) {
                    try { conexion.rollback(); } catch (SQLException ignorada) { }
                }
                if ("23505".equals(e.getSQLState())) {
                    errores.put("matricula", "Ya existe una propiedad con esa matrícula.");
                } else {
                    errores.put("general", mensajeError(e));
                }
            } finally {
                if (conexion != null) {
                    try { conexion.close(); } catch (SQLException ignorada) { }
                }
            }
        }
        request.setAttribute("elegidas", elegidas);
        accion = creando ? "nueva" : "editar";
    }

    if ("nueva".equals(accion) || "editar".equals(accion)) {
        boolean editando = "editar".equals(accion);
        if (editando && propiedadActual == null) {
            response.sendRedirect(destinoGestion);
            return;
        }
        try (Connection conexion = abrirConexion()) {
            request.setAttribute("ciudades", listarCiudades(conexion));
            request.setAttribute("tipos", listarTiposPropiedad(conexion));
            request.setAttribute("caracteristicas", listarCaracteristicas(conexion));
            if (esAdmin) {
                request.setAttribute("empresas", listarInmobiliarias(conexion, null, 200, 0));
            }
            if (editando) {
                request.setAttribute("imagenes", listarImagenes(conexion, idPropiedad));
                if (request.getAttribute("elegidas") == null) {
                    request.setAttribute("elegidas", new ArrayList<Integer>(idsCaracteristicas(conexion, idPropiedad)));
                }
                if (valores.isEmpty()) {
                    valores.put("matricula", (String) propiedadActual.get("matricula"));
                    valores.put("titulo", (String) propiedadActual.get("titulo"));
                    valores.put("descripcion", (String) propiedadActual.get("descripcion"));
                    valores.put("direccion", (String) propiedadActual.get("direccion"));
                    valores.put("operacion", (String) propiedadActual.get("operacion"));
                    valores.put("id_ciudad", String.valueOf(propiedadActual.get("idCiudad")));
                    valores.put("id_tipo_propiedad", String.valueOf(propiedadActual.get("idTipoPropiedad")));
                    valores.put("precio", formatoArea((BigDecimal) propiedadActual.get("precio")));
                    valores.put("area", formatoArea((BigDecimal) propiedadActual.get("area")));
                    valores.put("habitaciones", String.valueOf(propiedadActual.get("habitaciones")));
                    valores.put("banos", String.valueOf(propiedadActual.get("banos")));
                    valores.put("id_inmobiliaria", String.valueOf(propiedadActual.get("idInmobiliaria")));
                    valores.put("destacada", Boolean.TRUE.equals(propiedadActual.get("destacada")) ? "1" : null);
                }
            }
        }
        request.setAttribute("propiedad", propiedadActual);
        request.setAttribute("modo", editando ? "editar" : "nueva");
        request.setAttribute("esAdmin", Boolean.valueOf(esAdmin));
        request.setAttribute("errores", errores);
        request.setAttribute("valores", valores);
        request.getRequestDispatcher("/WEB-INF/vista/formulario_propiedad.jsp").forward(request, response);
        return;
    }

    // ---------- Gestión ----------
    Map<String, Object> filtros = new HashMap<String, Object>();
    if (!esAdmin) {
        filtros.put("idInmobiliaria", miInmobiliaria);
    }
    filtros.put("texto", limpiar(request.getParameter("q")));
    Integer paginaPedida = aEntero(request.getParameter("pagina"));
    int pagina = paginaPedida == null || paginaPedida < 1 ? 1 : paginaPedida;
    try (Connection conexion = abrirConexion()) {
        int total = contarPropiedades(conexion, filtros);
        int paginas = Math.max(1, (total + PROPIEDADES_POR_PAGINA - 1) / PROPIEDADES_POR_PAGINA);
        pagina = Math.min(pagina, paginas);
        request.setAttribute("propiedades",
                listarPropiedades(conexion, filtros, null, PROPIEDADES_POR_PAGINA, (pagina - 1) * PROPIEDADES_POR_PAGINA));
        request.setAttribute("total", total);
        request.setAttribute("pagina", pagina);
        request.setAttribute("paginas", paginas);
    }
    request.setAttribute("busqueda", limpiar(request.getParameter("q")));
    request.setAttribute("esAdmin", Boolean.valueOf(esAdmin));
    request.getRequestDispatcher("/WEB-INF/vista/propiedades.jsp").forward(request, response);
%>
