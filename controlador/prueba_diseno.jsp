<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%-- Catálogo de componentes de B1 (desarrollo). Solo responde en el propio equipo. --%>
<%
    String origen = request.getRemoteAddr();
    if (!"127.0.0.1".equals(origen) && !"0:0:0:0:0:0:0:1".equals(origen)) {
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
        return;
    }
    String tituloPagina = "Componentes";
    String menuActivo = "";
    boolean vistaPanel = false;

    String[][] propiedades = {
        {"Apartamento en Cabecera", "Bucaramanga", "VENTA", "3", "2", "85", "320000000", "DISPONIBLE", "02-apartamento-chapinero.jpg"},
        {"Casa en conjunto cerrado", "Floridablanca", "ARRIENDO", "3", "2", "110", "1800000", "DISPONIBLE", "03-casa-jardin.jpg"},
        {"Local comercial en el centro", "Girón", "VENTA", "0", "1", "60", "210000000", "VENDIDA", "06-local-comercial.jpg"}
    };
    String[] estados = {"DISPONIBLE", "VENDIDA", "ARRENDADA", "PENDIENTE", "CONFIRMADA", "REALIZADA",
                        "CANCELADA", "RECHAZADA", "APROBADA", "FINALIZADA", "APROBADO", "RECHAZADO", "ACTIVA", "INACTIVA"};
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<section class="portada py-5">
  <div class="container">
    <h1 class="display-6 fw-bold"><%= LEMA_APP %></h1>
    <p class="lead mb-4">Portada del inicio con búsqueda rápida.</p>
    <form class="buscador-rapido row g-2 align-items-end" method="get" action="<%= ctx %>/controlador/propiedad.jsp">
      <input type="hidden" name="accion" value="catalogo">
      <div class="col-md-4">
        <label class="form-label text-body" for="ciudadDemo">Ciudad</label>
        <select class="form-select" id="ciudadDemo" name="id_ciudad"><option>Bucaramanga</option></select>
      </div>
      <div class="col-md-4">
        <label class="form-label text-body" for="tipoDemo">Tipo de inmueble</label>
        <select class="form-select" id="tipoDemo" name="id_tipo_propiedad"><option>Apartamento</option></select>
      </div>
      <div class="col-md-4 d-grid">
        <button type="button" class="btn btn-primary"><i class="bi bi-search"></i> Buscar propiedades</button>
      </div>
    </form>
  </div>
</section>

