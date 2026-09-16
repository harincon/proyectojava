<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection,java.sql.SQLException,java.util.Arrays,java.util.HashSet,java.util.Map" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/modelo/favorito.jspf" %>
<%@ include file="/WEB-INF/modelo/propiedad.jspf" %>
<%
    request.setAttribute("rolesPermitidos", new HashSet<String>(Arrays.asList("CLIENTE")));
%>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    if (!rolesUsuario.contains("CLIENTE")) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
        return;
    }

    String ctx = request.getContextPath();
    String accion = limpiar(request.getParameter("accion"));
    Integer idPropiedad = aEntero(request.getParameter("id_propiedad"));
    boolean esPost = "POST".equals(request.getMethod());
    String destino = ctx + "/controlador/favorito.jsp?accion=listar";

    if ("agregar".equals(accion) || "quitar".equals(accion)) {
        if (!esPost) {
            response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            return;
        }
        if (!tokenValido(request)) {
            session.setAttribute("mensajeError", "El formulario expiró. Vuelve a intentarlo.");
        } else if (idPropiedad == null) {
            session.setAttribute("mensajeError", "No se indicó la propiedad.");
        } else {
            try (Connection conexion = abrirConexion()) {
                if ("agregar".equals(accion)) {
                    Map<String, Object> propiedad = buscarPropiedad(conexion, idPropiedad);
                    if (propiedad == null || !(Boolean) propiedad.get("activa")
                            || !"DISPONIBLE".equals(propiedad.get("estado"))) {
                        session.setAttribute("mensajeError", "La propiedad no está disponible.");
                    } else if (agregarFavorito(conexion, idUsuarioSesion, idPropiedad)) {
                        session.setAttribute("mensaje", "Propiedad guardada en favoritos.");
                    } else {
                        session.setAttribute("mensaje", "La propiedad ya estaba en tus favoritos.");
                    }
                    destino = ctx + "/controlador/propiedad.jsp?accion=detalle&id_propiedad=" + idPropiedad;
                } else if (quitarFavorito(conexion, idUsuarioSesion, idPropiedad)) {
                    session.setAttribute("mensaje", "Propiedad eliminada de favoritos.");
                } else {
                    session.setAttribute("mensajeError", "El favorito ya no existe.");
                }
            } catch (SQLException e) {
                session.setAttribute("mensajeError", mensajeError(e));
            }
        }
        response.sendRedirect(destino);
        return;
    }

    if (accion != null && !"listar".equals(accion)) {
        response.sendRedirect(destino);
        return;
    }
    try (Connection conexion = abrirConexion()) {
        request.setAttribute("favoritos", listarFavoritos(conexion, idUsuarioSesion));
    }
    request.getRequestDispatcher("/WEB-INF/vista/favoritos.jsp").forward(request, response);
%>
