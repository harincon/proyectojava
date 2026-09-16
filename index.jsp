<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Inicio";
    String menuActivo = "inicio";
    boolean vistaPanel = false;

    String[][] propiedades = {
        {"Casa familiar en Cabecera", "Bucaramanga", "VENTA", "4", "3", "180", "680000000", "02-apartamento-chapinero.jpg"},
        {"Apartamento con vista al parque", "Bucaramanga", "VENTA", "3", "2", "92", "390000000", "04-penthouse.jpg"},
        {"Casa en conjunto de Cañaveral", "Floridablanca", "ARRIENDO", "3", "3", "145", "2800000", "03-casa-jardin.jpg"}
    };
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<section class="portada portada-inicio">
  <div class="container py-5">
    <p class="portada-etiqueta mb-3">Propiedades en Colombia</p>
    <h1 class="portada-titulo mb-4">Encuentra el lugar<br><span class="texto-acento">donde quieres vivir</span></h1>
    <p class="portada-descripcion mb-4">Casas, apartamentos, locales, oficinas y terrenos en venta y arriendo, publicados por inmobiliarias registradas.</p>

    <div class="buscador-rapido row g-3 align-items-end" aria-label="Búsqueda de propiedades">
      <div class="col-md-3">
        <label class="form-label" for="ciudadInicio">Ciudad</label>
        <select class="form-select" id="ciudadInicio">
          <option>Bucaramanga</option>
          <option>Floridablanca</option>
          <option>Bogotá</option>
          <option>Medellín</option>
        </select>
      </div>
      <div class="col-md-3">
        <label class="form-label" for="tipoInicio">Tipo de inmueble</label>
        <select class="form-select" id="tipoInicio">
          <option>Todos</option>
          <option>Casa</option>
          <option>Apartamento</option>
          <option>Local</option>
          <option>Oficina</option>
          <option>Terreno</option>
        </select>
      </div>
      <div class="col-md-3">
        <label class="form-label" for="operacionInicio">Modalidad</label>
        <select class="form-select" id="operacionInicio">
          <option>Venta y arriendo</option>
          <option>Venta</option>
          <option>Arriendo</option>
        </select>
      </div>
      <div class="col-md-3 d-grid">
        <a class="btn btn-primary py-2" href="#propiedades-destacadas"><i class="bi bi-search me-1"></i>Explorar propiedades</a>
      </div>
    </div>
  </div>
</section>

<section class="franja-estadisticas" aria-label="Información disponible">
  <div class="container">
    <div class="row row-cols-2 row-cols-lg-4">
      <div class="col estadistica"><strong>20</strong><span>Propiedades registradas</span></div>
      <div class="col estadistica"><strong>10</strong><span>Inmobiliarias</span></div>
      <div class="col estadistica"><strong>10</strong><span>Ciudades</span></div>
      <div class="col estadistica"><strong>5</strong><span>Tipos de inmueble</span></div>
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
      <% if (!haySesion) { %>
      <a class="btn btn-outline-primary" href="<%= ctx %>/controlador/acceso.jsp?accion=registro">Crear cuenta</a>
      <% } %>
    </div>

    <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
      <% for (String[] p : propiedades) { %>
      <div class="col">
        <article class="card tarjeta-propiedad">
          <img class="foto" src="<%= ctx %>/img/habita/<%= p[7] %>" alt="Fotografía de <%= escapar(p[0]) %>">
          <div class="card-body p-4">
            <div class="d-flex justify-content-between align-items-center gap-2 mb-3">
              <span class="badge etiqueta-propiedad"><%= p[2] %></span>
              <span class="estado estado-DISPONIBLE">DISPONIBLE</span>
            </div>
            <h3 class="h5 titulo-pagina mb-2"><%= escapar(p[0]) %></h3>
            <p class="datos mb-2"><i class="bi bi-geo-alt me-1"></i><%= escapar(p[1]) %></p>
            <p class="datos mb-4"><%= p[3] %> hab · <%= p[4] %> baños · <%= p[5] %> m²</p>
            <div class="d-flex justify-content-between align-items-center gap-2 mt-auto">
              <span class="precio"><%= formatoPesos(aImporte(p[6])) %><%= "ARRIENDO".equals(p[2]) ? " / mes" : "" %></span>
              <span class="text-suave small"><i class="bi bi-building me-1"></i>Inmobiliaria</span>
            </div>
          </div>
        </article>
      </div>
      <% } %>
    </div>
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
