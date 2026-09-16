<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection,java.util.Arrays,java.util.HashSet,java.util.Set" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/modelo/usuario_rol.jspf" %>
<%@ include file="/WEB-INF/modelo/auditoria.jspf" %>
<%--
  Asignación de roles (solo ADMINISTRADOR).
  POST ?accion=asignar | revocar (id_usuario, rol). Solo ADMINISTRADOR y CLIENTE;
  INMOBILIARIA se gestiona desde inmobiliaria.jsp (B3) porque exige empresa.
--%>
<%
    request.setAttribute("rolesPermitidos", new HashSet<String>(Arrays.asList("ADMINISTRADOR")));
%>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    String ctx = request.getContextPath();
    String accion = limpiar(request.getParameter("accion"));
    Integer idObjetivo = aEntero(request.getParameter("id_usuario"));
    String rol = limpiar(request.getParameter("rol"));

    if (!"POST".equals(request.getMethod()) || idObjetivo == null) {
        response.sendRedirect(ctx + "/controlador/usuario.jsp?accion=listar");
        return;
    }

    if (!tokenValido(request)) {
        session.setAttribute("mensajeError", "El formulario expiró. Vuelve a intentarlo.");
    } else if ("INMOBILIARIA".equals(rol)) {
        session.setAttribute("mensajeError", "El rol INMOBILIARIA se asigna al vincular una empresa.");
    } else if (!"ADMINISTRADOR".equals(rol) && !"CLIENTE".equals(rol)) {
        session.setAttribute("mensajeError", "Rol no válido.");
    } else if ("asignar".equals(accion)) {
        try (Connection conexion = abrirConexion()) {
            if (asignarRol(conexion, idObjetivo, rol)) {
                registrarEvento(conexion, idUsuarioSesion, "ROL_ASIGNADO · cuenta " + idObjetivo + " · " + rol);
                session.setAttribute("mensaje", "Rol " + rol + " asignado.");
            } else {
                session.setAttribute("mensaje", "La cuenta ya tenía el rol " + rol + ".");
            }
        }
    } else if ("revocar".equals(accion)) {
        if ("ADMINISTRADOR".equals(rol) && idObjetivo.equals(idUsuarioSesion)) {
            session.setAttribute("mensajeError", "No puedes quitarte tu propio rol ADMINISTRADOR.");
        } else {
            try (Connection conexion = abrirConexion()) {
                Set<String> actuales = rolesDeUsuario(conexion, idObjetivo);
                if (actuales.contains(rol) && actuales.size() == 1) {
                    session.setAttribute("mensajeError", "La cuenta debe conservar al menos un rol.");
                } else if (revocarRol(conexion, idObjetivo, rol)) {
                    registrarEvento(conexion, idUsuarioSesion, "ROL_REVOCADO · cuenta " + idObjetivo + " · " + rol);
                    session.setAttribute("mensaje", "Rol " + rol + " revocado.");
                } else {
                    session.setAttribute("mensajeError", "La cuenta no tenía el rol " + rol + ".");
                }
            }
        }
    } else {
        session.setAttribute("mensajeError", "Acción no válida.");
    }
    response.sendRedirect(ctx + "/controlador/usuario.jsp?accion=editar&id_usuario=" + idObjetivo);
%>
