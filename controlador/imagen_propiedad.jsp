<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection,java.sql.SQLException,java.util.Arrays,java.util.HashSet,java.util.Map" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/modelo/propiedad.jspf" %>
<%@ include file="/WEB-INF/modelo/imagen_propiedad.jspf" %>
<%@ include file="/WEB-INF/modelo/inmobiliaria.jspf" %>
<%--
  Fotografías de una propiedad (INMOBILIARIA dueña o ADMINISTRADOR).
  POST ?accion=agregar&id_propiedad=N (ruta: enlace https o archivo dentro de img/) | eliminar&id_propiedad=N&id_imagen=M
  La primera imagen es la que se muestra en el catálogo.
--%>
<%!
    private static final int IMAGENES_POR_PROPIEDAD = 8;
%>
<%
    request.setAttribute("rolesPermitidos", new HashSet<String>(Arrays.asList("ADMINISTRADOR", "INMOBILIARIA")));
%>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    String ctx = request.getContextPath();
    String accion = limpiar(request.getParameter("accion"));
    Integer idPropiedad = aEntero(request.getParameter("id_propiedad"));
    boolean esAdmin = rolesUsuario.contains("ADMINISTRADOR");

    if (!"POST".equals(request.getMethod()) || idPropiedad == null) {
        response.sendRedirect(ctx + "/controlador/propiedad.jsp?accion=gestionar");
        return;
    }

    try (Connection conexion = abrirConexion()) {
        Map<String, Object> propiedad = buscarPropiedad(conexion, idPropiedad);
        if (propiedad == null) {
            session.setAttribute("mensajeError", "La propiedad no existe.");
            response.sendRedirect(ctx + "/controlador/propiedad.jsp?accion=gestionar");
            return;
        }
        if (!esAdmin) {
            Map<String, Object> empresa = buscarInmobiliariaPorUsuario(conexion, idUsuarioSesion);
            if (empresa == null || !propiedad.get("idInmobiliaria").equals(empresa.get("idInmobiliaria"))) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
        }

        if (!tokenValido(request)) {
            session.setAttribute("mensajeError", "El formulario expiró. Vuelve a intentarlo.");
        } else if ("agregar".equals(accion)) {
            String ruta = limpiar(request.getParameter("ruta"));
            if (!rutaImagenValida(ruta)) {
                session.setAttribute("mensajeError", "La fotografía debe ser un enlace https o un archivo de img/ (jpg, png, svg o webp).");
            } else if (contarImagenes(conexion, idPropiedad) >= IMAGENES_POR_PROPIEDAD) {
                session.setAttribute("mensajeError", "Cada propiedad admite hasta " + IMAGENES_POR_PROPIEDAD + " fotografías.");
            } else {
                agregarImagen(conexion, idPropiedad, ruta);
                session.setAttribute("mensaje", "Fotografía agregada.");
            }
        } else if ("eliminar".equals(accion)) {
            Integer idImagen = aEntero(request.getParameter("id_imagen"));
            if (idImagen != null && eliminarImagen(conexion, idImagen, idPropiedad)) {
                session.setAttribute("mensaje", "Fotografía eliminada.");
            } else {
                session.setAttribute("mensajeError", "La fotografía no existe.");
            }
        } else {
            session.setAttribute("mensajeError", "Acción no válida.");
        }
    } catch (SQLException e) {
        session.setAttribute("mensajeError", mensajeError(e));
    }
    response.sendRedirect(ctx + "/controlador/propiedad.jsp?accion=editar&id_propiedad=" + idPropiedad);
%>
