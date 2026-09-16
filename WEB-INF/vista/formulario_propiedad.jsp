<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    boolean editando = "editar".equals(request.getAttribute("modo"));
    boolean esAdmin = Boolean.TRUE.equals(request.getAttribute("esAdmin"));
    Map<?, ?> propiedad = (Map<?, ?>) request.getAttribute("propiedad");
    List<?> ciudades = (List<?>) request.getAttribute("ciudades");
    List<?> tipos = (List<?>) request.getAttribute("tipos");
    List<?> caracteristicas = (List<?>) request.getAttribute("caracteristicas");
    List<?> elegidas = (List<?>) request.getAttribute("elegidas");
    List<?> empresas = (List<?>) request.getAttribute("empresas");
    List<?> imagenes = (List<?>) request.getAttribute("imagenes");
    String tituloPagina = editando ? "Editar propiedad" : "Nueva propiedad";
    String menuActivo = "propiedades";
    boolean vistaPanel = true;
    String accionFormulario = editando ? "actualizar&id_propiedad=" + propiedad.get("idPropiedad") : "crear";
    if (elegidas == null) {
        elegidas = new java.util.ArrayList<Integer>();
    }
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<a class="small" href="<%= ctx %>/controlador/propiedad.jsp?accion=gestionar"><i class="bi bi-arrow-left me-1"></i>Volver a propiedades</a>
<h1 class="h3 titulo-pagina mt-2 mb-1"><%= tituloPagina %></h1>
<p class="text-suave mb-4"><%= editando ? "Actualiza los datos y administra las fotografías de la publicación."
        : "Registra el inmueble. Al guardar podrás agregar sus fotografías." %></p>

