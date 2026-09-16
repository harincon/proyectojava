<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.math.BigDecimal,java.util.List" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    Map<?, ?> propiedad = (Map<?, ?>) request.getAttribute("propiedad");
    List<?> imagenes = (List<?>) request.getAttribute("imagenes");
    List<?> caracteristicas = (List<?>) request.getAttribute("caracteristicas");
    List<?> parecidas = (List<?>) request.getAttribute("parecidas");
    boolean puedeEditar = Boolean.TRUE.equals(request.getAttribute("puedeEditar"));
    String tituloPagina = String.valueOf(propiedad.get("titulo"));
    String menuActivo = "catalogo";
    boolean vistaPanel = false;
    boolean enArriendo = "ARRIENDO".equals(propiedad.get("operacion"));
    boolean disponible = "DISPONIBLE".equals(propiedad.get("estado"));
    int idPropiedad = (Integer) propiedad.get("idPropiedad");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<div class="container py-5">
  <a class="small" href="<%= ctx %>/controlador/propiedad.jsp?accion=catalogo"><i class="bi bi-arrow-left me-1"></i>Volver al catálogo</a>

  <div class="row g-4 mt-1">
    <div class="col-lg-8">
      <% if (imagenes.size() > 1) { %>
      <div id="galeriaPropiedad" class="carousel slide mb-4">
        <div class="carousel-indicators">
          <% for (int i = 0; i < imagenes.size(); i++) { %>
          <button type="button" data-bs-target="#galeriaPropiedad" data-bs-slide-to="<%= i %>"<%= i == 0 ? " class=\"active\" aria-current=\"true\"" : "" %> aria-label="Fotografía <%= i + 1 %>"></button>
          <% } %>
        </div>
        <div class="carousel-inner rounded-4">
          <% for (int i = 0; i < imagenes.size(); i++) {
               Map<?, ?> imagen = (Map<?, ?>) imagenes.get(i); %>
          <div class="carousel-item<%= i == 0 ? " active" : "" %>">
            <img class="foto-detalle" src="<%= urlImagen(ctx, imagen.get("ruta")) %>" alt="Fotografía <%= i + 1 %> de <%= escapar(propiedad.get("titulo")) %>">
          </div>
          <% } %>
        </div>
        <button class="carousel-control-prev" type="button" data-bs-target="#galeriaPropiedad" data-bs-slide="prev">
          <span class="carousel-control-prev-icon" aria-hidden="true"></span><span class="visually-hidden">Anterior</span>
        </button>
        <button class="carousel-control-next" type="button" data-bs-target="#galeriaPropiedad" data-bs-slide="next">
          <span class="carousel-control-next-icon" aria-hidden="true"></span><span class="visually-hidden">Siguiente</span>
        </button>
      </div>
      <% } else { %>
      <img class="foto-detalle rounded-4 mb-4" src="<%= urlImagen(ctx, imagenes.isEmpty() ? null : ((Map<?, ?>) imagenes.get(0)).get("ruta")) %>"
           alt="Fotografía de <%= escapar(propiedad.get("titulo")) %>">
      <% } %>

      <div class="d-flex flex-wrap align-items-center gap-2 mb-2">
        <span class="badge etiqueta-propiedad"><%= escapar(propiedad.get("operacion")) %></span>
        <span class="estado estado-<%= escapar(propiedad.get("estado")) %>"><%= escapar(propiedad.get("estado")) %></span>
        <% if (!(Boolean) propiedad.get("activa")) { %>
        <span class="estado estado-INACTIVA">RETIRADA</span>
        <% } %>
      </div>
      <h1 class="titulo-pagina h2 mb-2"><%= escapar(propiedad.get("titulo")) %></h1>
      <p class="text-suave mb-4"><i class="bi bi-geo-alt me-1"></i><%= escapar(propiedad.get("direccion")) %>, <%= escapar(propiedad.get("ciudad")) %></p>

      <div class="row row-cols-2 row-cols-md-4 g-3 mb-4">
        <div class="col"><div class="card border-0 shadow-sm h-100"><div class="card-body p-3">
          <p class="text-suave small mb-1">Tipo</p><p class="fw-semibold mb-0"><%= escapar(propiedad.get("tipo")) %></p></div></div></div>
        <div class="col"><div class="card border-0 shadow-sm h-100"><div class="card-body p-3">
          <p class="text-suave small mb-1">Habitaciones</p><p class="fw-semibold mb-0"><%= propiedad.get("habitaciones") %></p></div></div></div>
        <div class="col"><div class="card border-0 shadow-sm h-100"><div class="card-body p-3">
          <p class="text-suave small mb-1">Baños</p><p class="fw-semibold mb-0"><%= propiedad.get("banos") %></p></div></div></div>
        <div class="col"><div class="card border-0 shadow-sm h-100"><div class="card-body p-3">
          <p class="text-suave small mb-1">Área</p><p class="fw-semibold mb-0"><%= formatoArea((BigDecimal) propiedad.get("area")) %> m²</p></div></div></div>
      </div>

      <% if (propiedad.get("descripcion") != null) { %>
      <h2 class="h5 titulo-pagina">Descripción</h2>
      <p class="mb-4"><%= escapar(propiedad.get("descripcion")) %></p>
      <% } %>

      <% if (!caracteristicas.isEmpty()) { %>
      <h2 class="h5 titulo-pagina">Características</h2>
      <p class="mb-0">
        <% for (Object elemento : caracteristicas) { Map<?, ?> caracteristica = (Map<?, ?>) elemento; %>
        <span class="badge bg-marca me-1 mb-1"><i class="bi bi-check2 me-1"></i><%= escapar(caracteristica.get("nombre")) %></span>
        <% } %>
      </p>
      <% } %>
    </div>

    <div class="col-lg-4">
      <div class="card border-0 shadow-sm mb-4">
        <div class="card-body p-4">
          <p class="text-suave small mb-1">Matrícula <%= escapar(propiedad.get("matricula")) %></p>
          <p class="precio h3 mb-1"><%= formatoPesos((BigDecimal) propiedad.get("precio")) %></p>
          <p class="text-suave mb-4"><%= enArriendo ? "Canon mensual" : "Precio de venta" %></p>

          <h2 class="h6 titulo-pagina mb-1">Publicada por</h2>
          <p class="fw-semibold mb-3"><%= escapar(propiedad.get("inmobiliaria")) %></p>
          <% if (haySesion) { %>
          <p class="mb-1"><i class="bi bi-telephone me-2"></i><%= escapar(propiedad.get("telefonoEmpresa")) %></p>
          <p class="mb-4"><i class="bi bi-envelope me-2"></i><%= escapar(propiedad.get("correoContacto")) %></p>
          <% } else { %>
          <p class="text-suave mb-4"><i class="bi bi-lock me-2"></i>Inicia sesión para ver los datos de contacto.</p>
          <% } %>

          <% if (!disponible || !(Boolean) propiedad.get("activa")) { %>
          <p class="text-suave mb-0"><i class="bi bi-info-circle me-2"></i>Esta propiedad ya no está disponible.</p>
          <% } else if (!haySesion) { %>
          <div class="d-grid gap-2">
            <a class="btn btn-primary" href="<%= ctx %>/controlador/acceso.jsp?accion=ingresar">Iniciar sesión</a>
            <a class="btn btn-outline-primary" href="<%= ctx %>/controlador/acceso.jsp?accion=registro">Crear cuenta</a>
          </div>
          <% } else if (rolesSesion.contains("CLIENTE")) { %>
          <div class="d-grid gap-2">
            <a class="btn btn-primary" href="<%= ctx %>/controlador/cita.jsp?accion=nueva&id_propiedad=<%= idPropiedad %>"><i class="bi bi-calendar-plus me-1"></i>Agendar visita</a>
            <a class="btn btn-outline-primary" href="<%= ctx %>/controlador/solicitud.jsp?accion=nueva&id_propiedad=<%= idPropiedad %>"><i class="bi bi-folder-plus me-1"></i>Enviar solicitud</a>
            <form method="post" action="<%= ctx %>/controlador/favorito.jsp?accion=agregar&id_propiedad=<%= idPropiedad %>">
              <%= campoToken(session) %>
              <button type="submit" class="btn btn-outline-secondary w-100"><i class="bi bi-heart me-1"></i>Guardar en favoritos</button>
            </form>
          </div>
          <% } %>

          <% if (puedeEditar) { %>
          <a class="btn btn-outline-secondary w-100 mt-3" href="<%= ctx %>/controlador/propiedad.jsp?accion=editar&id_propiedad=<%= idPropiedad %>"><i class="bi bi-pencil me-1"></i>Editar publicación</a>
          <% } %>
        </div>
      </div>
    </div>
  </div>

  <% if (!parecidas.isEmpty()) { %>
  <h2 class="h4 titulo-pagina mt-5 mb-3">Otras propiedades en <%= escapar(propiedad.get("ciudad")) %></h2>
  <div class="row row-cols-1 row-cols-md-3 g-4">
    <% for (Object elemento : parecidas) {
         Map<?, ?> otra = (Map<?, ?>) elemento;
         String enlace = ctx + "/controlador/propiedad.jsp?accion=detalle&id_propiedad=" + otra.get("idPropiedad"); %>
    <div class="col">
      <article class="card tarjeta-propiedad h-100">
        <a href="<%= enlace %>"><img class="foto" src="<%= urlImagen(ctx, otra.get("foto")) %>" alt="Fotografía de <%= escapar(otra.get("titulo")) %>"></a>
        <div class="card-body p-4 d-flex flex-column">
          <h3 class="h6 titulo-pagina mb-2"><a class="text-decoration-none text-marca" href="<%= enlace %>"><%= escapar(otra.get("titulo")) %></a></h3>
          <p class="datos mb-3"><%= escapar(otra.get("tipo")) %> · <%= formatoArea((BigDecimal) otra.get("area")) %> m²</p>
          <span class="precio mt-auto"><%= formatoPesos((BigDecimal) otra.get("precio")) %></span>
        </div>
      </article>
    </div>
    <% } %>
  </div>
  <% } %>
</div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
