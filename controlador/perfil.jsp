<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.File,java.io.FileInputStream,java.io.InputStream,java.io.OutputStream,java.sql.Connection,java.sql.SQLException,java.util.Arrays,java.util.HashMap,java.util.HashSet,java.util.Map,javax.servlet.http.Part" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/modelo/perfil.jspf" %>
<%--
  Perfil propio. Registrado en web.xml con multipart-config (foto hasta 2 MB).
  GET  ?accion=ver | foto[&id_usuario=N, solo administrador para otra cuenta]
  POST ?accion=guardar (nombres, apellidos, documento, telefono, direccion) | subir_foto (foto)
--%>
<%!
    // Reconoce JPG y PNG por sus primeros bytes, no por el nombre.
    private String extensionImagen(byte[] inicio, int leidos) {
        if (leidos >= 3 && (inicio[0] & 0xFF) == 0xFF && (inicio[1] & 0xFF) == 0xD8 && (inicio[2] & 0xFF) == 0xFF) {
            return "jpg";
        }
        if (leidos >= 8 && (inicio[0] & 0xFF) == 0x89 && inicio[1] == 'P' && inicio[2] == 'N' && inicio[3] == 'G') {
            return "png";
        }
        return null;
    }
%>
<%
    request.setAttribute("rolesPermitidos", new HashSet<String>(Arrays.asList("ADMINISTRADOR", "INMOBILIARIA", "CLIENTE")));
