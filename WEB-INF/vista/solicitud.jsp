<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.math.BigDecimal,java.time.LocalDateTime,java.util.List,java.util.Map" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Detalle de solicitud";
    boolean clienteSolicitud = Boolean.TRUE.equals(request.getAttribute("vistaCliente"));
    String menuActivo = clienteSolicitud ? "solicitudes" : "solicitudes_recibidas";
    boolean vistaPanel = true;
    Map<?, ?> solicitud = (Map<?, ?>) request.getAttribute("solicitud");
    List<?> documentos = (List<?>) request.getAttribute("documentos");
    boolean puedeSubir = Boolean.TRUE.equals(request.getAttribute("puedeSubir"));
    boolean puedeRevisar = Boolean.TRUE.equals(request.getAttribute("puedeRevisar"));
    String estadoSolicitud = (String) solicitud.get("estado");
    Object idSolicitudVista = solicitud.get("idSolicitud");
    String cliente = String.valueOf(solicitud.get("cliente"));
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-4">
  <div>
    <p class="text-suave mb-1">Solicitud #<%= idSolicitudVista %> · <%= formatoFecha((LocalDateTime) solicitud.get("fecha")) %></p>
    <h1 class="h3 titulo-pagina mb-1"><%= escapar(solicitud.get("titulo")) %></h1>
    <p class="mb-0"><span class="estado estado-<%= escapar(estadoSolicitud) %>"><%= escapar(estadoSolicitud) %></span></p>
  </div>
  <a class="btn btn-outline-secondary" href="<%= ctx %>/controlador/solicitud.jsp?accion=<%= clienteSolicitud ? "mis_solicitudes" : "recibidas" %>">Volver al listado</a>
</div>

<div class="row g-4 mb-4">
  <div class="col-lg-7">
    <div class="card border-0 shadow-sm h-100">
      <div class="card-body p-4">
        <h2 class="h5 titulo-pagina mb-3">Información del trámite</h2>
        <dl class="row mb-0">
          <dt class="col-sm-4">Propiedad</dt><dd class="col-sm-8"><a href="<%= ctx %>/controlador/propiedad.jsp?accion=detalle&id_propiedad=<%= solicitud.get("idPropiedad") %>"><%= escapar(solicitud.get("titulo")) %></a></dd>
          <dt class="col-sm-4">Matrícula</dt><dd class="col-sm-8"><%= escapar(solicitud.get("matricula")) %></dd>
          <dt class="col-sm-4">Operación</dt><dd class="col-sm-8"><%= escapar(solicitud.get("operacion")) %> · <%= formatoPesos((BigDecimal) solicitud.get("precio")) %></dd>
          <dt class="col-sm-4">Inmobiliaria</dt><dd class="col-sm-8"><%= escapar(solicitud.get("inmobiliaria")) %></dd>
          <dt class="col-sm-4">Cliente</dt><dd class="col-sm-8"><%= escapar(cliente.isEmpty() ? solicitud.get("correoCliente") : cliente) %><div class="small text-suave"><%= escapar(solicitud.get("correoCliente")) %></div></dd>
          <dt class="col-sm-4">Observación</dt><dd class="col-sm-8"><%= solicitud.get("observacion") == null ? "Sin observación" : escapar(solicitud.get("observacion")) %></dd>
        </dl>
      </div>
    </div>
  </div>

  <div class="col-lg-5">
    <div class="card border-0 shadow-sm h-100">
      <div class="card-body p-4">
        <h2 class="h5 titulo-pagina mb-3">Estado del inmueble</h2>
        <p class="mb-2"><span class="estado estado-<%= escapar(solicitud.get("estadoPropiedad")) %>"><%= escapar(solicitud.get("estadoPropiedad")) %></span></p>
        <p class="text-suave"><%= escapar(solicitud.get("ciudad")) %> · <%= escapar(solicitud.get("tipo")) %><br><%= escapar(solicitud.get("direccion")) %></p>

        <% if (puedeRevisar && "PENDIENTE".equals(estadoSolicitud)) { %>
        <form method="post" action="<%= ctx %>/controlador/solicitud.jsp?accion=revisar&id_solicitud=<%= idSolicitudVista %>" class="mt-4">
          <%= campoToken(session) %>
          <label class="form-label" for="observacionSolicitud">Observación de revisión *</label>
          <textarea class="form-control mb-3" id="observacionSolicitud" name="observacion" rows="3" maxlength="1000" required></textarea>
          <div class="d-flex flex-wrap gap-2">
            <button class="btn btn-primary" type="submit" name="estado" value="APROBADA">Aprobar solicitud</button>
            <button class="btn btn-outline-danger" type="submit" name="estado" value="RECHAZADA">Rechazar</button>
          </div>
        </form>
        <% } else if (puedeRevisar && "APROBADA".equals(estadoSolicitud)) { %>
        <form method="post" action="<%= ctx %>/controlador/solicitud.jsp?accion=finalizar&id_solicitud=<%= idSolicitudVista %>" class="mb-3">
          <%= campoToken(session) %>
          <button class="btn btn-primary w-100" type="submit"><i class="bi bi-check2-circle me-1"></i>Finalizar operación</button>
        </form>
        <form method="post" action="<%= ctx %>/controlador/solicitud.jsp?accion=revisar&id_solicitud=<%= idSolicitudVista %>">
          <%= campoToken(session) %>
          <label class="form-label" for="rechazoSolicitud">Motivo del rechazo *</label>
          <textarea class="form-control mb-2" id="rechazoSolicitud" name="observacion" rows="2" maxlength="1000" required></textarea>
          <button class="btn btn-outline-danger w-100" type="submit" name="estado" value="RECHAZADA">Rechazar solicitud</button>
        </form>
        <% } %>
      </div>
    </div>
  </div>
