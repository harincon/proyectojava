<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection,java.sql.SQLException,java.util.Arrays,java.util.HashMap,java.util.HashSet,java.util.Map" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/modelo/caracteristica.jspf" %>
<%--
  Catálogo de características (solo ADMINISTRADOR); pestaña de vista/catalogos.jsp.
  GET  ?accion=listar | editar&id_caracteristica=N
  POST ?accion=crear (nombre) | actualizar&id_caracteristica=N (nombre) | eliminar&id_caracteristica=N
--%>
<%
    request.setAttribute("rolesPermitidos", new HashSet<String>(Arrays.asList("ADMINISTRADOR")));
%>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    String ctx = request.getContextPath();
    String accion = limpiar(request.getParameter("accion"));
    boolean esPost = "POST".equals(request.getMethod());
    Integer idCaracteristica = aEntero(request.getParameter("id_caracteristica"));
    String destino = ctx + "/controlador/caracteristica.jsp?accion=listar";
    Map<String, String> errores = new HashMap<String, String>();
    Map<String, String> valores = new HashMap<String, String>();

    if ("eliminar".equals(accion) && esPost) {
        if (!tokenValido(request)) {
            session.setAttribute("mensajeError", "El formulario expiró. Vuelve a intentarlo.");
        } else if (idCaracteristica != null) {
            try (Connection conexion = abrirConexion()) {
                if (eliminarCaracteristica(conexion, idCaracteristica)) {
                    session.setAttribute("mensaje", "Característica eliminada.");
                } else {
                    session.setAttribute("mensajeError", "La característica no existe.");
                }
            } catch (SQLException e) {
                session.setAttribute("mensajeError", "23503".equals(e.getSQLState())
                        ? "No se puede eliminar: hay propiedades que tienen esa característica." : mensajeError(e));
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
        if (!creando && idCaracteristica == null) {
            response.sendRedirect(destino);
            return;
        }
        if (!longitudValida(nombre, 1, 60)) {
            errores.put("nombre", "Escribe el nombre de la característica (máximo 60 caracteres).");
        }
        if (errores.isEmpty()) {
            try (Connection conexion = abrirConexion()) {
                if (existeCaracteristica(conexion, nombre, creando ? 0 : idCaracteristica)) {
                    errores.put("nombre", "Ya existe una característica con ese nombre.");
                } else {
                    if (creando) {
                        crearCaracteristica(conexion, nombre);
                        session.setAttribute("mensaje", "Característica agregada.");
                    } else if (actualizarCaracteristica(conexion, idCaracteristica, nombre)) {
                        session.setAttribute("mensaje", "Característica actualizada.");
                    } else {
                        session.setAttribute("mensajeError", "La característica no existe.");
                    }
                    response.sendRedirect(destino);
                    return;
                }
            } catch (SQLException e) {
                if ("23505".equals(e.getSQLState())) {
                    errores.put("nombre", "Ya existe una característica con ese nombre.");
                } else {
                    errores.put("general", mensajeError(e));
                }
            }
        }
        accion = creando ? "listar" : "editar";
    }

    try (Connection conexion = abrirConexion()) {
        request.setAttribute("elementos", listarCaracteristicas(conexion));
    }
    request.setAttribute("catalogo", "caracteristica");
    request.setAttribute("idEditando", "editar".equals(accion) ? idCaracteristica : null);
    request.setAttribute("errores", errores);
    request.setAttribute("valores", valores);
    request.getRequestDispatcher("/WEB-INF/vista/catalogos.jsp").forward(request, response);
%>
