<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection,java.sql.Timestamp,java.time.LocalDate,java.time.format.DateTimeParseException,java.util.Arrays,java.util.HashSet" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/modelo/auditoria.jspf" %>
<%
    request.setAttribute("rolesPermitidos", new HashSet<String>(Arrays.asList("ADMINISTRADOR")));
%>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%!
    private static final int AUDITORIA_POR_PAGINA = 15;
%>
<%
    String ctx = request.getContextPath();
    String accion = limpiar(request.getParameter("accion"));
    if (!"GET".equals(request.getMethod())) {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        return;
    }
    if (accion != null && !"listar".equals(accion)) {
        response.sendRedirect(ctx + "/controlador/auditoria.jsp?accion=listar");
        return;
    }

    String usuario = limpiar(request.getParameter("usuario"));
    String texto = limpiar(request.getParameter("q"));
    String desdeTexto = limpiar(request.getParameter("desde"));
    String hastaTexto = limpiar(request.getParameter("hasta"));
    Timestamp desde = null;
    Timestamp hastaExclusiva = null;
    String errorFiltro = null;
    LocalDate fechaDesde = null;
    LocalDate fechaHasta = null;
    try {
        if (desdeTexto != null) {
            fechaDesde = LocalDate.parse(desdeTexto);
        }
        if (hastaTexto != null) {
            fechaHasta = LocalDate.parse(hastaTexto);
        }
        if (fechaDesde != null && fechaHasta != null && fechaHasta.isBefore(fechaDesde)) {
            errorFiltro = "La fecha final no puede ser anterior a la inicial.";
        } else {
            if (fechaDesde != null) {
                desde = Timestamp.valueOf(fechaDesde.atStartOfDay());
            }
            if (fechaHasta != null) {
                hastaExclusiva = Timestamp.valueOf(fechaHasta.plusDays(1).atStartOfDay());
            }
        }
    } catch (DateTimeParseException e) {
        errorFiltro = "Escribe un rango de fechas válido.";
    }

    Integer paginaPedida = aEntero(request.getParameter("pagina"));
    int pagina = paginaPedida == null || paginaPedida < 1 ? 1 : paginaPedida;
    try (Connection conexion = abrirConexion()) {
        int total = contarAuditoria(conexion, usuario, texto, desde, hastaExclusiva);
        int paginas = Math.max(1, (total + AUDITORIA_POR_PAGINA - 1) / AUDITORIA_POR_PAGINA);
        pagina = Math.min(pagina, paginas);
        request.setAttribute("registros", listarAuditoria(conexion, usuario, texto, desde, hastaExclusiva,
                AUDITORIA_POR_PAGINA, (pagina - 1) * AUDITORIA_POR_PAGINA));
        request.setAttribute("total", total);
        request.setAttribute("pagina", pagina);
        request.setAttribute("paginas", paginas);
    }
    request.setAttribute("usuario", usuario);
    request.setAttribute("texto", texto);
    request.setAttribute("desde", desdeTexto);
    request.setAttribute("hasta", hastaTexto);
    request.setAttribute("errorFiltro", errorFiltro);
    request.getRequestDispatcher("/WEB-INF/vista/auditoria.jsp").forward(request, response);
%>