<div class="container py-4">
  <p class="text-suave"><i class="bi bi-info-circle"></i> Página de muestra con datos de ejemplo. No consulta la base de datos.</p>

  <h2 class="h4 titulo-pagina mt-4">Avisos</h2>
  <div class="alert alert-success"><i class="bi bi-check-circle"></i> Propiedad publicada correctamente.</div>
  <div class="alert alert-danger"><i class="bi bi-exclamation-triangle"></i> La matrícula inmobiliaria ya se encuentra registrada.</div>

  <h2 class="h4 titulo-pagina mt-4">Botones</h2>
  <div class="d-flex flex-wrap gap-2">
    <button type="button" class="btn btn-primary">Acción principal</button>
    <button type="button" class="btn btn-marca">Marca</button>
    <button type="button" class="btn btn-outline-primary">Secundario</button>
    <button type="button" class="btn btn-outline-secondary">Cancelar</button>
    <button type="button" class="btn btn-outline-danger">Desactivar</button>
  </div>

  <h2 class="h4 titulo-pagina mt-4">Estados</h2>
  <div class="d-flex flex-wrap gap-2">
    <% for (String estado : estados) { %>
    <span class="estado estado-<%= estado %>"><%= estado %></span>
    <% } %>
  </div>

  <h2 class="h4 titulo-pagina mt-4">Tarjetas del catálogo</h2>
  <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
    <% for (String[] p : propiedades) { %>
    <div class="col">
      <article class="card tarjeta-propiedad">
        <img class="foto" src="<%= ctx %>/img/habita/<%= p[8] %>" alt="Fotografía de <%= escapar(p[0]) %>">
        <div class="card-body">
          <div class="d-flex justify-content-between align-items-center mb-2">
            <span class="badge bg-marca"><%= p[2] %></span>
            <span class="estado estado-<%= p[7] %>"><%= p[7] %></span>
          </div>
          <h3 class="h6 fw-bold mb-1"><%= escapar(p[0]) %></h3>
          <p class="datos mb-2"><i class="bi bi-geo-alt"></i> <%= escapar(p[1]) %></p>
          <p class="datos mb-3"><%= p[3] %> hab · <%= p[4] %> baños · <%= p[5] %> m²</p>
          <div class="d-flex justify-content-between align-items-center gap-2 mt-auto">
            <span class="precio"><%= formatoPesos(aImporte(p[6])) %><%= "ARRIENDO".equals(p[2]) ? " / mes" : "" %></span>
            <a class="btn btn-outline-primary btn-sm" href="#">Ver detalle</a>
          </div>
        </div>
      </article>
    </div>
    <% } %>
  </div>

  <h2 class="h4 titulo-pagina mt-5">Tabla de administración</h2>
  <div class="card border-0 shadow-sm">
    <div class="table-responsive">
      <table class="table tabla-habita mb-0">
        <thead><tr><th>Inmueble</th><th>Precio</th><th>Publicación</th><th>Disponibilidad</th><th class="text-end">Acciones</th></tr></thead>
        <tbody>
          <tr>
            <td>Apartamento en Cabecera</td><td><%= formatoPesos(aImporte("320000000")) %></td>
            <td><span class="estado estado-ACTIVA">ACTIVA</span></td><td><span class="estado estado-DISPONIBLE">DISPONIBLE</span></td>
            <td class="acciones"><a class="btn btn-outline-primary btn-sm" href="#">Editar</a> <button type="button" class="btn btn-outline-danger btn-sm">Desactivar</button></td>
          </tr>
          <tr>
            <td>Local comercial en el centro</td><td><%= formatoPesos(aImporte("210000000")) %></td>
            <td><span class="estado estado-INACTIVA">INACTIVA</span></td><td><span class="estado estado-VENDIDA">VENDIDA</span></td>
            <td class="acciones"><a class="btn btn-outline-primary btn-sm" href="#">Editar</a> <button type="button" class="btn btn-outline-primary btn-sm">Reactivar</button></td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>

  <h2 class="h4 titulo-pagina mt-5">Formulario con error en un campo</h2>
  <form class="card border-0 shadow-sm p-4" method="post" action="#" novalidate>
    <%= campoToken(session) %>
    <div class="row g-3">
      <div class="col-md-6">
        <label class="form-label" for="matriculaDemo">Matrícula inmobiliaria *</label>
        <input class="form-control is-invalid" id="matriculaDemo" name="matricula_inmobiliaria" value="300-12345" required aria-describedby="errorMatriculaDemo">
        <div class="invalid-feedback" id="errorMatriculaDemo">La matrícula ya se encuentra registrada.</div>
      </div>
      <div class="col-md-6">
        <label class="form-label" for="precioDemo">Precio (COP) *</label>
        <input class="form-control" id="precioDemo" name="precio" type="number" min="1" step="1" value="320000000" required>
      </div>
    </div>
    <div class="d-flex justify-content-end gap-2 mt-4">
      <a class="btn btn-outline-secondary" href="#">Cancelar</a>
      <button type="button" class="btn btn-primary">Guardar propiedad</button>
    </div>
  </form>

  <h2 class="h4 titulo-pagina mt-5">Lista vacía</h2>
  <div class="vacio"><i class="bi bi-house" aria-hidden="true"></i> No hay propiedades que coincidan con los filtros.</div>

  <h2 class="h4 titulo-pagina mt-5">Paginación</h2>
  <nav aria-label="Páginas de resultados">
    <ul class="pagination">
      <li class="page-item disabled"><span class="page-link">Anterior</span></li>
      <li class="page-item active" aria-current="page"><span class="page-link">1</span></li>
      <li class="page-item"><a class="page-link" href="#">2</a></li>
      <li class="page-item"><a class="page-link" href="#">Siguiente</a></li>
    </ul>
  </nav>
</div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
