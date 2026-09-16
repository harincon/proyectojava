<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.math.BigDecimal,java.util.Map" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Nueva solicitud";
    String menuActivo = "solicitudes";
    boolean vistaPanel = true;
    Map<?, ?> propiedad = (Map<?, ?>) request.getAttribute("propiedad");
    Object idPropiedadFormulario = propiedad.get("idPropiedad");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-4">
  <div>
    <h1 class="h3 titulo-pagina mb-1">Radicar solicitud</h1>
    <p class="text-suave mb-0">Inicia el trámite con la inmobiliaria responsable.</p>
  </div>
  <a class="btn btn-outline-secondary" href="<%= ctx %>/controlador/propiedad.jsp?accion=detalle&id_propiedad=<%= idPropiedadFormulario %>">Volver a la propiedad</a>
</div>

<div class="row g-4">
  <div class="col-lg-5">
    <article class="card tarjeta-propiedad h-100">
      <img class="foto" src="<%= urlImagen(ctx, propiedad.get("foto")) %>" alt="Fotografía de <%= escapar(propiedad.get("titulo")) %>">
      <div class="card-body p-4">
        <div class="d-flex justify-content-between align-items-center gap-2 mb-3">
          <span class="badge etiqueta-propiedad"><%= escapar(propiedad.get("operacion")) %></span>
          <span class="estado estado-DISPONIBLE">DISPONIBLE</span>
        </div>
        <h2 class="h5 titulo-pagina"><%= escapar(propiedad.get("titulo")) %></h2>
        <p class="datos mb-2"><i class="bi bi-geo-alt me-1"></i><%= escapar(propiedad.get("ciudad")) %> · <%= escapar(propiedad.get("tipo")) %></p>
        <p class="datos mb-3"><%= escapar(propiedad.get("direccion")) %></p>
        <span class="precio"><%= formatoPesos((BigDecimal) propiedad.get("precio")) + ("ARRIENDO".equals(propiedad.get("operacion")) ? " / mes" : "") %></span>
      </div>
    </article>
  </div>

  <div class="col-lg-7">
    <div class="card border-0 shadow-sm h-100">
      <div class="card-body p-4 p-lg-5">
        <h2 class="h5 titulo-pagina mb-4">Datos de la solicitud</h2>
        <form method="post" action="<%= ctx %>/controlador/solicitud.jsp?accion=crear&id_propiedad=<%= idPropiedadFormulario %>">
          <%= campoToken(session) %>
          <div class="mb-4">
            <label class="form-label" for="observacion">Descripción de tu interés</label>
            <textarea class="form-control<%= invalido(request, "observacion") %>" id="observacion" name="observacion" rows="6" maxlength="1000"
                      placeholder="Cuéntale a la inmobiliaria cómo deseas continuar con el trámite"><%= valorFormulario(request, "observacion") %></textarea>
            <div class="invalid-feedback"><%= errorFormulario(request, "observacion") %></div>
            <div class="form-text">Opcional, máximo 1000 caracteres.</div>
          </div>
          <div class="d-flex flex-wrap gap-2">
            <button type="submit" class="btn btn-primary"><i class="bi bi-folder-check me-1"></i>Radicar solicitud</button>
            <a class="btn btn-outline-secondary" href="<%= ctx %>/controlador/solicitud.jsp?accion=mis_solicitudes">Ver mis solicitudes</a>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
