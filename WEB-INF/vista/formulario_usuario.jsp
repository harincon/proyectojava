<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    boolean editando = "editar".equals(request.getAttribute("modo"));
    String tituloPagina = editando ? "Editar usuario" : "Nuevo usuario";
    String menuActivo = "usuarios";
    boolean vistaPanel = true;
    Map<?, ?> usuario = (Map<?, ?>) request.getAttribute("usuario");
    Collection<?> rolesCuenta = (Collection<?>) request.getAttribute("rolesCuenta");
    Collection<?> rolesElegidos = (Collection<?>) request.getAttribute("rolesElegidos");
    String accionFormulario = editando
            ? "actualizar&id_usuario=" + usuario.get("idUsuario") : "crear";
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<a class="small" href="<%= ctx %>/controlador/usuario.jsp?accion=listar"><i class="bi bi-arrow-left me-1"></i>Volver a usuarios</a>
<h1 class="h3 titulo-pagina mt-2 mb-4"><%= tituloPagina %></h1>

<div class="row g-4">
  <div class="<%= editando ? "col-lg-7" : "col-lg-8" %>">
    <form class="card border-0 shadow-sm" method="post" action="<%= ctx %>/controlador/usuario.jsp?accion=<%= accionFormulario %>">
      <div class="card-body p-4">
        <%= campoToken(session) %>
        <div class="row g-3">
          <div class="col-md-6">
            <label class="form-label" for="nombres">Nombres *</label>
            <input class="form-control<%= invalido(request, "nombres") %>" id="nombres" name="nombres" maxlength="100"
                   value="<%= valorFormulario(request, "nombres") %>" required>
            <div class="invalid-feedback"><%= errorFormulario(request, "nombres") %></div>
          </div>
          <div class="col-md-6">
            <label class="form-label" for="apellidos">Apellidos *</label>
            <input class="form-control<%= invalido(request, "apellidos") %>" id="apellidos" name="apellidos" maxlength="100"
                   value="<%= valorFormulario(request, "apellidos") %>" required>
            <div class="invalid-feedback"><%= errorFormulario(request, "apellidos") %></div>
          </div>
          <div class="col-12">
            <label class="form-label" for="correo">Correo electrónico *</label>
            <input class="form-control<%= invalido(request, "correo") %>" type="email" id="correo" name="correo" maxlength="150"
                   value="<%= valorFormulario(request, "correo") %>" required>
            <div class="invalid-feedback"><%= errorFormulario(request, "correo") %></div>
          </div>
          <div class="col-12">
            <label class="form-label" for="clave"><%= editando ? "Nueva contraseña (opcional)" : "Contraseña inicial *" %></label>
            <input class="form-control<%= invalido(request, "clave") %>" type="password" id="clave" name="clave"
                   minlength="8" maxlength="100" autocomplete="new-password"<%= editando ? "" : " required" %>>
            <div class="invalid-feedback"><%= errorFormulario(request, "clave") %></div>
            <div class="form-text">Mínimo 8 caracteres.<%= editando ? " Déjala vacía para conservar la actual." : "" %></div>
          </div>
          <% if (!editando) { %>
          <div class="col-12">
            <span class="form-label d-block">Roles *</span>
            <% for (String rol : new String[] {"ADMINISTRADOR", "CLIENTE"}) {
                 boolean marcado = rolesElegidos == null ? "CLIENTE".equals(rol) : rolesElegidos.contains(rol); %>
            <div class="form-check form-check-inline">
              <input class="form-check-input<%= invalido(request, "roles") %>" type="checkbox" id="rol<%= rol %>" name="roles" value="<%= rol %>"<%= marcado ? " checked" : "" %>>
              <label class="form-check-label" for="rol<%= rol %>"><%= rol %></label>
            </div>
            <% } %>
            <div class="text-danger small"><%= errorFormulario(request, "roles") %></div>
            <div class="form-text">El rol INMOBILIARIA se asigna al vincular una empresa.</div>
          </div>
          <% } %>
        </div>
        <div class="d-flex justify-content-end gap-2 mt-4">
          <a class="btn btn-outline-secondary" href="<%= ctx %>/controlador/usuario.jsp?accion=listar">Cancelar</a>
          <button type="submit" class="btn btn-primary"><%= editando ? "Guardar cambios" : "Crear usuario" %></button>
        </div>
      </div>
    </form>
  </div>

  <% if (editando) {
       int idCuenta = (Integer) usuario.get("idUsuario");
       boolean activo = (Boolean) usuario.get("activo"); %>
  <div class="col-lg-5">
    <div class="card border-0 shadow-sm mb-4">
      <div class="card-body p-4">
        <h2 class="h5 titulo-pagina">Estado de la cuenta</h2>
        <p class="mb-3"><span class="estado estado-<%= activo ? "ACTIVO" : "INACTIVO" %>"><%= activo ? "ACTIVO" : "INACTIVO" %></span></p>
        <form method="post" action="<%= ctx %>/controlador/usuario.jsp?accion=cambiar_estado&id_usuario=<%= idCuenta %>">
          <%= campoToken(session) %>
          <input type="hidden" name="activo" value="<%= !activo %>">
          <button type="submit" class="btn btn-sm <%= activo ? "btn-outline-danger" : "btn-outline-primary" %>"><%= activo ? "Desactivar cuenta" : "Activar cuenta" %></button>
        </form>
      </div>
    </div>

    <div class="card border-0 shadow-sm">
      <div class="card-body p-4">
        <h2 class="h5 titulo-pagina">Roles</h2>
        <ul class="list-group list-group-flush">
          <% for (String rol : new String[] {"ADMINISTRADOR", "INMOBILIARIA", "CLIENTE"}) {
               boolean tiene = rolesCuenta.contains(rol); %>
          <li class="list-group-item d-flex justify-content-between align-items-center gap-2 px-0">
            <div>
              <span class="fw-semibold"><%= rol %></span>
              <span class="estado estado-<%= tiene ? "ACTIVO" : "INACTIVO" %> ms-2"><%= tiene ? "ASIGNADO" : "SIN ASIGNAR" %></span>
            </div>
            <% if ("INMOBILIARIA".equals(rol)) { %>
            <a class="btn btn-sm btn-outline-primary" href="<%= ctx %>/controlador/inmobiliaria.jsp?accion=vincular&id_usuario=<%= idCuenta %>">Empresa</a>
            <% } else { %>
            <form class="m-0" method="post" action="<%= ctx %>/controlador/usuario_rol.jsp?accion=<%= tiene ? "revocar" : "asignar" %>&id_usuario=<%= idCuenta %>&rol=<%= rol %>">
              <%= campoToken(session) %>
              <button type="submit" class="btn btn-sm <%= tiene ? "btn-outline-danger" : "btn-outline-primary" %>"><%= tiene ? "Revocar" : "Asignar" %></button>
            </form>
            <% } %>
          </li>
          <% } %>
        </ul>
        <p class="form-text mb-0 mt-2">El rol INMOBILIARIA se gestiona junto con la empresa que administra la cuenta.</p>
      </div>
    </div>
  </div>
  <% } %>
</div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
