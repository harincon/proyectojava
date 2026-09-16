<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection,java.sql.SQLException,java.time.LocalDateTime,java.util.Arrays,java.util.HashMap,java.util.HashSet,java.util.Map" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/modelo/cita.jspf" %>
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
    Integer idCita = aEntero(request.getParameter("id_cita"));
    String destinoCliente = ctx + "/controlador/cita.jsp?accion=mis_citas";
    String destinoEmpresa = ctx + "/controlador/cita.jsp?accion=recibidas";
    Map<String, String> errores = new HashMap<String, String>();
    Map<String, String> valores = new HashMap<String, String>();

    if (accion == null) {
        accion = esCliente ? "mis_citas" : "recibidas";
    }

    // Crear una cita es exclusivo de una cuenta con rol CLIENTE.
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
            String fecha = limpiar(request.getParameter("fecha"));
            String hora = limpiar(request.getParameter("hora"));
            valores.put("fecha", fecha);
            valores.put("hora", hora);
            LocalDateTime fechaHora = aFechaHora(fecha, hora);
            if (!tokenValido(request)) {
                errores.put("general", "El formulario expiró. Vuelve a intentarlo.");
            }
            if (fechaHora == null || !fechaHora.isAfter(ahora())) {
                errores.put("fecha_hora", "Elige una fecha y hora futuras.");
            }

            if (errores.isEmpty()) {
                Connection conexion = null;
                try {
                    conexion = abrirConexion();
                    conexion.setAutoCommit(false);
                    Map<String, Object> bloqueada = bloquearPropiedadParaCita(conexion, idPropiedad);
                    if (bloqueada == null || !(Boolean) bloqueada.get("activa")
                            || !"DISPONIBLE".equals(bloqueada.get("estado"))) {
                        errores.put("general", "La propiedad no está activa y disponible.");
                    } else {
                        int idResponsable = (Integer) bloqueada.get("idResponsable");
                        bloquearParticipantesCita(conexion, idUsuarioSesion, idResponsable);
                        if (propiedadTieneCitaActiva(conexion, idPropiedad, fechaHora)) {
                            errores.put("fecha_hora", "Ese horario ya está reservado");
                        } else if (clienteTieneCitaActiva(conexion, idUsuarioSesion, fechaHora)) {
                            errores.put("fecha_hora", "Ya tienes otra cita activa en esa fecha y hora.");
                        } else if (responsableTieneCitaActiva(conexion, idResponsable, fechaHora)) {
                            errores.put("fecha_hora", "La inmobiliaria ya tiene otra cita activa en esa fecha y hora.");
                        } else {
                            crearCita(conexion, idUsuarioSesion, idPropiedad, fechaHora);
                        }
                    }
                    if (errores.isEmpty()) {
                        conexion.commit();
                        session.setAttribute("mensaje", "Cita solicitada. La inmobiliaria debe confirmarla.");
                        response.sendRedirect(destinoCliente);
                        return;
                    }
                    conexion.rollback();
                } catch (SQLException e) {
                    if (conexion != null) {
                        try { conexion.rollback(); } catch (SQLException ignorada) { }
                    }
                    if ("23505".equals(e.getSQLState())) {
                        errores.put("fecha_hora", "Ese horario ya está reservado");
                    } else {
                        errores.put("general", mensajeError(e));
                    }
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
                session.setAttribute("mensajeError", "La propiedad no está disponible para visitas.");
                response.sendRedirect(ctx + "/controlador/propiedad.jsp?accion=catalogo");
                return;
            }
            request.setAttribute("propiedad", propiedad);
        }
        request.setAttribute("errores", errores);
        request.setAttribute("valores", valores);
        request.getRequestDispatcher("/WEB-INF/vista/formulario_cita.jsp").forward(request, response);
        return;
    }

    // Acciones de estado siempre se ejecutan por POST y dentro de una transacción.
    boolean cambiaEstado = "cancelar".equals(accion) || "confirmar".equals(accion)
            || "rechazar".equals(accion) || "realizar".equals(accion);
    if (cambiaEstado) {
        if (!esPost) {
            response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            return;
        }
        boolean accionCliente = "cancelar".equals(accion);
        String destinoCambio = accionCliente && !esAdmin ? destinoCliente : destinoEmpresa;
        if ((accionCliente && !esCliente && !esAdmin)
                || (!accionCliente && !esInmobiliaria && !esAdmin)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        if (!tokenValido(request)) {
            session.setAttribute("mensajeError", "El formulario expiró. Vuelve a intentarlo.");
            response.sendRedirect(destinoCambio);
            return;
        }
        if (idCita == null) {
            session.setAttribute("mensajeError", "No se indicó la cita.");
            response.sendRedirect(destinoCambio);
            return;
        }

        Connection conexion = null;
        try {
            conexion = abrirConexion();
            conexion.setAutoCommit(false);
            Map<String, Object> empresa = null;
            if (!accionCliente && !esAdmin) {
                empresa = buscarInmobiliariaPorUsuario(conexion, idUsuarioSesion);
            }
            Map<String, Object> cita = bloquearCita(conexion, idCita);
            if (cita == null) {
                conexion.rollback();
                session.setAttribute("mensajeError", "La cita no existe.");
                response.sendRedirect(destinoCambio);
                return;
            }
            if (accionCliente && !esAdmin && !cita.get("idCliente").equals(idUsuarioSesion)) {
                conexion.rollback();
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            if (!accionCliente && !esAdmin
                    && (empresa == null || !cita.get("idInmobiliaria").equals(empresa.get("idInmobiliaria")))) {
                conexion.rollback();
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            String actual = (String) cita.get("estado");
            String nuevo = null;
            String mensaje = null;
            if ("cancelar".equals(accion) && ("PENDIENTE".equals(actual) || "CONFIRMADA".equals(actual))) {
                nuevo = "CANCELADA";
                mensaje = "Cita cancelada.";
            } else if ("confirmar".equals(accion) && "PENDIENTE".equals(actual)) {
                nuevo = "CONFIRMADA";
                mensaje = "Cita confirmada.";
            } else if ("rechazar".equals(accion) && ("PENDIENTE".equals(actual) || "CONFIRMADA".equals(actual))) {
                nuevo = "RECHAZADA";
                mensaje = "Cita rechazada.";
            } else if ("realizar".equals(accion) && "CONFIRMADA".equals(actual)
                    && ((LocalDateTime) cita.get("fechaHora")).isBefore(ahora())) {
                nuevo = "REALIZADA";
                mensaje = "Cita marcada como realizada.";
            }

            if (nuevo == null) {
                conexion.rollback();
                session.setAttribute("mensajeError", "La transición solicitada no está permitida.");
            } else {
                cambiarEstadoCita(conexion, idCita, nuevo);
                conexion.commit();
                session.setAttribute("mensaje", mensaje);
            }
            response.sendRedirect(destinoCambio);
            return;
        } catch (SQLException e) {
            if (conexion != null) {
                try { conexion.rollback(); } catch (SQLException ignorada) { }
            }
            session.setAttribute("mensajeError", mensajeError(e));
            response.sendRedirect(destinoCambio);
            return;
        } finally {
            if (conexion != null) {
                try { conexion.close(); } catch (SQLException ignorada) { }
            }
        }
    }

    if ("mis_citas".equals(accion)) {
        if (!esCliente) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        try (Connection conexion = abrirConexion()) {
            request.setAttribute("citas", listarCitasCliente(conexion, idUsuarioSesion));
        }
        request.setAttribute("modo", "cliente");
        request.setAttribute("esAdmin", Boolean.valueOf(esAdmin));
        request.getRequestDispatcher("/WEB-INF/vista/citas.jsp").forward(request, response);
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
        request.setAttribute("citas", listarCitasInmobiliaria(conexion, idEmpresa));
    }
    request.setAttribute("modo", "empresa");
    request.setAttribute("esAdmin", Boolean.valueOf(esAdmin));
    request.getRequestDispatcher("/WEB-INF/vista/citas.jsp").forward(request, response);
%>
