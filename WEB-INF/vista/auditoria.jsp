<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.net.URLEncoder,java.time.LocalDateTime,java.util.List,java.util.Map" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Auditoría";
    String menuActivo = "auditoria";
    boolean vistaPanel = true;
    List<?> registros = (List<?>) request.getAttribute("registros");
    String usuarioFiltro = (String) request.getAttribute("usuario");
    String textoFiltro = (String) request.getAttribute("texto");
    String desdeFiltro = (String) request.getAttribute("desde");
    String hastaFiltro = (String) request.getAttribute("hasta");
    String errorFiltro = (String) request.getAttribute("errorFiltro");
    int total = (Integer) request.getAttribute("total");
    int pagina = (Integer) request.getAttribute("pagina");
    int paginas = (Integer) request.getAttribute("paginas");
    StringBuilder filtroUrlB7 = new StringBuilder();
    if (usuarioFiltro != null) filtroUrlB7.append("&usuario=").append(URLEncoder.encode(usuarioFiltro, "UTF-8"));
    if (textoFiltro != null) filtroUrlB7.append("&q=").append(URLEncoder.encode(textoFiltro, "UTF-8"));
    if (desdeFiltro != null) filtroUrlB7.append("&desde=").append(URLEncoder.encode(desdeFiltro, "UTF-8"));
    if (hastaFiltro != null) filtroUrlB7.append("&hasta=").append(URLEncoder.encode(hastaFiltro, "UTF-8"));
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<div class="mb-3">
  <h1 class="h3 titulo-pagina mb-1">Auditoría</h1>
  <p class="text-suave mb-0"><%= total + (total == 1 ? " evento registrado." : " eventos registrados.") %></p>
</div>

<form class="card border-0 shadow-sm p-3 mb-3" method="get" action="<%= ctx %>/controlador/auditoria.jsp">
  <input type="hidden" name="accion" value="listar">
  <div class="row g-3 align-items-end">
    <div class="col-md-6 col-lg">
      <label class="form-label" for="usuario">Usuario</label>
      <input class="form-control" id="usuario" name="usuario" maxlength="150" value="<%= escapar(usuarioFiltro) %>" placeholder="Nombre o correo">
    </div>
    <div class="col-md-6 col-lg">
      <label class="form-label" for="q">Acción</label>
      <input class="form-control" id="q" name="q" maxlength="255" value="<%= escapar(textoFiltro) %>" placeholder="Texto del evento">
    </div>
    <div class="col-6 col-lg-2">
      <label class="form-label" for="desde">Desde</label>
      <input class="form-control" type="date" id="desde" name="desde" value="<%= escapar(desdeFiltro) %>">
    </div>
    <div class="col-6 col-lg-2">
      <label class="form-label" for="hasta">Hasta</label>
      <input class="form-control" type="date" id="hasta" name="hasta" value="<%= escapar(hastaFiltro) %>">
    </div>
    <div class="col-12 col-lg-auto d-flex gap-2">
      <button class="btn btn-marca text-nowrap" type="submit"><i class="bi bi-search me-1"></i>Filtrar</button>
      <a class="btn btn-outline-secondary text-nowrap" href="<%= ctx %>/controlador/auditoria.jsp?accion=listar">Limpiar</a>
    </div>
  </div>
  <% if (errorFiltro != null) { %><div class="text-danger small mt-2"><%= escapar(errorFiltro) %></div><% } %>
</form>

<% if (registros.isEmpty()) { %>
<div class="vacio"><i class="bi bi-journal-text"></i>No hay eventos que coincidan con los filtros.</div>
<% } else { %>
<div class="card border-0 shadow-sm">
  <div class="table-responsive">
    <table class="table tabla-habita mb-0">
      <thead><tr><th>ID</th><th>Fecha</th><th>Usuario</th><th>Acción</th></tr></thead>
      <tbody>
        <% for (Object elemento : registros) {
             Map<?, ?> registro = (Map<?, ?>) elemento;
             String nombre = registro.get("usuario") == null ? "" : registro.get("usuario").toString().trim();
             String correo = registro.get("correo") == null ? "" : registro.get("correo").toString(); %>
        <tr>
          <td><%= registro.get("idAuditoria") %></td>
          <td><%= formatoFecha((LocalDateTime) registro.get("fecha")) %></td>
          <td>
            <% if (registro.get("idUsuario") == null) { %>
            Sistema
            <% } else { %>
            <div><%= escapar(nombre.isEmpty() ? correo : nombre) %></div>
            <div class="small text-suave"><%= escapar(correo) %></div>
            <% } %>
          </td>
          <td><%= escapar(registro.get("accion")) %></td>
        </tr>
        <% } %>
      </tbody>
    </table>
  </div>
</div>

<% if (paginas > 1) { %>
<nav class="mt-3" aria-label="Páginas de auditoría">
  <ul class="pagination">
    <li class="page-item<%= pagina == 1 ? " disabled" : "" %>"><a class="page-link" href="<%= ctx %>/controlador/auditoria.jsp?accion=listar&pagina=<%= pagina - 1 %><%= filtroUrlB7 %>">Anterior</a></li>
    <% for (int numero = 1; numero <= paginas; numero++) { %>
    <li class="page-item<%= numero == pagina ? " active" : "" %>"><a class="page-link" href="<%= ctx %>/controlador/auditoria.jsp?accion=listar&pagina=<%= numero %><%= filtroUrlB7 %>"><%= numero %></a></li>
    <% } %>
    <li class="page-item<%= pagina == paginas ? " disabled" : "" %>"><a class="page-link" href="<%= ctx %>/controlador/auditoria.jsp?accion=listar&pagina=<%= pagina + 1 %><%= filtroUrlB7 %>">Siguiente</a></li>
  </ul>
</nav>
<% } %>
<% } %>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
