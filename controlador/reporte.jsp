<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection,java.util.Arrays,java.util.HashSet,java.util.Map" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/modelo/reporte.jspf" %>
<%@ include file="/WEB-INF/modelo/inmobiliaria.jspf" %>
<%
    request.setAttribute("rolesPermitidos", new HashSet<String>(Arrays.asList("ADMINISTRADOR", "INMOBILIARIA")));
%>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    String ctx = request.getContextPath();
    if (!"GET".equals(request.getMethod())) {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        return;
    }

    boolean esAdmin = rolesUsuario.contains("ADMINISTRADOR");
    boolean esInmobiliaria = rolesUsuario.contains("INMOBILIARIA");
    String accion = limpiar(request.getParameter("accion"));
    if (accion == null) {
        accion = esAdmin ? "general" : "empresa";
    }
    if (!("general".equals(accion) || "empresa".equals(accion))) {
        response.sendRedirect(ctx + "/controlador/reporte.jsp?accion=" + (esAdmin ? "general" : "empresa"));
        return;
    }
    if ("general".equals(accion) && !esAdmin) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
        return;
    }
    if ("empresa".equals(accion) && !esInmobiliaria) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
        return;
    }

    try (Connection conexion = abrirConexion()) {
        Integer idEmpresa = null;
        String nombreEmpresa = null;
        if ("empresa".equals(accion)) {
            Map<String, Object> empresa = buscarInmobiliariaPorUsuario(conexion, idUsuarioSesion);
            if (empresa == null) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            idEmpresa = (Integer) empresa.get("idInmobiliaria");
            nombreEmpresa = (String) empresa.get("nombre");
        }
        request.setAttribute("propiedades", listarReportePropiedades(conexion, idEmpresa));
        request.setAttribute("citas", listarReporteCitas(conexion, idEmpresa));
        request.setAttribute("solicitudes", listarReporteSolicitudes(conexion, idEmpresa));
        request.setAttribute("finalizadas", listarReporteFinalizadas(conexion, idEmpresa));
        request.setAttribute("nombreEmpresa", nombreEmpresa);
    }
    request.setAttribute("modo", accion);
    request.getRequestDispatcher("/WEB-INF/vista/reportes.jsp").forward(request, response);
%>
