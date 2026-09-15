<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection,java.util.Arrays,java.util.HashSet" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/modelo/usuario.jspf" %>
<%-- Panel inicial de cualquier cuenta autenticada. GET sin acción. --%>
<%
    request.setAttribute("rolesPermitidos", new HashSet<String>(Arrays.asList("ADMINISTRADOR", "INMOBILIARIA", "CLIENTE")));
%>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    if (rolesUsuario.contains("ADMINISTRADOR")) {
        try (Connection conexion = abrirConexion()) {
            request.setAttribute("totalUsuarios", contarUsuarios(conexion, null));
        }
    }
    request.getRequestDispatcher("/WEB-INF/vista/panel.jsp").forward(request, response);
%>
