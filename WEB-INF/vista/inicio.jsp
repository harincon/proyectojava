<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Inicio";
    String menuActivo = "inicio";
    boolean vistaPanel = false;
    List<?> vitrina = (List<?>) request.getAttribute("vitrina");
    List<?> ciudades = (List<?>) request.getAttribute("ciudades");
    List<?> tipos = (List<?>) request.getAttribute("tipos");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<section class="portada portada-inicio">
  <div class="container py-5">
    <p class="portada-etiqueta mb-3">Propiedades en Colombia</p>
    <h1 class="portada-titulo mb-4">Encuentra el lugar<br><span class="texto-acento">donde quieres vivir</span></h1>
    <p class="portada-descripcion mb-4">Casas, apartamentos, locales, oficinas y terrenos en venta y arriendo, publicados por inmobiliarias registradas.</p>

    <form class="buscador-rapido row g-3 align-items-end" method="get" action="<%= ctx %>/controlador/propiedad.jsp" aria-label="Búsqueda de propiedades">
      <input type="hidden" name="accion" value="catalogo">
      <div class="col-md-3">
        <label class="form-label" for="ciudadInicio">Ciudad</label>
        <select class="form-select" id="ciudadInicio" name="ciudad">
          <option value="">Todas</option>
          <% for (Object elemento : ciudades) { Map<?, ?> ciudad = (Map<?, ?>) elemento; %>
          <option value="<%= ciudad.get("id") %>"><%= escapar(ciudad.get("nombre")) %></option>
          <% } %>
        </select>
      </div>
      <div class="col-md-3">
        <label class="form-label" for="tipoInicio">Tipo de inmueble</label>
        <select class="form-select" id="tipoInicio" name="tipo">
          <option value="">Todos</option>
          <% for (Object elemento : tipos) { Map<?, ?> tipo = (Map<?, ?>) elemento; %>
          <option value="<%= tipo.get("id") %>"><%= escapar(tipo.get("nombre")) %></option>
          <% } %>
        </select>
      </div>
      <div class="col-md-3">
        <label class="form-label" for="operacionInicio">Modalidad</label>
        <select class="form-select" id="operacionInicio" name="operacion">
          <option value="">Venta y arriendo</option>
          <option value="VENTA">Venta</option>
          <option value="ARRIENDO">Arriendo</option>
        </select>
      </div>
      <div class="col-md-3 d-grid">
        <button type="submit" class="btn btn-primary py-2"><i class="bi bi-search me-1"></i>Explorar propiedades</button>
      </div>
    </form>
  </div>
</section>

<section class="franja-estadisticas" aria-label="Información disponible">
  <div class="container">
    <div class="row row-cols-2 row-cols-lg-4">
      <div class="col estadistica"><strong><%= request.getAttribute("totalPropiedades") %></strong><span>Propiedades disponibles</span></div>
      <div class="col estadistica"><strong><%= request.getAttribute("totalInmobiliarias") %></strong><span>Inmobiliarias</span></div>
      <div class="col estadistica"><strong><%= ciudades.size() %></strong><span>Ciudades</span></div>
      <div class="col estadistica"><strong><%= tipos.size() %></strong><span>Tipos de inmueble</span></div>
    </div>
  </div>
</section>

<section class="seccion-habita" id="propiedades-destacadas">
  <div class="container">
    <div class="d-flex flex-wrap justify-content-between align-items-end gap-3 mb-4">
      <div class="seccion-encabezado">
        <p class="seccion-etiqueta mb-2">Selección Habita</p>
        <h2 class="titulo-pagina display-6 mb-2">Propiedades destacadas</h2>
        <p class="text-suave mb-0">Opciones de venta y arriendo en ciudades colombianas.</p>
      </div>
      <a class="btn btn-outline-primary" href="<%= ctx %>/controlador/propiedad.jsp?accion=catalogo">Ver todo el catálogo</a>
    </div>

    <% if (vitrina.isEmpty()) { %>
    <div class="vacio"><i class="bi bi-house" aria-hidden="true"></i>Todavía no hay propiedades publicadas.</div>
    <% } else { %>
    <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
      <% for (Object elemento : vitrina) {
           Map<?, ?> propiedad = (Map<?, ?>) elemento; %>
      <div class="col">
        <article class="card tarjeta-propiedad h-100">
          <a href="<%= ctx %>/controlador/propiedad.jsp?accion=detalle&id_propiedad=<%= propiedad.get("idPropiedad") %>">
            <img class="foto" src="<%= urlImagen(ctx, propiedad.get("foto")) %>" alt="Fotografía de <%= escapar(propiedad.get("titulo")) %>">
          </a>
          <div class="card-body p-4 d-flex flex-column">
            <div class="d-flex justify-content-between align-items-center gap-2 mb-3">
              <span class="badge etiqueta-propiedad"><%= escapar(propiedad.get("operacion")) %></span>
              <span class="estado estado-<%= escapar(propiedad.get("estado")) %>"><%= escapar(propiedad.get("estado")) %></span>
            </div>
            <h3 class="h5 titulo-pagina mb-2">
              <a class="text-decoration-none text-marca" href="<%= ctx %>/controlador/propiedad.jsp?accion=detalle&id_propiedad=<%= propiedad.get("idPropiedad") %>"><%= escapar(propiedad.get("titulo")) %></a>
            </h3>
            <p class="datos mb-2"><i class="bi bi-geo-alt me-1"></i><%= escapar(propiedad.get("ciudad")) %> · <%= escapar(propiedad.get("tipo")) %></p>
            <p class="datos mb-4"><%= propiedad.get("habitaciones") %> hab · <%= propiedad.get("banos") %> baños · <%= formatoArea((java.math.BigDecimal) propiedad.get("area")) %> m²</p>
            <div class="mt-auto">
              <span class="precio d-block"><%= formatoPesos((java.math.BigDecimal) propiedad.get("precio")) + ("ARRIENDO".equals(propiedad.get("operacion")) ? " / mes" : "") %></span>
              <span class="text-suave small d-block text-truncate"><i class="bi bi-building me-1"></i><%= escapar(propiedad.get("inmobiliaria")) %></span>
            </div>
          </div>
        </article>
      </div>
      <% } %>
    </div>
    <% } %>
  </div>
</section>

<section class="seccion-habita seccion-habita-clara pt-0">
  <div class="container">
    <div class="llamado-publicar p-4 p-md-5">
      <div class="row align-items-center g-4">
        <div class="col-lg-8">
          <p class="portada-etiqueta mb-2">Para inmobiliarias</p>
          <h2 class="display-6 fw-semibold mb-3">Publica y administra tus propiedades</h2>
          <p class="mb-0 text-white-50">Centraliza publicaciones, citas y solicitudes desde un mismo panel.</p>
        </div>
        <div class="col-lg-4 text-lg-end">
          <% if (haySesion) { %>
          <a class="btn btn-primary btn-lg" href="<%= ctx %>/controlador/panel.jsp">Ir a mi panel</a>
          <% } else { %>
          <a class="btn btn-primary btn-lg" href="<%= ctx %>/controlador/acceso.jsp?accion=ingresar">Iniciar sesión</a>
          <% } %>
        </div>
      </div>
    </div>
  </div>
</section>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
