<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.net.URLEncoder,java.util.List" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Usuarios";
    String menuActivo = "usuarios";
    boolean vistaPanel = true;
    List<?> usuarios = (List<?>) request.getAttribute("usuarios");
    String busqueda = (String) request.getAttribute("busqueda");
    int pagina = (Integer) request.getAttribute("pagina");
    int paginas = (Integer) request.getAttribute("paginas");
    int total = (Integer) request.getAttribute("total");
    String filtroUrl = busqueda == null ? "" : "&q=" + URLEncoder.encode(busqueda, "UTF-8");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
  <div>
    <h1 class="h3 titulo-pagina mb-1">Usuarios</h1>
    <p class="text-suave mb-0">Cuentas, estado y roles del sistema. <%= total + (total == 1 ? " cuenta" : " cuentas") %>.</p>
  </div>
  <div class="d-flex gap-2">
    <a class="btn btn-outline-primary" href="<%= ctx %>/controlador/rol.jsp?accion=listar"><i class="bi bi-tags me-1"></i>Roles</a>
    <a class="btn btn-primary" href="<%= ctx %>/controlador/usuario.jsp?accion=nuevo"><i class="bi bi-person-plus me-1"></i>Nuevo usuario</a>
  </div>
</div>

<form class="row g-2 mb-3" method="get" action="<%= ctx %>/controlador/usuario.jsp">
  <input type="hidden" name="accion" value="listar">
  <div class="col-sm-8 col-lg-6">
    <label class="visually-hidden" for="q">Buscar</label>
    <input class="form-control" id="q" name="q" maxlength="150" value="<%= escapar(busqueda) %>" placeholder="Buscar por nombre o correo">
  </div>
  <div class="col-auto d-flex gap-2">
    <button type="submit" class="btn btn-marca"><i class="bi bi-search me-1"></i>Buscar</button>
    <% if (busqueda != null) { %>
    <a class="btn btn-outline-secondary" href="<%= ctx %>/controlador/usuario.jsp?accion=listar">Limpiar</a>
    <% } %>
  </div>
</form>

<% if (usuarios.isEmpty()) { %>
<div class="vacio"><i class="bi bi-people" aria-hidden="true"></i>No hay cuentas que coincidan con la búsqueda.</div>
<% } else { %>
<div class="card border-0 shadow-sm">
  <div class="table-responsive">
    <table class="table tabla-habita mb-0">
      <thead><tr><th>Nombre</th><th>Correo</th><th>Roles</th><th>Estado</th><th class="text-end">Acciones</th></tr></thead>
      <tbody>
        <% for (Object elemento : usuarios) {
             Map<?, ?> usuario = (Map<?, ?>) elemento;
             boolean activo = (Boolean) usuario.get("activo");
             String nombres = usuario.get("nombres") == null ? "" : usuario.get("nombres").toString();
             String apellidos = usuario.get("apellidos") == null ? "" : usuario.get("apellidos").toString(); %>
        <tr>
          <td><%= escapar((nombres + " " + apellidos).trim()) %></td>
          <td><%= escapar(usuario.get("correo")) %></td>
          <td>
            <% for (String rol : usuario.get("roles").toString().split(",")) { if (!rol.isEmpty()) { %><span class="badge bg-marca me-1"><%= escapar(rol) %></span><% } } %>
          </td>
          <td><span class="estado estado-<%= activo ? "ACTIVO" : "INACTIVO" %>"><%= activo ? "ACTIVO" : "INACTIVO" %></span></td>
          <td class="acciones">
            <a class="btn btn-outline-primary btn-sm" href="<%= ctx %>/controlador/usuario.jsp?accion=editar&id_usuario=<%= usuario.get("idUsuario") %>">Editar</a>
            <form class="d-inline" method="post" action="<%= ctx %>/controlador/usuario.jsp?accion=cambiar_estado&id_usuario=<%= usuario.get("idUsuario") %>">
              <%= campoToken(session) %>
              <input type="hidden" name="activo" value="<%= !activo %>">
              <button type="submit" class="btn btn-sm <%= activo ? "btn-outline-danger" : "btn-outline-primary" %>"><%= activo ? "Desactivar" : "Activar" %></button>
            </form>
          </td>
        </tr>
        <% } %>
      </tbody>
    </table>
  </div>
</div>

<% if (paginas > 1) { %>
<nav class="mt-3" aria-label="Páginas de usuarios">
  <ul class="pagination">
    <li class="page-item<%= pagina == 1 ? " disabled" : "" %>"><a class="page-link" href="<%= ctx %>/controlador/usuario.jsp?accion=listar&pagina=<%= pagina - 1 %><%= filtroUrl %>">Anterior</a></li>
    <% for (int numero = 1; numero <= paginas; numero++) { %>
    <li class="page-item<%= numero == pagina ? " active" : "" %>"><a class="page-link" href="<%= ctx %>/controlador/usuario.jsp?accion=listar&pagina=<%= numero %><%= filtroUrl %>"><%= numero %></a></li>
    <% } %>
    <li class="page-item<%= pagina == paginas ? " disabled" : "" %>"><a class="page-link" href="<%= ctx %>/controlador/usuario.jsp?accion=listar&pagina=<%= pagina + 1 %><%= filtroUrl %>">Siguiente</a></li>
  </ul>
</nav>
<% } %>
<% } %>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
