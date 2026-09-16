<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.math.BigDecimal,java.time.LocalDate,java.util.Map" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Agendar cita";
    String menuActivo = "citas";
    boolean vistaPanel = true;
    Map<?, ?> propiedad = (Map<?, ?>) request.getAttribute("propiedad");
    Object idPropiedadFormulario = propiedad.get("idPropiedad");
    String errorFechaHora = errorFormulario(request, "fecha_hora");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-4">
  <div>
    <h1 class="h3 titulo-pagina mb-1">Agendar visita</h1>
    <p class="text-suave mb-0">La inmobiliaria revisará la fecha y confirmará la cita.</p>
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
        <h2 class="h5 titulo-pagina mb-4">Fecha de la visita</h2>
        <form method="post" action="<%= ctx %>/controlador/cita.jsp?accion=crear&id_propiedad=<%= idPropiedadFormulario %>">
          <%= campoToken(session) %>
          <div class="row g-3">
            <div class="col-md-7">
              <label class="form-label" for="fecha">Fecha *</label>
              <input type="date" class="form-control<%= invalido(request, "fecha_hora") %>" id="fecha" name="fecha"
                     min="<%= LocalDate.now(java.time.ZoneId.of("America/Bogota")) %>" value="<%= valorFormulario(request, "fecha") %>" required>
            </div>
            <div class="col-md-5">
              <label class="form-label" for="hora">Hora *</label>
              <input type="time" class="form-control<%= invalido(request, "fecha_hora") %>" id="hora" name="hora"
                     value="<%= valorFormulario(request, "hora") %>" required>
            </div>
          </div>
          <% if (!errorFechaHora.isEmpty()) { %><div class="text-danger small mt-2"><%= errorFechaHora %></div><% } %>
          <p class="small text-suave mt-3 mb-4"><i class="bi bi-info-circle me-1"></i>El horario queda pendiente hasta que la inmobiliaria lo confirme.</p>
          <div class="d-flex flex-wrap gap-2">
            <button type="submit" class="btn btn-primary"><i class="bi bi-calendar-check me-1"></i>Solicitar cita</button>
            <a class="btn btn-outline-secondary" href="<%= ctx %>/controlador/cita.jsp?accion=mis_citas">Ver mis citas</a>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
