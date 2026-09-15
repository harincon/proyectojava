<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection,java.sql.SQLException,java.util.Arrays,java.util.HashMap,java.util.HashSet,java.util.Map" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/modelo/ciudad.jspf" %>
<%--
  Catálogo de ciudades (solo ADMINISTRADOR); pestaña de vista/catalogos.jsp.
  GET  ?accion=listar | editar&id_ciudad=N
  POST ?accion=crear (nombre) | actualizar&id_ciudad=N (nombre) | eliminar&id_ciudad=N
--%>
<%
    request.setAttribute("rolesPermitidos", new HashSet<String>(Arrays.asList("ADMINISTRADOR")));
%>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    String ctx = request.getContextPath();
    String accion = limpiar(request.getParameter("accion"));
    boolean esPost = "POST".equals(request.getMethod());
    Integer idCiudad = aEntero(request.getParameter("id_ciudad"));
    String destino = ctx + "/controlador/ciudad.jsp?accion=listar";
    Map<String, String> errores = new HashMap<String, String>();
    Map<String, String> valores = new HashMap<String, String>();

    if ("eliminar".equals(accion) && esPost) {
        if (!tokenValido(request)) {
            session.setAttribute("mensajeError", "El formulario expiró. Vuelve a intentarlo.");
        } else if (idCiudad != null) {
            try (Connection conexion = abrirConexion()) {
                if (eliminarCiudad(conexion, idCiudad)) {
                    session.setAttribute("mensaje", "Ciudad eliminada.");
                } else {
                    session.setAttribute("mensajeError", "La ciudad no existe.");
                }
            } catch (SQLException e) {
                session.setAttribute("mensajeError", "23503".equals(e.getSQLState()) || "23001".equals(e.getSQLState())
                        ? "No se puede eliminar: hay propiedades en esa ciudad." : mensajeError(e));
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
        if (!creando && idCiudad == null) {
            response.sendRedirect(destino);
            return;
        }
        if (!longitudValida(nombre, 1, 100)) {
            errores.put("nombre", "Escribe el nombre de la ciudad (máximo 100 caracteres).");
        }
        if (errores.isEmpty()) {
            try (Connection conexion = abrirConexion()) {
                if (existeCiudad(conexion, nombre, creando ? 0 : idCiudad)) {
                    errores.put("nombre", "Ya existe una ciudad con ese nombre.");
                } else {
                    if (creando) {
                        crearCiudad(conexion, nombre);
                        session.setAttribute("mensaje", "Ciudad agregada.");
                    } else if (actualizarCiudad(conexion, idCiudad, nombre)) {
                        session.setAttribute("mensaje", "Ciudad actualizada.");
                    } else {
                        session.setAttribute("mensajeError", "La ciudad no existe.");
                    }
                    response.sendRedirect(destino);
                    return;
                }
            } catch (SQLException e) {
                if ("23505".equals(e.getSQLState())) {
                    errores.put("nombre", "Ya existe una ciudad con ese nombre.");
                } else {
                    errores.put("general", mensajeError(e));
                }
            }
        }
        accion = creando ? "listar" : "editar";
    }

    try (Connection conexion = abrirConexion()) {
        request.setAttribute("elementos", listarCiudades(conexion));
    }
    request.setAttribute("catalogo", "ciudad");
    request.setAttribute("idEditando", "editar".equals(accion) ? idCiudad : null);
    request.setAttribute("errores", errores);
    request.setAttribute("valores", valores);
    request.getRequestDispatcher("/WEB-INF/vista/catalogos.jsp").forward(request, response);
%>