%>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    String ctx = request.getContextPath();
    String accion = limpiar(request.getParameter("accion"));
    boolean esPost = "POST".equals(request.getMethod());
    String destinoVer = ctx + "/controlador/perfil.jsp?accion=ver";

    if ("foto".equals(accion)) {
        Integer solicitado = aEntero(request.getParameter("id_usuario"));
        int idFoto = solicitado == null ? idUsuarioSesion : solicitado;
        if (idFoto != idUsuarioSesion && !rolesUsuario.contains("ADMINISTRADOR")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        String ruta;
        try (Connection conexion = abrirConexion()) {
            Map<String, Object> perfil = buscarPerfil(conexion, idFoto);
            ruta = perfil == null ? null : (String) perfil.get("foto");
        }
        File carpeta = carpetaArchivos(application).getCanonicalFile();
        File archivo = ruta == null ? null : new File(carpeta, ruta).getCanonicalFile();
        if (archivo == null || !archivo.getPath().startsWith(carpeta.getPath() + File.separator) || !archivo.isFile()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        out.clear();
        // reset() quita el charset que la directiva de la página agrega al tipo de contenido.
        response.reset();
        response.setContentType(archivo.getName().endsWith(".png") ? "image/png" : "image/jpeg");
        response.setHeader("Cache-Control", "private, no-store");
        response.setContentLength((int) archivo.length());
        try (InputStream entrada = new FileInputStream(archivo)) {
            OutputStream salida = response.getOutputStream();
            byte[] bloque = new byte[8192];
            int leidos;
            while ((leidos = entrada.read(bloque)) != -1) {
                salida.write(bloque, 0, leidos);
            }
            salida.flush();
        }
        return;
    }

    if ("subir_foto".equals(accion) && esPost) {
        try {
            Part foto = request.getPart("foto");
            if (!tokenValido(request)) {
                session.setAttribute("mensajeError", "El formulario expiró. Vuelve a intentarlo.");
            } else if (foto == null || foto.getSize() == 0) {
                session.setAttribute("mensajeError", "Selecciona una foto JPG o PNG.");
            } else {
                byte[] inicio = new byte[8];
                int leidos;
                try (InputStream entrada = foto.getInputStream()) {
                    leidos = entrada.read(inicio);
                }
                String extension = extensionImagen(inicio, leidos);
                if (extension == null) {
                    session.setAttribute("mensajeError", "La foto debe ser una imagen JPG o PNG.");
                } else {
                    File carpeta = new File(carpetaArchivos(application), "perfiles");
                    if (!carpeta.isDirectory() && !carpeta.mkdirs()) {
                        throw new IllegalStateException("No se pudo crear la carpeta de fotos.");
                    }
                    byte[] azar = new byte[6];
                    ALEATORIO.nextBytes(azar);
                    String nombre = "u" + idUsuarioSesion + "-" + Base64.getUrlEncoder().withoutPadding().encodeToString(azar) + "." + extension;
                    File destino = new File(carpeta, nombre);
                    foto.write(destino.getAbsolutePath());

                    Connection conexion = null;
                    try {
                        conexion = abrirConexion();
                        conexion.setAutoCommit(false);
                        String anterior = reemplazarFotoPerfil(conexion, idUsuarioSesion, "perfiles/" + nombre);
                        conexion.commit();
                        if (anterior != null) {
                            new File(carpetaArchivos(application), anterior).delete();
                        }
                        session.setAttribute("mensaje", "Foto actualizada.");
                    } catch (SQLException e) {
                        if (conexion != null) {
                            try { conexion.rollback(); } catch (SQLException ignorada) { }
                        }
                        destino.delete();
                        session.setAttribute("mensajeError", mensajeError(e));
                    } finally {
                        if (conexion != null) {
                            try { conexion.close(); } catch (SQLException ignorada) { }
                        }
                    }
                }
            }
        } catch (IllegalStateException e) {
            session.setAttribute("mensajeError", "La foto supera el tamaño máximo permitido (2 MB).");
        }
        response.sendRedirect(destinoVer);
        return;
    }

    Map<String, String> errores = new HashMap<String, String>();
    Map<String, String> valores = new HashMap<String, String>();

    if ("guardar".equals(accion) && esPost) {
        String nombres = limpiar(request.getParameter("nombres"));
        String apellidos = limpiar(request.getParameter("apellidos"));
        String documento = limpiar(request.getParameter("documento"));
        String telefono = limpiar(request.getParameter("telefono"));
        String direccion = limpiar(request.getParameter("direccion"));
        valores.put("nombres", nombres);
        valores.put("apellidos", apellidos);
        valores.put("documento", documento);
        valores.put("telefono", telefono);
        valores.put("direccion", direccion);

        if (!tokenValido(request)) {
            errores.put("general", "El formulario expiró. Vuelve a intentarlo.");
        }
        if (!longitudValida(nombres, 1, 100)) {
            errores.put("nombres", "Escribe tus nombres (máximo 100 caracteres).");
        }
        if (!longitudValida(apellidos, 1, 100)) {
            errores.put("apellidos", "Escribe tus apellidos (máximo 100 caracteres).");
        }
        if (documento != null && !documento.matches("[0-9A-Za-z-]{5,30}")) {
            errores.put("documento", "El documento debe tener entre 5 y 30 letras, números o guiones.");
        }
        if (telefono != null && !esTelefono(telefono)) {
            errores.put("telefono", "Escribe un teléfono válido (7 a 25 dígitos, espacios, + o guiones).");
        }
        if (!longitudValida(direccion, 0, 200)) {
            errores.put("direccion", "La dirección admite máximo 200 caracteres.");
        }

        if (errores.isEmpty()) {
            try (Connection conexion = abrirConexion()) {
                guardarPerfil(conexion, idUsuarioSesion, nombres, apellidos, documento, telefono, direccion);
                session.setAttribute("nombreUsuario", (nombres + " " + apellidos).trim());
                session.setAttribute("mensaje", "Perfil actualizado.");
                response.sendRedirect(destinoVer);
                return;
            } catch (SQLException e) {
                errores.put("general", mensajeError(e));
            }
        }
    }

    try (Connection conexion = abrirConexion()) {
        Map<String, Object> perfil = buscarPerfil(conexion, idUsuarioSesion);
        request.setAttribute("perfil", perfil);
        if (valores.isEmpty() && perfil != null) {
            for (String campo : new String[] {"nombres", "apellidos", "documento", "telefono", "direccion"}) {
                valores.put(campo, (String) perfil.get(campo));
            }
        }
    }
    request.setAttribute("errores", errores);
    request.setAttribute("valores", valores);
    request.getRequestDispatcher("/WEB-INF/vista/perfil.jsp").forward(request, response);
%>
