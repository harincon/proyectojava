<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Iniciar sesión";
    String menuActivo = "";
    boolean vistaPanel = false;
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<div class="container pagina-acceso">
  <div class="card acceso-tarjeta">
    <div class="row g-0">
      <div class="col-lg-5 acceso-imagen d-none d-lg-flex">
        <div>
          <p class="portada-etiqueta mb-2">Bienvenido a Habita</p>
          <h2 class="h1 mb-3">Tu próximo espacio está más cerca.</h2>
          <p class="mb-0 text-white-50">Gestiona favoritos, citas, solicitudes y propiedades desde una sola cuenta.</p>
        </div>
      </div>
      <div class="col-lg-7 bg-white">
        <div class="card-body p-4 p-md-5">
          <div class="mb-4">
            <img class="acceso-logo" src="<%= ctx %>/img/habita/habita-logo.svg" alt="Habita">
            <h1 class="h2 titulo-pagina mt-4 mb-2">Iniciar sesión</h1>
            <p class="text-suave mb-0">Ingresa con tu correo y tu contraseña.</p>
          </div>
          <form method="post" action="<%= ctx %>/controlador/acceso.jsp?accion=ingresar">
            <%= campoToken(session) %>
            <div class="mb-3">
              <label class="form-label" for="correo">Correo electrónico</label>
              <input class="form-control" type="email" id="correo" name="correo" maxlength="150"
                     value="<%= valorFormulario(request, "correo") %>" autocomplete="email" required autofocus>
            </div>
            <div class="mb-4">
              <label class="form-label" for="clave">Contraseña</label>
              <input class="form-control" type="password" id="clave" name="clave" maxlength="100"
                     autocomplete="current-password" required>
            </div>
            <button type="submit" class="btn btn-primary w-100">Ingresar</button>
          </form>
          <p class="text-center text-suave mt-4 mb-0">¿Aún no tienes cuenta? <a href="<%= ctx %>/controlador/acceso.jsp?accion=registro">Crear cuenta</a></p>
        </div>
      </div>
    </div>
  </div>
</div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