</div>

<div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
  <div><h2 class="h4 titulo-pagina mb-1">Documentos</h2><p class="text-suave mb-0">Archivos privados asociados al trámite.</p></div>
</div>

<% if (puedeSubir) { %>
<div class="card border-0 shadow-sm mb-4">
  <div class="card-body p-4">
    <h3 class="h5 titulo-pagina mb-3">Agregar documento</h3>
    <form method="post" enctype="multipart/form-data" action="<%= ctx %>/controlador/documento_solicitud.jsp?accion=subir&id_solicitud=<%= idSolicitudVista %>" class="row g-3 align-items-end">
      <%= campoToken(session) %>
      <div class="col-md-5"><label class="form-label" for="nombreDocumento">Nombre *</label><input class="form-control" id="nombreDocumento" name="nombre" maxlength="100" placeholder="Ej. Cédula" required></div>
      <div class="col-md-5"><label class="form-label" for="archivoDocumento">PDF *</label><input class="form-control" id="archivoDocumento" type="file" name="archivo" accept="application/pdf,.pdf" required><div class="form-text">Máximo 5 MB.</div></div>
      <div class="col-md-2 d-grid"><button class="btn btn-primary" type="submit">Subir PDF</button></div>
    </form>
  </div>
</div>
<% } %>

<% if (documentos.isEmpty()) { %>
<div class="vacio"><i class="bi bi-file-earmark-pdf" aria-hidden="true"></i>No hay documentos cargados.</div>
<% } else { %>
<div class="card border-0 shadow-sm">
  <div class="table-responsive">
    <table class="table tabla-habita mb-0">
      <thead><tr><th>Documento</th><th>Estado</th><th>Observación</th><th class="text-end">Acciones</th></tr></thead>
      <tbody>
        <% for (Object elemento : documentos) {
             Map<?, ?> documento = (Map<?, ?>) elemento;
             String estadoDocumento = (String) documento.get("estado"); %>
        <tr>
          <td class="fw-semibold"><i class="bi bi-file-earmark-pdf me-1"></i><%= escapar(documento.get("nombre")) %></td>
          <td><span class="estado estado-<%= escapar(estadoDocumento) %>"><%= escapar(estadoDocumento) %></span></td>
          <td><%= documento.get("observacion") == null ? "—" : escapar(documento.get("observacion")) %></td>
          <td class="acciones">
            <a class="btn btn-outline-secondary btn-sm" href="<%= ctx %>/controlador/documento_solicitud.jsp?accion=descargar&id_documento=<%= documento.get("idDocumento") %>">Descargar</a>
            <% if (puedeRevisar && "PENDIENTE".equals(estadoDocumento)
                    && ("PENDIENTE".equals(estadoSolicitud) || "APROBADA".equals(estadoSolicitud))) { %>
            <form class="d-inline-flex gap-1 mt-1" method="post" action="<%= ctx %>/controlador/documento_solicitud.jsp?accion=revisar&id_documento=<%= documento.get("idDocumento") %>">
              <%= campoToken(session) %>
              <label class="visually-hidden" for="obsDocumento<%= documento.get("idDocumento") %>">Observación</label>
              <input class="form-control form-control-sm" id="obsDocumento<%= documento.get("idDocumento") %>" name="observacion" maxlength="1000" placeholder="Observación" required>
              <button class="btn btn-primary btn-sm" type="submit" name="estado" value="APROBADO">Aprobar</button>
              <button class="btn btn-outline-danger btn-sm" type="submit" name="estado" value="RECHAZADO">Rechazar</button>
            </form>
            <% } %>
          </td>
        </tr>
        <% } %>
      </tbody>
    </table>
  </div>
</div>
<% } %>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
