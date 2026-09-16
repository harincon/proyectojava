<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection,java.sql.SQLException,java.util.HashMap,java.util.Map,java.util.Set" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/modelo/usuario.jspf" %>
<%@ include file="/WEB-INF/modelo/perfil.jspf" %>
<%@ include file="/WEB-INF/modelo/usuario_rol.jspf" %>
<%@ include file="/WEB-INF/modelo/auditoria.jspf" %>
<%--
  Controlador público de acceso.
  GET  ?accion=ingresar | registro
  POST ?accion=ingresar (correo, clave) | registro (nombres, apellidos, correo, clave, confirmar_clave) | salir
--%>
<%!
    // Hash de relleno: iguala el tiempo de respuesta cuando el correo no existe.
    private static final String HASH_RELLENO =
            "pbkdf2-sha256$120000$RiPdkp+xz3VYK4N6iVRXHQ==$/VY7HGSXXcnqm0r8aqaGUbHVIYulwl30Vid2IGcjl0g=";

    // Tras 5 intentos fallidos seguidos, el correo queda bloqueado 5 minutos.
    private static final int INTENTOS_PERMITIDOS = 5;
    private static final int MINUTOS_BLOQUEO = 5;

    private String mensajeBloqueo(int segundos) {
        int minutos = Math.max(1, (segundos + 59) / 60);
        return "Demasiados intentos fallidos. Por seguridad, espera " + minutos
                + (minutos == 1 ? " minuto" : " minutos") + " antes de volver a intentarlo.";
    }
