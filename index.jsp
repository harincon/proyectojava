<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%-- Entrada temporal de desarrollo; B4 la reemplaza al implementar el inicio. --%>
<%
    String tituloPagina = "Avance del proyecto";
    String menuActivo = "";
    boolean vistaPanel = false;
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<section class="portada py-5">
  <div class="container">
    <h1 class="display-6 fw-bold"><%= NOMBRE_APP %></h1>
    <p class="lead mb-0"><%= LEMA_APP %>. Página temporal para revisar lo construido hasta ahora.</p>
  </div>
</section>

<div class="container py-4">
  <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
    <div class="col">
      <div class="card h-100 border-0 shadow-sm">
        <div class="card-body d-flex flex-column">
          <span class="estado estado-FINALIZADA align-self-start mb-2">B2 · Acceso</span>
          <h2 class="h5 titulo-pagina">Cuentas y perfil</h2>
          <p class="text-suave flex-grow-1">Ingreso, registro, panel por roles, perfil con foto y administración de usuarios.</p>
          <div class="d-flex flex-wrap gap-2">
            <a class="btn btn-primary" href="<%= ctx %>/controlador/acceso.jsp?accion=ingresar">Iniciar sesión</a>
            <a class="btn btn-outline-primary" href="<%= ctx %>/controlador/acceso.jsp?accion=registro">Registrarse</a>
          </div>
        </div>
      </div>
    </div>
    <div class="col">
      <div class="card h-100 border-0 shadow-sm">
        <div class="card-body d-flex flex-column">
          <span class="estado estado-FINALIZADA align-self-start mb-2">B3 · Empresas</span>
          <h2 class="h5 titulo-pagina">Inmobiliarias y catálogos</h2>
          <p class="text-suave flex-grow-1">Empresas con su cuenta responsable, Mi empresa y catálogos de ciudades, tipos y características. Requiere iniciar sesión.</p>
          <div class="d-flex flex-wrap gap-2">
            <a class="btn btn-primary" href="<%= ctx %>/controlador/inmobiliaria.jsp">Inmobiliarias</a>
            <a class="btn btn-outline-primary" href="<%= ctx %>/controlador/ciudad.jsp?accion=listar">Catálogos</a>
          </div>
        </div>
      </div>
    </div>
    <div class="col">
      <div class="card h-100 border-0 shadow-sm">
        <div class="card-body d-flex flex-column">
          <span class="estado estado-FINALIZADA align-self-start mb-2">B1 · Diseño</span>
          <h2 class="h5 titulo-pagina">Muestra de componentes</h2>
          <p class="text-suave flex-grow-1">Colores, botones, estados, tarjetas, tablas, formularios y paginación de Habita.</p>
          <a class="btn btn-primary" href="<%= ctx %>/controlador/prueba_diseno.jsp">Ver diseño</a>
        </div>
      </div>
    </div>
    <div class="col">
      <div class="card h-100 border-0 shadow-sm">
        <div class="card-body d-flex flex-column">
          <span class="estado estado-FINALIZADA align-self-start mb-2">B1 · Errores</span>
          <h2 class="h5 titulo-pagina">Páginas de error</h2>
          <p class="text-suave flex-grow-1">Cómo se ven una dirección inexistente (404) y un acceso no permitido (403).</p>
          <div class="d-flex gap-2">
            <a class="btn btn-outline-primary" href="<%= ctx %>/controlador/no_existe.jsp">Ver 404</a>
            <a class="btn btn-outline-primary" href="<%= ctx %>/sql/01-esquema.sql">Ver 403</a>
          </div>
        </div>
      </div>
    </div>
    <div class="col">
      <div class="card h-100 border-0 shadow-sm">
        <div class="card-body d-flex flex-column">
          <span class="estado estado-FINALIZADA align-self-start mb-2">B0 · Base</span>
          <h2 class="h5 titulo-pagina">Pruebas técnicas</h2>
          <p class="text-suave flex-grow-1">Conexión a PostgreSQL, utilidades comunes y subida de archivos.</p>
          <div class="d-flex flex-wrap gap-2">
            <a class="btn btn-outline-primary" href="<%= ctx %>/controlador/prueba_conexion.jsp">Conexión</a>
            <a class="btn btn-outline-primary" href="<%= ctx %>/controlador/prueba_subida.jsp">Subida</a>
          </div>
        </div>
      </div>
    </div>
    <div class="col">
      <div class="card h-100 border-0 shadow-sm">
        <div class="card-body d-flex flex-column">
          <span class="estado estado-PENDIENTE align-self-start mb-2">Planificación</span>
          <h2 class="h5 titulo-pagina">Plano del proyecto</h2>
          <p class="text-suave flex-grow-1">Alcance, estructura, paletas, etapas e índice de documentos.</p>
          <a class="btn btn-marca" href="<%= ctx %>/varios/planificacion/PLANO.html">Ver plano</a>
        </div>
      </div>
    </div>
  </div>

  <p class="text-suave small mt-4 mb-0">
    <i class="bi bi-info-circle me-1"></i>Las páginas de prueba solo responden desde este equipo.
  </p>
</div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
