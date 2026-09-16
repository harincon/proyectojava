<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.math.BigDecimal,java.time.LocalDateTime,java.util.List,java.util.Map" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String modoReporte = (String) request.getAttribute("modo");
    boolean reporteEmpresa = "empresa".equals(modoReporte);
    String tituloPagina = reporteEmpresa ? "Reportes de mi empresa" : "Reportes generales";
    String menuActivo = reporteEmpresa ? "reportes_empresa" : "reportes";
    boolean vistaPanel = true;
    String nombreEmpresa = (String) request.getAttribute("nombreEmpresa");
    List<?> propiedades = (List<?>) request.getAttribute("propiedades");
    List<?> citas = (List<?>) request.getAttribute("citas");
    List<?> solicitudes = (List<?>) request.getAttribute("solicitudes");
    List<?> finalizadas = (List<?>) request.getAttribute("finalizadas");
    int totalSolicitudes = 0;
    for (Object elemento : solicitudes) {
        totalSolicitudes += (Integer) ((Map<?, ?>) elemento).get("total");
    }

    // Totales para los resúmenes: propiedades por ciudad y estado, y citas por estado.
    List<String> estadosPropiedad = java.util.Arrays.asList("DISPONIBLE", "VENDIDA", "ARRENDADA");
    Map<String, int[]> propiedadesPorCiudad = new java.util.LinkedHashMap<String, int[]>();
    int[] totalesPorEstado = new int[estadosPropiedad.size()];
    for (Object elemento : propiedades) {
        Map<?, ?> fila = (Map<?, ?>) elemento;
        String ciudadFila = String.valueOf(fila.get("ciudad"));
        int[] conteo = propiedadesPorCiudad.get(ciudadFila);
        if (conteo == null) {
            conteo = new int[estadosPropiedad.size()];
            propiedadesPorCiudad.put(ciudadFila, conteo);
        }
        int indice = estadosPropiedad.indexOf(String.valueOf(fila.get("estado")));
        if (indice >= 0) {
            conteo[indice]++;
            totalesPorEstado[indice]++;
        }
    }
    Map<String, Integer> citasPorEstado = new java.util.LinkedHashMap<String, Integer>();
    for (Object elemento : citas) {
        String estadoCita = String.valueOf(((Map<?, ?>) elemento).get("estado"));
        Integer actual = citasPorEstado.get(estadoCita);
        citasPorEstado.put(estadoCita, actual == null ? 1 : actual + 1);
    }
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<div class="mb-4">
  <h1 class="h3 titulo-pagina mb-1"><%= escapar(tituloPagina) %></h1>
  <p class="text-suave mb-0"><%= reporteEmpresa
          ? "Resultados de " + escapar(nombreEmpresa) + "."
          : "Resumen consolidado de la operación de Habita." %></p>
</div>

<section class="card border-0 shadow-sm mb-4">
  <div class="card-header bg-white d-flex justify-content-between align-items-center">
    <h2 class="h5 mb-0">Propiedades por ciudad y estado</h2>
    <span class="badge bg-marca"><%= propiedades.size() %> propiedades</span>
  </div>
  <% if (propiedades.isEmpty()) { %>
  <div class="vacio m-3"><i class="bi bi-house"></i>No hay propiedades para mostrar.</div>
  <% } else { %>
  <div class="table-responsive border-bottom">
    <table class="table table-sm mb-0">
      <thead><tr><th class="ps-3">Resumen por ciudad</th><% for (String estado : estadosPropiedad) { %><th class="text-end"><%= estado %></th><% } %><th class="text-end pe-3">Total</th></tr></thead>
      <tbody>
        <% for (Map.Entry<String, int[]> ciudadConteo : propiedadesPorCiudad.entrySet()) {
             int totalCiudad = 0; %>
        <tr>
          <td class="ps-3"><%= escapar(ciudadConteo.getKey()) %></td>
          <% for (int cantidad : ciudadConteo.getValue()) { totalCiudad += cantidad; %><td class="text-end"><%= cantidad %></td><% } %>
          <td class="text-end pe-3 fw-semibold"><%= totalCiudad %></td>
        </tr>
        <% } %>
        <tr class="fw-semibold">
          <td class="ps-3">Total</td>
          <% for (int cantidad : totalesPorEstado) { %><td class="text-end"><%= cantidad %></td><% } %>
          <td class="text-end pe-3"><%= propiedades.size() %></td>
        </tr>
      </tbody>
    </table>
  </div>
  <div class="table-responsive">
    <table class="table tabla-habita mb-0">
      <thead><tr><th>Ciudad</th><th>Estado</th><th>Matrícula</th><th>Propiedad</th><th>Tipo</th><th>Inmobiliaria</th><th>Operación</th><th class="text-end">Precio</th></tr></thead>
      <tbody>
        <% for (Object elemento : propiedades) {
             Map<?, ?> fila = (Map<?, ?>) elemento; %>
        <tr>
          <td><%= escapar(fila.get("ciudad")) %></td>
          <td><span class="estado estado-<%= escapar(fila.get("estado")) %>"><%= escapar(fila.get("estado")) %></span></td>
          <td class="text-nowrap"><%= escapar(fila.get("matricula")) %></td>
          <td><%= escapar(fila.get("titulo")) %></td>
          <td><%= escapar(fila.get("tipo")) %></td>
          <td><%= escapar(fila.get("inmobiliaria")) %></td>
          <td><%= escapar(fila.get("operacion")) %></td>
          <td class="text-end"><%= formatoPesos((BigDecimal) fila.get("precio")) %></td>
        </tr>
        <% } %>
      </tbody>
    </table>
  </div>
  <% } %>
