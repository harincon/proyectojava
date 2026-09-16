<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection,java.sql.SQLException,java.util.Arrays,java.util.HashMap,java.util.HashSet,java.util.Map" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/modelo/solicitud.jspf" %>
<%@ include file="/WEB-INF/modelo/documento_solicitud.jspf" %>
<%@ include file="/WEB-INF/modelo/propiedad.jspf" %>
<%@ include file="/WEB-INF/modelo/inmobiliaria.jspf" %>
<%
    request.setAttribute("rolesPermitidos", new HashSet<String>(Arrays.asList("CLIENTE", "INMOBILIARIA")));
%>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    String ctx = request.getContextPath();
    String accion = limpiar(request.getParameter("accion"));
    boolean esPost = "POST".equals(request.getMethod());
    boolean esAdmin = rolesUsuario.contains("ADMINISTRADOR");
    boolean esCliente = rolesUsuario.contains("CLIENTE");
    boolean esInmobiliaria = rolesUsuario.contains("INMOBILIARIA");
    Integer idPropiedad = aEntero(request.getParameter("id_propiedad"));
    Integer idSolicitud = aEntero(request.getParameter("id_solicitud"));
    String destinoCliente = ctx + "/controlador/solicitud.jsp?accion=mis_solicitudes";
    String destinoEmpresa = ctx + "/controlador/solicitud.jsp?accion=recibidas";
    Map<String, String> errores = new HashMap<String, String>();
    Map<String, String> valores = new HashMap<String, String>();

    if (accion == null) {
        accion = esCliente ? "mis_solicitudes" : "recibidas";
    }

    if ("nueva".equals(accion) || "crear".equals(accion)) {
        if (!esCliente) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        if (idPropiedad == null) {
            session.setAttribute("mensajeError", "No se indicó la propiedad.");
            response.sendRedirect(ctx + "/controlador/propiedad.jsp?accion=catalogo");
            return;
        }

        if ("crear".equals(accion)) {
            if (!esPost) {
                response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
                return;
            }
            String observacion = limpiar(request.getParameter("observacion"));
            valores.put("observacion", observacion);
            if (!tokenValido(request)) {
                errores.put("general", "El formulario expiró. Vuelve a intentarlo.");
            }
            if (observacion != null && observacion.length() > 1000) {
                errores.put("observacion", "La descripción admite máximo 1000 caracteres.");
            }

            if (errores.isEmpty()) {
                Connection conexion = null;
                try {
                    conexion = abrirConexion();
                    conexion.setAutoCommit(false);
                    Map<String, Object> propiedadBloqueada = bloquearPropiedadSolicitud(conexion, idPropiedad);
                    if (propiedadBloqueada == null || !(Boolean) propiedadBloqueada.get("activa")
                            || !"DISPONIBLE".equals(propiedadBloqueada.get("estado"))) {
                        errores.put("general", "La propiedad no está activa y disponible.");
                    } else if (existeSolicitudAbierta(conexion, idUsuarioSesion, idPropiedad)) {
                        errores.put("general", "Ya tienes una solicitud abierta para esta propiedad.");
                    } else {
                        int nueva = crearSolicitud(conexion, idUsuarioSesion, idPropiedad, observacion);
                        conexion.commit();
                        session.setAttribute("mensaje", "Solicitud radicada correctamente.");
                        response.sendRedirect(ctx + "/controlador/solicitud.jsp?accion=detalle&id_solicitud=" + nueva);
                        return;
                    }
                    conexion.rollback();
                } catch (SQLException e) {
                    if (conexion != null) {
                        try { conexion.rollback(); } catch (SQLException ignorada) { }
                    }
                    errores.put("general", mensajeError(e));
                } finally {
                    if (conexion != null) {
                        try { conexion.close(); } catch (SQLException ignorada) { }
                    }
                }
            }
            accion = "nueva";
        }

        try (Connection conexion = abrirConexion()) {
            Map<String, Object> propiedad = buscarPropiedad(conexion, idPropiedad);
            if (propiedad == null || !(Boolean) propiedad.get("activa")
                    || !"DISPONIBLE".equals(propiedad.get("estado"))) {
                session.setAttribute("mensajeError", "La propiedad no está disponible para solicitudes.");
                response.sendRedirect(ctx + "/controlador/propiedad.jsp?accion=catalogo");
                return;
            }
            request.setAttribute("propiedad", propiedad);
        }
        request.setAttribute("errores", errores);
        request.setAttribute("valores", valores);
        request.getRequestDispatcher("/WEB-INF/vista/formulario_solicitud.jsp").forward(request, response);
        return;
    }

    boolean revisar = "revisar".equals(accion);
    boolean finalizar = "finalizar".equals(accion);
    if (revisar || finalizar) {
        if (!esPost) {
            response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            return;
        }
        if (!esInmobiliaria && !esAdmin) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        if (!tokenValido(request)) {
            session.setAttribute("mensajeError", "El formulario expiró. Vuelve a intentarlo.");
            response.sendRedirect(idSolicitud == null ? destinoEmpresa
                    : ctx + "/controlador/solicitud.jsp?accion=detalle&id_solicitud=" + idSolicitud);
            return;
        }
        if (idSolicitud == null) {
            session.setAttribute("mensajeError", "No se indicó la solicitud.");
            response.sendRedirect(destinoEmpresa);
            return;
        }

        String nuevoEstado = revisar ? limpiar(request.getParameter("estado")) : "FINALIZADA";
        String observacionRevision = revisar ? limpiar(request.getParameter("observacion")) : null;
        if (revisar && !("APROBADA".equals(nuevoEstado) || "RECHAZADA".equals(nuevoEstado))) {
            session.setAttribute("mensajeError", "El estado solicitado no es válido.");
            response.sendRedirect(ctx + "/controlador/solicitud.jsp?accion=detalle&id_solicitud=" + idSolicitud);
            return;
        }
        if (revisar && !longitudValida(observacionRevision, 1, 1000)) {
            session.setAttribute("mensajeError", "Escribe una observación de máximo 1000 caracteres.");
            response.sendRedirect(ctx + "/controlador/solicitud.jsp?accion=detalle&id_solicitud=" + idSolicitud);
            return;
        }

        Connection conexion = null;
        try {
            conexion = abrirConexion();
            conexion.setAutoCommit(false);
            Integer propiedadSolicitud = idPropiedadDeSolicitud(conexion, idSolicitud);
            if (propiedadSolicitud == null) {
                conexion.rollback();
                session.setAttribute("mensajeError", "La solicitud no existe.");
                response.sendRedirect(destinoEmpresa);
                return;
            }
            Map<String, Object> propiedadBloqueada = bloquearPropiedadSolicitud(conexion, propiedadSolicitud);
            Map<String, Object> solicitudBloqueada = bloquearSolicitud(conexion, idSolicitud);
            if (propiedadBloqueada == null || solicitudBloqueada == null
                    || !propiedadSolicitud.equals(solicitudBloqueada.get("idPropiedad"))) {
                conexion.rollback();
                session.setAttribute("mensajeError", "La solicitud ya no está disponible.");
                response.sendRedirect(destinoEmpresa);
                return;
            }

            Map<String, Object> empresa = esAdmin ? null : buscarInmobiliariaPorUsuario(conexion, idUsuarioSesion);
            if (!esAdmin && (empresa == null
                    || !solicitudBloqueada.get("idInmobiliaria").equals(empresa.get("idInmobiliaria")))) {
                conexion.rollback();
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            String estadoActual = (String) solicitudBloqueada.get("estado");
            if (revisar) {
                boolean transicionValida = ("APROBADA".equals(nuevoEstado) && "PENDIENTE".equals(estadoActual))
                        || ("RECHAZADA".equals(nuevoEstado)
                            && ("PENDIENTE".equals(estadoActual) || "APROBADA".equals(estadoActual)));
                if (!transicionValida) {
                    conexion.rollback();
                    session.setAttribute("mensajeError", "La transición solicitada no está permitida.");
                } else if ("APROBADA".equals(nuevoEstado)
                        && (!(Boolean) propiedadBloqueada.get("activa")
                            || !"DISPONIBLE".equals(propiedadBloqueada.get("estado")))) {
                    conexion.rollback();
                    session.setAttribute("mensajeError", "La propiedad ya no está disponible.");
                } else {
                    cambiarEstadoSolicitud(conexion, idSolicitud, nuevoEstado, observacionRevision);
                    conexion.commit();
                    session.setAttribute("mensaje", "APROBADA".equals(nuevoEstado)
                            ? "Solicitud aprobada." : "Solicitud rechazada.");
                }
            } else if (!"APROBADA".equals(estadoActual)
                    || !"DISPONIBLE".equals(propiedadBloqueada.get("estado"))) {
                conexion.rollback();
                session.setAttribute("mensajeError", "Solo se finaliza una solicitud aprobada sobre una propiedad disponible.");
            } else {
                String estadoPropiedad = "VENTA".equals(propiedadBloqueada.get("operacion"))
                        ? "VENDIDA" : "ARRENDADA";
                cambiarEstadoSolicitud(conexion, idSolicitud, "FINALIZADA",
                        (String) solicitudBloqueada.get("observacion"));
                if (!actualizarDisponibilidad(conexion, propiedadSolicitud, estadoPropiedad)) {
                    throw new SQLException("No se pudo actualizar la propiedad.", "P0002");
                }
                rechazarOtrasSolicitudesAbiertas(conexion, propiedadSolicitud, idSolicitud);
                conexion.commit();
                session.setAttribute("mensaje", "Solicitud finalizada y propiedad marcada como " + estadoPropiedad + ".");
            }
            response.sendRedirect(ctx + "/controlador/solicitud.jsp?accion=detalle&id_solicitud=" + idSolicitud);
            return;
        } catch (SQLException e) {
            if (conexion != null) {
                try { conexion.rollback(); } catch (SQLException ignorada) { }
            }
            session.setAttribute("mensajeError", mensajeError(e));
            response.sendRedirect(ctx + "/controlador/solicitud.jsp?accion=detalle&id_solicitud=" + idSolicitud);
            return;
        } finally {
            if (conexion != null) {
                try { conexion.close(); } catch (SQLException ignorada) { }
            }
        }
    }

    if ("detalle".equals(accion)) {
        if (idSolicitud == null) {
            response.sendRedirect(esCliente ? destinoCliente : destinoEmpresa);
            return;
        }
        try (Connection conexion = abrirConexion()) {
            Map<String, Object> solicitud = buscarSolicitud(conexion, idSolicitud);
            if (solicitud == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            boolean propiaCliente = esCliente && solicitud.get("idCliente").equals(idUsuarioSesion);
            boolean propiaEmpresa = false;
            if (esInmobiliaria && !esAdmin) {
                Map<String, Object> empresa = buscarInmobiliariaPorUsuario(conexion, idUsuarioSesion);
                propiaEmpresa = empresa != null
                        && solicitud.get("idInmobiliaria").equals(empresa.get("idInmobiliaria"));
            }
            if (!esAdmin && !propiaCliente && !propiaEmpresa) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            String estado = (String) solicitud.get("estado");
            request.setAttribute("solicitud", solicitud);
            request.setAttribute("documentos", listarDocumentosSolicitud(conexion, idSolicitud));
            request.setAttribute("vistaCliente", Boolean.valueOf(propiaCliente && !esAdmin));
            request.setAttribute("puedeSubir", Boolean.valueOf(propiaCliente
                    && ("PENDIENTE".equals(estado) || "APROBADA".equals(estado))));
            request.setAttribute("puedeRevisar", Boolean.valueOf(esAdmin || propiaEmpresa));
        }
        request.getRequestDispatcher("/WEB-INF/vista/solicitud.jsp").forward(request, response);
        return;
    }

    if ("mis_solicitudes".equals(accion)) {
        if (!esCliente) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        try (Connection conexion = abrirConexion()) {
            request.setAttribute("solicitudes", listarSolicitudesCliente(conexion, idUsuarioSesion));
        }
        request.setAttribute("modo", "cliente");
        request.setAttribute("esAdmin", Boolean.valueOf(esAdmin));
        request.getRequestDispatcher("/WEB-INF/vista/solicitudes.jsp").forward(request, response);
        return;
    }

    if (!"recibidas".equals(accion)) {
        response.sendRedirect(esCliente ? destinoCliente : destinoEmpresa);
        return;
    }
    if (!esInmobiliaria && !esAdmin) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
        return;
    }
    try (Connection conexion = abrirConexion()) {
        Integer idEmpresa = null;
        if (!esAdmin) {
            Map<String, Object> empresa = buscarInmobiliariaPorUsuario(conexion, idUsuarioSesion);
            if (empresa == null) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            idEmpresa = (Integer) empresa.get("idInmobiliaria");
        }
        request.setAttribute("solicitudes", listarSolicitudesInmobiliaria(conexion, idEmpresa));
    }
    request.setAttribute("modo", "empresa");
    request.setAttribute("esAdmin", Boolean.valueOf(esAdmin));
    request.getRequestDispatcher("/WEB-INF/vista/solicitudes.jsp").forward(request, response);
%>
