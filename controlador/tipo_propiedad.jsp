<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection,java.sql.SQLException,java.util.Arrays,java.util.HashMap,java.util.HashSet,java.util.Map" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/modelo/tipo_propiedad.jspf" %>
<%--
  Catálogo de tipos de propiedad (solo ADMINISTRADOR); pestaña de vista/catalogos.jsp.
  GET  ?accion=listar | editar&id_tipo_propiedad=N
  POST ?accion=crear (nombre) | actualizar&id_tipo_propiedad=N (nombre) | eliminar&id_tipo_propiedad=N
--%>
<%
    request.setAttribute("rolesPermitidos", new HashSet<String>(Arrays.asList("ADMINISTRADOR")));
%>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    String ctx = request.getContextPath();
    String accion = limpiar(request.getParameter("accion"));
    boolean esPost = "POST".equals(request.getMethod());
    Integer idTipo = aEntero(request.getParameter("id_tipo_propiedad"));
    String destino = ctx + "/controlador/tipo_propiedad.jsp?accion=listar";
    Map<String, String> errores = new HashMap<String, String>();
    Map<String, String> valores = new HashMap<String, String>();

    if ("eliminar".equals(accion) && esPost) {
        if (!tokenValido(request)) {
            session.setAttribute("mensajeError", "El formulario expiró. Vuelve a intentarlo.");
        } else if (idTipo != null) {
            try (Connection conexion = abrirConexion()) {
                if (eliminarTipoPropiedad(conexion, idTipo)) {
                    session.setAttribute("mensaje", "Tipo de propiedad eliminado.");
                } else {
                    session.setAttribute("mensajeError", "El tipo de propiedad no existe.");
                }
            } catch (SQLException e) {
                session.setAttribute("mensajeError", "23503".equals(e.getSQLState()) || "23001".equals(e.getSQLState())
                        ? "No se puede eliminar: hay propiedades de ese tipo." : mensajeError(e));
            }
        }
        response.sendRedirect(destino);
        return;
    }

    if (("crear".equals(accion) || "actualizar".equals(accion)) && esPost) {
        boolean creando = "crear".equals(accion);
        String nombre = limpiar(request.getParameter("nombre"));
        valores.put("nombre", nombre);
        if (!tokenValido(request)) {
            errores.put("general", "El formulario expiró. Vuelve a intentarlo.");
        }
        if (!creando && idTipo == null) {
            response.sendRedirect(destino);
            return;
        }
        if (!longitudValida(nombre, 1, 50)) {
            errores.put("nombre", "Escribe el nombre del tipo (máximo 50 caracteres).");
        }
        if (errores.isEmpty()) {
            try (Connection conexion = abrirConexion()) {
                if (existeTipoPropiedad(conexion, nombre, creando ? 0 : idTipo)) {
                    errores.put("nombre", "Ya existe un tipo de propiedad con ese nombre.");
                } else {
                    if (creando) {
                        crearTipoPropiedad(conexion, nombre);
                        session.setAttribute("mensaje", "Tipo de propiedad agregado.");
                    } else if (actualizarTipoPropiedad(conexion, idTipo, nombre)) {
                        session.setAttribute("mensaje", "Tipo de propiedad actualizado.");
                    } else {
                        session.setAttribute("mensajeError", "El tipo de propiedad no existe.");
                    }
                    response.sendRedirect(destino);
                    return;
                }
            } catch (SQLException e) {
                if ("23505".equals(e.getSQLState())) {
                    errores.put("nombre", "Ya existe un tipo de propiedad con ese nombre.");
                } else {
                    errores.put("general", mensajeError(e));
                }
            }
        }
        accion = creando ? "listar" : "editar";
    }

    try (Connection conexion = abrirConexion()) {
        request.setAttribute("elementos", listarTiposPropiedad(conexion));
    }
    request.setAttribute("catalogo", "tipo_propiedad");
    request.setAttribute("idEditando", "editar".equals(accion) ? idTipo : null);
    request.setAttribute("errores", errores);
    request.setAttribute("valores", valores);
    request.getRequestDispatcher("/WEB-INF/vista/catalogos.jsp").forward(request, response);
%>
