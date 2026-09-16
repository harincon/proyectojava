<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Mi perfil";
    String menuActivo = "perfil";
    boolean vistaPanel = true;
    Map<?, ?> perfil = (Map<?, ?>) request.getAttribute("perfil");
    boolean tieneFoto = perfil != null && perfil.get("foto") != null;
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<h1 class="h3 titulo-pagina mb-1">Mi perfil</h1>
<p class="text-suave mb-4">Gestiona tu información personal y de contacto.</p>

<div class="row g-4">
  <div class="col-lg-4">
    <div class="card border-0 shadow-sm text-center">
      <div class="card-body p-4">
        <img class="rounded-circle mb-3 border foto-perfil"
             src="<%= tieneFoto ? ctx + "/controlador/perfil.jsp?accion=foto" : ctx + "/img/sin_foto.svg" %>"
             alt="Foto de perfil">
        <p class="fw-semibold mb-0"><%= escapar(nombreSesion) %></p>
        <p class="text-suave small mb-3"><%= escapar(perfil == null ? "" : perfil.get("correo")) %></p>
        <form method="post" action="<%= ctx %>/controlador/perfil.jsp?accion=subir_foto" enctype="multipart/form-data">
          <%= campoToken(session) %>
          <label class="form-label small text-start w-100" for="foto">Cambiar foto</label>
          <input class="form-control form-control-sm mb-2" type="file" id="foto" name="foto" accept="image/jpeg,image/png" required>
          <div class="form-text mb-3">Formatos JPG o PNG. Máximo 2 MB.</div>
          <button type="submit" class="btn btn-outline-primary btn-sm w-100">Subir foto</button>
        </form>
      </div>
    </div>
  </div>

  <div class="col-lg-8">
    <form class="card border-0 shadow-sm" method="post" action="<%= ctx %>/controlador/perfil.jsp?accion=guardar">
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
          <div class="col-md-6">
            <label class="form-label" for="documento">Documento de identidad</label>
            <input class="form-control<%= invalido(request, "documento") %>" id="documento" name="documento" maxlength="30"
                   value="<%= valorFormulario(request, "documento") %>">
            <div class="invalid-feedback"><%= errorFormulario(request, "documento") %></div>
          </div>
          <div class="col-md-6">
            <label class="form-label" for="telefono">Teléfono</label>
            <input class="form-control<%= invalido(request, "telefono") %>" type="tel" id="telefono" name="telefono" maxlength="25"
                   value="<%= valorFormulario(request, "telefono") %>" placeholder="+57 300 123 4567">
            <div class="invalid-feedback"><%= errorFormulario(request, "telefono") %></div>
          </div>
          <div class="col-12">
            <label class="form-label" for="direccion">Dirección</label>
            <input class="form-control<%= invalido(request, "direccion") %>" id="direccion" name="direccion" maxlength="200"
                   value="<%= valorFormulario(request, "direccion") %>">
            <div class="invalid-feedback"><%= errorFormulario(request, "direccion") %></div>
          </div>
        </div>
        <div class="d-flex justify-content-end mt-4">
          <button type="submit" class="btn btn-primary">Guardar cambios</button>
        </div>
      </div>
    </form>
  </div>
</div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
