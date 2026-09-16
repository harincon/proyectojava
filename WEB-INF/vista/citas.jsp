<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.time.LocalDateTime,java.util.List,java.util.Map" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String modoCitas = (String) request.getAttribute("modo");
    boolean vistaCliente = "cliente".equals(modoCitas);
    boolean administradorCitas = Boolean.TRUE.equals(request.getAttribute("esAdmin"));
    String tituloPagina = vistaCliente ? "Mis citas" : (administradorCitas ? "Todas las citas" : "Citas recibidas");
    String menuActivo = vistaCliente ? "citas" : "citas_recibidas";
    boolean vistaPanel = true;
    List<?> citas = (List<?>) request.getAttribute("citas");
    LocalDateTime momentoActual = ahora();
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
  <div>
    <h1 class="h3 titulo-pagina mb-1"><%= tituloPagina %></h1>
    <p class="text-suave mb-0"><%= vistaCliente ? "Consulta y cancela las visitas que has solicitado." : "Revisa y gestiona las visitas de las propiedades." %></p>
  </div>
  <% if (vistaCliente) { %>
  <a class="btn btn-primary" href="<%= ctx %>/controlador/propiedad.jsp?accion=catalogo"><i class="bi bi-calendar-plus me-1"></i>Agendar visita</a>
  <% } %>
</div>

<% if (citas.isEmpty()) { %>
<div class="vacio"><i class="bi bi-calendar2" aria-hidden="true"></i><%= vistaCliente ? "Todavía no has solicitado citas." : "No hay citas para gestionar." %></div>
<% } else { %>
<div class="card border-0 shadow-sm">
  <div class="table-responsive">
    <table class="table tabla-habita mb-0">
      <thead>
        <tr><th>Propiedad</th><% if (!vistaCliente) { %><th>Cliente</th><% } %><th>Fecha y hora</th><th>Estado</th><th class="text-end">Acciones</th></tr>
      </thead>
      <tbody>
        <% for (Object elemento : citas) {
             Map<?, ?> cita = (Map<?, ?>) elemento;
             String estado = (String) cita.get("estado");
             LocalDateTime fechaHora = (LocalDateTime) cita.get("fechaHora");
             Object id = cita.get("idCita");
             String cliente = String.valueOf(cita.get("cliente"));
             boolean activa = "PENDIENTE".equals(estado) || "CONFIRMADA".equals(estado); %>
        <tr>
          <td>
            <div class="fw-semibold"><a class="text-decoration-none text-marca" href="<%= ctx %>/controlador/propiedad.jsp?accion=detalle&id_propiedad=<%= cita.get("idPropiedad") %>"><%= escapar(cita.get("titulo")) %></a></div>
            <div class="small text-suave"><%= escapar(cita.get("ciudad")) %> · <%= escapar(cita.get("inmobiliaria")) %></div>
          </td>
          <% if (!vistaCliente) { %>
          <td><div><%= escapar(cliente.isEmpty() ? cita.get("correoCliente") : cliente) %></div><div class="small text-suave"><%= escapar(cita.get("correoCliente")) %></div></td>
          <% } %>
          <td><%= formatoFecha(fechaHora) %><% if (fechaHora.isBefore(momentoActual)) { %><div class="small text-suave">Fecha pasada</div><% } %></td>
          <td><span class="estado estado-<%= escapar(estado) %>"><%= escapar(estado) %></span></td>
          <td class="acciones">
            <% if (vistaCliente && activa) { %>
            <form class="d-inline" method="post" action="<%= ctx %>/controlador/cita.jsp?accion=cancelar&id_cita=<%= id %>">
              <%= campoToken(session) %><button type="submit" class="btn btn-outline-danger btn-sm">Cancelar</button>
            </form>
            <% } else if (!vistaCliente && "PENDIENTE".equals(estado)) { %>
            <form class="d-inline" method="post" action="<%= ctx %>/controlador/cita.jsp?accion=confirmar&id_cita=<%= id %>">
              <%= campoToken(session) %><button type="submit" class="btn btn-primary btn-sm">Confirmar</button>
            </form>
            <form class="d-inline" method="post" action="<%= ctx %>/controlador/cita.jsp?accion=rechazar&id_cita=<%= id %>">
              <%= campoToken(session) %><button type="submit" class="btn btn-outline-danger btn-sm">Rechazar</button>
            </form>
            <% if (administradorCitas) { %>
            <form class="d-inline" method="post" action="<%= ctx %>/controlador/cita.jsp?accion=cancelar&id_cita=<%= id %>">
              <%= campoToken(session) %><button type="submit" class="btn btn-outline-secondary btn-sm">Cancelar</button>
            </form>
            <% } %>
            <% } else if (!vistaCliente && "CONFIRMADA".equals(estado)) { %>
            <% if (fechaHora.isBefore(momentoActual)) { %>
            <form class="d-inline" method="post" action="<%= ctx %>/controlador/cita.jsp?accion=realizar&id_cita=<%= id %>">
              <%= campoToken(session) %><button type="submit" class="btn btn-marca btn-sm">Marcar realizada</button>
            </form>
            <% } %>
            <form class="d-inline" method="post" action="<%= ctx %>/controlador/cita.jsp?accion=rechazar&id_cita=<%= id %>">
              <%= campoToken(session) %><button type="submit" class="btn btn-outline-danger btn-sm">Rechazar</button>
            </form>
            <% if (administradorCitas) { %>
            <form class="d-inline" method="post" action="<%= ctx %>/controlador/cita.jsp?accion=cancelar&id_cita=<%= id %>">
              <%= campoToken(session) %><button type="submit" class="btn btn-outline-secondary btn-sm">Cancelar</button>
            </form>
            <% } %>
            <% } else { %>
            <span class="small text-suave">Sin acciones</span>
            <% } %>
          </td>
        </tr>
        <% } %>
      </tbody>
    </table>
  </div>
</div>
<% } %>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
