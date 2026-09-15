<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection,java.util.Arrays,java.util.HashSet" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/modelo/rol.jspf" %>
<%-- Consulta de roles del sistema (solo ADMINISTRADOR). GET ?accion=listar --%>
<%
    request.setAttribute("rolesPermitidos", new HashSet<String>(Arrays.asList("ADMINISTRADOR")));
%>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    try (Connection conexion = abrirConexion()) {
        request.setAttribute("roles", listarRolesConUsuarios(conexion));
    }
    request.getRequestDispatcher("/WEB-INF/vista/roles.jsp").forward(request, response);
%>
