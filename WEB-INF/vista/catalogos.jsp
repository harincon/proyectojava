<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Catálogos";
    String menuActivo = "catalogos";
    boolean vistaPanel = true;
    String catalogo = (String) request.getAttribute("catalogo");
    List<?> elementos = (List<?>) request.getAttribute("elementos");
    Integer idEditando = (Integer) request.getAttribute("idEditando");
    // controlador, pestaña, parámetro del id, largo máximo, campo, descripción
    String[][] pestanas = {
        {"ciudad", "Ciudades", "id_ciudad", "100", "Nombre de la ciudad", "Ciudades donde se ubican las propiedades."},
        {"tipo_propiedad", "Tipos<span class=\"d-none d-sm-inline\"> de propiedad</span>","id_tipo_propiedad", "50", "Nombre del tipo", "Clasificación de los inmuebles: casa, apartamento, local…"},
        {"caracteristica", "Características", "id_caracteristica", "60", "Nombre de la característica", "Servicios o cualidades que se marcan en cada propiedad."}
    };
    String[] actual = pestanas[0];
    for (String[] pestana : pestanas) {
        if (pestana[0].equals(catalogo)) {
            actual = pestana;
        }
    }
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<%
    String rutaCatalogo = ctx + "/controlador/" + actual[0] + ".jsp";
%>
<h1 class="h3 titulo-pagina mb-1">Catálogos</h1>
<p class="text-suave mb-4">Listas que se usan al publicar y filtrar propiedades. No se elimina lo que esté en uso.</p>

<div class="card border-0 shadow-sm">
  <div class="card-header bg-white pb-0">
    <ul class="nav nav-tabs card-header-tabs">
      <% for (String[] pestana : pestanas) { %>
      <li class="nav-item">
        <a class="nav-link<%= pestana == actual ? " active" : "" %>"<%= pestana == actual ? " aria-current=\"page\"" : "" %>
           href="<%= ctx %>/controlador/<%= pestana[0] %>.jsp?accion=listar"><%= pestana[1] %></a>
      </li>
      <% } %>
    </ul>
  </div>
  <div class="card-body p-4">
    <p class="text-suave"><%= actual[5] %></p>
    <form class="row g-2 mb-4" method="post" action="<%= rutaCatalogo %>?accion=crear">
      <%= campoToken(session) %>
      <div class="col-sm-8 col-lg-6">
        <label class="visually-hidden" for="nombreNuevo"><%= actual[4] %></label>
        <input class="form-control<%= idEditando == null ? invalido(request, "nombre") : "" %>" id="nombreNuevo" name="nombre"
               maxlength="<%= actual[3] %>" placeholder="<%= actual[4] %>"
               value="<%= idEditando == null ? valorFormulario(request, "nombre") : "" %>" required>
        <div class="invalid-feedback"><%= errorFormulario(request, "nombre") %></div>
      </div>
      <div class="col-auto">
        <button type="submit" class="btn btn-primary"><i class="bi bi-plus-lg me-1"></i>Agregar</button>
      </div>
    </form>

    <% if (elementos.isEmpty()) { %>
    <div class="vacio"><i class="bi bi-tags" aria-hidden="true"></i>Todavía no hay registros en este catálogo.</div>
    <% } else { %>
    <div class="table-responsive">
      <table class="table tabla-habita mb-0">
        <thead><tr><th>Nombre</th><th class="text-end">Propiedades</th><th class="text-end">Acciones</th></tr></thead>
        <tbody>
          <% for (Object elemento : elementos) {
               Map<?, ?> fila = (Map<?, ?>) elemento;
               int id = (Integer) fila.get("id");
               int usos = (Integer) fila.get("usos");
               boolean editandoFila = idEditando != null && idEditando == id; %>
          <tr>
            <% if (editandoFila) {
                 boolean conError = !errorFormulario(request, "nombre").isEmpty(); %>
            <td colspan="3">
              <form class="d-flex flex-wrap gap-2 align-items-start" method="post" action="<%= rutaCatalogo %>?accion=actualizar&<%= actual[2] %>=<%= id %>">
                <%= campoToken(session) %>
                <div class="flex-grow-1">
                  <label class="visually-hidden" for="nombreEditado"><%= actual[4] %></label>
                  <input class="form-control<%= invalido(request, "nombre") %>" id="nombreEditado" name="nombre" maxlength="<%= actual[3] %>"
                         value="<%= conError ? valorFormulario(request, "nombre") : escapar(fila.get("nombre")) %>" required autofocus>
                  <div class="invalid-feedback"><%= errorFormulario(request, "nombre") %></div>
                </div>
                <button type="submit" class="btn btn-primary">Guardar</button>
                <a class="btn btn-outline-secondary" href="<%= rutaCatalogo %>?accion=listar">Cancelar</a>
              </form>
            </td>
            <% } else { %>
            <td><%= escapar(fila.get("nombre")) %></td>
            <td class="text-end"><%= usos %></td>
            <td class="acciones">
              <a class="btn btn-outline-primary btn-sm" href="<%= rutaCatalogo %>?accion=editar&<%= actual[2] %>=<%= id %>">Editar</a>
              <% if (usos == 0) { %>
              <form class="d-inline" method="post" action="<%= rutaCatalogo %>?accion=eliminar&<%= actual[2] %>=<%= id %>"
                    onsubmit="return confirm('¿Eliminar este registro?');">
                <%= campoToken(session) %>
                <button type="submit" class="btn btn-outline-danger btn-sm">Eliminar</button>
              </form>
              <% } else { %>
              <span class="btn btn-sm disabled border-0 text-suave">En uso</span>
              <% } %>
            </td>
            <% } %>
          </tr>
          <% } %>
        </tbody>
      </table>
    </div>
    <% } %>
  </div>
</div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