</section>

<section class="card border-0 shadow-sm mb-4">
  <div class="card-header bg-white d-flex justify-content-between align-items-center">
    <h2 class="h5 mb-0">Citas por estado</h2>
    <span class="badge bg-marca"><%= citas.size() %> citas</span>
  </div>
  <% if (citas.isEmpty()) { %>
  <div class="vacio m-3"><i class="bi bi-calendar-event"></i>No hay citas para mostrar.</div>
  <% } else { %>
  <div class="d-flex flex-wrap gap-2 px-3 py-2 border-bottom">
    <% for (Map.Entry<String, Integer> estadoConteo : citasPorEstado.entrySet()) { %>
    <span class="estado estado-<%= escapar(estadoConteo.getKey()) %>"><%= escapar(estadoConteo.getKey()) + ": " + estadoConteo.getValue() %></span>
    <% } %>
  </div>
  <div class="table-responsive">
    <table class="table tabla-habita mb-0">
      <thead><tr><th>Estado</th><th>Fecha</th><th>Matrícula</th><th>Propiedad</th><th>Ciudad</th><th>Cliente</th></tr></thead>
      <tbody>
        <% for (Object elemento : citas) {
             Map<?, ?> fila = (Map<?, ?>) elemento; %>
        <tr>
          <td><span class="estado estado-<%= escapar(fila.get("estado")) %>"><%= escapar(fila.get("estado")) %></span></td>
          <td><%= formatoFecha((LocalDateTime) fila.get("fecha")) %></td>
          <td class="text-nowrap"><%= escapar(fila.get("matricula")) %></td>
          <td><%= escapar(fila.get("propiedad")) %></td>
          <td><%= escapar(fila.get("ciudad")) %></td>
          <td><%= escapar(fila.get("cliente")) %></td>
        </tr>
        <% } %>
      </tbody>
    </table>
  </div>
  <% } %>
</section>

<section class="card border-0 shadow-sm mb-4">
  <div class="card-header bg-white d-flex justify-content-between align-items-center">
    <h2 class="h5 mb-0">Solicitudes por inmobiliaria</h2>
    <span class="badge bg-marca"><%= totalSolicitudes %> solicitudes</span>
  </div>
  <% if (solicitudes.isEmpty()) { %>
  <div class="vacio m-3"><i class="bi bi-file-earmark-text"></i>No hay solicitudes para mostrar.</div>
  <% } else { %>
  <div class="table-responsive">
    <table class="table tabla-habita mb-0">
      <thead><tr><th>Inmobiliaria</th><th>Estado</th><th class="text-end">Total</th></tr></thead>
      <tbody>
        <% for (Object elemento : solicitudes) {
             Map<?, ?> fila = (Map<?, ?>) elemento; %>
        <tr>
          <td><%= escapar(fila.get("inmobiliaria")) %></td>
          <td><span class="estado estado-<%= escapar(fila.get("estado")) %>"><%= escapar(fila.get("estado")) %></span></td>
          <td class="text-end"><%= fila.get("total") %></td>
        </tr>
        <% } %>
      </tbody>
    </table>
  </div>
  <% } %>
</section>

<section class="card border-0 shadow-sm">
  <div class="card-header bg-white d-flex justify-content-between align-items-center">
    <h2 class="h5 mb-0">Ventas y arriendos finalizados</h2>
    <span class="badge bg-marca"><%= finalizadas.size() %> operaciones</span>
  </div>
  <% if (finalizadas.isEmpty()) { %>
  <div class="vacio m-3"><i class="bi bi-check2-circle"></i>No hay operaciones finalizadas.</div>
  <% } else { %>
  <div class="table-responsive">
    <table class="table tabla-habita mb-0">
      <thead><tr><th>Fecha</th><th>Operación</th><th>Estado</th><th>Matrícula</th><th>Propiedad</th><th>Inmobiliaria</th><th>Cliente</th></tr></thead>
      <tbody>
        <% for (Object elemento : finalizadas) {
             Map<?, ?> fila = (Map<?, ?>) elemento; %>
        <tr>
          <td><%= formatoFecha((LocalDateTime) fila.get("fecha")) %></td>
          <td><%= escapar(fila.get("operacion")) %></td>
          <td><span class="estado estado-<%= escapar(fila.get("estadoPropiedad")) %>"><%= escapar(fila.get("estadoPropiedad")) %></span></td>
          <td class="text-nowrap"><%= escapar(fila.get("matricula")) %></td>
          <td><%= escapar(fila.get("propiedad")) %></td>
          <td><%= escapar(fila.get("inmobiliaria")) %></td>
          <td><%= escapar(fila.get("cliente")) %></td>
        </tr>
        <% } %>
      </tbody>
    </table>
  </div>
  <% } %>
</section>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
