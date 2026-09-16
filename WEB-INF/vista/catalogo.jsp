<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.math.BigDecimal,java.net.URLEncoder,java.util.List" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Catálogo";
    String menuActivo = "catalogo";
    boolean vistaPanel = false;
    List<?> propiedades = (List<?>) request.getAttribute("propiedades");
    List<?> ciudades = (List<?>) request.getAttribute("ciudades");
    List<?> tipos = (List<?>) request.getAttribute("tipos");
    List<?> caracteristicas = (List<?>) request.getAttribute("caracteristicas");
    List<?> elegidas = (List<?>) request.getAttribute("elegidas");
    int pagina = (Integer) request.getAttribute("pagina");
    int paginas = (Integer) request.getAttribute("paginas");
    int total = (Integer) request.getAttribute("total");
    String orden = (String) request.getAttribute("orden");

    // Los filtros se conservan al cambiar de página.
    StringBuilder filtroUrl = new StringBuilder();
    String[] camposFiltro = {"q", "ciudad", "tipo", "operacion", "precio_min", "precio_max", "orden"};
    for (String campo : camposFiltro) {
        String valor = limpiar(request.getParameter(campo));
        if (valor != null) {
            filtroUrl.append("&").append(campo).append("=").append(URLEncoder.encode(valor, "UTF-8"));
        }
    }
    for (Object id : elegidas) {
        filtroUrl.append("&caracteristica=").append(id);
    }
    boolean hayFiltros = filtroUrl.length() > 0;
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<div class="container py-5">
  <div class="seccion-encabezado mb-4">
    <p class="seccion-etiqueta mb-2">Catálogo</p>
    <h1 class="titulo-pagina display-6 mb-2">Propiedades disponibles</h1>
    <p class="text-suave mb-0"><%= total + (total == 1 ? " propiedad encontrada" : " propiedades encontradas") %>.</p>
  </div>

  <div class="row g-4">
    <div class="col-lg-3">
      <form class="card border-0 shadow-sm" method="get" action="<%= ctx %>/controlador/propiedad.jsp">
        <input type="hidden" name="accion" value="catalogo">
        <div class="card-body p-4">
          <h2 class="h6 titulo-pagina mb-3">Filtros</h2>
          <div class="mb-3">
            <label class="form-label" for="q">Buscar</label>
            <input class="form-control" id="q" name="q" maxlength="150" value="<%= escapar(request.getParameter("q")) %>" placeholder="Título, dirección o empresa">
          </div>
          <div class="mb-3">
            <label class="form-label" for="ciudad">Ciudad</label>
            <select class="form-select" id="ciudad" name="ciudad">
              <option value="">Todas</option>
              <% for (Object elemento : ciudades) { Map<?, ?> ciudad = (Map<?, ?>) elemento;
                   boolean marcada = String.valueOf(ciudad.get("id")).equals(request.getParameter("ciudad")); %>
              <option value="<%= ciudad.get("id") %>"<%= marcada ? " selected" : "" %>><%= escapar(ciudad.get("nombre")) %></option>
              <% } %>
            </select>
          </div>
          <div class="mb-3">
            <label class="form-label" for="tipo">Tipo de inmueble</label>
            <select class="form-select" id="tipo" name="tipo">
              <option value="">Todos</option>
              <% for (Object elemento : tipos) { Map<?, ?> tipo = (Map<?, ?>) elemento;
                   boolean marcado = String.valueOf(tipo.get("id")).equals(request.getParameter("tipo")); %>
              <option value="<%= tipo.get("id") %>"<%= marcado ? " selected" : "" %>><%= escapar(tipo.get("nombre")) %></option>
              <% } %>
            </select>
          </div>
          <div class="mb-3">
            <label class="form-label" for="operacion">Modalidad</label>
            <select class="form-select" id="operacion" name="operacion">
              <option value="">Venta y arriendo</option>
              <option value="VENTA"<%= "VENTA".equals(request.getParameter("operacion")) ? " selected" : "" %>>Venta</option>
              <option value="ARRIENDO"<%= "ARRIENDO".equals(request.getParameter("operacion")) ? " selected" : "" %>>Arriendo</option>
            </select>
          </div>
          <div class="row g-2 mb-3">
            <div class="col-6">
              <label class="form-label" for="precio_min">Precio desde</label>
              <input class="form-control" type="number" id="precio_min" name="precio_min" min="0" step="100000" value="<%= escapar(request.getParameter("precio_min")) %>">
            </div>
            <div class="col-6">
              <label class="form-label" for="precio_max">Hasta</label>
              <input class="form-control" type="number" id="precio_max" name="precio_max" min="0" step="100000" value="<%= escapar(request.getParameter("precio_max")) %>">
            </div>
          </div>
          <div class="mb-3">
            <label class="form-label" for="orden">Ordenar por</label>
            <select class="form-select" id="orden" name="orden">
              <option value="">Destacadas primero</option>
              <option value="precio_asc"<%= "precio_asc".equals(orden) ? " selected" : "" %>>Precio: menor a mayor</option>
              <option value="precio_desc"<%= "precio_desc".equals(orden) ? " selected" : "" %>>Precio: mayor a menor</option>
              <option value="area_desc"<%= "area_desc".equals(orden) ? " selected" : "" %>>Área: mayor primero</option>
            </select>
          </div>
          <% if (!caracteristicas.isEmpty()) { %>
          <span class="form-label d-block">Características</span>
          <div class="mb-3">
            <% for (Object elemento : caracteristicas) { Map<?, ?> caracteristica = (Map<?, ?>) elemento;
                 Object id = caracteristica.get("id"); %>
            <div class="form-check">
              <input class="form-check-input" type="checkbox" id="caracteristica<%= id %>" name="caracteristica" value="<%= id %>"<%= elegidas.contains(id) ? " checked" : "" %>>
              <label class="form-check-label" for="caracteristica<%= id %>"><%= escapar(caracteristica.get("nombre")) %></label>
            </div>
            <% } %>
          </div>
          <% } %>
          <div class="d-grid gap-2">
            <button type="submit" class="btn btn-primary"><i class="bi bi-funnel me-1"></i>Filtrar</button>
            <% if (hayFiltros) { %>
            <a class="btn btn-outline-secondary" href="<%= ctx %>/controlador/propiedad.jsp?accion=catalogo">Limpiar filtros</a>
            <% } %>
          </div>
        </div>
      </form>
    </div>

    <div class="col-lg-9">
      <% if (propiedades.isEmpty()) { %>
      <div class="vacio"><i class="bi bi-search" aria-hidden="true"></i>Ninguna propiedad coincide con los filtros elegidos.</div>
      <% } else { %>
      <div class="row row-cols-1 row-cols-md-2 row-cols-xl-3 g-4">
        <% for (Object elemento : propiedades) {
             Map<?, ?> propiedad = (Map<?, ?>) elemento;
             String enlace = ctx + "/controlador/propiedad.jsp?accion=detalle&id_propiedad=" + propiedad.get("idPropiedad"); %>
        <div class="col">
          <article class="card tarjeta-propiedad h-100">
            <a href="<%= enlace %>"><img class="foto" src="<%= urlImagen(ctx, propiedad.get("foto")) %>" alt="Fotografía de <%= escapar(propiedad.get("titulo")) %>"></a>
            <div class="card-body p-4 d-flex flex-column">
              <div class="d-flex justify-content-between align-items-center gap-2 mb-3">
                <span class="badge etiqueta-propiedad"><%= escapar(propiedad.get("operacion")) %></span>
                <span class="estado estado-<%= escapar(propiedad.get("estado")) %>"><%= escapar(propiedad.get("estado")) %></span>
              </div>
              <h2 class="h5 titulo-pagina mb-2"><a class="text-decoration-none text-marca" href="<%= enlace %>"><%= escapar(propiedad.get("titulo")) %></a></h2>
              <p class="datos mb-2"><i class="bi bi-geo-alt me-1"></i><%= escapar(propiedad.get("ciudad")) %> · <%= escapar(propiedad.get("tipo")) %></p>
              <p class="datos mb-4"><%= propiedad.get("habitaciones") %> hab · <%= propiedad.get("banos") %> baños · <%= formatoArea((BigDecimal) propiedad.get("area")) %> m²</p>
              <div class="mt-auto">
                <span class="precio d-block"><%= formatoPesos((BigDecimal) propiedad.get("precio")) + ("ARRIENDO".equals(propiedad.get("operacion")) ? " / mes" : "") %></span>
                <span class="text-suave small d-block text-truncate"><i class="bi bi-building me-1"></i><%= escapar(propiedad.get("inmobiliaria")) %></span>
              </div>
            </div>
          </article>
        </div>
        <% } %>
      </div>

      <% if (paginas > 1) { %>
      <nav class="mt-4" aria-label="Páginas del catálogo">
        <ul class="pagination">
          <li class="page-item<%= pagina == 1 ? " disabled" : "" %>"><a class="page-link" href="<%= ctx %>/controlador/propiedad.jsp?accion=catalogo&pagina=<%= pagina - 1 %><%= filtroUrl %>">Anterior</a></li>
          <% for (int numero = 1; numero <= paginas; numero++) { %>
          <li class="page-item<%= numero == pagina ? " active" : "" %>"><a class="page-link" href="<%= ctx %>/controlador/propiedad.jsp?accion=catalogo&pagina=<%= numero %><%= filtroUrl %>"><%= numero %></a></li>
          <% } %>
          <li class="page-item<%= pagina == paginas ? " disabled" : "" %>"><a class="page-link" href="<%= ctx %>/controlador/propiedad.jsp?accion=catalogo&pagina=<%= pagina + 1 %><%= filtroUrl %>">Siguiente</a></li>
        </ul>
      </nav>
      <% } %>
      <% } %>
    </div>
  </div>
</div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
