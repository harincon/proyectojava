<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.math.BigDecimal,java.net.URLEncoder,java.util.List" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Propiedades";
    String menuActivo = "propiedades";
    boolean vistaPanel = true;
    List<?> propiedades = (List<?>) request.getAttribute("propiedades");
    String busqueda = (String) request.getAttribute("busqueda");
    boolean esAdmin = Boolean.TRUE.equals(request.getAttribute("esAdmin"));
    int pagina = (Integer) request.getAttribute("pagina");
    int paginas = (Integer) request.getAttribute("paginas");
    int total = (Integer) request.getAttribute("total");
    String filtroUrl = busqueda == null ? "" : "&q=" + URLEncoder.encode(busqueda, "UTF-8");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
  <div>
    <h1 class="h3 titulo-pagina mb-1"><%= esAdmin ? "Todas las propiedades" : "Mis propiedades" %></h1>
    <p class="text-suave mb-0">Publicaciones, estado y visibilidad en el catálogo. <%= total + (total == 1 ? " propiedad" : " propiedades") %>.</p>
  </div>
  <a class="btn btn-primary" href="<%= ctx %>/controlador/propiedad.jsp?accion=nueva"><i class="bi bi-plus-lg me-1"></i>Nueva propiedad</a>
</div>

<form class="row g-2 mb-3" method="get" action="<%= ctx %>/controlador/propiedad.jsp">
  <input type="hidden" name="accion" value="gestionar">
  <div class="col-sm-8 col-lg-6">
    <label class="visually-hidden" for="q">Buscar</label>
    <input class="form-control" id="q" name="q" maxlength="150" value="<%= escapar(busqueda) %>" placeholder="Buscar por título, dirección o matrícula">
  </div>
  <div class="col-auto d-flex gap-2">
    <button type="submit" class="btn btn-marca"><i class="bi bi-search me-1"></i>Buscar</button>
    <% if (busqueda != null) { %>
    <a class="btn btn-outline-secondary" href="<%= ctx %>/controlador/propiedad.jsp?accion=gestionar">Limpiar</a>
    <% } %>
  </div>
</form>

<% if (propiedades.isEmpty()) { %>
<div class="vacio"><i class="bi bi-house-add" aria-hidden="true"></i>Todavía no hay propiedades publicadas.</div>
<% } else { %>
<div class="card border-0 shadow-sm">
  <div class="table-responsive">
    <table class="table tabla-habita mb-0">
      <thead><tr><th>Propiedad</th><% if (esAdmin) { %><th>Empresa</th><% } %><th>Ciudad y tipo</th><th class="text-end">Precio</th><th>Estado</th><th>Catálogo</th><th class="text-end">Acciones</th></tr></thead>
      <tbody>
        <% for (Object elemento : propiedades) {
             Map<?, ?> propiedad = (Map<?, ?>) elemento;
             boolean activa = (Boolean) propiedad.get("activa");
             Object id = propiedad.get("idPropiedad"); %>
        <tr>
          <td>
            <div class="fw-semibold"><%= escapar(propiedad.get("titulo")) %></div>
            <div class="small text-suave"><%= escapar(propiedad.get("matricula")) %><%= Boolean.TRUE.equals(propiedad.get("destacada")) ? " · destacada" : "" %></div>
          </td>
          <% if (esAdmin) { %><td><%= escapar(propiedad.get("inmobiliaria")) %></td><% } %>
          <td>
            <div><%= escapar(propiedad.get("ciudad")) %></div>
            <div class="small text-suave"><%= escapar(propiedad.get("tipo")) %> · <%= escapar(propiedad.get("operacion")) %></div>
          </td>
          <td class="text-end"><%= formatoPesos((BigDecimal) propiedad.get("precio")) %></td>
          <td><span class="estado estado-<%= escapar(propiedad.get("estado")) %>"><%= escapar(propiedad.get("estado")) %></span></td>
          <td><span class="estado estado-<%= activa ? "ACTIVA" : "INACTIVA" %>"><%= activa ? "VISIBLE" : "RETIRADA" %></span></td>
          <td class="acciones">
            <a class="btn btn-outline-secondary btn-sm" href="<%= ctx %>/controlador/propiedad.jsp?accion=detalle&id_propiedad=<%= id %>">Ver</a>
            <a class="btn btn-outline-primary btn-sm" href="<%= ctx %>/controlador/propiedad.jsp?accion=editar&id_propiedad=<%= id %>">Editar</a>
            <form class="d-inline" method="post" action="<%= ctx %>/controlador/propiedad.jsp?accion=cambiar_activa&id_propiedad=<%= id %>">
              <%= campoToken(session) %>
              <input type="hidden" name="activa" value="<%= !activa %>">
              <button type="submit" class="btn btn-sm <%= activa ? "btn-outline-danger" : "btn-outline-primary" %>"><%= activa ? "Retirar" : "Publicar" %></button>
            </form>
          </td>
        </tr>
        <% } %>
      </tbody>
    </table>
  </div>
</div>

<% if (paginas > 1) { %>
<nav class="mt-3" aria-label="Páginas de propiedades">
  <ul class="pagination">
    <li class="page-item<%= pagina == 1 ? " disabled" : "" %>"><a class="page-link" href="<%= ctx %>/controlador/propiedad.jsp?accion=gestionar&pagina=<%= pagina - 1 %><%= filtroUrl %>">Anterior</a></li>
    <% for (int numero = 1; numero <= paginas; numero++) { %>
    <li class="page-item<%= numero == pagina ? " active" : "" %>"><a class="page-link" href="<%= ctx %>/controlador/propiedad.jsp?accion=gestionar&pagina=<%= numero %><%= filtroUrl %>"><%= numero %></a></li>
    <% } %>
    <li class="page-item<%= pagina == paginas ? " disabled" : "" %>"><a class="page-link" href="<%= ctx %>/controlador/propiedad.jsp?accion=gestionar&pagina=<%= pagina + 1 %><%= filtroUrl %>">Siguiente</a></li>
  </ul>
</nav>
<% } %>
<% } %>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
