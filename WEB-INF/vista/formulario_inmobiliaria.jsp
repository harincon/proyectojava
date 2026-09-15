<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String modo = (String) request.getAttribute("modo");   // vincular | editar | empresa
    boolean vinculando = "vincular".equals(modo);
    boolean propia = "empresa".equals(modo);
    Map<?, ?> empresa = (Map<?, ?>) request.getAttribute("empresa");
    List<?> cuentas = (List<?>) request.getAttribute("cuentas");
    String tituloPagina = vinculando ? "Nueva inmobiliaria" : propia ? "Mi empresa" : "Editar inmobiliaria";
    String menuActivo = propia ? "empresa" : "inmobiliarias";
    boolean vistaPanel = true;
    String accionFormulario = vinculando ? "crear" : propia ? "guardar_empresa"
            : "actualizar&id_inmobiliaria=" + (empresa == null ? "" : empresa.get("idInmobiliaria"));
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<% if (!propia) { %>
<a class="small" href="<%= ctx %>/controlador/inmobiliaria.jsp?accion=listar"><i class="bi bi-arrow-left me-1"></i>Volver a inmobiliarias</a>
<% } %>
<h1 class="h3 titulo-pagina <%= propia ? "" : "mt-2 " %>mb-1"><%= tituloPagina %></h1>
<p class="text-suave mb-4"><%= vinculando ? "Elige la cuenta que administrará la empresa. Al guardar recibe el rol INMOBILIARIA."
        : propia ? "Datos que verán los clientes en tus publicaciones." : "Datos de la empresa. La cuenta responsable no cambia." %></p>

