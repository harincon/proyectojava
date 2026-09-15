<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Roles";
    String menuActivo = "usuarios";
    boolean vistaPanel = true;
    List<?> roles = (List<?>) request.getAttribute("roles");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
<a class="small" href="<%= ctx %>/controlador/usuario.jsp?accion=listar"><i class="bi bi-arrow-left me-1"></i>Volver a usuarios</a>
<h1 class="h3 titulo-pagina mt-2 mb-1">Roles del sistema</h1>
<p class="text-suave mb-4">Los roles son fijos. Se asignan o revocan desde la edición de cada usuario.</p>

<div class="card border-0 shadow-sm">
  <div class="table-responsive">
    <table class="table tabla-habita mb-0">
      <thead><tr><th>Rol</th><th>Permite</th><th class="text-end">Cuentas activas</th><th class="text-end">Cuentas inactivas</th></tr></thead>
      <tbody>
        <% for (Object elemento : roles) {
             Map<?, ?> rol = (Map<?, ?>) elemento;
             String nombre = String.valueOf(rol.get("nombre"));
             String descripcion = "ADMINISTRADOR".equals(nombre) ? "Acceso total: usuarios, roles, catálogos, reportes y auditoría."
                     : "INMOBILIARIA".equals(nombre) ? "Administrar su empresa, publicaciones, citas y solicitudes."
                     : "CLIENTE".equals(nombre) ? "Favoritos, citas, solicitudes y perfil propio." : ""; %>
        <tr>
          <td><span class="badge bg-marca"><%= escapar(nombre) %></span></td>
          <td><%= descripcion %></td>
          <td class="text-end"><%= rol.get("activos") %></td>
          <td class="text-end"><%= rol.get("inactivos") %></td>
        </tr>
        <% } %>
      </tbody>
    </table>
  </div>
</div>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
