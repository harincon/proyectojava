<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Crear cuenta";
    String menuActivo = "";
    boolean vistaPanel = false;
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<div class="container pagina-acceso">
  <div class="card acceso-tarjeta">
    <div class="row g-0">
      <div class="col-lg-5 acceso-imagen acceso-imagen-registro d-none d-lg-flex">
        <div>
          <p class="portada-etiqueta mb-2">Únete a Habita</p>
          <h2 class="h1 mb-3">Encuentra un espacio para cada etapa.</h2>
          <p class="mb-0 text-white-50">Guarda propiedades, agenda visitas y realiza tus solicitudes de manera organizada.</p>
        </div>
      </div>
      <div class="col-lg-7 bg-white">
        <div class="card-body p-4 p-md-5">
          <div class="mb-4">
            <img class="acceso-logo" src="<%= ctx %>/img/habita/habita-logo.svg" alt="Habita">
            <h1 class="h2 titulo-pagina mt-4 mb-2">Crear cuenta</h1>
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
