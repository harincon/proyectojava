<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Mi panel";
    String menuActivo = "panel";
    boolean vistaPanel = true;
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<h1 class="h3 titulo-pagina mb-1"><%= "¡Hola, " + escapar(nombreSesion) + "!" %></h1>
<p class="text-suave mb-2">Estas son las opciones disponibles para tu cuenta.</p>
<div class="mb-4">
  <% for (String rol : rolesSesion) { %><span class="estado estado-CONFIRMADA me-1"><%= escapar(rol) %></span><% } %>
</div>

<div class="row row-cols-1 row-cols-md-2 row-cols-xl-3 g-4">
  <% if (rolesSesion.contains("ADMINISTRADOR")) { %>
  <div class="col">
    <div class="card h-100 border-0 shadow-sm">
      <div class="card-body d-flex flex-column">
        <h2 class="h5 titulo-pagina"><i class="bi bi-shield-check me-1"></i>Administración</h2>
        <p class="text-suave">Cuentas registradas: <strong><%= request.getAttribute("totalUsuarios") %></strong></p>
        <div class="d-flex flex-wrap gap-2 mt-auto">
          <a class="btn btn-primary" href="<%= ctx %>/controlador/usuario.jsp?accion=listar">Usuarios</a>
          <a class="btn btn-outline-primary" href="<%= ctx %>/controlador/rol.jsp?accion=listar">Roles</a>
          <a class="btn btn-outline-primary" href="<%= ctx %>/controlador/inmobiliaria.jsp?accion=listar">Inmobiliarias</a>
          <a class="btn btn-outline-primary" href="<%= ctx %>/controlador/ciudad.jsp?accion=listar">Catálogos</a>
        </div>
      </div>
    </div>
  </div>
  <% } %>

  <% if (rolesSesion.contains("INMOBILIARIA")) { %>
  <div class="col">
    <div class="card h-100 border-0 shadow-sm">
      <div class="card-body d-flex flex-column">
        <h2 class="h5 titulo-pagina"><i class="bi bi-building me-1"></i>Inmobiliaria</h2>
        <p class="text-suave">Publica propiedades y atiende citas y solicitudes de tus clientes.</p>
        <div class="d-flex flex-wrap gap-2 mt-auto">
          <a class="btn btn-primary" href="<%= ctx %>/controlador/inmobiliaria.jsp?accion=empresa">Mi empresa</a>
          <a class="btn btn-outline-primary" href="<%= ctx %>/controlador/propiedad.jsp?accion=gestionar">Mis propiedades</a>
          <a class="btn btn-outline-primary" href="<%= ctx %>/controlador/cita.jsp?accion=recibidas">Citas</a>
          <a class="btn btn-outline-primary" href="<%= ctx %>/controlador/solicitud.jsp?accion=recibidas">Solicitudes</a>
        </div>
      </div>
    </div>
  </div>
  <% } %>

  <% if (rolesSesion.contains("CLIENTE")) { %>
  <div class="col">
    <div class="card h-100 border-0 shadow-sm">
      <div class="card-body d-flex flex-column">
        <h2 class="h5 titulo-pagina"><i class="bi bi-house-heart me-1"></i>Cliente</h2>
        <p class="text-suave">Guarda favoritos, agenda visitas y sigue tus solicitudes.</p>
        <div class="d-flex flex-wrap gap-2 mt-auto">
          <a class="btn btn-primary" href="<%= ctx %>/controlador/propiedad.jsp?accion=catalogo">Buscar propiedades</a>
          <a class="btn btn-outline-primary" href="<%= ctx %>/controlador/favorito.jsp?accion=listar">Favoritos</a>
          <a class="btn btn-outline-primary" href="<%= ctx %>/controlador/cita.jsp?accion=mis_citas">Mis citas</a>
        </div>
      </div>
    </div>
  </div>
  <% } %>

  <div class="col">
    <div class="card h-100 border-0 shadow-sm">
      <div class="card-body d-flex flex-column">
        <h2 class="h5 titulo-pagina"><i class="bi bi-person me-1"></i>Mi cuenta</h2>
        <p class="text-suave">Actualiza tus datos personales y tu foto.</p>
        <div class="mt-auto">
          <a class="btn btn-outline-primary" href="<%= ctx %>/controlador/perfil.jsp?accion=ver">Mi perfil</a>
        </div>
      </div>
    </div>
  </div>
</div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
