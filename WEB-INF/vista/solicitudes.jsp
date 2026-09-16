<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.time.LocalDateTime,java.util.List,java.util.Map" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String modoSolicitudes = (String) request.getAttribute("modo");
    boolean vistaCliente = "cliente".equals(modoSolicitudes);
    boolean administradorSolicitudes = Boolean.TRUE.equals(request.getAttribute("esAdmin"));
    String tituloPagina = vistaCliente ? "Mis solicitudes"
            : (administradorSolicitudes ? "Todas las solicitudes" : "Solicitudes recibidas");
    String menuActivo = vistaCliente ? "solicitudes" : "solicitudes_recibidas";
    boolean vistaPanel = true;
    List<?> solicitudes = (List<?>) request.getAttribute("solicitudes");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
  <div>
    <h1 class="h3 titulo-pagina mb-1"><%= tituloPagina %></h1>
    <p class="text-suave mb-0"><%= vistaCliente ? "Consulta el avance de tus trámites y documentos." : "Revisa las solicitudes asociadas a las propiedades." %></p>
  </div>
  <% if (vistaCliente) { %>
  <a class="btn btn-primary" href="<%= ctx %>/controlador/propiedad.jsp?accion=catalogo"><i class="bi bi-folder-plus me-1"></i>Nueva solicitud</a>
  <% } %>
</div>

<% if (solicitudes.isEmpty()) { %>
<div class="vacio"><i class="bi bi-folder2-open" aria-hidden="true"></i><%= vistaCliente ? "Todavía no has radicado solicitudes." : "No hay solicitudes para gestionar." %></div>
<% } else { %>
<div class="card border-0 shadow-sm">
  <div class="table-responsive">
    <table class="table tabla-habita mb-0">
      <thead><tr><th>Propiedad</th><% if (!vistaCliente) { %><th>Cliente</th><% } %><th>Radicación</th><th>Estado</th><th class="text-end">Acciones</th></tr></thead>
      <tbody>
        <% for (Object elemento : solicitudes) {
             Map<?, ?> solicitud = (Map<?, ?>) elemento;
             String cliente = String.valueOf(solicitud.get("cliente")); %>
        <tr>
          <td>
            <div class="fw-semibold"><%= escapar(solicitud.get("titulo")) %></div>
            <div class="small text-suave"><%= escapar(solicitud.get("matricula")) %> · <%= escapar(solicitud.get("inmobiliaria")) %></div>
          </td>
          <% if (!vistaCliente) { %>
          <td><div><%= escapar(cliente.isEmpty() ? solicitud.get("correoCliente") : cliente) %></div><div class="small text-suave"><%= escapar(solicitud.get("correoCliente")) %></div></td>
          <% } %>
          <td><%= formatoFecha((LocalDateTime) solicitud.get("fecha")) %></td>
          <td><span class="estado estado-<%= escapar(solicitud.get("estado")) %>"><%= escapar(solicitud.get("estado")) %></span></td>
          <td class="acciones"><a class="btn btn-outline-primary btn-sm" href="<%= ctx %>/controlador/solicitud.jsp?accion=detalle&id_solicitud=<%= solicitud.get("idSolicitud") %>">Ver detalle</a></td>
        </tr>
        <% } %>
      </tbody>
    </table>
  </div>
</div>
<% } %>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
