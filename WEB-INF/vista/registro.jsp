<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Crear cuenta";
    String menuActivo = "";
    boolean vistaPanel = false;
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<div class="container py-5">
  <div class="row justify-content-center">
    <div class="col-md-9 col-lg-6">
      <div class="card border-0 shadow-sm">
        <div class="card-body p-4 p-md-5">
          <div class="text-center mb-4">
            <img src="<%= ctx %>/img/logo.svg" alt="" width="56" height="56">
            <h1 class="h3 titulo-pagina mt-3 mb-1">Crear cuenta</h1>
            <p class="text-suave mb-0">Regístrate para guardar favoritos, agendar visitas y enviar solicitudes.</p>
          </div>
          <form method="post" action="<%= ctx %>/controlador/acceso.jsp?accion=registro">
            <%= campoToken(session) %>
            <div class="row g-3">
              <div class="col-sm-6">
                <label class="form-label" for="nombres">Nombres *</label>
                <input class="form-control<%= invalido(request, "nombres") %>" id="nombres" name="nombres" maxlength="100"
                       value="<%= valorFormulario(request, "nombres") %>" autocomplete="given-name" required>
                <div class="invalid-feedback"><%= errorFormulario(request, "nombres") %></div>
              </div>
              <div class="col-sm-6">
                <label class="form-label" for="apellidos">Apellidos *</label>
                <input class="form-control<%= invalido(request, "apellidos") %>" id="apellidos" name="apellidos" maxlength="100"
                       value="<%= valorFormulario(request, "apellidos") %>" autocomplete="family-name" required>
                <div class="invalid-feedback"><%= errorFormulario(request, "apellidos") %></div>
              </div>
              <div class="col-12">
                <label class="form-label" for="correo">Correo electrónico *</label>
                <input class="form-control<%= invalido(request, "correo") %>" type="email" id="correo" name="correo" maxlength="150"
                       value="<%= valorFormulario(request, "correo") %>" autocomplete="email" required>
                <div class="invalid-feedback"><%= errorFormulario(request, "correo") %></div>
              </div>
              <div class="col-sm-6">
                <label class="form-label" for="clave">Contraseña *</label>
                <input class="form-control<%= invalido(request, "clave") %>" type="password" id="clave" name="clave"
                       minlength="8" maxlength="100" autocomplete="new-password" required aria-describedby="ayudaClave">
                <div class="invalid-feedback"><%= errorFormulario(request, "clave") %></div>
                <div class="form-text" id="ayudaClave">Mínimo 8 caracteres.</div>
              </div>
              <div class="col-sm-6">
                <label class="form-label" for="confirmar_clave">Confirmar contraseña *</label>
                <input class="form-control<%= invalido(request, "confirmar_clave") %>" type="password" id="confirmar_clave" name="confirmar_clave"
                       minlength="8" maxlength="100" autocomplete="new-password" required>
                <div class="invalid-feedback"><%= errorFormulario(request, "confirmar_clave") %></div>
              </div>
            </div>
            <button type="submit" class="btn btn-primary w-100 mt-4">Registrarme</button>
          </form>
          <p class="text-center text-suave mt-4 mb-0">¿Ya tienes una cuenta? <a href="<%= ctx %>/controlador/acceso.jsp?accion=ingresar">Inicia sesión</a></p>
        </div>
      </div>
    </div>
  </div>
</div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
