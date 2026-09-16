<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    Object codigoError = request.getAttribute("javax.servlet.error.status_code");
    boolean noEncontrada = codigoError != null && "404".equals(codigoError.toString());
    String tituloPagina = noEncontrada ? "Página no encontrada" : "Ocurrió un error";
    String menuActivo = "";
    boolean vistaPanel = false;
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<div class="container py-5">
  <div class="row justify-content-center">
    <div class="col-md-8 col-lg-6">
      <div class="card border-0 shadow-sm text-center p-4">
        <i class="bi <%= noEncontrada ? "bi-signpost-split" : "bi-exclamation-octagon" %> text-marca icono-estado-pagina" aria-hidden="true"></i>
        <h1 class="h3 titulo-pagina mt-3"><%= tituloPagina %></h1>
        <p class="text-suave">
          <%= noEncontrada
                  ? "La dirección no existe o fue movida."
                  : "No fue posible completar la solicitud. Intenta de nuevo en unos minutos." %>
        </p>
        <div><a class="btn btn-primary" href="<%= ctx %>/">Volver al inicio</a></div>
      </div>
    </div>
  </div>
</div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
