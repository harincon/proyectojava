<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection,java.sql.PreparedStatement,java.sql.ResultSet,java.util.ArrayList,java.util.List" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%-- Diagnóstico de desarrollo (B0). Solo responde en el propio equipo. --%>
<%
    String origen = request.getRemoteAddr();
    if (!"127.0.0.1".equals(origen) && !"0:0:0:0:0:0:0:1".equals(origen)) {
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
        return;
    }

    List<String[]> pruebas = new ArrayList<String[]>();

    try (Connection conexion = abrirConexion()) {
        pruebas.add(new String[]{"Conexión JDBC", "OK", conexion.getMetaData().getDatabaseProductName() + " " + conexion.getMetaData().getDatabaseProductVersion()});

        try (PreparedStatement sentencia = conexion.prepareStatement("SELECT current_schema()");
             ResultSet resultado = sentencia.executeQuery()) {
            String esquema = resultado.next() ? resultado.getString(1) : "";
            pruebas.add(new String[]{"Esquema activo", "inmobiliaria".equals(esquema) ? "OK" : "FALLA", esquema});
        }

        try (PreparedStatement sentencia = conexion.prepareStatement(
                "SELECT count(*) FROM information_schema.tables WHERE table_schema = current_schema()");
             ResultSet resultado = sentencia.executeQuery()) {
            int tablas = resultado.next() ? resultado.getInt(1) : 0;
            pruebas.add(new String[]{"Tablas del esquema", tablas == 16 ? "OK" : "FALLA", String.valueOf(tablas)});
        }

        try (PreparedStatement sentencia = conexion.prepareStatement(
                "SELECT count(*) FROM information_schema.columns WHERE table_schema = current_schema() "
                + "AND ((table_name = 'usuario' AND column_name = ?) OR (table_name = 'propiedad' AND column_name = ?))")) {
            sentencia.setString(1, "contraseña_hash");
            sentencia.setString(2, "baños");
            try (ResultSet resultado = sentencia.executeQuery()) {
                int columnas = resultado.next() ? resultado.getInt(1) : 0;
                pruebas.add(new String[]{"Columnas con ñ", columnas == 2 ? "OK" : "FALLA", "contraseña_hash, baños"});
            }
        }
    } catch (Exception e) {
        pruebas.add(new String[]{"Conexión JDBC", "FALLA", e.getClass().getSimpleName() + ": " + e.getMessage()});
    }

    String hash = generarClave("Clave123");
    boolean hashCorrecto = hash.startsWith("pbkdf2-sha256$120000$") && hash.length() <= 255
            && verificarClave("Clave123", hash) && !verificarClave("clave123", hash)
            && !hash.equals(generarClave("Clave123"));
    pruebas.add(new String[]{"Clave PBKDF2", hashCorrecto ? "OK" : "FALLA", hash});

    boolean escapeCorrecto = "&lt;b&gt;&quot;Peña&quot; &amp; &#39;x&#39;&lt;/b&gt;".equals(escapar("<b>\"Peña\" & 'x'</b>"));
    pruebas.add(new String[]{"Escape HTML", escapeCorrecto ? "OK" : "FALLA", "<b>\"Peña\" & 'x'</b>"});

    boolean validacionesCorrectas = esCorreo("persona@dominio.com") && !esCorreo("persona@@dominio")
            && esTelefono("+57 300 123 4567") && aEntero("3") == 3 && aEntero("3,5") == null
            && aImporte("320000000.50") != null && aImporte("abc") == null && longitudValida("Casa", 1, 150);
    pruebas.add(new String[]{"Validaciones", validacionesCorrectas ? "OK" : "FALLA", formatoPesos(aImporte("320000000"))});

    LocalDateTime cita = aFechaHora("2030-01-10", "10:30");
    pruebas.add(new String[]{"Fechas America/Bogota", cita != null && cita.isAfter(ahora()) ? "OK" : "FALLA",
            "ahora " + formatoFecha(ahora()) + " · cita " + formatoFecha(cita)});

    String textoRecibido = null;
    Boolean tokenRecibidoValido = null;
    if ("POST".equals(request.getMethod())) {
        tokenRecibidoValido = tokenValido(request);
        textoRecibido = request.getParameter("texto");
    }
%>
<!doctype html>
<html lang="es">
<head>
<meta charset="utf-8">
<title>Prueba de base B0</title>
<style>
  body{font-family:Arial,sans-serif;margin:32px;color:#223249}
  table{border-collapse:collapse;margin-bottom:24px}
  td,th{border-bottom:1px solid #dce2e9;padding:8px 12px;text-align:left;vertical-align:top}
  td:last-child{font-family:Consolas,monospace;font-size:13px;word-break:break-all;max-width:620px}
  .OK{color:#1d7a4d;font-weight:bold}.FALLA{color:#a12d2d;font-weight:bold}
</style>
</head>
<body>
<h1>Prueba de base B0</h1>
<table>
  <tr><th>Prueba</th><th>Resultado</th><th>Detalle</th></tr>
  <% for (String[] fila : pruebas) { %>
  <tr><td><%= escapar(fila[0]) %></td><td class="<%= fila[1] %>"><%= fila[1] %></td><td><%= escapar(fila[2]) %></td></tr>
  <% } %>
  <% if (tokenRecibidoValido != null) { %>
  <tr><td>Token del formulario</td><td class="<%= tokenRecibidoValido ? "OK" : "FALLA" %>"><%= tokenRecibidoValido ? "OK" : "FALLA" %></td><td><%= tokenRecibidoValido ? "válido" : "rechazado" %></td></tr>
  <tr><td>Codificación de la petición</td><td class="<%= "UTF-8".equalsIgnoreCase(request.getCharacterEncoding()) ? "OK" : "FALLA" %>"><%= "UTF-8".equalsIgnoreCase(request.getCharacterEncoding()) ? "OK" : "FALLA" %></td><td><%= escapar(request.getCharacterEncoding()) + " · " + escapar(request.getContentType()) %></td></tr>
  <tr><td>Texto POST en UTF-8</td><td class="<%= "Peña & <b>".equals(textoRecibido) ? "OK" : "FALLA" %>"><%= "Peña & <b>".equals(textoRecibido) ? "OK" : "FALLA" %></td><td><%= escapar(textoRecibido) %></td></tr>
  <% } %>
</table>

<form method="post">
  <%= campoToken(session) %>
  <label>Texto de prueba <input name="texto" value="Peña &amp; &lt;b&gt;"></label>
  <button type="submit">Probar token y UTF-8</button>
</form>
<p><a href="prueba_subida.jsp">Probar subida de archivos</a></p>
</body>
</html>
