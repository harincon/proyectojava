<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.File,java.io.FileInputStream,java.io.IOException,java.io.InputStream,java.io.OutputStream,java.sql.Connection,java.sql.SQLException,java.util.Arrays,java.util.Base64,java.util.HashSet,java.util.Map,javax.servlet.http.Part" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/modelo/solicitud.jspf" %>
<%@ include file="/WEB-INF/modelo/documento_solicitud.jspf" %>
<%@ include file="/WEB-INF/modelo/inmobiliaria.jspf" %>
<%!
    private boolean esPdfB6(byte[] inicio, int leidos) {
        return leidos >= 5 && inicio[0] == '%' && inicio[1] == 'P' && inicio[2] == 'D'
                && inicio[3] == 'F' && inicio[4] == '-';
    }
%>
<%
    request.setAttribute("rolesPermitidos", new HashSet<String>(Arrays.asList("ADMINISTRADOR", "INMOBILIARIA", "CLIENTE")));
%>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    String ctx = request.getContextPath();
    String accion = limpiar(request.getParameter("accion"));
    boolean esPost = "POST".equals(request.getMethod());
    boolean esAdmin = rolesUsuario.contains("ADMINISTRADOR");
    boolean esCliente = rolesUsuario.contains("CLIENTE");
    boolean esInmobiliaria = rolesUsuario.contains("INMOBILIARIA");
    Integer idSolicitud = aEntero(request.getParameter("id_solicitud"));
    Integer idDocumento = aEntero(request.getParameter("id_documento"));

    if ("descargar".equals(accion)) {
        if (!"GET".equals(request.getMethod())) {
            response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            return;
        }
        if (idDocumento == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        Map<String, Object> documento;
        try (Connection conexion = abrirConexion()) {
            documento = buscarDocumentoSolicitud(conexion, idDocumento);
            if (documento == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            boolean clienteDueno = esCliente && documento.get("idCliente").equals(idUsuarioSesion);
            boolean empresaDuena = false;
            if (esInmobiliaria && !esAdmin) {
                Map<String, Object> empresa = buscarInmobiliariaPorUsuario(conexion, idUsuarioSesion);
                empresaDuena = empresa != null
                        && documento.get("idInmobiliaria").equals(empresa.get("idInmobiliaria"));
            }
            if (!esAdmin && !clienteDueno && !empresaDuena) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
        }

        File carpeta = carpetaArchivos(application).getCanonicalFile();
        File archivo = new File(carpeta, (String) documento.get("ruta")).getCanonicalFile();
        if (!archivo.getPath().startsWith(carpeta.getPath() + File.separator) || !archivo.isFile()) {
            session.setAttribute("mensajeError", "El archivo de este documento no está disponible.");
            response.sendRedirect(ctx + "/controlador/solicitud.jsp?accion=detalle&id_solicitud="
                    + documento.get("idSolicitud"));
            return;
        }
        out.clear();
        response.reset();
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=\"documento-" + idDocumento + ".pdf\"");
        response.setHeader("Cache-Control", "private, no-store");
        response.setContentLength((int) archivo.length());
        try (InputStream entrada = new FileInputStream(archivo)) {
            OutputStream salida = response.getOutputStream();
            byte[] bloque = new byte[8192];
            int leidos;
            while ((leidos = entrada.read(bloque)) != -1) {
                salida.write(bloque, 0, leidos);
            }
            salida.flush();
        }
        return;
    }

    if ("subir".equals(accion)) {
        if (!esPost) {
            response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            return;
        }
        if (!esCliente) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        if (idSolicitud == null) {
            session.setAttribute("mensajeError", "No se indicó la solicitud.");
            response.sendRedirect(ctx + "/controlador/solicitud.jsp?accion=mis_solicitudes");
            return;
        }
        String destinoDetalle = ctx + "/controlador/solicitud.jsp?accion=detalle&id_solicitud=" + idSolicitud;
        try {
            Part archivoParte = request.getPart("archivo");
            String nombre = limpiar(request.getParameter("nombre"));
            if (!tokenValido(request)) {
                session.setAttribute("mensajeError", "El formulario expiró. Vuelve a intentarlo.");
            } else if (!longitudValida(nombre, 1, 100)) {
                session.setAttribute("mensajeError", "Escribe el nombre del documento (máximo 100 caracteres).");
            } else if (archivoParte == null || archivoParte.getSize() == 0) {
                session.setAttribute("mensajeError", "Selecciona un archivo PDF.");
            } else if (archivoParte.getSize() > 5242880L) {
                session.setAttribute("mensajeError", "El PDF supera el tamaño máximo permitido (5 MB).");
            } else {
                byte[] inicio = new byte[5];
                int leidos;
                try (InputStream entrada = archivoParte.getInputStream()) {
                    leidos = entrada.read(inicio);
                }
                if (!esPdfB6(inicio, leidos)) {
                    session.setAttribute("mensajeError", "El archivo debe ser un PDF válido.");
                } else {
                    File carpetaSolicitudes = new File(carpetaArchivos(application), "solicitudes");
                    if (!carpetaSolicitudes.isDirectory() && !carpetaSolicitudes.mkdirs()) {
                        throw new IOException("No se pudo crear la carpeta de solicitudes.");
                    }
                    byte[] azar = new byte[9];
                    ALEATORIO.nextBytes(azar);
                    String nombreArchivo = "s" + idSolicitud + "-"
                            + Base64.getUrlEncoder().withoutPadding().encodeToString(azar) + ".pdf";
                    File destino = new File(carpetaSolicitudes, nombreArchivo);
                    Connection conexion = null;
                    try {
                        conexion = abrirConexion();
                        conexion.setAutoCommit(false);
                        Map<String, Object> solicitud = bloquearSolicitud(conexion, idSolicitud);
                        if (solicitud == null) {
                            conexion.rollback();
                            session.setAttribute("mensajeError", "La solicitud no existe.");
                        } else if (!solicitud.get("idCliente").equals(idUsuarioSesion)) {
                            conexion.rollback();
                            response.sendError(HttpServletResponse.SC_FORBIDDEN);
                            return;
                        } else if (!("PENDIENTE".equals(solicitud.get("estado"))
                                || "APROBADA".equals(solicitud.get("estado")))) {
                            conexion.rollback();
                            session.setAttribute("mensajeError", "La solicitud está cerrada y no admite documentos.");
                        } else {
                            archivoParte.write(destino.getAbsolutePath());
                            crearDocumentoSolicitud(conexion, idSolicitud, nombre, "solicitudes/" + nombreArchivo);
                            conexion.commit();
                            session.setAttribute("mensaje", "Documento cargado correctamente.");
                        }
                    } catch (SQLException e) {
                        if (conexion != null) {
                            try { conexion.rollback(); } catch (SQLException ignorada) { }
                        }
                        destino.delete();
                        session.setAttribute("mensajeError", mensajeError(e));
                    } catch (IOException e) {
                        if (conexion != null) {
                            try { conexion.rollback(); } catch (SQLException ignorada) { }
                        }
                        destino.delete();
                        session.setAttribute("mensajeError", "No fue posible guardar el archivo.");
                    } finally {
                        if (conexion != null) {
                            try { conexion.close(); } catch (SQLException ignorada) { }
                        }
                    }
                }
            }
        } catch (IllegalStateException e) {
            session.setAttribute("mensajeError", "El PDF supera el tamaño máximo permitido (5 MB).");
        } catch (IOException e) {
            session.setAttribute("mensajeError", "No fue posible leer o guardar el archivo.");
        }
        response.sendRedirect(destinoDetalle);
        return;
    }

    if ("revisar".equals(accion)) {
        if (!esPost) {
            response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            return;
        }
        if (!esInmobiliaria && !esAdmin) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        String estado = limpiar(request.getParameter("estado"));
        String observacion = limpiar(request.getParameter("observacion"));
        if (!tokenValido(request)) {
            session.setAttribute("mensajeError", "El formulario expiró. Vuelve a intentarlo.");
            response.sendRedirect(ctx + "/controlador/solicitud.jsp?accion=recibidas");
            return;
        }
        if (idDocumento == null || !("APROBADO".equals(estado) || "RECHAZADO".equals(estado))
                || !longitudValida(observacion, 1, 1000)) {
            session.setAttribute("mensajeError", "Indica un estado y una observación válida.");
            response.sendRedirect(ctx + "/controlador/solicitud.jsp?accion=recibidas");
            return;
        }

        Connection conexion = null;
        int solicitudDestino = 0;
        try {
            conexion = abrirConexion();
            conexion.setAutoCommit(false);
            Map<String, Object> inicial = buscarDocumentoSolicitud(conexion, idDocumento);
            if (inicial == null) {
                conexion.rollback();
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            solicitudDestino = (Integer) inicial.get("idSolicitud");
            Map<String, Object> solicitud = bloquearSolicitud(conexion, solicitudDestino);
            Map<String, Object> documento = bloquearDocumentoSolicitud(conexion, idDocumento);
            if (solicitud == null || documento == null
                    || !documento.get("idSolicitud").equals(solicitud.get("idSolicitud"))) {
                conexion.rollback();
                session.setAttribute("mensajeError", "El documento ya no está disponible.");
            } else {
                Map<String, Object> empresa = esAdmin ? null : buscarInmobiliariaPorUsuario(conexion, idUsuarioSesion);
                if (!esAdmin && (empresa == null
                        || !solicitud.get("idInmobiliaria").equals(empresa.get("idInmobiliaria")))) {
                    conexion.rollback();
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
                boolean solicitudAbierta = "PENDIENTE".equals(solicitud.get("estado"))
                        || "APROBADA".equals(solicitud.get("estado"));
                if (!solicitudAbierta || !"PENDIENTE".equals(documento.get("estado"))) {
                    conexion.rollback();
                    session.setAttribute("mensajeError", "El documento ya no admite revisión.");
                } else {
                    revisarDocumentoSolicitud(conexion, idDocumento, estado, observacion);
                    conexion.commit();
                    session.setAttribute("mensaje", "Documento " + estado.toLowerCase() + ".");
                }
            }
        } catch (SQLException e) {
            if (conexion != null) {
                try { conexion.rollback(); } catch (SQLException ignorada) { }
            }
            session.setAttribute("mensajeError", mensajeError(e));
        } finally {
            if (conexion != null) {
                try { conexion.close(); } catch (SQLException ignorada) { }
            }
        }
        response.sendRedirect(solicitudDestino == 0
                ? ctx + "/controlador/solicitud.jsp?accion=recibidas"
                : ctx + "/controlador/solicitud.jsp?accion=detalle&id_solicitud=" + solicitudDestino);
        return;
    }

    response.sendRedirect(ctx + "/controlador/solicitud.jsp?accion=mis_solicitudes");
%>