%>
<%
    String ctx = request.getContextPath();
    String accion = limpiar(request.getParameter("accion"));
    boolean esPost = "POST".equals(request.getMethod());
    Map<String, String> errores = new HashMap<String, String>();
    Map<String, String> valores = new HashMap<String, String>();

    if ("salir".equals(accion)) {
        if (esPost && tokenValido(request)) {
            Object idSaliente = session.getAttribute("idUsuario");
            if (idSaliente instanceof Integer) {
                // La auditoría no debe impedir que la persona cierre sesión.
                try (Connection conexion = abrirConexion()) {
                    registrarEvento(conexion, (Integer) idSaliente, "CIERRE_SESION");
                } catch (Exception ignorada) { }
            }
            session.invalidate();
            request.getSession(true).setAttribute("mensaje", "Cerraste sesión correctamente.");
        }
        response.sendRedirect(ctx + "/controlador/acceso.jsp?accion=ingresar");
        return;
    }

    if (session.getAttribute("idUsuario") != null) {
        response.sendRedirect(ctx + "/controlador/panel.jsp");
        return;
    }

    if ("registro".equals(accion)) {
        if (esPost) {
            String nombres = limpiar(request.getParameter("nombres"));
            String apellidos = limpiar(request.getParameter("apellidos"));
            String correo = limpiar(request.getParameter("correo"));
            String clave = request.getParameter("clave");
            String confirmar = request.getParameter("confirmar_clave");
            if (correo != null) {
                correo = correo.toLowerCase(Locale.ROOT);
            }
            valores.put("nombres", nombres);
            valores.put("apellidos", apellidos);
            valores.put("correo", correo);

            if (!tokenValido(request)) {
                errores.put("general", "El formulario expiró. Vuelve a intentarlo.");
            }
            if (!longitudValida(nombres, 1, 100)) {
                errores.put("nombres", "Escribe tus nombres (máximo 100 caracteres).");
            }
            if (!longitudValida(apellidos, 1, 100)) {
                errores.put("apellidos", "Escribe tus apellidos (máximo 100 caracteres).");
            }
            if (!esCorreo(correo)) {
                errores.put("correo", "Escribe un correo válido.");
            }
            if (clave == null || clave.length() < 8 || clave.length() > 100) {
                errores.put("clave", "La contraseña debe tener entre 8 y 100 caracteres.");
            } else if (!clave.equals(confirmar)) {
                errores.put("confirmar_clave", "Las contraseñas no coinciden.");
            }

            if (errores.isEmpty()) {
                Connection conexion = null;
                try {
                    conexion = abrirConexion();
                    conexion.setAutoCommit(false);
                    int idNuevo = crearUsuario(conexion, correo, generarClave(clave));
                    crearPerfil(conexion, idNuevo, nombres, apellidos);
                    if (!asignarRol(conexion, idNuevo, "CLIENTE")) {
                        throw new SQLException("No existe el rol CLIENTE.", "P0001");
                    }
                    registrarEvento(conexion, idNuevo, "REGISTRO · " + correo);
                    conexion.commit();
                    session.setAttribute("mensaje", "Tu cuenta fue creada. Ya puedes iniciar sesión.");
                    response.sendRedirect(ctx + "/controlador/acceso.jsp?accion=ingresar");
                    return;
                } catch (SQLException e) {
                    if (conexion != null) {
                        try { conexion.rollback(); } catch (SQLException ignorada) { }
                    }
                    if ("23505".equals(e.getSQLState())) {
                        errores.put("correo", "El correo ya se encuentra registrado.");
                    } else {
                        errores.put("general", mensajeError(e));
                    }
                } catch (ClassNotFoundException e) {
                    errores.put("general", "No fue posible conectar con la base de datos.");
                } finally {
                    if (conexion != null) {
                        try { conexion.close(); } catch (SQLException ignorada) { }
                    }
                }
            }
        }
        request.setAttribute("errores", errores);
        request.setAttribute("valores", valores);
        request.getRequestDispatcher("/WEB-INF/vista/registro.jsp").forward(request, response);
        return;
    }

    if (esPost) {
        String correo = limpiar(request.getParameter("correo"));
        String clave = request.getParameter("clave");
        if (correo != null) {
            correo = correo.toLowerCase(Locale.ROOT);
        }
        valores.put("correo", correo);

        if (!tokenValido(request)) {
            errores.put("general", "El formulario expiró. Vuelve a intentarlo.");
        } else if (correo == null || clave == null || clave.isEmpty()) {
            errores.put("general", "Escribe tu correo y tu contraseña.");
        } else {
            try (Connection conexion = abrirConexion()) {
                Map<String, Object> cuenta = buscarCuentaPorCorreo(conexion, correo);
                String correoAuditado = correo.length() > 150 ? correo.substring(0, 150) : correo;
                Integer idCuenta = cuenta == null ? null : (Integer) cuenta.get("idUsuario");
                // Durante el bloqueo no se revisa la clave: ni la correcta permite entrar.
                int segundosBloqueo = segundosBloqueoIngreso(conexion, correoAuditado, MINUTOS_BLOQUEO);
                boolean claveCorrecta = false;
                if (segundosBloqueo == 0) {
                    if (cuenta == null) {
                        verificarClave(clave, HASH_RELLENO);
                    } else {
                        claveCorrecta = verificarClave(clave, (String) cuenta.get("contrasenaHash"));
                    }
                }
                if (segundosBloqueo > 0) {
                    registrarEvento(conexion, idCuenta, "INGRESO_BLOQUEADO · " + correoAuditado);
                    errores.put("general", mensajeBloqueo(segundosBloqueo));
                } else if (!claveCorrecta) {
                    registrarEvento(conexion, idCuenta, "INGRESO_FALLIDO · " + correoAuditado);
                    if (intentosFallidosSeguidos(conexion, correoAuditado) >= INTENTOS_PERMITIDOS) {
                        registrarEvento(conexion, idCuenta,
                                "INGRESO_BLOQUEO · " + correoAuditado + " · " + MINUTOS_BLOQUEO + " minutos");
                        errores.put("general", mensajeBloqueo(MINUTOS_BLOQUEO * 60));
                    } else {
                        errores.put("general", "Correo o contraseña incorrectos.");
                    }
                } else if (!(Boolean) cuenta.get("activo")) {
                    registrarEvento(conexion, idCuenta, "INGRESO_FALLIDO · " + correoAuditado + " · cuenta desactivada");
                    errores.put("general", "Tu cuenta está desactivada. Comunícate con el administrador.");
                } else {
                    int idUsuario = (Integer) cuenta.get("idUsuario");
                    registrarEvento(conexion, idUsuario, "INGRESO · " + correoAuditado);
                    Set<String> roles = rolesDeUsuario(conexion, idUsuario);
                    Map<String, Object> usuario = buscarUsuario(conexion, idUsuario);
                    request.changeSessionId();
                    session.removeAttribute("tokenFormulario");
                    session.setAttribute("idUsuario", idUsuario);
                    session.setAttribute("roles", roles);
                    session.setAttribute("nombreUsuario", nombreCompleto(usuario));
                    response.sendRedirect(ctx + "/controlador/panel.jsp");
                    return;
                }
            } catch (SQLException e) {
                errores.put("general", mensajeError(e));
            } catch (ClassNotFoundException e) {
                errores.put("general", "No fue posible conectar con la base de datos.");
            }
        }
    }
    request.setAttribute("errores", errores);
    request.setAttribute("valores", valores);
    request.getRequestDispatcher("/WEB-INF/vista/login.jsp").forward(request, response);
%>
