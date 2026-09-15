<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.net.URLEncoder,java.util.List" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Inmobiliarias";
    String menuActivo = "inmobiliarias";
    boolean vistaPanel = true;
    List<?> empresas = (List<?>) request.getAttribute("empresas");
    String busqueda = (String) request.getAttribute("busqueda");
    int pagina = (Integer) request.getAttribute("pagina");
    int paginas = (Integer) request.getAttribute("paginas");
    int total = (Integer) request.getAttribute("total");
    String filtroUrl = busqueda == null ? "" : "&q=" + URLEncoder.encode(busqueda, "UTF-8");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
  <div>
    <h1 class="h3 titulo-pagina mb-1">Inmobiliarias</h1>
    <p class="text-suave mb-0">Empresas y su cuenta responsable. <%= total + (total == 1 ? " empresa" : " empresas") %>.</p>
  </div>
  <a class="btn btn-primary" href="<%= ctx %>/controlador/inmobiliaria.jsp?accion=vincular"><i class="bi bi-building-add me-1"></i>Nueva inmobiliaria</a>
</div>

<form class="row g-2 mb-3" method="get" action="<%= ctx %>/controlador/inmobiliaria.jsp">
  <input type="hidden" name="accion" value="listar">
  <div class="col-sm-8 col-lg-6">
    <label class="visually-hidden" for="q">Buscar</label>
    <input class="form-control" id="q" name="q" maxlength="150" value="<%= escapar(busqueda) %>" placeholder="Buscar por empresa, identificación o responsable">
  </div>
  <div class="col-auto d-flex gap-2">
    <button type="submit" class="btn btn-marca"><i class="bi bi-search me-1"></i>Buscar</button>
    <% if (busqueda != null) { %>
    <a class="btn btn-outline-secondary" href="<%= ctx %>/controlador/inmobiliaria.jsp?accion=listar">Limpiar</a>
    <% } %>
  </div>
</form>

<% if (empresas.isEmpty()) { %>
<div class="vacio"><i class="bi bi-buildings" aria-hidden="true"></i>No hay empresas que coincidan con la búsqueda.</div>
<% } else { %>
<div class="card border-0 shadow-sm">
  <div class="table-responsive">
    <table class="table tabla-habita mb-0">
      <thead><tr><th>Empresa</th><th>Responsable</th><th>Contacto</th><th class="text-end">Propiedades</th><th>Cuenta</th><th class="text-end">Acciones</th></tr></thead>
      <tbody>
        <% for (Object elemento : empresas) {
             Map<?, ?> empresa = (Map<?, ?>) elemento;
             boolean activo = (Boolean) empresa.get("activo");
             String responsable = String.valueOf(empresa.get("responsable")); %>
        <tr>
          <td>
            <div class="fw-semibold"><%= escapar(empresa.get("nombre")) %></div>
            <div class="small text-suave"><%= escapar(empresa.get("identificacion")) %></div>
          </td>
          <td>
            <div><%= escapar(responsable.isEmpty() ? empresa.get("correoResponsable") : responsable) %></div>
            <div class="small text-suave"><%= escapar(empresa.get("correoResponsable")) %></div>
          </td>
          <td>
            <div><%= escapar(empresa.get("telefono")) %></div>
            <div class="small text-suave"><%= escapar(empresa.get("correoContacto")) %></div>
          </td>
          <td class="text-end"><%= empresa.get("propiedades") %></td>
          <td><span class="estado estado-<%= activo ? "ACTIVO" : "INACTIVO" %>"><%= activo ? "ACTIVO" : "INACTIVO" %></span></td>
          <td class="acciones">
            <a class="btn btn-outline-primary btn-sm" href="<%= ctx %>/controlador/inmobiliaria.jsp?accion=editar&id_inmobiliaria=<%= empresa.get("idInmobiliaria") %>">Editar</a>
            <a class="btn btn-outline-secondary btn-sm" href="<%= ctx %>/controlador/usuario.jsp?accion=editar&id_usuario=<%= empresa.get("idUsuario") %>">Cuenta</a>
          </td>
        </tr>
        <% } %>
      </tbody>
    </table>
  </div>
</div>

<% if (paginas > 1) { %>
<nav class="mt-3" aria-label="Páginas de inmobiliarias">
  <ul class="pagination">
    <li class="page-item<%= pagina == 1 ? " disabled" : "" %>"><a class="page-link" href="<%= ctx %>/controlador/inmobiliaria.jsp?accion=listar&pagina=<%= pagina - 1 %><%= filtroUrl %>">Anterior</a></li>
    <% for (int numero = 1; numero <= paginas; numero++) { %>
    <li class="page-item<%= numero == pagina ? " active" : "" %>"><a class="page-link" href="<%= ctx %>/controlador/inmobiliaria.jsp?accion=listar&pagina=<%= numero %><%= filtroUrl %>"><%= numero %></a></li>
    <% } %>
    <li class="page-item<%= pagina == paginas ? " disabled" : "" %>"><a class="page-link" href="<%= ctx %>/controlador/inmobiliaria.jsp?accion=listar&pagina=<%= pagina + 1 %><%= filtroUrl %>">Siguiente</a></li>
  </ul>
</nav>
<% } %>
<% } %>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