<% if (propia && empresa == null) { %>
<div class="vacio"><i class="bi bi-building" aria-hidden="true"></i>Tu cuenta no tiene una empresa vinculada. Comunícate con el administrador.</div>
<% } else if (vinculando && cuentas.isEmpty()) { %>
<div class="vacio"><i class="bi bi-person-exclamation" aria-hidden="true"></i>Todas las cuentas activas ya administran una empresa.
  <a href="<%= ctx %>/controlador/usuario.jsp?accion=nuevo">Crea primero la cuenta del responsable.</a></div>
<% } else { %>
<div class="row g-4">
  <div class="<%= vinculando ? "col-lg-8" : "col-lg-7" %>">
    <form class="card border-0 shadow-sm" method="post" action="<%= ctx %>/controlador/inmobiliaria.jsp?accion=<%= accionFormulario %>">
      <div class="card-body p-4">
        <%= campoToken(session) %>
        <div class="row g-3">
          <% if (vinculando) {
               String cuentaElegida = valorFormulario(request, "id_usuario"); %>
          <div class="col-12">
            <label class="form-label" for="id_usuario">Cuenta responsable *</label>
            <select class="form-select<%= invalido(request, "id_usuario") %>" id="id_usuario" name="id_usuario" required>
              <option value="">Elige una cuenta activa sin empresa</option>
              <% for (Object elemento : cuentas) {
                   Map<?, ?> cuenta = (Map<?, ?>) elemento;
                   String idCuenta = String.valueOf(cuenta.get("idUsuario"));
                   String nombreCuenta = String.valueOf(cuenta.get("nombre")); %>
              <option value="<%= idCuenta %>"<%= idCuenta.equals(cuentaElegida) ? " selected" : "" %>><%= escapar(nombreCuenta.isEmpty() ? cuenta.get("correo") : nombreCuenta + " · " + cuenta.get("correo")) %></option>
              <% } %>
            </select>
            <div class="invalid-feedback"><%= errorFormulario(request, "id_usuario") %></div>
          </div>
          <% } %>
          <div class="col-md-6">
            <label class="form-label" for="nombre">Nombre de la empresa *</label>
            <input class="form-control<%= invalido(request, "nombre") %>" id="nombre" name="nombre" maxlength="150"
                   value="<%= valorFormulario(request, "nombre") %>" required>
            <div class="invalid-feedback"><%= errorFormulario(request, "nombre") %></div>
          </div>
          <div class="col-md-6">
            <label class="form-label" for="identificacion">Identificación empresarial *</label>
            <% if (propia) { %>
            <input class="form-control bg-body-secondary" id="identificacion" value="<%= escapar(empresa.get("identificacion")) %>" readonly>
            <div class="form-text">Solo el administrador puede cambiarla.</div>
            <% } else { %>
            <input class="form-control<%= invalido(request, "identificacion") %>" id="identificacion" name="identificacion" maxlength="50"
                   value="<%= valorFormulario(request, "identificacion") %>" placeholder="NIT-900123456-7" required>
            <div class="invalid-feedback"><%= errorFormulario(request, "identificacion") %></div>
            <% } %>
          </div>
          <div class="col-md-6">
            <label class="form-label" for="telefono">Teléfono *</label>
            <input class="form-control<%= invalido(request, "telefono") %>" type="tel" id="telefono" name="telefono" maxlength="25"
                   value="<%= valorFormulario(request, "telefono") %>" required>
            <div class="invalid-feedback"><%= errorFormulario(request, "telefono") %></div>
          </div>
          <div class="col-md-6">
            <label class="form-label" for="correo_contacto">Correo de contacto *</label>
            <input class="form-control<%= invalido(request, "correo_contacto") %>" type="email" id="correo_contacto" name="correo_contacto" maxlength="150"
                   value="<%= valorFormulario(request, "correo_contacto") %>" required>
            <div class="invalid-feedback"><%= errorFormulario(request, "correo_contacto") %></div>
          </div>
          <div class="col-12">
            <label class="form-label" for="direccion">Dirección *</label>
            <input class="form-control<%= invalido(request, "direccion") %>" id="direccion" name="direccion" maxlength="200"
                   value="<%= valorFormulario(request, "direccion") %>" required>
            <div class="invalid-feedback"><%= errorFormulario(request, "direccion") %></div>
          </div>
        </div>
        <div class="d-flex justify-content-end gap-2 mt-4">
          <a class="btn btn-outline-secondary" href="<%= ctx %>/controlador/<%= propia ? "panel.jsp" : "inmobiliaria.jsp?accion=listar" %>">Cancelar</a>
          <button type="submit" class="btn btn-primary"><%= vinculando ? "Vincular empresa" : "Guardar cambios" %></button>
        </div>
      </div>
    </form>
  </div>

  <% if (!vinculando) {
       boolean activo = (Boolean) empresa.get("activo");
       String responsable = String.valueOf(empresa.get("responsable")); %>
  <div class="col-lg-5">
    <div class="card border-0 shadow-sm">
      <div class="card-body p-4">
        <h2 class="h5 titulo-pagina">Responsable</h2>
        <p class="mb-1 fw-semibold"><%= escapar(responsable.isEmpty() ? empresa.get("correoResponsable") : responsable) %></p>
        <p class="mb-2 text-suave"><%= escapar(empresa.get("correoResponsable")) %></p>
        <p class="mb-3"><span class="estado estado-<%= activo ? "ACTIVO" : "INACTIVO" %>"><%= activo ? "ACTIVO" : "INACTIVO" %></span></p>
        <p class="mb-3">Propiedades publicadas: <strong><%= empresa.get("propiedades") %></strong></p>
        <% if (propia) { %>
        <a class="btn btn-outline-primary btn-sm" href="<%= ctx %>/controlador/propiedad.jsp?accion=gestionar">Mis propiedades</a>
        <% } else { %>
        <a class="btn btn-outline-primary btn-sm" href="<%= ctx %>/controlador/usuario.jsp?accion=editar&id_usuario=<%= empresa.get("idUsuario") %>">Ver cuenta</a>
        <% } %>
      </div>
    </div>
  </div>
  <% } %>
</div>
<% } %>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
