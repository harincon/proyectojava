<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection,java.util.HashMap,java.util.List,java.util.Map" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/modelo/propiedad.jspf" %>
<%@ include file="/WEB-INF/modelo/ciudad.jspf" %>
<%@ include file="/WEB-INF/modelo/tipo_propiedad.jspf" %>
<%@ include file="/WEB-INF/modelo/inmobiliaria.jspf" %>
<%-- Portada pública. GET sin acción; index.jsp reenvía aquí. --%>
<%
    Map<String, Object> publicas = new HashMap<String, Object>();
    publicas.put("publicas", Boolean.TRUE);
    publicas.put("estado", "DISPONIBLE");

    try (Connection conexion = abrirConexion()) {
        Map<String, Object> destacadas = new HashMap<String, Object>(publicas);
        destacadas.put("destacada", Boolean.TRUE);
        List<Map<String, Object>> vitrina = listarPropiedades(conexion, destacadas, null, 6, 0);
        if (vitrina.isEmpty()) {
            vitrina = listarPropiedades(conexion, publicas, null, 6, 0);
        }
        request.setAttribute("vitrina", vitrina);
        request.setAttribute("totalPropiedades", contarPropiedades(conexion, publicas));
        request.setAttribute("totalInmobiliarias", contarInmobiliarias(conexion, null));
        request.setAttribute("ciudades", listarCiudades(conexion));
        request.setAttribute("tipos", listarTiposPropiedad(conexion));
    }
    request.getRequestDispatcher("/WEB-INF/vista/inicio.jsp").forward(request, response);
%>
