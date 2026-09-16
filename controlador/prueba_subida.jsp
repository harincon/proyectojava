<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="javax.servlet.http.Part" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%-- Diagnóstico de subida multipart (B0). Registrada en web.xml con sus límites. --%>
<%
    String origen = request.getRemoteAddr();
    if (!"127.0.0.1".equals(origen) && !"0:0:0:0:0:0:0:1".equals(origen)) {
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
        return;
    }

    String resultado = null;
    boolean correcto = false;

    if ("POST".equals(request.getMethod())) {
        try {
            Part archivo = request.getPart("archivo");
            if (!tokenValido(request)) {
                resultado = "Token rechazado.";
            } else if (archivo == null || archivo.getSize() == 0) {
                resultado = "No se recibió ningún archivo.";
            } else {
                File destino = File.createTempFile("prueba-", ".tmp", carpetaArchivos(application));
                archivo.write(destino.getAbsolutePath());
                long guardado = destino.length();
                boolean eliminado = destino.delete();
                correcto = guardado == archivo.getSize() && eliminado;
                resultado = "Archivo: " + archivo.getSubmittedFileName() + " · tipo: " + archivo.getContentType()
                        + " · " + archivo.getSize() + " bytes · guardado en carpeta privada y eliminado: "
                        + (correcto ? "sí" : "no");
            }
        } catch (IllegalStateException e) {
            resultado = "El archivo supera el tamaño máximo permitido (10 MB).";
        }
    }
%>
<!doctype html>
<html lang="es">
<head>
<meta charset="utf-8">
<title>Prueba de subida B0</title>
<style>
  body{font-family:Arial,sans-serif;margin:32px;color:#252525;background:#F7F2E8}
  .OK{color:#47613B;font-weight:bold}.FALLA{color:#a12d2d;font-weight:bold}
</style>
</head>
<body>
<h1>Prueba de subida de archivos</h1>
<% if (resultado != null) { %>
<p class="<%= correcto ? "OK" : "FALLA" %>" id="resultado"><%= correcto ? "OK" : "FALLA" %> · <%= escapar(resultado) %></p>
<% } %>
<form method="post" enctype="multipart/form-data">
  <%= campoToken(session) %>
  <input type="file" name="archivo">
  <button type="submit">Subir</button>
</form>
<p><a href="prueba_conexion.jsp">Volver a la prueba de base</a></p>
</body>
</html>
