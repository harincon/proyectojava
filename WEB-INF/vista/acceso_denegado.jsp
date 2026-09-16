<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
    String tituloPagina = "Acceso denegado";
    String menuActivo = "";
    boolean vistaPanel = false;
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<div class="container py-5">
  <div class="row justify-content-center">
    <div class="col-md-8 col-lg-6">
      <div class="card border-0 shadow-sm text-center p-4">
        <i class="bi bi-shield-lock text-marca icono-estado-pagina" aria-hidden="true"></i>
        <h1 class="h3 titulo-pagina mt-3">Acceso denegado</h1>
        <% if (haySesion) { %>
        <p class="text-suave">Tu cuenta no tiene permiso para abrir esta sección.</p>
        <div><a class="btn btn-primary" href="<%= ctx %>/controlador/panel.jsp">Ir a mi panel</a></div>
        <% } else { %>
        <p class="text-suave">Inicia sesión con una cuenta autorizada para continuar.</p>
        <div class="d-flex justify-content-center gap-2">
          <a class="btn btn-primary" href="<%= ctx %>/controlador/acceso.jsp?accion=ingresar">Iniciar sesión</a>
          <a class="btn btn-outline-primary" href="<%= ctx %>/">Volver al inicio</a>
        </div>
        <% } %>
      </div>
    </div>
  </div>
</div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
