<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.math.BigDecimal,java.util.List,java.util.Map" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Favoritos";
    String menuActivo = "favoritos";
    boolean vistaPanel = true;
    List<?> favoritos = (List<?>) request.getAttribute("favoritos");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-4">
  <div>
    <h1 class="h3 titulo-pagina mb-1">Mis favoritos</h1>
    <p class="text-suave mb-0">Propiedades que guardaste para consultarlas después.</p>
  </div>
  <a class="btn btn-primary" href="<%= ctx %>/controlador/propiedad.jsp?accion=catalogo"><i class="bi bi-search me-1"></i>Explorar catálogo</a>
</div>

<% if (favoritos.isEmpty()) { %>
<div class="vacio"><i class="bi bi-heart" aria-hidden="true"></i>Todavía no tienes propiedades favoritas.</div>
<% } else { %>
<div class="row row-cols-1 row-cols-md-2 row-cols-xl-3 g-4">
  <% for (Object elemento : favoritos) {
       Map<?, ?> propiedad = (Map<?, ?>) elemento;
       Object id = propiedad.get("idPropiedad");
       String enlace = ctx + "/controlador/propiedad.jsp?accion=detalle&id_propiedad=" + id;
       boolean activa = Boolean.TRUE.equals(propiedad.get("activa")); %>
  <div class="col">
    <article class="card tarjeta-propiedad h-100">
      <a href="<%= enlace %>"><img class="foto" src="<%= urlImagen(ctx, propiedad.get("foto")) %>" alt="Fotografía de <%= escapar(propiedad.get("titulo")) %>"></a>
      <div class="card-body p-4 d-flex flex-column">
        <div class="d-flex justify-content-between align-items-center gap-2 mb-3">
          <span class="badge etiqueta-propiedad"><%= escapar(propiedad.get("operacion")) %></span>
          <span class="estado estado-<%= activa ? escapar(propiedad.get("estado")) : "INACTIVA" %>"><%= activa ? escapar(propiedad.get("estado")) : "RETIRADA" %></span>
        </div>
        <h2 class="h5 titulo-pagina mb-2"><a class="text-decoration-none text-marca" href="<%= enlace %>"><%= escapar(propiedad.get("titulo")) %></a></h2>
        <p class="datos mb-2"><i class="bi bi-geo-alt me-1"></i><%= escapar(propiedad.get("ciudad")) %> · <%= escapar(propiedad.get("tipo")) %></p>
        <p class="datos mb-4"><%= propiedad.get("habitaciones") %> hab · <%= propiedad.get("banos") %> baños · <%= formatoArea((BigDecimal) propiedad.get("area")) %> m²</p>
        <div class="mt-auto">
          <span class="precio d-block"><%= formatoPesos((BigDecimal) propiedad.get("precio")) + ("ARRIENDO".equals(propiedad.get("operacion")) ? " / mes" : "") %></span>
          <span class="text-suave small d-block text-truncate mb-3"><i class="bi bi-building me-1"></i><%= escapar(propiedad.get("inmobiliaria")) %></span>
          <form method="post" action="<%= ctx %>/controlador/favorito.jsp?accion=quitar&id_propiedad=<%= id %>">
            <%= campoToken(session) %>
            <button type="submit" class="btn btn-outline-danger btn-sm w-100"><i class="bi bi-heartbreak me-1"></i>Quitar de favoritos</button>
          </form>
        </div>
      </div>
    </article>
  </div>
  <% } %>
</div>
<% } %>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