<div class="row g-4">
  <div class="col-lg-<%= editando ? "7" : "9" %>">
    <form class="card border-0 shadow-sm" method="post" action="<%= ctx %>/controlador/propiedad.jsp?accion=<%= accionFormulario %>">
      <div class="card-body p-4">
        <%= campoToken(session) %>
        <div class="row g-3">
          <% if (esAdmin && !editando) { %>
          <div class="col-12">
            <label class="form-label" for="id_inmobiliaria">Empresa que publica *</label>
            <select class="form-select<%= invalido(request, "id_inmobiliaria") %>" id="id_inmobiliaria" name="id_inmobiliaria" required>
              <option value="">Elige la inmobiliaria</option>
              <% for (Object elemento : empresas) { Map<?, ?> empresa = (Map<?, ?>) elemento;
                   String idEmpresa = String.valueOf(empresa.get("idInmobiliaria")); %>
              <option value="<%= idEmpresa %>"<%= idEmpresa.equals(valorFormulario(request, "id_inmobiliaria")) ? " selected" : "" %>><%= escapar(empresa.get("nombre")) %></option>
              <% } %>
            </select>
            <div class="invalid-feedback"><%= errorFormulario(request, "id_inmobiliaria") %></div>
          </div>
          <% } %>
          <div class="col-md-8">
            <label class="form-label" for="titulo">Título de la publicación *</label>
            <input class="form-control<%= invalido(request, "titulo") %>" id="titulo" name="titulo" maxlength="150"
                   value="<%= valorFormulario(request, "titulo") %>" required>
            <div class="invalid-feedback"><%= errorFormulario(request, "titulo") %></div>
          </div>
          <div class="col-md-4">
            <label class="form-label" for="matricula">Matrícula inmobiliaria *</label>
            <input class="form-control<%= invalido(request, "matricula") %>" id="matricula" name="matricula" maxlength="50"
                   value="<%= valorFormulario(request, "matricula") %>" placeholder="HAB-2026-021" required>
            <div class="invalid-feedback"><%= errorFormulario(request, "matricula") %></div>
          </div>
          <div class="col-md-4">
            <label class="form-label" for="id_ciudad">Ciudad *</label>
            <select class="form-select<%= invalido(request, "id_ciudad") %>" id="id_ciudad" name="id_ciudad" required>
              <option value="">Elige la ciudad</option>
              <% for (Object elemento : ciudades) { Map<?, ?> ciudad = (Map<?, ?>) elemento;
                   String idCiudad = String.valueOf(ciudad.get("id")); %>
              <option value="<%= idCiudad %>"<%= idCiudad.equals(valorFormulario(request, "id_ciudad")) ? " selected" : "" %>><%= escapar(ciudad.get("nombre")) %></option>
              <% } %>
            </select>
            <div class="invalid-feedback"><%= errorFormulario(request, "id_ciudad") %></div>
          </div>
          <div class="col-md-4">
            <label class="form-label" for="id_tipo_propiedad">Tipo de inmueble *</label>
            <select class="form-select<%= invalido(request, "id_tipo_propiedad") %>" id="id_tipo_propiedad" name="id_tipo_propiedad" required>
              <option value="">Elige el tipo</option>
              <% for (Object elemento : tipos) { Map<?, ?> tipo = (Map<?, ?>) elemento;
                   String idTipo = String.valueOf(tipo.get("id")); %>
              <option value="<%= idTipo %>"<%= idTipo.equals(valorFormulario(request, "id_tipo_propiedad")) ? " selected" : "" %>><%= escapar(tipo.get("nombre")) %></option>
              <% } %>
            </select>
            <div class="invalid-feedback"><%= errorFormulario(request, "id_tipo_propiedad") %></div>
          </div>
          <div class="col-md-4">
            <label class="form-label" for="operacion">Modalidad *</label>
            <select class="form-select<%= invalido(request, "operacion") %>" id="operacion" name="operacion" required>
              <option value="">Elige la modalidad</option>
              <option value="VENTA"<%= "VENTA".equals(valorFormulario(request, "operacion")) ? " selected" : "" %>>Venta</option>
              <option value="ARRIENDO"<%= "ARRIENDO".equals(valorFormulario(request, "operacion")) ? " selected" : "" %>>Arriendo</option>
            </select>
            <div class="invalid-feedback"><%= errorFormulario(request, "operacion") %></div>
          </div>
          <div class="col-12">
            <label class="form-label" for="direccion">Dirección *</label>
            <input class="form-control<%= invalido(request, "direccion") %>" id="direccion" name="direccion" maxlength="200"
                   value="<%= valorFormulario(request, "direccion") %>" required>
            <div class="invalid-feedback"><%= errorFormulario(request, "direccion") %></div>
          </div>
          <div class="col-md-3">
            <label class="form-label" for="precio">Precio en pesos *</label>
            <input class="form-control<%= invalido(request, "precio") %>" type="number" id="precio" name="precio" min="1" step="1000"
                   value="<%= valorFormulario(request, "precio") %>" required>
            <div class="invalid-feedback"><%= errorFormulario(request, "precio") %></div>
          </div>
          <div class="col-md-3">
            <label class="form-label" for="area">Área en m² *</label>
            <input class="form-control<%= invalido(request, "area") %>" type="number" id="area" name="area" min="1" step="0.01"
                   value="<%= valorFormulario(request, "area") %>" required>
            <div class="invalid-feedback"><%= errorFormulario(request, "area") %></div>
          </div>
          <div class="col-md-3">
            <label class="form-label" for="habitaciones">Habitaciones *</label>
            <input class="form-control<%= invalido(request, "habitaciones") %>" type="number" id="habitaciones" name="habitaciones" min="0" max="50"
                   value="<%= valorFormulario(request, "habitaciones") %>" required>
            <div class="invalid-feedback"><%= errorFormulario(request, "habitaciones") %></div>
          </div>
          <div class="col-md-3">
            <label class="form-label" for="banos">Baños *</label>
            <input class="form-control<%= invalido(request, "banos") %>" type="number" id="banos" name="banos" min="0" max="50"
                   value="<%= valorFormulario(request, "banos") %>" required>
            <div class="invalid-feedback"><%= errorFormulario(request, "banos") %></div>
          </div>
          <div class="col-12">
            <label class="form-label" for="descripcion">Descripción</label>
            <textarea class="form-control<%= invalido(request, "descripcion") %>" id="descripcion" name="descripcion" rows="4" maxlength="2000"><%= valorFormulario(request, "descripcion") %></textarea>
            <div class="invalid-feedback"><%= errorFormulario(request, "descripcion") %></div>
          </div>
          <% if (!caracteristicas.isEmpty()) { %>
          <div class="col-12">
            <span class="form-label d-block">Características</span>
            <div class="row row-cols-2 row-cols-md-3 g-1">
              <% for (Object elemento : caracteristicas) { Map<?, ?> caracteristica = (Map<?, ?>) elemento;
                   Object id = caracteristica.get("id"); %>
              <div class="col">
                <div class="form-check">
                  <input class="form-check-input" type="checkbox" id="car<%= id %>" name="caracteristica" value="<%= id %>"<%= elegidas.contains(id) ? " checked" : "" %>>
                  <label class="form-check-label" for="car<%= id %>"><%= escapar(caracteristica.get("nombre")) %></label>
                </div>
              </div>
              <% } %>
            </div>
          </div>
          <% } %>
          <% if (esAdmin) { %>
          <div class="col-12">
            <div class="form-check">
              <input class="form-check-input" type="checkbox" id="destacada" name="destacada" value="1"<%= valorFormulario(request, "destacada").isEmpty() ? "" : " checked" %>>
              <label class="form-check-label" for="destacada">Mostrar como destacada en la portada</label>
            </div>
          </div>
          <% } %>
        </div>
        <div class="d-flex justify-content-end gap-2 mt-4">
          <a class="btn btn-outline-secondary" href="<%= ctx %>/controlador/propiedad.jsp?accion=gestionar">Cancelar</a>
          <button type="submit" class="btn btn-primary"><%= editando ? "Guardar cambios" : "Publicar propiedad" %></button>
        </div>
      </div>
    </form>
  </div>

  <% if (editando) { %>
  <div class="col-lg-5">
    <div class="card border-0 shadow-sm mb-4">
      <div class="card-body p-4">
        <h2 class="h5 titulo-pagina">Fotografías</h2>
        <p class="text-suave small">La primera es la que aparece en el catálogo. Pega el enlace https de la fotografía.</p>
        <form class="row g-2 mb-3" method="post" action="<%= ctx %>/controlador/imagen_propiedad.jsp?accion=agregar&id_propiedad=<%= propiedad.get("idPropiedad") %>">
          <%= campoToken(session) %>
          <div class="col-12">
            <label class="visually-hidden" for="ruta">Dirección de la fotografía</label>
            <input class="form-control" id="ruta" name="ruta" maxlength="500" placeholder="https://…" required>
          </div>
          <div class="col-12 d-grid">
            <button type="submit" class="btn btn-outline-primary"><i class="bi bi-image me-1"></i>Agregar fotografía</button>
          </div>
        </form>

        <% if (imagenes.isEmpty()) { %>
        <div class="vacio"><i class="bi bi-images" aria-hidden="true"></i>Sin fotografías; se muestra la imagen de reemplazo.</div>
        <% } else { %>
        <ul class="list-group list-group-flush">
          <% for (Object elemento : imagenes) { Map<?, ?> imagen = (Map<?, ?>) elemento; %>
          <li class="list-group-item d-flex align-items-center gap-3 px-0">
            <img class="miniatura" src="<%= urlImagen(ctx, imagen.get("ruta")) %>" alt="">
            <span class="small text-truncate flex-grow-1"><%= escapar(imagen.get("ruta")) %></span>
            <form method="post" action="<%= ctx %>/controlador/imagen_propiedad.jsp?accion=eliminar&id_propiedad=<%= propiedad.get("idPropiedad") %>&id_imagen=<%= imagen.get("idImagen") %>"
                  onsubmit="return confirm('¿Eliminar esta fotografía?');">
              <%= campoToken(session) %>
              <button type="submit" class="btn btn-outline-danger btn-sm">Quitar</button>
            </form>
          </li>
          <% } %>
        </ul>
        <% } %>
      </div>
    </div>

    <div class="card border-0 shadow-sm">
      <div class="card-body p-4">
        <h2 class="h5 titulo-pagina">Estado</h2>
        <p class="mb-2">
          <span class="estado estado-<%= escapar(propiedad.get("estado")) %>"><%= escapar(propiedad.get("estado")) %></span>
          <span class="estado estado-<%= Boolean.TRUE.equals(propiedad.get("activa")) ? "ACTIVA" : "INACTIVA" %> ms-1"><%= Boolean.TRUE.equals(propiedad.get("activa")) ? "VISIBLE" : "RETIRADA" %></span>
        </p>
        <p class="text-suave small mb-3">El estado comercial cambia al finalizar una solicitud. Aquí solo se controla si la publicación aparece en el catálogo.</p>
        <div class="d-flex flex-wrap gap-2">
          <form method="post" action="<%= ctx %>/controlador/propiedad.jsp?accion=cambiar_activa&id_propiedad=<%= propiedad.get("idPropiedad") %>">
            <%= campoToken(session) %>
            <input type="hidden" name="activa" value="<%= !Boolean.TRUE.equals(propiedad.get("activa")) %>">
            <button type="submit" class="btn btn-sm <%= Boolean.TRUE.equals(propiedad.get("activa")) ? "btn-outline-danger" : "btn-outline-primary" %>"><%= Boolean.TRUE.equals(propiedad.get("activa")) ? "Retirar del catálogo" : "Publicar en el catálogo" %></button>
          </form>
          <a class="btn btn-outline-secondary btn-sm" href="<%= ctx %>/controlador/propiedad.jsp?accion=detalle&id_propiedad=<%= propiedad.get("idPropiedad") %>">Ver publicación</a>
        </div>
      </div>
    </div>
  </div>
  <% } %>
</div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
